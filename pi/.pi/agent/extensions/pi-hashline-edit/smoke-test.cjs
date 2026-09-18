/* Smoke test: load the extension via jiti (as pi does) and exercise read/edit. */
const { createJiti } = require("jiti");
const { writeFileSync, readFileSync, rmSync, mkdtempSync } = require("node:fs");
const { join } = require("node:path");
const { tmpdir } = require("node:os");

const jiti = createJiti(__filename);
const mod = jiti("./index.ts");
// renderDiff reads pi's global theme singleton — initialize it headless.
const { initTheme } = jiti("@earendil-works/pi-coding-agent");
initTheme();

const registered = [];
const pi = {
	registerTool: (t) => registered.push(t),
	on: () => {},
};
mod.default(pi);

const byName = Object.fromEntries(registered.map((t) => [t.name, t]));
console.log("registered tools:", registered.map((t) => t.name).sort());
if (registered.map((t) => t.name).sort().join() !== "edit,grep,read") {
	throw new Error("expected read, edit, grep registered");
}

const dir = mkdtempSync(join(tmpdir(), "hashline-smoke-"));
const file = join(dir, "sample.ts");
writeFileSync(file, "const x = 1;\nconst y = 2;\nconst z = 3;\n");

const ctx = { cwd: dir };
const noop = () => {};

async function run(tool, params) {
	return tool.execute("id", params, undefined, noop, ctx);
}

