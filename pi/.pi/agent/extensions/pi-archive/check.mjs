// Run: node check.mjs (Node >=23 strips the TypeScript helper module's types).
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import os from "node:os";
import { Readable } from "node:stream";
import {
    searchSessions,
    entryText,
    matchesAll,
    excerptAround,
    projectLabel,
    firstUserTitle,
    recentSessions,
    formatResults,
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
        line({
            type: "message",
            id: "m1",
            parentId: null,
            message: { role: "user", content: [{ type: "text", text: "fix the jwt auth refresh bug" }] },
        }),
        line({
            type: "message",
            id: "m2",
            parentId: "m1",
            message: {
                role: "assistant",
                content: [
                    { type: "thinking", thinking: "irrelevant" },
                    { type: "text", text: "the token expiry was 5 minutes, raised to 30" },
                ],
            },
        }),
        line({ type: "compaction", id: "c1", parentId: "m2", summary: "Fixed jwt refresh; expiry 5->30 min" }),
        line({
            type: "message",
            id: "m3",
            parentId: "m2",
            message: {
                role: "toolResult",
                toolCallId: "t1",
                toolName: "bash",
                content: [{ type: "text", text: "Error EACCES: jwt key file unreadable" }],
            },
        }),
        "",
    ].join("\n"),
);
fs.writeFileSync(
    path.join(projB, "2026-09-02T00-00-00-000Z_bbbb.jsonl"),
    [
        line({ type: "session", version: 3, id: "bbbb" }),
        line({
            type: "message",
            id: "m1",
            parentId: null,
            message: { role: "user", content: [{ type: "text", text: "unrelated work on the renderer" }] },
        }),
        "",
    ].join("\n"),
);
const currentFile = path.join(projA, "2026-09-03T00-00-00-000Z_cccc.jsonl");
fs.writeFileSync(
    currentFile,
    [
        line({ type: "session", version: 3, id: "cccc" }),
        line({
            type: "message",
            id: "m1",
            parentId: null,
            message: { role: "user", content: [{ type: "text", text: "jwt again but this session is the live one" }] },
        }),
        "",
    ].join("\n"),
);
fs.writeFileSync(
    path.join(projB, "2026-09-04T00-00-00-000Z_dddd.jsonl"),
    line({ type: "message", message: { role: "user", content: "literal\u2028and\u2029separators plain string" } }) +
        "\n",
);
const largeFile = path.join(projB, "2026-09-05T00-00-00-000Z_eeee.jsonl");
const largeFd = fs.openSync(largeFile, "w");
fs.writeFileSync(largeFd, Buffer.alloc(16 * 1024 * 1024 + 128 * 1024, 120)); // oversized record spans chunks
fs.writeFileSync(
    largeFd,
    `\n${line({ type: "message", message: { role: "assistant", content: [{ type: "text", text: "largeentry survives" }] } })}\n${line({ type: "message", message: { role: "user", content: "late title" } })}\n`,
);
fs.closeSync(largeFd);

// entryText: skips thinking, reads compaction summaries
const et = entryText({
    type: "message",
    message: {
        role: "assistant",
        content: [
            { type: "thinking", thinking: "x" },
            { type: "text", text: "hello" },
        ],
    },
});
assert.equal(et?.text, "hello");
assert.equal(entryText({ type: "compaction", summary: "sum" })?.role, "summary");
assert.equal(entryText({ type: "model_change" }), null);
assert.equal(entryText({ type: "message", message: { role: "user", content: "plain string" } })?.text, "plain string");
assert.equal(entryText({ type: "message", message: { role: "system", content: "not searchable" } }), null);

assert.ok(matchesAll("Fix The JWT Bug", ["jwt", "bug"]));
assert.ok(!matchesAll("Fix The JWT Bug", ["jwt", "renderer"]));

assert.ok(excerptAround("x".repeat(400) + "needle" + "y".repeat(400), ["needle"]).includes("needle"));
assert.ok(excerptAround("a".repeat(400), ["needle"]).startsWith("a".repeat(300) + "…")); // no match: truncated prefix + ellipsis

