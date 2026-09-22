import { readFile, stat } from "node:fs/promises";
import { detectSupportedImageMimeTypeFromFile } from "@earendil-works/pi-coding-agent";

export type LoadedFile =
	| { kind: "directory" }
	| { kind: "image" }
	| { kind: "text"; text: string; hadUtf8DecodeErrors?: true }
	| { kind: "binary"; description: string };

/**
 * Classify a path and load its content.
 *
 * - Images use pi's own detection (jpeg/png/gif/webp/bmp); callers hand image
 *   reads to pi's built-in read tool.
 * - A null byte marks a file binary. pi's read tool makes no such check and
 *   would return mojibake; this extension needs text to anchor.
 * - Everything else is decoded as UTF-8, invalid bytes becoming U+FFFD. The
 *   flag records lossy decoding so callers can warn.
 */
export async function loadFileKindAndText(
	filePath: string,
): Promise<LoadedFile> {
	const pathStat = await stat(filePath);
	if (pathStat.isDirectory()) {
		return { kind: "directory" };
	}
	if (!pathStat.isFile()) {
		return { kind: "binary", description: "unsupported file type" };
	}

	if (await detectSupportedImageMimeTypeFromFile(filePath)) {
		return { kind: "image" };
	}

	const buffer = await readFile(filePath);
	if (buffer.includes(0)) {
		return { kind: "binary", description: "null bytes detected" };
	}

	let hadUtf8DecodeErrors = false;
	try {
		new TextDecoder("utf-8", { fatal: true }).decode(buffer);
	} catch {
		hadUtf8DecodeErrors = true;
	}

	return {
		kind: "text",
		text: buffer.toString("utf-8"),
		...(hadUtf8DecodeErrors ? { hadUtf8DecodeErrors: true as const } : {}),
	};
}
