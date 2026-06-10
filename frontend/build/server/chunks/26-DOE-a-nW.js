import { c as createApiClient } from './api-D-Ap1lTF.js';
import { f as fail, r as redirect } from './index-BQZSrJq2.js';
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
	const check = await api.get("/ist/assignment-check").catch(() => null);
	if (check?.completed) redirect(302, "/student-ist/result");
	if (!check?.available) return {
		subtests: [],
		unavailable: true
	};
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
		unavailable: false
	};
};
var actions = { default: async ({ request, locals }) => {
	const api = createApiClient(locals.token);
	const data = await request.formData();
	const answers = {};
	for (const [k, v] of data.entries()) answers[k] = v;
	const result = await api.post("/ist/submit", { answers });
	if (result?.error) return fail(422, { error: result.error });
	redirect(302, "/student-ist/result");
} };

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	actions: actions,
	load: load
});

const index = 26;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-DGg5hWSc.js')).default;
const server_id = "src/routes/(student)/student-ist/+page.server.ts";
const imports = ["_app/immutable/nodes/26.LGYFI9WA.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/DPeSmUG1.js","_app/immutable/chunks/Tkiqu5QU.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/BF_8UxNX.js","_app/immutable/chunks/CNqBn8Bn.js","_app/immutable/chunks/DVhTEUKU.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=26-DOE-a-nW.js.map
