/**
 * Display-only helpers for the delegate tool row.
 *
 * Deliberately free of pi imports: `node check.mjs` loads this module directly
 * (native type stripping) and exercises the formatting rules.
 *
 * Not reusing pi's own equivalents is forced, not lazy: formatTokens (interactive footer),
 * formatDuration (shell renderer) and getTextOutput (tools/render-utils) are module-private and
 * the extension loader only aliases package roots, so they cannot be imported.
 */

/** Same frames pi's own working indicator uses. */
export const SPINNER_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
export const SPINNER_INTERVAL_MS = 100;

export type ProgressInfo = {
	toolCalls?: number;
	contextTokens?: number;
	contextWindow?: number;
};

/** Token counts the way pi's footer shows them: 900, 1.2k, 145k, 1.2M. */
export function formatTokens(count: number): string {
	if (count < 1000) return String(count);
	if (count < 10000) return `${(count / 1000).toFixed(1)}k`;
	if (count < 1000000) return `${Math.round(count / 1000)}k`;
	if (count < 10000000) return `${(count / 1000000).toFixed(1)}M`;
	return `${Math.round(count / 1000000)}M`;
}

/** Elapsed time the way pi's shell renderer shows it: 42s, 1m 05s, 2h 07m. */
export function formatDuration(ms: number): string {
	const seconds = Math.max(0, Math.floor(ms / 1000));
	if (seconds < 60) return `${seconds}s`;
	const minutes = Math.floor(seconds / 60);
	if (minutes < 60) return `${minutes}m ${String(seconds % 60).padStart(2, "0")}s`;
	return `${Math.floor(minutes / 60)}h ${String(minutes % 60).padStart(2, "0")}m`;
}

/** "5 tool calls · 23k/200k · 1m 05s" - the running progress hint on the delegate row. */
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

/**
 * One-line argument summary for a child tool call, worded like pi's own renderers.
 * ponytail: bare tool name for anything that is not a pi builtin - add a case when a tool earns one.
 */
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
		case "delegate":
		case "subagent":
			return value("agent");
		default:
			return "";
	}
}

const EXPANDED_PAD = "   ";
const TASK_LABEL = "Task: ";

/**
 * Lines shown only when a delegate row is expanded: the full task the collapsed row hides,
 * then how the child was launched. Multi-line tasks keep their continuation aligned under the text.
 */
export function launchDetails(info: { task?: string; model?: string; tools: string[] }): string[] {
	const lines = [`${EXPANDED_PAD}Model: ${info.model ?? "default"}`, `${EXPANDED_PAD}Tools: ${info.tools.join(", ") || "all"}`];
	const task = (info.task ?? "").trim();
	if (task) {
		lines.push(...task.split("\n").map((line, index) => `${EXPANDED_PAD}${index ? " ".repeat(TASK_LABEL.length) : TASK_LABEL}${line}`));
	}
	return lines;
}

export const COLLAPSED_OUTPUT_LINES = 10;

/**
 * Split output for a collapsed row: the lines worth showing, and how many stayed hidden.
 * Closes a dangling code fence so the visible part still renders as the fenced block it is.
 */
export function outputPreview(text: string, maxLines = COLLAPSED_OUTPUT_LINES): { shown: string[]; hidden: number } {
	const lines = text.trim().split("\n");
	if (lines.length <= maxLines) return { shown: lines, hidden: 0 };
	const shown = lines.slice(0, maxLines);
	if (shown.filter((line) => line.trimStart().startsWith("```")).length % 2 === 1) shown.push("```");
	return { shown, hidden: lines.length - maxLines };
}

/** First non-empty line of a tool result, capped so the activity line stays one line. */
export function resultPreview(result: unknown, maxChars = 120): string | undefined {
	const content = (result as { content?: unknown })?.content;
	if (!Array.isArray(content)) return undefined;
	const text = content
		.map((part) => (part as { type?: string; text?: string }) ?? {})
		.filter((part) => part.type === "text" && typeof part.text === "string")
		.map((part) => part.text as string)
		.join("\n");
	const line = text.split("\n").find((candidate) => candidate.trim())?.trim();
	if (!line) return undefined;
	return line.length > maxChars ? `${line.slice(0, maxChars - 1)}…` : line;
}