(async () => {
	// 1. read: 3-char hashes, LINE#HASH:content, no space after colon
	const readResult = await run(byName.read, { path: file });
	const readText = readResult.content[0].text;
	console.log("--- read output ---");
	console.log(readText);
	if (!/^\s*1#[A-Z]{3}:const x = 1;$/m.test(readText)) {
		throw new Error("expected 3-char hash prefixes");
	}
	if (readResult.details.snapshotId !== undefined) {
		throw new Error("snapshotId should be gone");
	}

	// 2. edit: replace line 2 using the anchor from read output
	const anchor = readText.match(/^\s*2#([A-Z]{3}):/m);
	if (!anchor) throw new Error("no anchor for line 2");
	const editResult = await run(byName.edit, {
		path: file,
		edits: [
			{ op: "replace", pos: `2#${anchor[1]}`, lines: ["const y = 20;"] },
		],
	});
	console.log("--- edit result ---");
	console.log(editResult.content[0].text);
	const after = readFileSync(file, "utf8");
	if (after !== "const x = 1;\nconst y = 20;\nconst z = 3;\n") {
		throw new Error(`unexpected file content: ${JSON.stringify(after)}`);
	}

	// 3. Bug fix 1: anchor with " " after colon (hash matches) must NOT be stale
	writeFileSync(file, "const x = 1;\nconst y = 2;\nconst z = 3;\n");
	const reread = await run(byName.read, { path: file });
	const m = reread.content[0].text.match(/^\s*2#([A-Z]{3}):(.*)$/m);
	const hintedEdit = await run(byName.edit, {
		path: file,
		edits: [{ op: "replace", pos: `2#${m[1]}: ${m[2]}`, lines: ["const y = 222;"] }],
	});
	if (hintedEdit.isError !== undefined || /E_STALE_ANCHOR/.test(hintedEdit.content[0].text)) {
		throw new Error("bug1: hinted anchor wrongly rejected: " + hintedEdit.content[0].text);
	}
	console.log("--- bug1 (space after colon) OK ---");

	// 4. replace_text must fail with the teaching error
	try {
		await run(byName.edit, {
			path: file,
			edits: [{ op: "replace", pos: `2#${m[1]}`, oldText: "const y = 2;", newText: "nope" }],
		});
		throw new Error("expected replace_text to fail");
	} catch (e) {
		if (!/Text-replace edits are not supported/.test(e.message)) {
			throw new Error("wrong teaching error: " + e.message);
		}
		console.log("--- replace_text teaching error OK ---");
	}

	// 5. top-level oldText/newText fails in prepareArguments (pre-schema), like pi's agent loop
	try {
		byName.edit.prepareArguments({ path: file, oldText: "a", newText: "b" });
		throw new Error("expected top-level oldText to fail");
	} catch (e) {
		if (!/Text-replace edits are not supported/.test(e.message)) {
			throw new Error("wrong root teaching error: " + e.message);
		}
		console.log("--- top-level oldText teaching error OK (prepareArguments) ---");
	}

	// 6. raw read of a huge single line: no inverted range, no nextOffset
	const bigFile = join(dir, "big.txt");
	writeFileSync(bigFile, "x".repeat(60 * 1024));
	const big = await run(byName.read, { path: bigFile, raw: true });
	if (/lines 1-0/.test(big.content[0].text) || big.details.nextOffset !== undefined) {
		throw new Error("bug3: raw oversized line still broken: " + JSON.stringify(big));
	}
	console.log("--- bug3 (raw oversized line) OK:", JSON.stringify(big.content[0].text.slice(0, 80)));

	// 7. grep smoke (if rg present)
	if (byName.grep) {
		const grepResult = await run(byName.grep, { pattern: "const y", path: dir, glob: "*.ts" });
		console.log("--- grep output ---");
		console.log(grepResult.content[0].text);
		if (!/#[A-Z]{3}:const y/.test(grepResult.content[0].text)) {
			throw new Error("grep output missing 3-char anchors");
		}
	}

	// 8. renderer wiring: edit defines NO custom renderers, so pi merges its
	// built-in edit renderers by tool name; read defines a custom (prefix-
	// stripping) result renderer — see 9.
	const fakeTheme = { fg: (name, txt) => `«${name}»${txt}`, bg: (_n, txt) => txt, bold: (txt) => txt };
	const renderToString = (comp) => comp.render(120).join("\n");
	const stripAnsi = (s) => s.replace(/\u001b\[[0-9;]*m/g, "");
	if (byName.edit.renderCall !== undefined) {
		throw new Error("edit should use pi's built-in call renderer");
	}
	if (byName.edit.renderResult === undefined || byName.read.renderResult === undefined) {
		throw new Error("edit/read should define their result renderers");
	}
	console.log("--- renderer wiring OK (edit call: built-in; results: custom) ---");

	// edit result rendering: diff via pi's renderDiff + the warnings section
	const warnFile = join(dir, "warn.ts");
	writeFileSync(warnFile, "const a = 1;\nconst b = 2;\nconst c = 3;\n");
	const wRead = await run(byName.read, { path: warnFile });
	// append after line 1 the exact lines that already follow it → duplicate-insert warning
	const firstAnchor = wRead.content[0].text.match(/^\s*1#([A-Z]{3}):/m);
	const warnRes = await run(byName.edit, {
		path: warnFile,
		edits: [{ op: "append", pos: `1#${firstAnchor[1]}`, lines: ["const b = 2;", "const c = 3;"] }],
	});
	if (!warnRes.details.warnings.length) throw new Error("expected a duplicate-insert warning");
	const wComp = byName.edit.renderResult(warnRes, { isPartial: false }, fakeTheme, { state: {}, lastComponent: undefined, isError: false, args: { path: warnFile } });
	const wText = stripAnsi(renderToString(wComp));
	console.log("--- edit renderResult (diff + warnings) ---");
	console.log(wText.trim());
	if (!/«warning»Potential duplicate insert/.test(wText)) {
		throw new Error("warnings not rendered in warning color: " + JSON.stringify(wText.slice(0, 200)));
	}
	if (/Warnings:/.test(wText)) {
		throw new Error("warnings should render headerless, like pi's own warning notes");
	}
	if (wText.startsWith("\n")) {
		throw new Error("rendered edit result must not add a leading blank line (call Box already pads)");
	}
	if (!/const c = 3;/.test(wText)) throw new Error("diff missing from rendered edit result");
	console.log("--- edit renderResult: diff + warnings OK ---");

	// error results render the model-facing error text
	const errComp = byName.edit.renderResult(
		{ content: [{ type: "text", text: "[E_STALE_ANCHOR] boom" }], details: { diff: "", classification: "noop", warnings: [] } },
		{ isPartial: false },
		fakeTheme,
		{ state: {}, lastComponent: undefined, isError: true, args: { path: warnFile } },
	);
	if (!/E_STALE_ANCHOR/.test(stripAnsi(renderToString(errComp)))) throw new Error("error text missing from rendered edit result");
	console.log("--- edit renderResult: error path OK ---");

	// collapsed diffs are capped with an expand hint; expanded shows everything
	const longDiff = Array.from({ length: 30 }, (_, i) => `+${i + 1} const v${i} = ${i};`).join("\n");
	const longRes = { content: [{ type: "text", text: "anchors" }], details: { diff: longDiff, classification: "applied", warnings: [] } };
	const longCtx = { state: {}, lastComponent: undefined, isError: false, args: { path: warnFile } };
	const collapsedText = stripAnsi(renderToString(byName.edit.renderResult(longRes, { isPartial: false, expanded: false }, fakeTheme, longCtx)));
	const expandedText = stripAnsi(renderToString(byName.edit.renderResult(longRes, { isPartial: false, expanded: true }, fakeTheme, longCtx)));
	if (!/more diff lines/.test(collapsedText) || !/to expand/.test(collapsedText)) {
		throw new Error("collapsed diff missing expand hint: " + JSON.stringify(collapsedText.slice(-120)));
	}
	if (collapsedText.split("\n").length >= expandedText.split("\n").length) {
		throw new Error("collapsed diff should be shorter than expanded");
	}
	if (!/const v29/.test(expandedText) || /const v29/.test(collapsedText)) {
		throw new Error("expanded diff should show all lines, collapsed should not");
	}
	console.log("--- edit renderResult: collapsed cap + expand hint OK ---");

	// duplicate-payload guard still fires through the pipeline
	writeFileSync(file, "const x = 1;\nconst y = 2;\nconst z = 3;\n");
	const rr = await run(byName.read, { path: file });
	const anchorM = rr.content[0].text.match(/^\s*2#([A-Z]{3}):/m);
	const editArgs = { path: file, edits: [{ op: "replace", pos: `2#${anchorM[1]}`, lines: ["const y = 24;"] }] };
	await run(byName.edit, editArgs);
	let dupError = null;
	try {
		await run(byName.edit, editArgs);
	} catch (e) {
		dupError = e;
	}
	if (!dupError || !/E_DUPLICATE_EDIT/.test(dupError.message)) throw new Error("expected duplicate guard to fire");
	console.log("--- duplicate guard OK ---");

	// 9. read renderer: content after the LINE#HASH: prefix must be syntax
	// highlighted (the raw prefixed line would highlight as a comment).
	const tsFile = join(dir, "render-check.ts");
	writeFileSync(tsFile, "const value = 1;\n// a comment\nexport function hi() { return value; }\n");
	const readRes = await run(byName.read, { path: tsFile });
	const readCtx = { state: {}, lastComponent: undefined, argsComplete: true, executionStarted: true, invalidate: () => {}, cwd: dir, expanded: true, isError: false, showImages: true, args: { path: tsFile } };
	const readComp = byName.read.renderResult(readRes, { expanded: true, isPartial: false }, fakeTheme, readCtx);
	const readRendered = renderToString(readComp);
	console.log("--- read renderResult ---");
	console.log(readRendered.slice(0, 300));
	if (!/value/.test(readRendered)) throw new Error("read render lost content");

	// anchors are stripped for display and the code carries highlight colors:
	// a rendered line must contain at least two distinct truecolor codes and
	// no LINE#HASH prefix.
	if (/^\s*\d+#[A-Z]{3}:/m.test(readRendered)) {
		throw new Error("read render still shows anchor prefixes");
	}
	const line1 = readRendered.split("\n").find((l) => l.includes("value = "));
	if (!line1) throw new Error("read render lost line 1");
	const colors = new Set(line1.match(/\u001b\[38;2;[0-9;]+m/g) ?? []);
	if (colors.size < 2) {
		throw new Error("read content not syntax highlighted (one color only): " + JSON.stringify(line1));
	}
	console.log("--- read renderer: prefixes stripped + highlighted code OK ---");

	// raw mode has no prefixes; content must still be highlighted
	const rawRes = await run(byName.read, { path: tsFile, raw: true });
	const rawComp = byName.read.renderResult(rawRes, { expanded: true, isPartial: false }, fakeTheme, { ...readCtx, args: { path: tsFile, raw: true } });
	const rawRendered = renderToString(rawComp);
	const rawLine = rawRendered.split("\n").find((l) => l.includes("value = "));
	const rawColors = new Set((rawLine ?? "").match(/\u001b\[38;2;[0-9;]+m/g) ?? []);
	if (rawColors.size < 2) {
		throw new Error("raw read not highlighted: " + JSON.stringify(rawLine));
	}
	console.log("--- read renderer: raw mode highlighted OK ---");

	// 10. grep renderer: prefixes stripped, 15-line collapsed cap with expand hint
	const grepRes = await run(byName.grep, { pattern: "const ", path: dir, glob: "*.ts", limit: 5 });
	const gCtx = { state: {}, lastComponent: undefined, argsComplete: true, executionStarted: true, invalidate: () => {}, cwd: dir, expanded: false, isError: false };
	const gComp = byName.grep.renderResult(grepRes, { expanded: false, isPartial: false }, fakeTheme, gCtx);
	const gText = stripAnsi(renderToString(gComp));
	if (/^\s*\d+#[A-Z]{3}:/m.test(gText)) throw new Error("grep render still shows anchor prefixes");
	if (!/const /.test(gText)) throw new Error("grep render lost content");
	const gExpanded = stripAnsi(renderToString(byName.grep.renderResult(grepRes, { expanded: true, isPartial: false }, fakeTheme, { ...gCtx, expanded: true })));
	if (!/const /.test(gExpanded)) throw new Error("expanded grep render lost content");
	console.log("--- grep renderer: prefixes stripped OK ---");

	// 11. file-kind: text / binary (null bytes) / image (pi's detector) / directory
	const fk = jiti("./src/file-kind.ts");
	const textKind = await fk.loadFileKindAndText(join(dir, "sample.ts"));
	if (textKind.kind !== "text" || !textKind.text.includes("const")) throw new Error("text classification failed");
	const binFile = join(dir, "bin.dat");
	writeFileSync(binFile, Buffer.from([0x50, 0x4b, 0x03, 0x04, 0x00, 0x01]));
	if ((await fk.loadFileKindAndText(binFile)).kind !== "binary") throw new Error("binary classification failed");
	const pngFile = join(dir, "img.png");
	writeFileSync(pngFile, Buffer.from("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==", "base64"));
	if ((await fk.loadFileKindAndText(pngFile)).kind !== "image") throw new Error("image classification failed");
	if ((await fk.loadFileKindAndText(dir)).kind !== "directory") throw new Error("directory classification failed");
	console.log("--- file-kind: text / binary / image / directory OK ---");

	rmSync(dir, { recursive: true, force: true });
	console.log("\nALL SMOKE TESTS PASSED");
})().catch((e) => {
	console.error("SMOKE TEST FAILED:", e);
	process.exit(1);
});
