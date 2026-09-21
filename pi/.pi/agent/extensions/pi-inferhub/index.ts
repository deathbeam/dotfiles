import type { ThinkingLevel, ThinkingLevelMap } from "@earendil-works/pi-ai";
import type { ExtensionAPI, ProviderModelConfig } from "@earendil-works/pi-coding-agent";

const BASE_URL = "https://api.inferhub.dev/v1";
const PI_THINKING_LEVELS = ["minimal", "low", "medium", "high", "xhigh", "max"] as const satisfies readonly ThinkingLevel[];

const COMPAT = {
	supportsStore: false,
	supportsDeveloperRole: false,
	supportsReasoningEffort: true,
	supportsUsageInStreaming: true,
	supportsStrictMode: false,
	maxTokensField: "max_tokens",
} as const;

type CatalogEntry = {
	id?: unknown;
	owned_by?: unknown;
	modality?: unknown;
	output_modality?: unknown;
	input_token_limit?: unknown;
	max_output_tokens?: unknown;
	reasoning_levels?: unknown;
	upstream_label?: unknown;
	pricing?: {
		min_ask_in?: unknown;
		min_ask_out?: unknown;
		official_in?: unknown;
		official_out?: unknown;
	};
};

function advertisedLevels(entry: CatalogEntry): string[] {
	return Array.isArray(entry.reasoning_levels)
		? entry.reasoning_levels.filter((level): level is string => typeof level === "string")
		: [];
}

function thinkingLevelMap(advertised: string[]): ThinkingLevelMap {
	const map: ThinkingLevelMap = { off: "none", xhigh: null, max: null };
	for (const level of PI_THINKING_LEVELS) {
		const supported = advertised.length > 0 ? advertised.includes(level) : level !== "xhigh" && level !== "max";
		map[level] = supported ? level : null;
	}
	return map;
}

function normalizeName(id: string): string {
	return (id.split("/").pop() ?? id)
		.toLowerCase()
		.replace(/[^a-z0-9]/g, "");
}

function smallest(sources: CatalogEntry[], value: (entry: CatalogEntry) => unknown, fallback: number): number {
	const numbers = sources
		.map(value)
		.filter((entry): entry is number => typeof entry === "number" && Number.isFinite(entry) && entry > 0);
	return numbers.length > 0 ? Math.min(...numbers) : fallback;
}

function cheapest(sources: CatalogEntry[], key: "input" | "output"): number {
	const prices = sources
		.map((entry) =>
			key === "input"
				? (entry.pricing?.min_ask_in ?? entry.pricing?.official_in)
				: (entry.pricing?.min_ask_out ?? entry.pricing?.official_out),
		)
		.filter((value): value is number => typeof value === "number" && Number.isFinite(value) && value >= 0);
	return prices.length > 0 ? Math.min(...prices) : 0;
}

function commonLevels(sources: CatalogEntry[]): string[] {
	const [first = [], ...rest] = sources.map(advertisedLevels);
	return first.filter((level) => rest.every((levels) => levels.includes(level)));
}

function toPiModel(entry: CatalogEntry, members: CatalogEntry[]): ProviderModelConfig | undefined {
	if (typeof entry.id !== "string" || !entry.id || entry.output_modality === "image") return undefined;

	const sources = members.length > 0 ? members : [entry];
	const label = sources.find((source) => typeof source.upstream_label === "string" && source.upstream_label)
		?.upstream_label;

	return {
		id: entry.id,
		name: typeof label === "string" ? label : entry.id,
		reasoning: true,
		thinkingLevelMap: thinkingLevelMap(commonLevels(sources)),
		input: sources.every((source) => typeof source.modality === "string" && source.modality.includes("image"))
			? ["text", "image"]
			: ["text"],
		cost: { input: cheapest(sources, "input"), output: cheapest(sources, "output"), cacheRead: 0, cacheWrite: 0 },
		contextWindow: smallest(sources, (source) => source.input_token_limit, 128000),
		maxTokens: smallest(sources, (source) => source.max_output_tokens, 16384),
		compat: { ...COMPAT },
	};
}

function buildModels(entries: CatalogEntry[]): ProviderModelConfig[] {
	const byName = new Map<string, CatalogEntry[]>();
	for (const entry of entries) {
		if (typeof entry.id !== "string" || entry.owned_by === "alias") continue;
		const key = normalizeName(entry.id);
		const list = byName.get(key);
		if (list) list.push(entry);
		else byName.set(key, [entry]);
	}

	return entries
		.filter((entry) => typeof entry.id === "string")
		.map((entry) =>
			toPiModel(entry, entry.owned_by === "alias" ? (byName.get(normalizeName(entry.id as string)) ?? []) : []),
		)
		.filter((model): model is ProviderModelConfig => model !== undefined);
}

async function fetchCatalog(apiKey: string, signal: AbortSignal): Promise<ProviderModelConfig[]> {
	const response = await fetch(`${BASE_URL}/models`, {
		headers: { Accept: "application/json", Authorization: `Bearer ${apiKey}` },
		signal,
	});
	if (!response.ok) {
		throw new Error(`InferHub model catalog failed: ${response.status} ${await response.text()}`);
	}
	const payload = (await response.json()) as { data?: CatalogEntry[] };
	if (!Array.isArray(payload.data)) throw new Error("InferHub model catalog has no data array");
	return buildModels(payload.data);
}

export default async function (pi: ExtensionAPI) {
	const envKey = process.env.INFERHUB_API_KEY;
	let registry: ProviderModelConfig[] =
		envKey && !process.env.PI_OFFLINE ? await fetchCatalog(envKey, AbortSignal.timeout(5000)).catch(() => []) : [];

	pi.registerProvider("inferhub", {
		name: "InferHub",
		baseUrl: BASE_URL,
		apiKey: "$INFERHUB_API_KEY",
		api: "openai-completions",
		models: registry,
		refreshModels: async (context) => {
			const cached = context.stored?.models.map(({ provider: _provider, ...model }) => model) ?? [];
			const known = cached.length > 0 ? cached : registry;
			if (!context.allowNetwork || context.signal.aborted) return known;

			const apiKey = context.credential?.type === "api_key" ? context.credential.key : undefined;
			if (!apiKey) return known;

			registry = await fetchCatalog(apiKey, context.signal);
			await context.publish({ persist: { models: registry, checkedAt: Date.now() } });
			return registry;
		},
	});
}
