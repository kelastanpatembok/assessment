import { c as createApiClient } from './api-DMwaKFMh.js';
import { f as fail, r as redirect } from './index-BQZSrJq2.js';
import './public-BeDJ_vVj.js';
import './index-DBqjc0Yf.js';

//#region src/routes/(student)/student-ist/+page.server.ts
var SUBTESTS = [
	"SE",
	"WA",
	"AN",
	"GE",
	"RA",
	"ZR",
	"FA",
	"WU",
	"ME"
];
var load = async ({ locals }) => {
	const api = createApiClient(locals.token);
	const check = await api.get("/ist/check").catch(() => null);
	if (!check?.canTake) {
		if (await api.get("/ist/result/me").then(() => true).catch(() => false)) redirect(302, "/student-ist/result");
		return {
			subtests: [],
			unavailable: true,
			assignmentId: null
		};
	}
	return {
		subtests: (await Promise.allSettled(SUBTESTS.map((st) => api.get(`/ist/questions?subtest=${st}`).then((q) => ({
			key: st,
			questions: q
		}))))).map((r, i) => {
			const key = SUBTESTS[i];
			if (r.status === "rejected" || !Array.isArray(r.value?.questions)) return {
				key,
				label: key,
				questions: []
			};
			return {
				key,
				label: key,
				questions: r.value.questions
			};
		}),
		unavailable: false,
		assignmentId: check.assignmentId ?? null
	};
};
var actions = { default: async ({ request, locals }) => {
	const api = createApiClient(locals.token);
	const data = await request.formData();
	const assignmentId = Number(data.get("assignmentId") ?? 0);
	const subtestMap = /* @__PURE__ */ new Map();
	for (const [k, v] of data.entries()) {
		const m = k.match(/^ist_([A-Z]{2})_(\d+)$/);
		if (m) {
			const [, code, itemNo] = m;
			if (!subtestMap.has(code)) subtestMap.set(code, []);
			subtestMap.get(code).push({
				itemNo: Number(itemNo),
				answer: v
			});
		}
	}
	const subtests = Array.from(subtestMap.entries()).map(([subtestCode, items]) => ({
		subtestCode,
		items: items.sort((a, b) => a.itemNo - b.itemNo)
	}));
	if (subtests.length === 0) return fail(422, { error: "Harap isi semua jawaban" });
	const result = await api.post("/ist/submit", {
		assignmentId,
		subtests
	});
	if (result?.code === "INTERNAL_SERVER_ERROR" || result?.error) return fail(422, { error: result.message ?? result.error ?? "Gagal mengirim jawaban" });
	redirect(302, "/student-ist/result");
} };

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	actions: actions,
	load: load
});

const index = 27;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-DKsgvDQv.js')).default;
const server_id = "src/routes/(student)/student-ist/+page.server.ts";
const imports = ["_app/immutable/nodes/27.BrW2GGLS.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/DO4JpYBh.js","_app/immutable/chunks/DW31PRUZ.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/s5vJXri2.js","_app/immutable/chunks/CWqowtwQ.js","_app/immutable/chunks/BA3ZsZfN.js","_app/immutable/chunks/D079eXbb.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=27-DMT1RihA.js.map
