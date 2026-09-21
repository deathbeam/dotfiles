// Self-check for pi-archive.ts. Run: node ~/.pi/agent/extensions/pi-archive.check.mjs
// Node >= 23 loads .ts via native type stripping; the extension's pi-package
// imports are dynamic (inside the factory), so importing the module is safe.
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import os from "node:os";
import {
	searchSessions,
	entryText,
	matchesAll,
	excerptAround,
	projectLabel,
	firstUserTitle,
	recentSessions,
} from "./index.ts";

const root = fs.mkdtempSync(path.join(os.tmpdir(), "pi-archive-check-"));
const projA = path.join(root, "--home-user-git-projA--");
const projB = path.join(root, "--home-user-git-projB--");
fs.mkdirSync(projA);
fs.mkdirSync(projB);

const line = (obj) => JSON.stringify(obj);
fs.writeFileSync(
	path.join(projA, "2026-09-01T00-00-00-000Z_aaaa.jsonl"),
	[
		line({ type: "session", version: 3, id: "aaaa" }),
		line({ type: "message", id: "m1", parentId: null, message: { role: "user", content: [{ type: "text", text: "fix the jwt auth refresh bug" }] } }),
		line({ type: "message", id: "m2", parentId: "m1", message: { role: "assistant", content: [{ type: "thinking", thinking: "irrelevant" }, { type: "text", text: "the token expiry was 5 minutes, raised to 30" }] } }),
		line({ type: "compaction", id: "c1", parentId: "m2", summary: "Fixed jwt refresh; expiry 5->30 min" }),
		"",
	].join("\n"),
);
fs.writeFileSync(
	path.join(projB, "2026-09-02T00-00-00-000Z_bbbb.jsonl"),
	[
		line({ type: "session", version: 3, id: "bbbb" }),
		line({ type: "message", id: "m1", parentId: null, message: { role: "user", content: [{ type: "text", text: "unrelated work on the renderer" }] } }),
		"",
	].join("\n"),
);
const currentFile = path.join(projA, "2026-09-03T00-00-00-000Z_cccc.jsonl");
fs.writeFileSync(
	currentFile,
	[
		line({ type: "session", version: 3, id: "cccc" }),
		line({ type: "message", id: "m1", parentId: null, message: { role: "user", content: [{ type: "text", text: "jwt again but this session is the live one" }] } }),
		"",
	].join("\n"),
);

// entryText: skips thinking, reads compaction summaries
const et = entryText({ type: "message", message: { role: "assistant", content: [{ type: "thinking", thinking: "x" }, { type: "text", text: "hello" }] } });
assert.equal(et?.text, "hello");
assert.equal(entryText({ type: "compaction", summary: "sum" })?.role, "summary");
assert.equal(entryText({ type: "model_change" }), null);

assert.ok(matchesAll("Fix The JWT Bug", ["jwt", "bug"]));
assert.ok(!matchesAll("Fix The JWT Bug", ["jwt", "renderer"]));

assert.ok(excerptAround("x".repeat(400) + "needle" + "y".repeat(400), ["needle"]).includes("needle"));
assert.ok(excerptAround("a".repeat(400), ["needle"]).startsWith("a".repeat(300) + "…")); // no match: truncated prefix + ellipsis

assert.equal(projectLabel("--home-deathbeam-git-dotfiles--"), "git/dotfiles");
assert.equal(projectLabel("--home-user--"), "home/user");

// search: ranking (current session first, then same project), AND terms, compaction hit
const res = searchSessions(root, "jwt", { currentFile, currentDir: projA });
assert.equal(res.matches.length, 3);
assert.equal(res.matches[0].currentSession, true);
assert.equal(res.matches[0].role, "user");
assert.equal(res.matches[1].sameProject, true);
assert.equal(res.matches[1].date, "2026-09-01");
assert.ok(res.matches.some((m) => m.role === "summary"));
assert.ok(res.matches.some((m) => m.excerpt.includes("30")));

// AND across terms finds nothing in projB
const none = searchSessions(root, "jwt renderer", {});
assert.equal(none.matches.length, 0);

// session filter
const filtered = searchSessions(root, "renderer", { sessionFilter: "projB" });
assert.equal(filtered.matches.length, 1);
assert.equal(filtered.matches[0].project, "git/projB");

// limit
assert.equal(searchSessions(root, "jwt", { limit: 1 }).matches.length, 1);

// titles + recent sessions
assert.equal(firstUserTitle(path.join(projA, "2026-09-01T00-00-00-000Z_aaaa.jsonl")), "fix the jwt auth refresh bug");
assert.equal(firstUserTitle(path.join(projB, "does-not-exist.jsonl")), null);
const recent = recentSessions(projA, currentFile, 5);
assert.equal(recent.length, 1);
assert.equal(recent[0].name, "2026-09-01T00-00-00-000Z_aaaa.jsonl");

fs.rmSync(root, { recursive: true, force: true });
console.log("pi-archive: all checks passed");
