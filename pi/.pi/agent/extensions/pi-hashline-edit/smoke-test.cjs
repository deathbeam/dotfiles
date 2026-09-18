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

	// 8. renderers: edit renderCall live preview + renderResult via pi's renderDiff
	const fakeTheme = { fg: (_n, txt) => txt, bold: (txt) => txt };
	const renderToString = (comp) => comp.render(120).join("\n");

	writeFileSync(file, "const x = 1;\nconst y = 2;\nconst z = 3;\n");
	const rr = await run(byName.read, { path: file });
	const anchorM = rr.content[0].text.match(/^\s*2#([A-Z]{3}):/m);
	const editArgs = { path: file, edits: [{ op: "replace", pos: `2#${anchorM[1]}`, lines: ["const y = 24;"] }] };

	// incomplete args → header only
	let rctx = { state: {}, lastComponent: undefined, argsComplete: false, executionStarted: false, invalidate: () => {}, cwd: dir, expanded: false };
	let callComp = byName.edit.renderCall(editArgs, fakeTheme, rctx);
	const header = renderToString(callComp);
	if (!/edit/.test(header) || !/sample/.test(header)) throw new Error("renderCall header missing: " + JSON.stringify(header));

	// complete args → async live preview, then re-render
	rctx = { state: {}, lastComponent: callComp, argsComplete: true, executionStarted: false, invalidate: () => {}, cwd: dir, expanded: false };
	callComp = byName.edit.renderCall(editArgs, fakeTheme, rctx);
	await new Promise((r) => setTimeout(r, 300));
	callComp = byName.edit.renderCall(editArgs, fakeTheme, rctx);
	const previewText = renderToString(callComp);
	console.log("--- renderCall live preview ---");
	console.log(previewText);
	if (!/const y = 2;/.test(previewText) || !/const y = 24;/.test(previewText)) {
		throw new Error("preview missing old/new line: " + JSON.stringify(previewText));
	}

	// execute + renderResult → pi-standard diff
	const editRes = await run(byName.edit, editArgs);
	const rctx2 = { state: {}, lastComponent: undefined, argsComplete: true, executionStarted: true, invalidate: () => {}, cwd: dir, expanded: true, isError: false, args: editArgs };
	const resComp = byName.edit.renderResult(editRes, { isPartial: false }, fakeTheme, rctx2);
	const resText = renderToString(resComp);
	console.log("--- renderResult (pi renderDiff) ---");
	console.log(resText.slice(0, 400));
	if (!/const y = 24/.test(resText)) throw new Error("rendered result missing diff content");

	// resending the same payload → E_DUPLICATE_EDIT; its thrown error renders
	// through the isError path as plain error text.
	let dupError = null;
	try {
		await run(byName.edit, editArgs);
	} catch (e) {
		dupError = e;
	}
	if (!dupError || !/E_DUPLICATE_EDIT/.test(dupError.message)) throw new Error("expected duplicate guard to fire");
	const dupResult = { content: [{ type: "text", text: dupError.message }], details: { diff: "", classification: "noop", warnings: [] } };
	const dupComp = byName.edit.renderResult(dupResult, { isPartial: false }, fakeTheme, { ...rctx2, isError: true, args: editArgs });
	const dupText = renderToString(dupComp);
	if (!/E_DUPLICATE_EDIT/.test(dupText)) throw new Error("error render missing message");
	console.log("--- renderResult error path OK ---");

	rmSync(dir, { recursive: true, force: true });
	console.log("\nALL SMOKE TESTS PASSED");
})().catch((e) => {
	console.error("SMOKE TEST FAILED:", e);
	process.exit(1);
});
