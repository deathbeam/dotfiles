import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { readdirSync, readFileSync, unlinkSync, writeFileSync } from "node:fs";
import { stripTypeScriptTypes } from "node:module";
import { tmpdir } from "node:os";
import { join } from "node:path";
import {
    formatDuration,
    formatTokens,
    jobLine,
    launchDetails,
    outputPreview,
    progressStats,
    reportText,
    resultPreview,
    SPINNER_FRAMES,
    toolCallDetail,
} from "./format.ts";

const root = new URL("./", import.meta.url);
const index = readFileSync(new URL("index.ts", root), "utf8");

// The assertions below only regex-match index.ts, so compile it too: a broken file still passes those.
const indexCheckFile = join(tmpdir(), "pi-delegate-index-check.mjs");
writeFileSync(indexCheckFile, stripTypeScriptTypes(index));
try {
    execFileSync(process.execPath, ["--check", indexCheckFile], { stdio: "pipe" });
} finally {
    unlinkSync(indexCheckFile);
}

assert.match(index, /name: "delegate"/);
assert.match(index, /before_agent_start/);
assert.match(index, /systemPromptOptions\.sections\.agents/);
assert.match(index, /startsWith\("~\/"\)/);
assert.match(index, /SPINNER_INTERVAL_MS/);
assert.match(index, /contextWindowFor\(ctx, model\)/);
assert.match(index, /if \(!model\) throw new Error\(/);
assert.match(index, /\["--model", model, "--tools", tools\.join\(","\)\]/);
assert.match(index, /progressStats\(report, report\.elapsedMs\)/);
assert.match(index, /registerMessageRenderer\(RESULT_MESSAGE/);
assert.match(index, /pi\.sendMessage\(/);
assert.match(index, /setWidget\(WIDGET_KEY/);
assert.match(index, /background: ctx\.hasUI/);
assert.match(index, /description: Type\.String/);
assert.match(index, /keyHint\("app\.tools\.expand", context\.expanded \? "to collapse" : "to expand"\)/);
assert.match(index, /launchDetails\(details\)\.join\("\\n"\)/);

const expected = ["explore", "general", "researcher", "reviewer"];
const names = readdirSync(new URL("agents/", root))
    .filter((file) => file.endsWith(".md"))
    .map((file) => readFileSync(new URL(`agents/${file}`, root), "utf8").match(/^name:\s*(.+)$/m)?.[1])
    .sort();
assert.deepEqual(names, expected);

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
console.log("pi-delegate check passed");
