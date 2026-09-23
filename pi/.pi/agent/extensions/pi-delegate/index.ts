import { spawn } from "node:child_process";
import { randomUUID } from "node:crypto";
import { existsSync, readdirSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { isAbsolute, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import {
    calculateContextTokens,
    getAgentDir,
    getMarkdownTheme,
    keyHint,
    parseFrontmatter,
} from "@earendil-works/pi-coding-agent";
import { Container, Markdown, Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import {
    COLLAPSED_OUTPUT_LINES,
    type DelegateReport,
    jobLine,
    launchDetails,
    outputPreview,
    progressStats,
    reportText,
    resultPreview,
    SPINNER_FRAMES,
    SPINNER_INTERVAL_MS,
    toolCallDetail,
} from "./format.ts";

type AgentFile = {
    name: string;
    description: string;
    tools?: string[];
    model?: string;
    thinking?: string;
    prompt: string;
};

/** Details on the `delegate` tool row: how the child was launched, for the collapsed/expanded row. */
type DelegateDetails = {
    /** Short random id shared with the follow-up message, so a result can be linked back to its call. */
    id: string;
    agent: string;
    description: string;
    task: string;
    model: string;
    tools: string[];
    /** True when the child keeps running after the tool returns and reports back as a follow-up message. */
    background: boolean;
};

/** A child agent running in the background: the widget shows it, and the report message is built from it. */
type DelegateJob = {
    id: string;
    agent: string;
    description: string;
    task: string;
    model: string;
    tools: string[];
    toolCalls: number;
    lastTool?: string;
    lastDetail?: string;
    lastResult?: string;
    contextTokens?: number;
    contextWindow?: number;
    startedAt: number;
    controller: AbortController;
};

type DelegateConfig = {
    agentDirs?: unknown;
    models?: Record<string, unknown>;
};

const DEFAULT_AGENT_DIR = "~/.agents/agents";
const BUNDLED_AGENT_DIR = fileURLToPath(new URL("./agents", import.meta.url));
const DELEGATION_TOOLS = new Set(["delegate", "subagent", "subagent_supervisor", "contact_supervisor", "bg_wait"]);
const MAX_OUTPUT_BYTES = 50 * 1024;
const MODEL_TIERS = new Set(["cheap", "balanced", "strong"]);
const WIDGET_KEY = "delegate";
const RESULT_MESSAGE = "delegate-result";

function expandPath(value: string, cwd: string): string {
    if (value === "~") return homedir();
    if (value.startsWith("~/")) return join(homedir(), value.slice(2));
    return isAbsolute(value) ? value : resolve(cwd, value);
}

function stringList(value: unknown): string[] {
    const values = Array.isArray(value) ? value : typeof value === "string" ? value.split(",") : [];
    return values
        .filter((item): item is string => typeof item === "string")
        .map((item) => item.trim())
        .filter(Boolean);
}

function readConfig(path: string): DelegateConfig {
    try {
        const parsed: unknown = JSON.parse(readFileSync(path, "utf8"));
        if (!parsed || typeof parsed !== "object") return {};
        const delegate = (parsed as { delegate?: unknown }).delegate;
        return delegate && typeof delegate === "object" ? (delegate as DelegateConfig) : {};
    } catch {
        return {};
    }
}

function configFor(cwd: string): DelegateConfig {
    const global = readConfig(join(getAgentDir(), "settings.json"));
    const project = readConfig(join(cwd, ".pi", "settings.json"));
    return {
        agentDirs: [...stringList(global.agentDirs), ...stringList(project.agentDirs)],
        models: { ...(global.models ?? {}), ...(project.models ?? {}) },
    };
}

function loadAgents(dir: string): AgentFile[] {
    if (!existsSync(dir)) return [];
    const agents: AgentFile[] = [];
    for (const entry of readdirSync(dir, { withFileTypes: true })) {
        if (!entry.name.endsWith(".md") || (!entry.isFile() && !entry.isSymbolicLink())) continue;
        try {
            const { frontmatter, body } = parseFrontmatter<Record<string, unknown>>(
                readFileSync(join(dir, entry.name), "utf8"),
            );
            if (typeof frontmatter.name !== "string" || typeof frontmatter.description !== "string") continue;
            agents.push({
                name: frontmatter.name,
                description: frontmatter.description,
                tools: stringList(frontmatter.tools),
                model: typeof frontmatter.model === "string" ? frontmatter.model : undefined,
                thinking: typeof frontmatter.thinking === "string" ? frontmatter.thinking : undefined,
                prompt: body.trim(),
            });
        } catch {
            // One malformed agent file should not disable delegation.
        }
    }
    return agents;
}

function discoverAgents(cwd: string, configuredDirs: unknown): AgentFile[] {
    const dirs = [BUNDLED_AGENT_DIR, DEFAULT_AGENT_DIR, ...stringList(configuredDirs)].map((dir) =>
        expandPath(dir, cwd),
    );
    const agents = new Map<string, AgentFile>();
    for (const dir of [...new Set(dirs)]) {
        for (const agent of loadAgents(dir)) agents.set(agent.name, agent);
    }
    return [...agents.values()];
}

function resolveModel(
    value: string | undefined,
    models: Record<string, unknown>,
    current: ExtensionContext["model"],
): string | undefined {
    if (value && !MODEL_TIERS.has(value)) return value;
    const configured = value ? models[value] : undefined;
    if (typeof configured === "string" && configured) return configured;
    return current ? `${current.provider}/${current.id}` : undefined;
}

function limitOutput(text: string): string {
    const bytes = Buffer.byteLength(text, "utf8");
    if (bytes <= MAX_OUTPUT_BYTES) return text;
    let result = text.slice(0, MAX_OUTPUT_BYTES);
    while (Buffer.byteLength(result, "utf8") > MAX_OUTPUT_BYTES) result = result.slice(0, -1);
    return `${result}\n\n[Output truncated: ${bytes - Buffer.byteLength(result, "utf8")} bytes omitted.]`;
}

/** What a child event can change on the live job; undefined values keep the old field. */
type ChildUpdate = Partial<Pick<DelegateJob, "toolCalls" | "lastTool" | "lastDetail" | "lastResult" | "contextTokens">>;
type ChildUpdateHandler = (update: ChildUpdate) => void;

/** Provider usage is only meaningful once it reports tokens; 0 means "nothing reported yet". */
function usageTokens(usage: unknown): number | undefined {
    const tokens = calculateContextTokens(usage as Parameters<typeof calculateContextTokens>[0]);
    return tokens > 0 ? tokens : undefined;
}

/** Context window of the model the child runs on, for the used/limit hint. */
function contextWindowFor(ctx: ExtensionContext, model: string | undefined): number | undefined {
    if (!model) return undefined;
    const match = ctx.modelRegistry.getAll().find((candidate) => `${candidate.provider}/${candidate.id}` === model);
    return match?.contextWindow;
}

function runChild(
    args: string[],
    cwd: string,
    signal: AbortSignal | undefined,
    onUpdate?: ChildUpdateHandler,
): Promise<string> {
    return new Promise((resolveChild, reject) => {
        const child = spawn("pi", ["--mode", "json", "--print", "--no-session", ...args], {
            cwd,
            shell: false,
            stdio: ["ignore", "pipe", "pipe"],
        });
        let buffer = "";
        let liveText = "";
        let toolCalls = 0;
        let stderr = "";
        let childError: string | undefined;
        let aborted = false;
        let settled = false;
        const fail = (error: Error) => {
            if (settled) return;
            settled = true;
            reject(error);
        };
        const parse = (line: string) => {
            if (!line.trim()) return;
            try {
                const event = JSON.parse(line) as any;
                switch (event.type) {
                    case "tool_execution_start":
                        toolCalls += 1;
                        onUpdate?.({
                            toolCalls,
                            lastTool: event.toolName,
                            lastDetail: toolCallDetail(event.toolName, event.args),
                            lastResult: "",
                        });
                        return;
                    case "tool_execution_end":
                        onUpdate?.({ lastResult: resultPreview(event.result) });
                        return;
                    case "message_update": {
                        const contextTokens = usageTokens(event.usage);
                        const delta =
                            event.assistantMessageEvent?.type === "text_delta"
                                ? (event.assistantMessageEvent.delta ?? "")
                                : "";
                        if (delta) liveText += delta;
                        if (contextTokens !== undefined) onUpdate?.({ contextTokens });
                        return;
                    }
                    case "message_end": {
                        if (event.message?.role !== "assistant") return;
                        // Last assistant message wins: a retry that succeeds clears an earlier error.
                        childError = event.message.errorMessage;
                        const text =
                            event.message.content
                                ?.filter((part: any) => part.type === "text")
                                .map((part: any) => part.text ?? "")
                                .join("") ?? "";
                        if (text) {
                            liveText = text;
                            onUpdate?.({ contextTokens: usageTokens(event.message.usage) });
                        }
                        return;
                    }
                    default:
                        return;
                }
            } catch {
                // JSON mode may still emit non-JSON diagnostics; ignore those lines.
            }
        };
        child.stdout.on("data", (chunk: Buffer) => {
            buffer += chunk.toString();
            const lines = buffer.split("\n");
            buffer = lines.pop() ?? "";
            for (const line of lines) parse(line);
        });
        child.stderr.on("data", (chunk: Buffer) => {
            stderr += chunk.toString();
            if (stderr.length > 16 * 1024) stderr = stderr.slice(-16 * 1024);
        });
        child.on("error", (error) => fail(error));
        child.on("close", (code) => {
            if (settled) return;
            if (buffer) parse(buffer);
            settled = true;
            signal?.removeEventListener("abort", abort);
            if (aborted) reject(new Error("Delegated agent was aborted"));
            else if (code !== 0) reject(new Error(childError || stderr.trim() || `Child exited with status ${code}`));
            // A failed API call ends the child cleanly with an empty message; surface it instead of "(no output)".
            else if (childError) reject(new Error(childError));
            // liveText holds the last completed message text, plus any trailing partial deltas if the child died mid-stream.
            else resolveChild(limitOutput(liveText.trim() || "(no output)"));
        });
        const abort = () => {
            aborted = true;
            child.kill("SIGTERM");
            setTimeout(() => {
                if (!settled) child.kill("SIGKILL");
            }, 5000).unref();
        };
        if (signal?.aborted) abort();
        else signal?.addEventListener("abort", abort, { once: true });
    });
}

export default function (pi: ExtensionAPI) {
    /** Background children by job id; the widget renders this map and the report message is built from it. */
    const running = new Map<string, DelegateJob>();
    let ticker: ReturnType<typeof setInterval> | undefined;

    const refreshWidget = (ctx: ExtensionContext) => {
        if (!ctx.hasUI) return;
        if (running.size === 0) {
            ctx.ui.setWidget(WIDGET_KEY, undefined);
            return;
        }
        const theme = ctx.ui.theme;
        const now = Date.now();
        const frame = SPINNER_FRAMES[Math.floor(now / SPINNER_INTERVAL_MS) % SPINNER_FRAMES.length]!;
        ctx.ui.setWidget(
            WIDGET_KEY,
            [...running.values()].flatMap((job) => {
                const head = `${theme.fg("warning", frame)} ${theme.fg("toolTitle", theme.bold(job.agent))} ${theme.fg("muted", jobLine(job, now - job.startedAt))}`;
                const activity = job.lastTool
                    ? [
                          `   ${theme.fg("toolTitle", theme.bold(job.lastTool))}${job.lastDetail ? ` ${theme.fg("accent", job.lastDetail)}` : ""}`,
                      ]
                    : [];
                const result = job.lastResult
                    ? [`   ${theme.fg("muted", "↳")} ${theme.fg("toolOutput", job.lastResult)}`]
                    : [];
                return [head, ...activity, ...result];
            }),
        );
    };

    const stopTicker = () => {
        if (ticker) clearInterval(ticker);
        ticker = undefined;
    };

    /** Drop a finished job, then hand the result to the parent as a follow-up message. */
    const finishJob = (ctx: ExtensionContext, job: DelegateJob, output?: string, error?: string) => {
        running.delete(job.id);
        // Shutdown aborts in-flight children after the UI is gone; teardown already cleared the widget.
        if (job.controller.signal.aborted) return;
        if (running.size === 0) stopTicker();
        refreshWidget(ctx);
        const report: DelegateReport = {
            id: job.id,
            agent: job.agent,
            description: job.description,
            model: job.model,
            toolCalls: job.toolCalls,
            contextTokens: job.contextTokens,
            contextWindow: job.contextWindow,
            elapsedMs: Date.now() - job.startedAt,
            output,
            error,
        };
        // The parent's turn has usually ended by now, so this starts a new turn with the result.
        pi.sendMessage(
            { customType: RESULT_MESSAGE, content: reportText(report), display: true, details: report },
            { triggerTurn: true, deliverAs: "followUp" },
        );
    };

    pi.on("session_shutdown", () => {
        stopTicker();
        for (const job of running.values()) job.controller.abort();
        running.clear();
    });

    pi.on("before_agent_start", (event, ctx) => {
        const agents = discoverAgents(ctx.cwd, configFor(ctx.cwd).agentDirs);
        event.systemPromptOptions.sections.agents = [
            "<agents>",
            "Delegate focused work with `delegate({ agent, description, task })`.",
            "Delegation is asynchronous: the tool returns immediately and the agent's result arrives later as a follow-up message. Keep working or finish your turn instead of waiting for it.",
            "Available agents:",
            ...agents.map((agent) => `- ${agent.name}: ${agent.description}`),
            "</agents>",
        ].join("\n");
    });

    pi.registerMessageRenderer(RESULT_MESSAGE, (message, { expanded }, theme) => {
        const report = message.details as DelegateReport | undefined;
        if (!report?.agent) return undefined;
        const icon = report.error ? theme.fg("error", "✗") : theme.fg("success", "✓");
        const container = new Container();
        container.addChild(
            new Text(
                `${icon} ${theme.fg("toolTitle", theme.bold(report.agent))} ${theme.fg("muted", report.description)} ${theme.fg("dim", report.id)} ${theme.fg("muted", progressStats(report, report.elapsedMs))}`,
                0,
                0,
            ),
        );
        if (report.error) container.addChild(new Text(theme.fg("error", report.error), 0, 0));
        else if (report.output) {
            const { shown, hidden } = outputPreview(report.output, expanded ? Infinity : COLLAPSED_OUTPUT_LINES);
            container.addChild(new Markdown(shown.join("\n"), 0, 0, getMarkdownTheme()));
            if (hidden > 0)
                container.addChild(
                    new Text(
                        theme.fg("muted", `… ${hidden} more lines, `) + keyHint("app.tools.expand", "to expand"),
                        0,
                        0,
                    ),
                );
        }
        return container;
    });

    pi.registerTool({
        name: "delegate",
        label: "Delegate",
        description:
            "Delegate one focused task to a background Pi agent using a named Markdown agent definition. Returns immediately; the agent's result arrives later as a follow-up message. `description` labels the delegation in the transcript; `task` is the full instruction the child receives.",
        parameters: Type.Object({
            agent: Type.String({ description: "Agent name, such as general, explore, researcher, or reviewer." }),
            description: Type.String({
                description: "Short 3-8 word summary of this delegation, shown in the transcript.",
            }),
            task: Type.String({ description: "The full instruction the delegated agent receives." }),
            model: Type.Optional(
                Type.String({ description: "Model tier (cheap, balanced, strong) or an explicit provider/model." }),
            ),
        }),
        async execute(_toolCallId, params, signal, _onUpdate, ctx) {
            const config = configFor(ctx.cwd);
            const agent = discoverAgents(ctx.cwd, config.agentDirs).find(
                (candidate) => candidate.name === params.agent,
            );
            if (!agent) throw new Error(`Unknown agent "${params.agent}".`);
            const model = resolveModel(params.model ?? agent.model, config.models, ctx.model);
            if (!model) throw new Error(`No model found for "${params.agent}".`);
            const tools = (agent.tools?.length ? agent.tools : pi.getActiveTools()).filter(
                (tool) => !DELEGATION_TOOLS.has(tool),
            );
            const job: DelegateJob = {
                id: randomUUID().slice(0, 8),
                agent: agent.name,
                description: params.description.trim(),
                task: params.task,
                model,
                tools,
                toolCalls: 0,
                startedAt: Date.now(),
                contextWindow: contextWindowFor(ctx, model),
                controller: new AbortController(),
            };
            const details: DelegateDetails = {
                id: job.id,
                agent: job.agent,
                description: job.description,
                task: job.task,
                model,
                tools,
                // Only a UI can deliver a result that arrives after the tool returned; headless runs must block.
                background: ctx.hasUI,
            };
            const args = ["--model", model, "--tools", tools.join(",")];
            const thinking = agent.thinking ?? ctx.thinkingLevel;
            if (thinking) args.push("--thinking", thinking);
            if (agent.prompt) args.push("--append-system-prompt", agent.prompt);
            args.push(params.task);
            const run = runChild(args, ctx.cwd, details.background ? job.controller.signal : signal, (update) => {
                for (const [key, value] of Object.entries(update)) {
                    if (value !== undefined) (job as Record<string, unknown>)[key] = value;
                }
            });

            if (!details.background) {
                const output = await run;
                return { content: [{ type: "text", text: output }], details };
            }

            running.set(job.id, job);
            if (!ticker) ticker = setInterval(() => refreshWidget(ctx), SPINNER_INTERVAL_MS);
            refreshWidget(ctx);
            // ponytail: swallowed — the only failure left here is reporting into a session that is being torn down,
            // and an unhandled rejection would crash pi.
            void run
                .then(
                    (output) => finishJob(ctx, job, output),
                    (error) => finishJob(ctx, job, undefined, error instanceof Error ? error.message : String(error)),
                )
                .catch(() => {});
            return {
                content: [
                    {
                        type: "text",
                        text: `Started agent "${job.agent}" in the background (job ${job.id}). Its result arrives as a follow-up message; keep working or finish your turn.`,
                    },
                ],
                details,
            };
        },

        renderCall(args, theme, context) {
            // Collapsed rows lead with the short description; the agent name and progress sit on the result line. The
            // hint always shows because the task, model and tools stay behind ctrl+o.
            const summary = args.description?.trim() || args.task?.split("\n")[0]?.trim() || "";
            const hint = `${theme.fg("muted", "(")}${keyHint("app.tools.expand", context.expanded ? "to collapse" : "to expand")}${theme.fg("muted", ")")}`;
            return new Text(
                `${theme.fg("toolTitle", theme.bold("delegate "))}${theme.fg("accent", summary)} ${hint}`,
                0,
                0,
            );
        },

        renderResult(result, { expanded }, theme, context) {
            const details = result.details as DelegateDetails | undefined;
            const body = result.content.flatMap((part) => (part.type === "text" ? [part.text] : [])).join("\n");
            if (!details?.agent) return new Text(body || "(no output)", 0, 0);

            const icon = context.isError ? theme.fg("error", "✗") : theme.fg("success", "✓");
            const status = details.background ? "started in background" : "completed";
            const container = new Container();
            container.addChild(
                new Text(
                    `${icon} ${theme.fg("toolTitle", theme.bold(details.agent))} ${theme.fg("muted", details.description)} ${theme.fg("dim", details.id)} ${theme.fg("dim", status)}`,
                    0,
                    0,
                ),
            );
            if (expanded) container.addChild(new Text(theme.fg("dim", launchDetails(details).join("\n")), 0, 0));
            // Background results arrive as their own message; headless runs still show the output here.
            if (!details.background && body) {
                const { shown, hidden } = outputPreview(body, expanded ? Infinity : COLLAPSED_OUTPUT_LINES);
                container.addChild(new Markdown(shown.join("\n"), 0, 0, getMarkdownTheme()));
                if (hidden > 0)
                    container.addChild(
                        new Text(
                            theme.fg("muted", `… ${hidden} more lines, `) + keyHint("app.tools.expand", "to expand"),
                            0,
                            0,
                        ),
                    );
            }
            return container;
        },
    });
}
