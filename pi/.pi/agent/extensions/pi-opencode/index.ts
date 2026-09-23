import { createHash } from "node:crypto";
import { getCurrentTools } from "@earendil-works/pi-ai";
import type { Context } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ModelRuntime } from "@earendil-works/pi-coding-agent";

const CANONICAL_SESSION = /^ses_[0-9a-f]{12}[0-9A-Za-z]{14}$/;
const GATE_TOOLS = [
    {
        name: "read",
        description: "Read a file",
        parameters: { type: "object", properties: { path: { type: "string" } }, required: ["path"] },
    },
    {
        name: "bash",
        description: "Run a shell command",
        parameters: { type: "object", properties: { command: { type: "string" } }, required: ["command"] },
    },
];

function isFreeModel(model: { provider: string; id: string }): boolean {
    return model.provider === "opencode" && (model.id === "big-pickle" || model.id.endsWith("-free"));
}

function withGateTools(model: { provider: string; id: string }, context: Context): Context {
    if (!isFreeModel(model)) return context;
    const declared = new Set([...(context.tools ?? []), ...getCurrentTools(context.messages)].map((tool) => tool.name));
    const missing = GATE_TOOLS.filter((tool) => !declared.has(tool.name));
    if (missing.length === 0) return context;

    const [head, ...rest] = context.messages;
    if (head?.role === "system") {
        return { ...context, messages: [{ ...head, toolsAdded: [...(head.toolsAdded ?? []), ...missing] }, ...rest] };
    }
    return { ...context, tools: [...(context.tools ?? []), ...missing] };
}

const patched = new WeakSet<ModelRuntime>();

export default function (pi: ExtensionAPI) {
    pi.on("before_provider_headers", (event, ctx) => {
        const model = ctx.model;
        if (!model || !isFreeModel(model)) return;

        const session = event.headers["x-opencode-session"] ?? ctx.sessionManager.getSessionId();
        if (session && !CANONICAL_SESSION.test(session)) {
            event.headers["x-opencode-session"] =
                `ses_${createHash("sha256").update(session).digest("hex").slice(0, 26)}`;
        }
        event.headers["User-Agent"] = "opencode/1.18.0";
    });

    pi.on("session_start", (_event, ctx) => {
        const { runtime } = ctx.modelRegistry as unknown as { runtime: ModelRuntime };
        if (patched.has(runtime)) return;
        patched.add(runtime);
        const streamSimple = runtime.streamSimple.bind(runtime);
        runtime.streamSimple = (model, context, options) => streamSimple(model, withGateTools(model, context), options);
    });
}
