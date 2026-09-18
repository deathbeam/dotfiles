import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { registerEditTool } from "./src/edit";
import { registerGrepTool } from "./src/grep";
import { registerReadTool } from "./src/read";

export default function (pi: ExtensionAPI): void {
	registerReadTool(pi);
	registerEditTool(pi);
	// Self-gates on ripgrep being available on PATH.
	registerGrepTool(pi);

	pi.on("session_start", async (_event, ctx) => {
		const debugValue = process.env.PI_HASHLINE_DEBUG;
		if (debugValue === "1" || debugValue === "true") {
			ctx.ui.notify("Hashline Edit mode active", "info");
		}
	});
}
