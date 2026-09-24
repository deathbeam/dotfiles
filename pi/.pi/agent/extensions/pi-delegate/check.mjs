import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { EventEmitter } from "node:events";
import { PassThrough } from "node:stream";
import { mkdtempSync, readdirSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { stripTypeScriptTypes } from "node:module";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
    formatDuration,
    formatTokens,
    jobLine,
    launchDetails,
    limitOutput,
    outputPreview,
    progressStats,
    reportText,
    resultPreview,
    SPINNER_FRAMES,
    toolCallDetail,
    widgetJobs,
    WIDGET_MAX_LINES,
} from "./format.ts";
import { runChild } from "./child.ts";

const root = new URL("./", import.meta.url);
const index = readFileSync(new URL("index.ts", root), "utf8");
const child = readFileSync(new URL("child.ts", root), "utf8");

// Regex tripwires cannot see runtime syntax or protocol behavior, so compile and exercise both below.
const indexCheckDir = mkdtempSync(join(tmpdir(), "pi-delegate-index-check-"));
const indexCheckFile = join(indexCheckDir, "index.mjs");
writeFileSync(indexCheckFile, stripTypeScriptTypes(index, { mode: "strip" }));
try {
    execFileSync(process.execPath, ["--check", indexCheckFile], { stdio: "pipe" });
} finally {
    rmSync(indexCheckDir, { recursive: true, force: true });
}

