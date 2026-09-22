import { createHash } from "node:crypto";
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const CANONICAL_SESSION = /^ses_[0-9a-f]{12}[0-9A-Za-z]{14}$/;

function isFreeModel(model: { provider: string; id: string }): boolean {
	return model.provider === "opencode" && (model.id === "big-pickle" || model.id.endsWith("-free"));
}

export default function (pi: ExtensionAPI) {
	pi.on("before_provider_headers", (event, ctx) => {
		const model = ctx.model;
		if (!model || !isFreeModel(model)) return;

		const session = event.headers["x-opencode-session"] ?? ctx.sessionManager.getSessionId();
		if (session && !CANONICAL_SESSION.test(session)) {
			event.headers["x-opencode-session"] = `ses_${createHash("sha256").update(session).digest("hex").slice(0, 26)}`;
		}
		event.headers["User-Agent"] = "opencode/1.18.0";
	});
}
