import { c as createApiClient } from './api-DMwaKFMh.js';
import { f as fail, r as redirect } from './index-BQZSrJq2.js';
import './public-BeDJ_vVj.js';
import './index-DBqjc0Yf.js';

//#region src/routes/(student)/student-holland/+page.server.ts
var load = async ({ locals }) => {
	const api = createApiClient(locals.token);
	const check = await api.get("/holland/check").catch(() => null);
	if (!check?.canTake) {
		if (await api.get("/holland/result/me").then(() => true).catch(() => false)) redirect(302, "/student-holland/result");
		return {
			questions: [],
			unavailable: true,
			assignmentId: null
		};
	}
	const questions = await api.get("/holland/questions").catch(() => []);
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
	const answers = [];
	for (const [k, v] of data.entries()) {
		const m = k.match(/^q(\d+)_score$/);
		if (m) answers.push({
			questionId: Number(m[1]),
			score: Number(v)
		});
	}
	if (answers.length === 0) return fail(422, { error: "Harap isi semua jawaban" });
	const result = await api.post("/holland/submit", {
		assignmentId,
		answers
	});
	if (result?.code === "INTERNAL_SERVER_ERROR" || result?.error) return fail(422, { error: result.message ?? result.error ?? "Gagal mengirim jawaban" });
	redirect(302, "/student-holland/result");
} };

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	actions: actions,
	load: load
});

const index = 25;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-Eb4S-tTh.js')).default;
const server_id = "src/routes/(student)/student-holland/+page.server.ts";
const imports = ["_app/immutable/nodes/25.B16hjYvp.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/DO4JpYBh.js","_app/immutable/chunks/DW31PRUZ.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/s5vJXri2.js","_app/immutable/chunks/CWqowtwQ.js","_app/immutable/chunks/BA3ZsZfN.js","_app/immutable/chunks/D079eXbb.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=25-BaTkfhBo.js.map
