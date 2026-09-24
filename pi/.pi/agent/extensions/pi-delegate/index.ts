import { spawn } from "node:child_process";
import { randomUUID } from "node:crypto";
import { existsSync, readdirSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import {
    CONFIG_DIR_NAME,
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
    SPINNER_FRAMES,
    SPINNER_INTERVAL_MS,
    widgetJobs,
} from "./format.ts";
import { runChild } from "./child.ts";

type AgentFile = {
    name: string;
    description: string;
    tools?: string[];
    model?: string;
    thinking?: string;
    prompt: string;
};

type DelegateDetails = Pick<DelegateJob, "id" | "agent" | "description" | "task" | "model" | "tools"> & {
    /** True when the child keeps running after the tool returns and reports back as a follow-up message. */
    background: boolean;
};

type SteerDetails = Pick<
    DelegateJob,
    "id" | "agent" | "description" | "toolCalls" | "contextTokens" | "contextWindow"
> & {
    message: string;
    elapsedMs: number;
};

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
    /** Set once the child is running; rejects when the child exits or rejects the command. */
    steer?: (message: string) => Promise<void>;
};

type DelegateConfig = {
    agentDirs?: unknown;
    models?: Record<string, unknown>;
};

const DEFAULT_AGENT_DIR = "~/.agents/agents";
const BUNDLED_AGENT_DIR = fileURLToPath(new URL("./agents", import.meta.url));
/** Exclude our own tools from children to prevent recursive delegation. */
const DELEGATION_TOOLS = new Set(["delegate", "delegate_list", "delegate_steer", "delegate_cancel"]);
const MODEL_TIERS = new Set(["cheap", "balanced", "strong"]);
const WIDGET_KEY = "delegate";
const RESULT_MESSAGE = "delegate-result";

