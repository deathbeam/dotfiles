import assert from "node:assert/strict";
import { readdirSync, readFileSync } from "node:fs";

const root = new URL("./", import.meta.url);
const index = readFileSync(new URL("index.ts", root), "utf8");
assert.match(index, /name: "delegate"/);
assert.match(index, /before_agent_start/);
assert.match(index, /systemPromptOptions\.sections\.agents/);
assert.match(index, /startsWith\("~\/"\)/);

const expected = ["explore", "general", "researcher", "reviewer"];
const names = readdirSync(new URL("agents/", root))
	.filter((file) => file.endsWith(".md"))
	.map((file) => readFileSync(new URL(`agents/${file}`, root), "utf8").match(/^name:\s*(.+)$/m)?.[1])
	.sort();
assert.deepEqual(names, expected);
console.log("pi-delegate check passed");
