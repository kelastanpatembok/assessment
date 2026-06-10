import { c as createApiClient } from './api-D-Ap1lTF.js';
import { f as fail, r as redirect } from './index-BQZSrJq2.js';
import './index-DBqjc0Yf.js';

//#region src/routes/(student)/student-papi/+page.server.ts
var load = async ({ locals }) => {
	const api = createApiClient(locals.token);
	const check = await api.get("/papi/assignment-check").catch(() => null);
	if (check?.completed) redirect(302, "/student-papi/result");
	if (!check?.available) return {
		pairs: [],
		unavailable: true
	};
	const questions = await api.get("/papi/questions").catch(() => []);
	const arr = Array.isArray(questions) ? questions : [];
	const pairs = [];
	for (let i = 0; i < arr.length; i += 2) {
		const a = arr[i];
		const b = arr[i + 1];
		if (a && b) pairs.push({
			id: `pair_${i / 2 + 1}`,
			stmtA: a.statement,
			stmtB: b.statement,
			traitA: a.trait,
			traitB: b.trait
		});
	}
	return {
		pairs,
		unavailable: false
	};
};
var actions = { default: async ({ request, locals }) => {
	const api = createApiClient(locals.token);
	const data = await request.formData();
	const answers = {};
	for (const [k, v] of data.entries()) answers[k] = v;
	const result = await api.post("/papi/submit", { answers });
	if (result?.error) return fail(422, { error: result.error });
	redirect(302, "/student-papi/result");
} };

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	actions: actions,
	load: load
});

const index = 28;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-DQg7hOOO.js')).default;
const server_id = "src/routes/(student)/student-papi/+page.server.ts";
const imports = ["_app/immutable/nodes/28.BGQ11YuS.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/DPeSmUG1.js","_app/immutable/chunks/Tkiqu5QU.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/BF_8UxNX.js","_app/immutable/chunks/CNqBn8Bn.js","_app/immutable/chunks/DVhTEUKU.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=28-DxRg5QCI.js.map
