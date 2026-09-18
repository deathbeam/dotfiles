import { open as fsOpen, stat as fsStat } from "fs/promises";
import { fileTypeFromBuffer } from "file-type";

const IMAGE_MIME_TYPES = new Set<string>([
	"image/jpeg",
	"image/png",
	"image/gif",
	"image/webp",
]);

const TEXT_LIKE_MIME_TYPES = new Set<string>([
	"application/rtf",
	"application/xml",
	"application/x-ms-regedit",
]);

function isTextLikeMimeType(mimeType: string): boolean {
	return mimeType.startsWith("text/") || TEXT_LIKE_MIME_TYPES.has(mimeType);
}

const FILE_TYPE_SNIFF_BYTES = 8192;

export type LoadedFile =
	| { kind: "directory" }
	| { kind: "image"; mimeType: string }
	| { kind: "text"; text: string; hadUtf8DecodeErrors?: true }
	| { kind: "binary"; description: string };

function hasNullByte(buffer: Uint8Array): boolean {
	return buffer.includes(0);
}

export async function loadFileKindAndText(
	filePath: string,
): Promise<LoadedFile> {
	const pathStat = await fsStat(filePath);
	if (pathStat.isDirectory()) {
		return { kind: "directory" };
	}
	if (!pathStat.isFile()) {
		return {
			kind: "binary",
			description: "unsupported file type",
		};
	}

	const fileHandle = await fsOpen(filePath, "r");
	try {
		const buffer = Buffer.alloc(FILE_TYPE_SNIFF_BYTES);
		const { bytesRead } = await fileHandle.read(
			buffer,
			0,
			FILE_TYPE_SNIFF_BYTES,
			0,
		);
		if (bytesRead === 0) {
			return { kind: "text", text: "" };
		}

		const sample = buffer.subarray(0, bytesRead);
		const detectedMimeType = (await fileTypeFromBuffer(sample))?.mime;
		if (
			detectedMimeType !== undefined &&
			!isTextLikeMimeType(detectedMimeType)
		) {
			if (IMAGE_MIME_TYPES.has(detectedMimeType)) {
				return { kind: "image", mimeType: detectedMimeType };
			}
			return {
				kind: "binary",
				description: detectedMimeType,
			};
		}
		if (hasNullByte(sample)) {
			return {
				kind: "binary",
				description: "null bytes detected",
			};
		}

		// Non-fatal decode, matching pi's built-in tools: invalid UTF-8 becomes
		// U+FFFD rather than rejecting the file. The null-byte guard above is the
		// only signal we treat as binary, so non-UTF-8 text (CP1251, GBK, …) reads
		// instead of forcing the model to bypass hashline with raw shell edits.
		// Track fatal-decoder failures separately so a literal, valid U+FFFD in a
		// UTF-8 file does not get mistaken for lossy decoding.
		const decoder = new TextDecoder("utf-8");
		const fatalDecoder = new TextDecoder("utf-8", { fatal: true });
		let hadUtf8DecodeErrors = false;
		const noteUtf8DecodeErrors = (chunk?: Uint8Array): void => {
			if (hadUtf8DecodeErrors) return;
			try {
				fatalDecoder.decode(chunk, { stream: chunk !== undefined });
			} catch (error: unknown) {
				if (error instanceof TypeError) {
					hadUtf8DecodeErrors = true;
					return;
				}
				throw error;
			}
		};

		noteUtf8DecodeErrors(sample);
		const parts: string[] = [decoder.decode(sample, { stream: true })];

		let position = bytesRead;
		while (true) {
			const { bytesRead: chunkBytesRead } = await fileHandle.read(
				buffer,
				0,
				FILE_TYPE_SNIFF_BYTES,
				position,
			);
			if (chunkBytesRead === 0) {
				break;
			}

			const chunk = buffer.subarray(0, chunkBytesRead);
			if (hasNullByte(chunk)) {
				return {
					kind: "binary",
					description: "null bytes detected",
				};
			}
			noteUtf8DecodeErrors(chunk);
			parts.push(decoder.decode(chunk, { stream: true }));
			position += chunkBytesRead;
		}

		noteUtf8DecodeErrors();
		parts.push(decoder.decode());

		return {
			kind: "text",
			text: parts.join(""),
			...(hadUtf8DecodeErrors ? { hadUtf8DecodeErrors: true as const } : {}),
		};
	} finally {
		await fileHandle.close();
	}
}