assert.equal(projectLabel("--home-deathbeam-git-dotfiles--"), "git/dotfiles");
assert.equal(projectLabel("--home-user--"), "home/user");

// search: ranking (current session first, then same project), AND terms, compaction hit
const res = await searchSessions(root, "jwt", { currentFile, currentDir: projA });
assert.equal(res.matches.length, 4);
assert.equal(res.matches[0].currentSession, true);
assert.equal(res.matches[0].role, "user");
assert.equal(res.matches[1].sameProject, true);
assert.equal(res.matches[1].date, "2026-09-01");
assert.ok(res.matches.some((m) => m.role === "summary"));
assert.ok(res.matches.some((m) => m.role === "toolResult" && m.excerpt.includes("EACCES")));
assert.ok(res.matches.some((m) => m.excerpt.includes("30")));

// AND across terms finds nothing in projB
const none = await searchSessions(root, "jwt renderer", {});
assert.equal(none.matches.length, 0);

// session filter
const filtered = await searchSessions(root, "renderer", { sessionFilter: "projB" });
assert.equal(filtered.matches[0].project, "git/projB");

// LF streaming must not split literal U+2028/U+2029, and oversized records must not be silently omitted.
assert.equal((await searchSessions(root, "literal", {})).matches.length, 1);
const large = await searchSessions(root, "largeentry", {});
assert.equal(large.matches.length, 1);
assert.equal(large.truncated, true);
assert.equal(await firstUserTitle(largeFile), "late title");

// limit
assert.equal((await searchSessions(root, "jwt", { limit: 1 })).matches.length, 1);
for (const limit of [0, -1, 1.5, Infinity, 101]) {
    await assert.rejects(searchSessions(root, "jwt", { limit }), /limit must be an integer/);
}
await assert.rejects(searchSessions(root, "", { limit: 0 }), /limit must be an integer/);

// abort: signal already aborted yields zero matches, truncated flag set
const ac = new AbortController();
ac.abort();
const aborted = await searchSessions(root, "jwt", {}, ac.signal);
assert.equal(aborted.matches.length, 0);
assert.equal(aborted.truncated, true);

// A changed/unreadable file during discovery is skipped without throwing.
const realStat = fs.promises.stat;
fs.promises.stat = async () => {
    throw new Error("file changed");
};
try {
    assert.deepEqual(await searchSessions(root, "jwt", {}), {
        matches: [],
        bytesScanned: 0,
        filesScanned: 0,
        truncated: false,
    });
} finally {
    fs.promises.stat = realStat;
}

// A read error is incomplete, not a definitive archive miss.
const realStream = fs.createReadStream;
fs.createReadStream = () =>
    Readable.from(
        (async function* () {
            throw new Error("read failed");
        })(),
    );
try {
    assert.equal((await searchSessions(root, "missing", { sessionFilter: "projA" })).truncated, true);
} finally {
    fs.createReadStream = realStream;
}

// Zero hits from an incomplete search must not claim a complete no-match result.
const empty = { matches: [], bytesScanned: 1, filesScanned: 1, truncated: true };
assert.match(formatResults("nothing", empty), /Search incomplete/);
assert.doesNotMatch(formatResults("nothing", { ...empty, truncated: false }), /Search incomplete/);

// titles + recent sessions
assert.equal(
    await firstUserTitle(path.join(projA, "2026-09-01T00-00-00-000Z_aaaa.jsonl")),
    "fix the jwt auth refresh bug",
);
assert.equal(await firstUserTitle(path.join(projB, "does-not-exist.jsonl")), null);
assert.equal(
    await firstUserTitle(path.join(projB, "2026-09-04T00-00-00-000Z_dddd.jsonl")),
    "literal\u2028and\u2029separators plain string",
);
const recent = recentSessions(projA, currentFile, 5);
assert.equal(recent.length, 1);
assert.equal(recent[0].name, "2026-09-01T00-00-00-000Z_aaaa.jsonl");

fs.rmSync(root, { recursive: true, force: true });
console.log("pi-archive: all checks passed");