function expandPath(value: string, cwd: string): string {
    return resolve(cwd, value.replace(/^~(?=\/|$)/, homedir()));
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
    const project = readConfig(join(cwd, CONFIG_DIR_NAME, "settings.json"));
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

function contextWindowFor(ctx: ExtensionContext, model: string | undefined): number | undefined {
    const separator = model?.indexOf("/") ?? -1;
    if (!model || separator < 0) return undefined;
    // Model ids may contain "/" themselves, so only the first one separates provider from id.
    return ctx.modelRegistry.find(model.slice(0, separator), model.slice(separator + 1))?.contextWindow;
}

export default function (pi: ExtensionAPI) {
    const running = new Map<string, DelegateJob>();
    let finished = 0;
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
        const { shown, hidden, detail } = widgetJobs([...running.values()]);
        const lines: string[] = [];
        if (running.size > 1 || finished > 0) {
            const counts = `${running.size} running${finished ? ` · ${finished} done` : ""}`;
            lines.push(`${theme.fg("warning", frame)} ${theme.fg("muted", counts)}`);
        }
        for (const job of shown) {
            lines.push(
                `${theme.fg("warning", frame)} ${theme.fg("toolTitle", theme.bold(job.agent))} ${theme.fg("muted", jobLine(job, now - job.startedAt))}`,
            );
            if (!detail) continue;
            if (job.lastTool)
                lines.push(
                    `   ${theme.fg("toolTitle", theme.bold(job.lastTool))}${job.lastDetail ? ` ${theme.fg("accent", job.lastDetail)}` : ""}`,
                );
            if (job.lastResult) lines.push(`   ${theme.fg("muted", "↳")} ${theme.fg("toolOutput", job.lastResult)}`);
        }
        if (hidden) lines.push(`   ${theme.fg("muted", `… ${hidden} more running`)}`);
        ctx.ui.setWidget(WIDGET_KEY, lines);
    };

    const stopTicker = () => {
        if (ticker) clearInterval(ticker);
        ticker = undefined;
    };

    const finishJob = (ctx: ExtensionContext, job: DelegateJob, output?: string, error?: string) => {
        // Cancellation was already acknowledged; shutdown has no UI to report into.
        if (job.controller.signal.aborted) return;
        running.delete(job.id);
        finished += 1;
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
        // Idle: this starts a new turn. Streaming: steer the report in at the next turn boundary —
        // a follow-up waits for a run end that a parent stuck polling may never reach.
        pi.sendMessage(
            { customType: RESULT_MESSAGE, content: reportText(report), display: true, details: report },
            { triggerTurn: true, deliverAs: "steer" },
        );
    };

    pi.on("session_shutdown", () => {
        stopTicker();
        for (const job of running.values()) job.controller.abort();
        running.clear();
        finished = 0;
    });

    pi.on("before_agent_start", (event, ctx) => {
        const agents = discoverAgents(ctx.cwd, configFor(ctx.cwd).agentDirs);
        // pi wraps each section in a tag of the same name, so this content stays untagged.
        event.systemPromptOptions.sections.agents = [
            "Available agents:",
            ...agents.map((agent) => `- ${agent.name}: ${agent.description}`),
            "Delegation is authorized here: prefer these agents over doing context-heavy work yourself; they run in parallel with isolated contexts and report back as follow-up messages.",
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
        promptSnippet: "Delegate a focused task to a background agent; the result arrives later as a follow-up message",
        promptGuidelines: [
            "Delegations run in the background and can run in parallel: call `delegate` and keep working instead of waiting for the result.",
            "Never sleep or poll to wait for a delegate: its completion reaches you on its own. End your turn when your next step needs a result; use delegate_list only for a one-shot status, never as a wait loop.",
        ],
        parameters: Type.Object({
            agent: Type.String({ description: "Agent name, one of the agents listed in the <agents> prompt section." }),
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
            const agents = discoverAgents(ctx.cwd, config.agentDirs);
            const agent = agents.find((candidate) => candidate.name === params.agent);
            if (!agent) {
                const names = agents.map((candidate) => candidate.name).join(", ") || "(none)";
                throw new Error(`Unknown agent "${params.agent}". Available agents: ${names}.`);
            }
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
            const child = spawn(process.execPath, [process.argv[1]!, "--mode", "rpc", "--no-session", ...args], {
                cwd: ctx.cwd,
                shell: false,
                stdio: ["pipe", "pipe", "pipe"],
            });
            const run = runChild(child, params.task, details.background ? job.controller.signal : signal, (update) => {
                for (const [key, value] of Object.entries(update)) {
                    if (value !== undefined) (job as Record<string, unknown>)[key] = value;
                }
            });
            job.steer = run.steer;

            if (!details.background) {
                const output = await run.done;
                return { content: [{ type: "text", text: output }], details };
            }

            running.set(job.id, job);
            if (!ticker) ticker = setInterval(() => refreshWidget(ctx), SPINNER_INTERVAL_MS);
            refreshWidget(ctx);
            // The only failure left here is reporting into a session that is being torn down,
            // and an unhandled rejection would crash pi.
            void run.done
                .then(
                    (output) => finishJob(ctx, job, output),
                    (error) => finishJob(ctx, job, undefined, error instanceof Error ? error.message : String(error)),
                )
                .catch(() => {});
            return {
                content: [
                    {
                        type: "text",
                        text: `Started agent "${job.agent}" in the background (job ${job.id}). Steer it with delegate_steer or stop it with delegate_cancel. Do not sleep or poll: its report arrives automatically unless cancelled.`,
                    },
                ],
                details,
            };
        },

        renderCall(args, theme, context) {
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

    pi.registerTool({
        name: "delegate_steer",
        label: "Steer delegate",
        description:
            "Send guidance to a running background delegate. The child receives it after its current tool calls and before its next model request; it cannot revive a finished job. Use delegate_list for the ids of running jobs.",
        promptSnippet: "Send guidance to a running background delegate by job id",
        parameters: Type.Object({
            id: Type.String({
                description: 'Job id from a delegate tool result or a delegate-result message, such as "38631a01".',
            }),
            message: Type.String({ description: "The guidance to deliver to the running child." }),
        }),
        async execute(_toolCallId, params) {
            const id = params.id.trim().replace(/^job\s+/i, "");
            const job = running.get(id);
            if (!job?.steer) throw new Error(`No running delegate job "${id}".`);
            await job.steer(params.message);
            const details: SteerDetails = {
                id: job.id,
                agent: job.agent,
                description: job.description,
                message: params.message,
                toolCalls: job.toolCalls,
                contextTokens: job.contextTokens,
                contextWindow: job.contextWindow,
                elapsedMs: Date.now() - job.startedAt,
            };
            return {
                content: [
                    { type: "text", text: `Steering message delivered to delegate "${job.agent}" (job ${job.id}).` },
                ],
                details,
            };
        },

        renderCall(args, theme, context) {
            const message = args.message?.split("\n")[0]?.trim() ?? "";
            const hint = `${theme.fg("muted", "(")}${keyHint("app.tools.expand", context.expanded ? "to collapse" : "to expand")}${theme.fg("muted", ")")}`;
            return new Text(
                `${theme.fg("toolTitle", theme.bold("delegate_steer "))}${theme.fg("accent", message)} ${hint}`,
                0,
                0,
            );
        },

        renderResult(result, { expanded }, theme, context) {
            const details = result.details as SteerDetails | undefined;
            const body = result.content.flatMap((part) => (part.type === "text" ? [part.text] : [])).join("\n");
            if (!details?.agent) return new Text(body || "(no output)", 0, 0);
            const icon = context.isError ? theme.fg("error", "✗") : theme.fg("success", "✓");
            const container = new Container();
            container.addChild(
                new Text(
                    `${icon} ${theme.fg("toolTitle", theme.bold(details.agent))} ${theme.fg("muted", details.description)} ${theme.fg("dim", details.id)} ${theme.fg("muted", progressStats(details, details.elapsedMs))}`,
                    0,
                    0,
                ),
            );
            if (expanded) container.addChild(new Text(theme.fg("dim", details.message), 0, 0));
            return container;
        },
    });

    pi.registerTool({
        name: "delegate_cancel",
        label: "Cancel delegate",
        description:
            "Cancel a running background delegate by job id. Requests abort now and forcibly kills the child after five seconds if needed. Cancelled jobs send no follow-up report.",
        promptSnippet: "Cancel a running background delegate by job id",
        parameters: Type.Object({
            id: Type.String({ description: "Job id from delegate or delegate_list." }),
        }),
        async execute(_toolCallId, params, _signal, _onUpdate, ctx) {
            const id = params.id.trim().replace(/^job\s+/i, "");
            const job = running.get(id);
            if (!job) throw new Error(`No running delegate job "${id}".`);
            running.delete(id);
            job.controller.abort();
            if (running.size === 0) stopTicker();
            refreshWidget(ctx);
            return {
                content: [
                    { type: "text", text: `Cancellation requested for delegate "${job.agent}" (job ${job.id}).` },
                ],
                details: { id: job.id, agent: job.agent },
            };
        },
    });

    pi.registerTool({
        name: "delegate_list",
        label: "List delegates",
        description:
            "List the background delegates still running, with their job ids and progress, for steering or checking. Finished delegates are not listed; their results arrive as follow-up messages.",
        promptSnippet: "List running background delegates and their job ids",
        parameters: Type.Object({}),
        async execute() {
            const now = Date.now();
            const jobs = [...running.values()];
            if (!jobs.length) return { content: [{ type: "text", text: "No delegates are running." }] };
            const lastActivity = (job: DelegateJob) =>
                job.lastTool ? ` · ${job.lastTool}${job.lastDetail ? ` ${job.lastDetail}` : ""}` : "";
            const lines = jobs.map(
                (job) => `- ${job.id} ${job.agent} · ${jobLine(job, now - job.startedAt)}${lastActivity(job)}`,
            );
            return { content: [{ type: "text", text: `${jobs.length} running:\n${lines.join("\n")}` }] };
        },
    });
}
