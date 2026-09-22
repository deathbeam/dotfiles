import * as os from "os";
import { isAbsolute, resolve as resolvePath } from "path";

function expandPath(filePath: string): string {
	if (filePath === "~") return os.homedir();
	if (filePath.startsWith("~/")) return os.homedir() + filePath.slice(1);
	return filePath;
}

export function resolveToCwd(filePath: string, cwd: string): string {
	const expanded = expandPath(filePath);
	return isAbsolute(expanded) ? expanded : resolvePath(cwd, expanded);
}
