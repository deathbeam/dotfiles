import type { spawn } from "node:child_process";
import { limitOutput, resultPreview, toolCallDetail } from "./format.ts";

type Child = ReturnType<typeof spawn>;

function usageTokens(usage: any): number | undefined {
    if (!usage) return undefined;
    const tokens = usage.totalTokens || usage.input + usage.output + usage.cacheRead + usage.cacheWrite;
    return tokens > 0 ? tokens : undefined;
}

export type ChildUpdate = {
    toolCalls?: number;
    lastTool?: string;
    lastDetail?: string;
    lastResult?: string;
    contextTokens?: number;
};
export type ChildUpdateHandler = (update: ChildUpdate) => void;

type ChildRun = {
    done: Promise<string>;
    steer: (message: string) => Promise<void>;
};

/** Run one RPC child, keeping its writer serialized so backpressure and EPIPE reach the caller. */
export function runChild(
    child: Child,
    task: string,
    signal: AbortSignal | undefined,
    onUpdate?: ChildUpdateHandler,
): ChildRun {
    let buffer = "";
    let liveText = "";
    let toolCalls = 0;
    let stderr = "";
    let childError: string | undefined;
    let childFailure: Error | undefined;
    let aborted = false;
    let settled = false;
    let finishing = false;
    let requestId = 0;
    let writeQueue = Promise.resolve();
    const pending = new Map<
        string,
        { command: string; resolve: () => void; reject: (error: Error) => void; timer: ReturnType<typeof setTimeout> }
    >();
    let send!: (command: Record<string, unknown>) => Promise<void>;

    const done = new Promise<string>((resolveChild, reject) => {
        const rejectPending = (error: Error) => {
            for (const request of pending.values()) {
                clearTimeout(request.timer);
                request.reject(error);
            }
            pending.clear();
        };
        const finish = (code: number | null, error?: Error) => {
            if (settled || finishing) return;
            finishing = true;
            if (buffer) {
                const lastLine = buffer;
                buffer = "";
                parse(lastLine);
            }
            settled = true;
            if (!child.stdin.destroyed) child.stdin.end();
            signal?.removeEventListener("abort", abort);
            const result = aborted
                ? new Error("Delegated agent was aborted")
                : (error ??
                  childFailure ??
                  (code !== 0
                      ? new Error(childError || stderr.trim() || `Child exited with status ${code}`)
                      : undefined));
            if (result) {
                rejectPending(result);
                reject(result);
            } else if (childError) {
                rejectPending(new Error(childError));
                reject(new Error(childError));
            } else {
                rejectPending(new Error("Delegated agent finished before acknowledging command"));
                resolveChild(limitOutput(liveText.trim() || "(no output)"));
            }
        };
        const fail = (error: Error) => {
            if (settled || finishing) return;
            childFailure = error;
            child.kill("SIGTERM");
            finish(null, error);
        };
        const parse = (line: string) => {
            if (!line.trim()) return;
            try {
                const event = JSON.parse(line) as any;
                if (event.type === "response" && typeof event.id === "string" && pending.has(event.id)) {
                    const request = pending.get(event.id)!;
                    pending.delete(event.id);
                    clearTimeout(request.timer);
                    if (event.success === true && event.command === request.command) {
                        request.resolve();
                        return;
                    }
                    const responseError = new Error(
                        event.command === request.command
                            ? event.error || `Child rejected ${request.command}`
                            : `Child returned ${event.command || "unknown"} response for ${request.command}`,
                    );
                    request.reject(responseError);
                    if (request.command === "prompt") childFailure ??= responseError;
                    return;
                }
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
                    case "agent_settled":
                        finish(0);
                        return;
                    case "extension_ui_request":
                        if (["select", "confirm", "input", "editor"].includes(event.method)) {
                            void enqueue({ type: "extension_ui_response", id: event.id, cancelled: true }).catch(
                                (error) => fail(error),
                            );
                        }
                        return;
                    default:
                        return;
                }
            } catch {
                // Diagnostics on stdout that are not JSON events; ignore those lines.
            }
        };
        const enqueue = (command: Record<string, unknown>) => {
            const line = `${JSON.stringify(command)}\n`;
            const write = writeQueue.then(
                () =>
                    new Promise<void>((resolveWrite, rejectWrite) => {
                        if (settled) return rejectWrite(childFailure ?? new Error("Delegated agent has finished"));
                        if (child.stdin.destroyed || !child.stdin.writable) {
                            return rejectWrite(new Error("Delegated agent stdin is not writable"));
                        }
                        child.stdin.write(line, (error) => (error ? rejectWrite(error) : resolveWrite()));
                    }),
            );
            writeQueue = write.catch(() => {});
            return write;
        };
        send = (command: Record<string, unknown>) => {
            const id = `delegate_${++requestId}`;
            const response = new Promise<void>((resolveResponse, rejectResponse) => {
                const timer = setTimeout(() => {
                    pending.delete(id);
                    rejectResponse(new Error(`Timed out waiting for ${command.type} acknowledgement`));
                }, 30_000);
                pending.set(id, {
                    command: String(command.type),
                    resolve: resolveResponse,
                    reject: rejectResponse,
                    timer,
                });
            });
            void enqueue({ ...command, id }).catch((error) => {
                const request = pending.get(id);
                if (request) {
                    pending.delete(id);
                    clearTimeout(request.timer);
                    request.reject(error);
                }
                if (!settled && !aborted) fail(error);
            });
            return response;
        };
        const abort = () => {
            if (settled || aborted) return;
            aborted = true;
            void send({ type: "abort" }).catch(() => {});
            setTimeout(() => {
                if (!settled) child.kill("SIGKILL");
            }, 5000).unref();
        };

        child.stdout.setEncoding("utf8");
        child.stdout.on("data", (chunk: string) => {
            buffer += chunk;
            const lines = buffer.split("\n");
            buffer = lines.pop() ?? "";
            for (const line of lines) parse(line);
        });
        child.stderr.setEncoding("utf8");
        child.stderr.on("data", (chunk: string) => {
            stderr += chunk;
            if (stderr.length > 16 * 1024) stderr = stderr.slice(-16 * 1024);
        });
        child.stdin.on("error", fail);
        child.on("error", fail);
        child.on("close", (code: number | null) => finish(code));
        if (signal?.aborted) {
            aborted = true;
            child.kill("SIGTERM");
            finish(null);
        } else {
            signal?.addEventListener("abort", abort, { once: true });
            void send({ type: "prompt", message: task }).catch((error) => {
                if (!settled) fail(error);
            });
        }
    });

    return {
        done,
        steer: (message) => send({ type: "steer", message }),
    };
}
