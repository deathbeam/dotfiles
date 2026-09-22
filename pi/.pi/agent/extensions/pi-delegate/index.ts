import { spawn } from "node:child_process";
import { existsSync, readdirSync, readFileSync } from "node:fs";
import { homedir } from "node:os";
import { isAbsolute, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";
import { getAgentDir, getMarkdownTheme, parseFrontmatter } from "@earendil-works/pi-coding-agent";
import { Container, Markdown, Text } from "@earendil-works/pi-tui";
import { Type } from "typebox";

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

type ChildUpdate = { status: string; output?: string };
type ChildUpdateHandler = (update: ChildUpdate) => void;

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
        if (event.type === "tool_execution_start") {
          onUpdate?.({ status: `using ${event.toolName}` });
          return;
        }
        if (event.type === "tool_execution_end") {
          onUpdate?.({ status: `finished ${event.toolName}` });
          return;
        }
        if (event.type === "message_update" && event.assistantMessageEvent?.type === "text_delta") {
          liveText += event.assistantMessageEvent.delta ?? "";
          onUpdate?.({ status: "writing response", output: limitOutput(liveText) });
          return;
        }
        if (event.type !== "message_end" || event.message?.role !== "assistant") return;
        if (event.message.errorMessage) childError = event.message.errorMessage;
        const text = event.message.content?.filter((part: any) => part.type === "text").map((part: any) => part.text ?? "").join("") ?? "";
        if (text) {
          output = text;
          liveText = text;
          onUpdate?.({ status: "finished", output: text });
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
      const details: DelegateDetails = { agent: agent.name, task: params.task, model, tools, status: "starting" };
      const update = (change: ChildUpdate) => {
        details.status = change.status;
        details.output = change.output;
        onUpdate?.({
          content: [{ type: "text", text: `${agent.name}: ${change.status}${change.output ? `\n\n${change.output}` : ""}` }],
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
      details.status = "completed";
      details.output = output;
      return { content: [{ type: "text", text: output }], details };
		},

    renderCall(args, theme) {
      return new Text(
        `${theme.fg("toolTitle", theme.bold("delegate "))}${theme.fg("accent", args.agent)}\n  ${theme.fg("dim", args.task)}`,
        0,
        0,
      );
    },

    renderResult(result, { expanded }, theme) {
      const details = result.details as DelegateDetails | undefined;
      if (!details) return new Text(result.content[0]?.type === "text" ? result.content[0].text : "(no output)", 0, 0);
      const icon = details.status === "completed" ? theme.fg("success", "✓") : theme.fg("warning", "⏳");
      const container = new Container();
      container.addChild(new Text(`${icon} ${theme.fg("toolTitle", theme.bold(details.agent))} ${theme.fg("muted", details.status)}`, 0, 0));
      if (expanded) container.addChild(new Text(theme.fg("dim", `Task: ${details.task}`), 0, 0));
      if (details.output) container.addChild(new Markdown(details.output.trim(), 0, 0, getMarkdownTheme()));
      return container;
    },
	});
}
