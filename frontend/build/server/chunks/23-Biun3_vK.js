import { c as createApiClient } from './api-DMwaKFMh.js';
import { f as fail, r as redirect } from './index-BQZSrJq2.js';
import './public-BeDJ_vVj.js';
import './index-DBqjc0Yf.js';

//#region src/routes/(student)/student-disc/+page.server.ts
var load = async ({ locals }) => {
	const api = createApiClient(locals.token);
	const check = await api.get("/disc/check").catch(() => null);
	if (!check?.canTake) {
		if (await api.get("/disc/result/me").then(() => true).catch(() => false)) redirect(302, "/student-disc/result");
		return {
			questions: [],
			unavailable: true,
			assignmentId: null
		};
	}
	const questions = await api.get("/disc/questions").catch(() => []);
	return {
		questions: Array.isArray(questions) ? questions : [],
		unavailable: false,
		assignmentId: check.assignmentId ?? null
	};
};
var actions = { default: async ({ request, locals }) => {
	const api = createApiClient(locals.token);
	const data = await request.formData();
	const assignmentId = Number(data.get("assignmentId") ?? 0);
	const blocksMap = /* @__PURE__ */ new Map();
	for (const [k, v] of data.entries()) {
		const mostMatch = k.match(/^b(\d+)_most$/);
		const leastMatch = k.match(/^b(\d+)_least$/);
		if (mostMatch) {
			const bn = Number(mostMatch[1]);
			blocksMap.set(bn, {
				...blocksMap.get(bn) ?? {},
				mostItemNo: Number(v)
			});
		} else if (leastMatch) {
			const bn = Number(leastMatch[1]);
			blocksMap.set(bn, {
				...blocksMap.get(bn) ?? {},
				leastItemNo: Number(v)
			});
		}
	}
	const answers = Array.from(blocksMap.entries()).sort(([a], [b]) => a - b).map(([blockNo, { mostItemNo, leastItemNo }]) => ({
		blockNo,
		mostItemNo,
		leastItemNo
	}));
	if (answers.some((a) => !a.mostItemNo || !a.leastItemNo)) return fail(422, { error: "Harap isi semua pilihan MOST dan LEAST" });
	const result = await api.post("/disc/submit", {
		assignmentId,
		answers
	});
	if (result?.code === "INTERNAL_SERVER_ERROR" || result?.error) return fail(422, { error: result.message ?? result.error ?? "Gagal mengirim jawaban" });
	redirect(302, "/student-disc/result");
} };

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	actions: actions,
	load: load
});

const index = 23;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-PPJxjnJm.js')).default;
const server_id = "src/routes/(student)/student-disc/+page.server.ts";
const imports = ["_app/immutable/nodes/23.EQCj5noo.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/DO4JpYBh.js","_app/immutable/chunks/DW31PRUZ.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/s5vJXri2.js","_app/immutable/chunks/CWqowtwQ.js","_app/immutable/chunks/BA3ZsZfN.js","_app/immutable/chunks/D079eXbb.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=23-Biun3_vK.js.map