// Tripwires for wiring the compiled-file check cannot see: the child protocol, the delivery path,
// and the prompt sections. Display text and formatting are deliberately not asserted.
assert.match(index, /name: "delegate"/);
assert.match(index, /name: "delegate_list"/);
assert.match(index, /name: "delegate_steer"/);
assert.match(index, /name: "delegate_cancel"/);
const excluded = index.match(/const DELEGATION_TOOLS = new Set\(\[([\s\S]*?)\]\)/)?.[1];
assert.ok(excluded, "missing child delegation denylist");
assert.deepEqual([...excluded.matchAll(/"([^"]+)"/g)].map(([, name]) => name).sort(), [
    "delegate",
    "delegate_cancel",
    "delegate_list",
    "delegate_steer",
]);
assert.match(index, /!DELEGATION_TOOLS\.has\(tool\)/);
assert.match(index, /process\.argv\[1\].*--mode", "rpc", "--no-session/);
assert.match(index, /\["--model", model, "--tools", tools\.join\(","\)\]/);
assert.match(child, /case "agent_settled"/);
assert.match(child, /type: "steer", message/);
assert.match(index, /systemPromptOptions\.sections\.agents/);
// pi wraps each section in a tag of its own, so the content must not add a second <agents>.
assert.doesNotMatch(index, /"<\/?agents>"/);
assert.match(index, /registerMessageRenderer\(RESULT_MESSAGE/);
assert.match(index, /pi\.sendMessage\(/);
// A follow-up waits for a run end; a parent stuck polling never reaches one and the report is lost.
assert.match(index, /background: ctx\.hasUI/);
assert.match(index, /deliverAs: "steer"/);
assert.match(index, /setWidget\(WIDGET_KEY/);

const expected = ["explore", "general", "researcher", "reviewer"];
const agentFiles = readdirSync(new URL("agents/", root))
    .filter((file) => file.endsWith(".md"))
    .map((file) => ({ file, text: readFileSync(new URL(`agents/${file}`, root), "utf8") }));
const names = agentFiles.map(({ text }) => text.match(/^name:\s*(.+)$/m)?.[1]).sort();
assert.deepEqual(names, expected);
// An invalid level makes every delegate of that agent fail at child launch, not at load.
const thinkingLevels = new Set(["off", "minimal", "low", "medium", "high", "xhigh", "max"]);
for (const { file, text } of agentFiles) {
    const level = text.match(/^thinking:\s*(\S+)/m)?.[1];
    if (level) assert.ok(thinkingLevels.has(level), `${file} has invalid thinking level "${level}"`);
}

assert.ok(SPINNER_FRAMES.length > 1);
assert.equal(
    launchDetails({ task: "do it", model: "x/y", tools: ["read", "ls"] }).join("\n"),
    "   Model: x/y\n   Tools: read, ls\n   Task: do it",
);
assert.deepEqual(launchDetails({ tools: [] }), ["   Model: default", "   Tools: all"]);
assert.deepEqual(launchDetails({ task: "first\nsecond", tools: ["read"] }), [
    "   Model: default",
    "   Tools: read",
    "   Task: first",
    "         second",
]);
assert.deepEqual(launchDetails({ task: "  \n ", tools: ["read"] }), ["   Model: default", "   Tools: read"]);
assert.deepEqual(outputPreview("a\nb", 5), { shown: ["a", "b"], hidden: 0 });
assert.deepEqual(outputPreview("a\nb\nc", 2), { shown: ["a", "b"], hidden: 1 });
assert.deepEqual(outputPreview("```\ncode\nmore", 2), { shown: ["```", "code", "```"], hidden: 1 });
assert.deepEqual(outputPreview("```\na\n```\nb", 3), { shown: ["```", "a", "```"], hidden: 1 });
assert.equal(formatTokens(900), "900");
assert.equal(formatTokens(1234), "1.2k");
assert.equal(formatTokens(200000), "200k");
assert.equal(formatDuration(42000), "42s");
assert.equal(formatDuration(65000), "1m 05s");
assert.equal(formatDuration(3720000), "1h 02m");
assert.equal(progressStats({}, 0), "0s");
assert.equal(
    progressStats({ toolCalls: 1, contextTokens: 2400, contextWindow: 200000 }, 42000),
    "1 tool call · 2.4k/200k · 42s",
);
assert.equal(progressStats({ toolCalls: 3, contextTokens: 2400 }, 1000), "3 tool calls · 2.4k · 1s");
assert.equal(toolCallDetail("bash", { command: "npm test\nsecond" }), "npm test");
assert.equal(toolCallDetail("read", { file_path: "src/a.ts" }), "src/a.ts");
assert.equal(toolCallDetail("edit", { path: "src/a.ts" }), "src/a.ts");
assert.equal(toolCallDetail("grep", { pattern: "foo", path: "src" }), "/foo/ in src");
assert.equal(toolCallDetail("ls", {}), ".");
assert.equal(toolCallDetail("bash", undefined), "");
assert.equal(resultPreview({ content: [{ type: "text", text: "\n  12 passing\n" }] }), "12 passing");
assert.equal(resultPreview({ content: [{ type: "image", data: "x" }] }), undefined);
assert.equal(resultPreview({ content: [{ type: "text", text: "x".repeat(200) }] }).length, 120);
assert.equal(
    reportText({
        id: "a1b2c3d4",
        agent: "explore",
        description: "find callers",
        toolCalls: 2,
        elapsedMs: 65000,
        output: "done",
    }),
    'Delegated agent "explore" (job a1b2c3d4) finished after 2 tool calls.\n\ndone',
);
assert.equal(
    reportText({ id: "a1b2c3d4", agent: "explore", description: "x", toolCalls: 0, elapsedMs: 1000 }),
    'Delegated agent "explore" (job a1b2c3d4) finished.',
);
assert.equal(
    reportText({ id: "a1b2c3d4", agent: "explore", description: "x", toolCalls: 1, elapsedMs: 1000, error: "boom" }),
    'Delegated agent "explore" (job a1b2c3d4) failed after 1 tool call: boom',
);
assert.equal(jobLine({ description: "find callers" }, 42000), "find callers · 42s");
assert.equal(jobLine({}, 0), "0s");
// A burst of delegations must never reach pi's ten-line widget cut, which chops mid-list.
for (let count = 1; count <= 40; count += 1) {
    const { shown, hidden, detail } = widgetJobs(Array.from({ length: count }, (_, i) => i));
    const lines = 1 + shown.length * (detail ? 3 : 1) + (hidden ? 1 : 0);
    assert.ok(lines <= WIDGET_MAX_LINES, `${count} jobs render ${lines} lines`);
}
assert.deepEqual(widgetJobs([1, 2, 3]), { shown: [1, 2, 3], hidden: 0, detail: true });
assert.deepEqual(widgetJobs([1, 2, 3, 4]), { shown: [1, 2, 3, 4], hidden: 0, detail: false });
assert.deepEqual(widgetJobs([1, 2, 3, 4, 5, 6, 7, 8, 9]), {
    shown: [2, 3, 4, 5, 6, 7, 8, 9],
    hidden: 1,
    detail: false,
});
assert.equal(limitOutput("ok"), "ok");
assert.equal(limitOutput("x".repeat(2000), 1000), "x".repeat(1000) + "\n\n[Output truncated: 1000 bytes omitted.]");
// A cut inside a multi-byte character backs off to the boundary instead of emitting U+FFFD.
const longCjk = limitOutput("あ".repeat(40000), 1000).split("\n\n")[0];
assert.ok(/^あ+$/.test(longCjk));
assert.equal(Buffer.byteLength(longCjk, "utf8"), 999);
// A 4-byte astral character must not be cut into a lone surrogate.
const longEmoji = limitOutput("🙂".repeat(1000), 1000).split("\n\n")[0];
assert.ok(/^[\u{1F642}]+$/u.test(longEmoji));
assert.equal(Array.from(longEmoji).length, 250);
// The protocol test uses a fake child: stdout splits a UTF-8 code point and steer returns a failed ack.
function fakeChild() {
    const child = new EventEmitter();
    child.stdin = new PassThrough();
    child.stdout = new PassThrough();
    child.stderr = new PassThrough();
    child.kill = () => true;
    return child;
}
const fake = fakeChild();
fake.stdin.on("data", (chunk) => {
    for (const line of chunk.toString().trim().split("\n")) {
        if (!line) continue;
        const command = JSON.parse(line);
        if (command.type === "prompt") {
            fake.stdout.write(
                `${JSON.stringify({ type: "response", id: command.id, command: "prompt", success: true })}\n`,
            );
            const bytes = Buffer.from(
                `${JSON.stringify({ type: "message_update", assistantMessageEvent: { type: "text_delta", delta: "é" } })}\n`,
            );
            const split = bytes.indexOf(0xc3) + 1;
            fake.stdout.write(bytes.subarray(0, split));
            fake.stdout.write(bytes.subarray(split));
        } else if (command.type === "steer") {
            fake.stdout.write(
                `${JSON.stringify({ type: "response", id: command.id, command: "steer", success: false, error: "steer rejected" })}\n`,
            );
        }
    }
});
const run = runChild(fake, "task", undefined);
assert.equal(fake.stdout.readableEncoding, "utf8");
await assert.rejects(run.steer("steer"), /steer rejected/);
fake.stdout.write(`${JSON.stringify({ type: "agent_settled" })}\n`);
assert.equal(await run.done, "é");

const rejected = fakeChild();
let killed = false;
rejected.kill = () => (killed = true);
rejected.stdin.on("data", (chunk) => {
    const command = JSON.parse(chunk.toString());
    rejected.stdout.write(
        `${JSON.stringify({ type: "response", id: command.id, command: "prompt", success: false, error: "prompt rejected" })}\n`,
    );
});
await assert.rejects(runChild(rejected, "bad task", undefined).done, /prompt rejected/);
assert.equal(killed, true);
assert.equal(rejected.stdin.writableEnded, true);

const signal = new AbortController();
signal.abort();
const cancelled = fakeChild();
await assert.rejects(runChild(cancelled, "task", signal.signal).done, /aborted/);
assert.equal(cancelled.stdin.writableEnded, true);

const controller = new AbortController();
const stopping = fakeChild();
let abortRequested = false;
stopping.stdin.on("data", (chunk) => {
    const command = JSON.parse(chunk.toString());
    if (command.type === "prompt") {
        stopping.stdout.write(
            `${JSON.stringify({ type: "response", id: command.id, command: "prompt", success: true })}\n`,
        );
    } else if (command.type === "abort") {
        abortRequested = true;
        stopping.stdout.write(
            `${JSON.stringify({ type: "response", id: command.id, command: "abort", success: true })}\n`,
        );
        stopping.stdout.write(`${JSON.stringify({ type: "agent_settled" })}\n`);
    }
});
const active = runChild(stopping, "task", controller.signal);
controller.abort();
await assert.rejects(active.done, /aborted/);
assert.equal(abortRequested, true);
assert.equal(stopping.stdin.writableEnded, true);

console.log("pi-delegate check passed");
