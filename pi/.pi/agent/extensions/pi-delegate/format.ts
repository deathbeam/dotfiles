/** UI helpers stay Pi-import-free for the native check; Pi's analogous formatters are private. */

export const SPINNER_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
export const SPINNER_INTERVAL_MS = 100;
/** pi slices extension widgets at ten lines and appends its own truncation note. */
export const WIDGET_MAX_LINES = 10;
/** Only a few jobs still fit with their tool-call and tool-result lines: 1 tally + 3×3 lines. */
const WIDGET_MAX_DETAIL_JOBS = 3;
/** In bulk, one row per job: 1 tally + 8 rows + 1 "more running" footer. */
const WIDGET_MAX_JOBS = 8;
const EXPANDED_PAD = "   ";
const TASK_LABEL = "Task: ";

export type ProgressInfo = {
    toolCalls?: number;
    contextTokens?: number;
    contextWindow?: number;
};

export function formatTokens(count: number): string {
    if (count < 1000) return String(count);
    if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
    if (count < 1000000) return `${Math.round(count / 1000)}k`;
    if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
    return `${Math.round(count / 1000000)}M`;
}

export function formatDuration(ms: number): string {
    const seconds = Math.max(0, Math.floor(ms / 1000));
    if (seconds < 60) return `${seconds}s`;
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return `${minutes}m ${String(seconds % 60).padStart(2, "0")}s`;
    return `${Math.floor(minutes / 60)}h ${String(minutes % 60).padStart(2, "0")}m`;
}

export function progressStats(progress: ProgressInfo, elapsedMs: number): string {
    const parts: string[] = [];
    if (progress.toolCalls) parts.push(`${progress.toolCalls} tool ${progress.toolCalls === 1 ? "call" : "calls"}`);
    if (progress.contextTokens) {
        parts.push(
            progress.contextWindow
                ? `${formatTokens(progress.contextTokens)}/${formatTokens(progress.contextWindow)}`
                : formatTokens(progress.contextTokens),
        );
    }
    parts.push(formatDuration(elapsedMs));
    return parts.join(" · ");
}

export function toolCallDetail(toolName: string, args: unknown): string {
    const input = (args ?? {}) as Record<string, unknown>;
    const value = (key: string) => (typeof input[key] === "string" ? (input[key] as string).trim() : "");
    const path = value("path") || ".";
    switch (toolName) {
        case "bash":
        case "powershell":
            return value("command").split("\n")[0];
        case "read":
        case "write":
        case "edit":
            return value("file_path") || value("path");
        case "grep":
            return `/${value("pattern")}/ in ${path}`;
        case "find":
            return `${value("pattern")} in ${path}`;
        case "ls":
            return path;
        default:
            return "";
    }
}

/** Align multi-line task details under the Task label. */
export function launchDetails(info: { task?: string; model?: string; tools: string[] }): string[] {
    const lines = [
        `${EXPANDED_PAD}Model: ${info.model ?? "default"}`,
        `${EXPANDED_PAD}Tools: ${info.tools.join(", ") || "all"}`,
    ];
    const task = (info.task ?? "").trim();
    if (task) {
        lines.push(
            ...task
                .split("\n")
                .map((line, index) => `${EXPANDED_PAD}${index ? " ".repeat(TASK_LABEL.length) : TASK_LABEL}${line}`),
        );
    }
    return lines;
}

export const COLLAPSED_OUTPUT_LINES = 10;

/** Close dangling Markdown fences so collapsed previews render correctly. */
export function outputPreview(text: string, maxLines = COLLAPSED_OUTPUT_LINES): { shown: string[]; hidden: number } {
    const lines = text.trim().split("\n");
    if (lines.length <= maxLines) return { shown: lines, hidden: 0 };
    const shown = lines.slice(0, maxLines);
    if (shown.filter((line) => line.trimStart().startsWith("```")).length % 2 === 1) shown.push("```");
    return { shown, hidden: lines.length - maxLines };
}

export const MAX_OUTPUT_BYTES = 50 * 1024;

/** Cap child output without splitting UTF-8 characters. */
export function limitOutput(text: string, maxBytes = MAX_OUTPUT_BYTES): string {
    const buffer = Buffer.from(text, "utf8");
    if (buffer.length <= maxBytes) return text;
    let end = maxBytes;
    // Back off any continuation byte so the cut lands on a character boundary.
    while (end > 0 && ((buffer[end] ?? 0) & 0xc0) === 0x80) end -= 1;
    return `${buffer.subarray(0, end).toString("utf8")}\n\n[Output truncated: ${buffer.length - end} bytes omitted.]`;
}

export function resultPreview(result: unknown, maxChars = 120): string | undefined {
    const content = (result as { content?: unknown })?.content;
    if (!Array.isArray(content)) return undefined;
    const text = content
        .map((part) => (part as { type?: string; text?: string }) ?? {})
        .filter((part) => part.type === "text" && typeof part.text === "string")
        .map((part) => part.text as string)
        .join("\n");
    const line = text
        .split("\n")
        .find((candidate) => candidate.trim())
        ?.trim();
    if (!line) return undefined;
    return line.length > maxChars ? `${line.slice(0, maxChars - 1)}…` : line;
}

export type DelegateReport = {
    id: string;
    agent: string;
    description: string;
    model?: string;
    toolCalls: number;
    contextTokens?: number;
    contextWindow?: number;
    elapsedMs: number;
    output?: string;
    error?: string;
};

export function reportText(report: DelegateReport): string {
    const calls = report.toolCalls
        ? ` after ${report.toolCalls} tool ${report.toolCalls === 1 ? "call" : "calls"}`
        : "";
    if (report.error) return `Delegated agent "${report.agent}" (job ${report.id}) failed${calls}: ${report.error}`;
    const output = (report.output ?? "").trim();
    return `Delegated agent "${report.agent}" (job ${report.id}) finished${calls}.${output ? `\n\n${output}` : ""}`;
}

export function jobLine(info: { description?: string } & ProgressInfo, elapsedMs: number): string {
    return [info.description?.trim(), progressStats(info, elapsedMs)].filter(Boolean).join(" · ");
}

/** Omit detail rows in bulk so Pi's ten-line widget cap cannot split jobs. */
export function widgetJobs<T>(jobs: T[]): { shown: T[]; hidden: number; detail: boolean } {
    const detail = jobs.length <= WIDGET_MAX_DETAIL_JOBS;
    const shown = detail ? jobs : jobs.slice(-WIDGET_MAX_JOBS);
    return { shown, hidden: jobs.length - shown.length, detail };
}
