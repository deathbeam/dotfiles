import assert from "node:assert/strict";
import { readdirSync, readFileSync } from "node:fs";
import { formatDuration, formatTokens, launchSummary, outputPreview, progressStats, resultPreview, SPINNER_FRAMES, toolCallDetail } from "./format.ts";

const root = new URL("./", import.meta.url);
const index = readFileSync(new URL("index.ts", root), "utf8");
assert.match(index, /name: "delegate"/);
assert.match(index, /before_agent_start/);
assert.match(index, /systemPromptOptions\.sections\.agents/);
assert.match(index, /startsWith\("~\/"\)/);
assert.match(index, /SPINNER_INTERVAL_MS/);
assert.match(index, /contextWindowFor\(ctx, model\)/);
assert.match(index, /progressStats\(details, elapsedMs\)/);

const expected = ["explore", "general", "researcher", "reviewer"];
const names = readdirSync(new URL("agents/", root))
	.filter((file) => file.endsWith(".md"))
	.map((file) => readFileSync(new URL(`agents/${file}`, root), "utf8").match(/^name:\s*(.+)$/m)?.[1])
	.sort();
assert.deepEqual(names, expected);

// Display helpers: these numbers and strings are what the delegate row shows.
assert.ok(SPINNER_FRAMES.length > 1);
assert.equal(launchSummary({ model: "x/y", tools: ["read", "ls"] }), "Model: x/y · Tools: read, ls");
assert.equal(launchSummary({ tools: [] }), "Model: default · Tools: all");
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
console.log("pi-delegate check passed");
