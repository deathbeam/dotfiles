import { spawn } from "node:child_process";
import { existsSync, readdirSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { isAbsolute, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { calculateContextTokens, getAgentDir, getMarkdownTheme, keyHint, parseFrontmatter } from "@earendil-works/pi-coding-agent";
import { Container, Markdown, Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";
import { COLLAPSED_OUTPUT_LINES, launchSummary, outputPreview, progressStats, resultPreview, SPINNER_FRAMES, SPINNER_INTERVAL_MS, toolCallDetail } from "./format.ts";

type AgentFile = {
	name: string;
	description: string;
	tools?: string[];
	model?: string;
	thinking?: string;
	prompt: string;
};

type DelegateDetails = {
  agent: string;
  task: string;
  model?: string;
  tools: string[];
  status: string;
  output?: string;
  toolCalls: number;
  lastTool?: string;
  lastDetail?: string;
  lastResult?: string;
  contextTokens?: number;
  contextWindow?: number;
  elapsedMs?: number;
};

type RenderState = {
  startedAt?: number;
  interval?: ReturnType<typeof setInterval>;
  lastDetails?: DelegateDetails;
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

function expandPath(value: string, cwd: string): string {
	if (value === "~") return homedir();
	if (value.startsWith("~/")) return join(homedir(), value.slice(2));
	return isAbsolute(value) ? value : resolve(cwd, value);
}

function stringList(value: unknown): string[] {
	const values = Array.isArray(value) ? value : typeof value === "string" ? value.split(",") : [];
	return values.filter((item): item is string => typeof item === "string").map((item) => item.trim()).filter(Boolean);
}

function readConfig(path: string): DelegateConfig {
	try {
		const parsed: unknown = JSON.parse(readFileSync(path, "utf8"));
		if (!parsed || typeof parsed !== "object") return {};
		const delegate = (parsed as { delegate?: unknown }).delegate;
		return delegate && typeof delegate === "object" ? delegate as DelegateConfig : {};
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
			const { frontmatter, body } = parseFrontmatter<Record<string, unknown>>(readFileSync(join(dir, entry.name), "utf8"));
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
  const dirs = [BUNDLED_AGENT_DIR, DEFAULT_AGENT_DIR, ...stringList(configuredDirs)]
    .map((dir) => expandPath(dir, cwd));
  const agents = new Map<string, AgentFile>();
  for (const dir of [...new Set(dirs)]) {
    for (const agent of loadAgents(dir)) agents.set(agent.name, agent);
  }
  return [...agents.values()];
}

function resolveModel(value: string | undefined, models: Record<string, unknown>, current: ExtensionContext["model"]): string | undefined {
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

type ChildUpdate = {
  status?: string;
  output?: string;
  toolCalls?: number;
  lastTool?: string;
  lastDetail?: string;
  lastResult?: string;
  contextTokens?: number;
};
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

function runChild(args: string[], cwd: string, signal: AbortSignal | undefined, onUpdate?: ChildUpdateHandler): Promise<string> {
  return new Promise((resolveChild, reject) => {
    const child = spawn("pi", ["--mode", "json", "--print", "--no-session", ...args], {
      cwd,
      shell: false,
      stdio: ["ignore", "pipe", "pipe"],
    });
    let buffer = "";
    let output = "";
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
              status: `using ${event.toolName}`,
              toolCalls,
              lastTool: event.toolName,
              lastDetail: toolCallDetail(event.toolName, event.args),
              lastResult: "",
            });
            return;
          case "tool_execution_end":
            onUpdate?.({ status: `finished ${event.toolName}`, lastResult: resultPreview(event.result) });
            return;
          case "message_update": {
            const contextTokens = usageTokens(event.usage);
            const delta = event.assistantMessageEvent?.type === "text_delta" ? (event.assistantMessageEvent.delta ?? "") : "";
            if (!delta && contextTokens === undefined) return;
            if (delta) liveText += delta;
            onUpdate?.({
              status: delta ? "writing response" : undefined,
              output: delta ? limitOutput(liveText) : undefined,
              contextTokens,
            });
            return;
          }
          case "message_end": {
            if (event.message?.role !== "assistant") return;
            if (event.message.errorMessage) childError = event.message.errorMessage;
            const text = event.message.content?.filter((part: any) => part.type === "text").map((part: any) => part.text ?? "").join("") ?? "";
            if (text) {
              output = text;
              liveText = text;
              onUpdate?.({ status: "finished", output: text, contextTokens: usageTokens(event.message.usage) });
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
      else if (code !== 0) reject(new Error(stderr.trim() || `Child exited with status ${code}`));
      else if (childError) reject(new Error(childError));
      else resolveChild(limitOutput(output.trim() || liveText.trim() || "(no output)"));
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
  pi.on("before_agent_start", (event, ctx) => {
    const agents = discoverAgents(ctx.cwd, configFor(ctx.cwd).agentDirs);
    event.systemPromptOptions.sections.agents = [
      "<agents>",
      "Delegate focused work with `delegate({ agent, task })`. Available agents:",
      ...agents.map((agent) => `- ${agent.name}: ${agent.description}`),
      "</agents>",
    ].join("\n");
  });

	pi.registerTool({
		name: "delegate",
		label: "Delegate",
		description: "Delegate one focused task to a separate Pi agent using a named Markdown agent definition.",
		parameters: Type.Object({
			agent: Type.String({ description: "Agent name, such as general, explore, researcher, or reviewer." }),
			task: Type.String({ description: "The focused task for the delegated agent." }),
			model: Type.Optional(Type.String({ description: "Model tier (cheap, balanced, strong) or an explicit provider/model." })),
		}),
    async execute(_toolCallId, params, signal, onUpdate, ctx) {
      const config = configFor(ctx.cwd);
      const agent = discoverAgents(ctx.cwd, config.agentDirs).find((candidate) => candidate.name === params.agent);
      if (!agent) throw new Error(`Unknown agent "${params.agent}".`);
      const model = resolveModel(params.model ?? agent.model, config.models ?? {}, ctx.model);
      const tools = (agent.tools?.length ? agent.tools : pi.getActiveTools())
        .filter((tool) => !DELEGATION_TOOLS.has(tool));
      const details: DelegateDetails = {
        agent: agent.name,
        task: params.task,
        model,
        tools,
        status: "starting",
        toolCalls: 0,
        contextWindow: contextWindowFor(ctx, model),
      };
      const startedAt = Date.now();
      const update = (change: ChildUpdate) => {
        for (const [key, value] of Object.entries(change)) {
          if (value !== undefined) (details as Record<string, unknown>)[key] = value;
        }
        onUpdate?.({
          content: [{ type: "text", text: `${agent.name}: ${details.status}${details.output ? `\n\n${details.output}` : ""}` }],
          details: { ...details },
        });
      };
      update({ status: "starting" });
      const args = ["--tools", tools.join(",")];
      if (model) args.push("--model", model);
      if (agent.thinking ?? ctx.thinkingLevel) args.push("--thinking", agent.thinking ?? ctx.thinkingLevel!);
      if (agent.prompt) args.push("--append-system-prompt", agent.prompt);
      args.push(params.task);
      const output = await runChild(args, ctx.cwd, signal, update);
      details.elapsedMs = Date.now() - startedAt;
      details.status = "completed";
      details.output = output;
      return { content: [{ type: "text", text: output }], details };
		},

    renderCall(args, theme, context) {
      const state = context.state as RenderState;
      if (context.executionStarted && state.startedAt === undefined) state.startedAt = Date.now();
      return new Text(
        `${theme.fg("toolTitle", theme.bold("delegate "))}${theme.fg("accent", args.agent)}\n  ${theme.fg("dim", args.task)}`,
        0,
        0,
      );
    },

    renderResult(result, { expanded, isPartial }, theme, context) {
      const state = context.state as RenderState;
      const snapshot = result.details as DelegateDetails | undefined;
      // Errors arrive as `details: {}`, so only trust a snapshot that is really ours.
      if (snapshot?.agent) state.lastDetails = snapshot;
      const details = snapshot?.agent ? snapshot : state.lastDetails;
      const body = result.content.flatMap((part) => (part.type === "text" ? [part.text] : [])).join("\n");
      if (!details) return new Text(body || "(no output)", 0, 0);

      // Animate like pi's own working indicator while the child runs.
      if (isPartial && !state.interval) state.interval = setInterval(() => context.invalidate(), SPINNER_INTERVAL_MS);
      if (!isPartial && state.interval) {
        clearInterval(state.interval);
        state.interval = undefined;
      }

      const elapsedMs = details.elapsedMs ?? (state.startedAt === undefined ? 0 : Date.now() - state.startedAt);
      const stats = progressStats(details, elapsedMs);
      const frame = SPINNER_FRAMES[Math.floor(Date.now() / SPINNER_INTERVAL_MS) % SPINNER_FRAMES.length]!;
      const icon = isPartial
        ? theme.fg("warning", frame)
        : theme.fg(context.isError ? "error" : "success", context.isError ? "✗" : "✓");

      const container = new Container();
      container.addChild(new Text(`${icon} ${theme.fg("toolTitle", theme.bold(details.agent))} ${theme.fg("muted", stats)}`, 0, 0));
      if (expanded) container.addChild(new Text(theme.fg("dim", launchSummary(details)), 0, 0));
      if (isPartial && details.lastTool) {
        const detail = details.lastDetail ? ` ${theme.fg("accent", details.lastDetail)}` : "";
        container.addChild(new Text(`   ${theme.fg("toolTitle", theme.bold(details.lastTool))}${detail}`, 0, 0));
        if (details.lastResult) container.addChild(new Text(`   ${theme.fg("muted", "↳")} ${theme.fg("toolOutput", details.lastResult)}`, 0, 0));
      }
      if (context.isError) container.addChild(new Text(theme.fg("error", body), 0, 0));
      else if (details.output) {
        // Long reports stay collapsed like any other tool output; ctrl+o shows all of it.
        const { shown, hidden } = outputPreview(details.output, expanded ? Infinity : COLLAPSED_OUTPUT_LINES);
        container.addChild(new Markdown(shown.join("\n"), 0, 0, getMarkdownTheme()));
        if (hidden > 0) container.addChild(new Text(theme.fg("muted", `… ${hidden} more lines, `) + keyHint("app.tools.expand", "to expand"), 0, 0));
      }
      return container;
    },
	});
}
