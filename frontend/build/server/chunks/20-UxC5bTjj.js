import { c as createApiClient } from './api-DMwaKFMh.js';
import { f as fail, r as redirect } from './index-BQZSrJq2.js';
import './public-BeDJ_vVj.js';
import './index-DBqjc0Yf.js';

//#region src/routes/(student)/student-cfit/+page.server.ts
var load = async ({ locals }) => {
	const api = createApiClient(locals.token);
	const check = await api.get("/cfit/check").catch(() => null);
	if (!check?.canTake) {
		if (await api.get("/cfit/result/me").then(() => true).catch(() => false)) redirect(302, "/student-cfit/result");
		return {
			subtests: [],
			unavailable: true,
			assignmentId: null
		};
	}
	const questions = await api.get("/cfit/questions").catch(() => []);
	const arr = Array.isArray(questions) ? questions : [];
	const subtestMap = {};
	for (const q of arr) {
		const st = `tes_${q.subtestNo ?? 1}`;
		if (!subtestMap[st]) subtestMap[st] = [];
		subtestMap[st].push(q);
	}
	return {
		subtests: [
			"tes_1",
			"tes_2",
			"tes_3",
			"tes_4"
		].map((k, i) => ({
			key: k,
			label: `Subtes ${i + 1}`,
			subtestNo: i + 1,
			questions: subtestMap[k] ?? []
		})),
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
		const m = k.match(/^st(\d+)_q(\d+)$/);
		if (m) answers.push({
			subtestNo: Number(m[1]),
			itemNo: Number(m[2]),
			answer: v
		});
	}
	if (answers.length === 0) return fail(422, { error: "Harap isi semua jawaban" });
	const result = await api.post("/cfit/submit", {
		assignmentId,
		answers
	});
	if (result?.code === "INTERNAL_SERVER_ERROR" || result?.error) return fail(422, { error: result.message ?? result.error ?? "Gagal mengirim jawaban" });
	redirect(302, "/student-cfit/result");
} };

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	actions: actions,
	load: load
});

const index = 20;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-pNfnF71P.js')).default;
const server_id = "src/routes/(student)/student-cfit/+page.server.ts";
const imports = ["_app/immutable/nodes/20.DzybOBiw.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/DO4JpYBh.js","_app/immutable/chunks/DW31PRUZ.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/s5vJXri2.js","_app/immutable/chunks/CWqowtwQ.js","_app/immutable/chunks/BA3ZsZfN.js","_app/immutable/chunks/D079eXbb.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=20-UxC5bTjj.js.map
