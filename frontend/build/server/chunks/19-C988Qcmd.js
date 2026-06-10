import { c as createApiClient } from './api-D-Ap1lTF.js';
import { f as fail, r as redirect } from './index-BQZSrJq2.js';
import './index-DBqjc0Yf.js';

//#region src/routes/(student)/student-cfit/+page.server.ts
var load = async ({ locals }) => {
	const api = createApiClient(locals.token);
	const check = await api.get("/cfit/assignment-check").catch(() => null);
	if (check?.completed) redirect(302, "/student-cfit/result");
	if (!check?.available) return {
		subtests: [],
		unavailable: true
	};
	const questions = await api.get("/cfit/questions").catch(() => []);
	const arr = Array.isArray(questions) ? questions : [];
	const subtestMap = {};
	for (const q of arr) {
		const st = q.subtest ?? "tes_1";
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
			questions: subtestMap[k] ?? []
		})),
		unavailable: false
	};
};
var actions = { default: async ({ request, locals }) => {
	const api = createApiClient(locals.token);
	const data = await request.formData();
	const answers = {};
	for (const [k, v] of data.entries()) answers[k] = v;
	const result = await api.post("/cfit/submit", { answers });
	if (result?.error) return fail(422, { error: result.error });
	redirect(302, "/student-cfit/result");
} };

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	actions: actions,
	load: load
});

const index = 19;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-Bk4Ewzpn.js')).default;
const server_id = "src/routes/(student)/student-cfit/+page.server.ts";
const imports = ["_app/immutable/nodes/19.B6aQkanI.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/DPeSmUG1.js","_app/immutable/chunks/Tkiqu5QU.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/BF_8UxNX.js","_app/immutable/chunks/CNqBn8Bn.js","_app/immutable/chunks/DVhTEUKU.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=19-C988Qcmd.js.map
