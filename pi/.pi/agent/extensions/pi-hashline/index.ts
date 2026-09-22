import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { registerEditTool } from "./src/edit";
import { registerGrepTool } from "./src/grep";
import { registerReadTool } from "./src/read";

export default function (pi: ExtensionAPI): void {
	registerReadTool(pi);
	registerEditTool(pi);
	registerGrepTool(pi);
}
