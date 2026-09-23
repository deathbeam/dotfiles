/**
 * Prompt loading. Prompt files are authored with 3-character anchor examples
 * (HASH_LENGTH), so nothing is rewritten at load time.
 */

import { readFileSync } from "node:fs";

export function loadPrompt(url: URL): string {
    return readFileSync(url, "utf8");
}

/** Read a prompt file and return its `- ` bullet lines as guideline strings. */
export function loadPromptGuidelines(url: URL): string[] {
    return loadPrompt(url)
        .split("\n")
        .map((line) => line.trim())
        .filter((line) => line.startsWith("- "))
        .map((line) => line.slice(2));
}
