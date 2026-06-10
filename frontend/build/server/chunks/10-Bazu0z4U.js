import { c as createApiClient } from './api-D-Ap1lTF.js';

//#region src/routes/(admin)/admin-fees/+page.server.ts
var load = async ({ locals }) => {
	return { config: await createApiClient(locals.token).get("/fee-config").catch(() => null) };
};
var actions = { update: async ({ request, locals }) => {
	const api = createApiClient(locals.token);
	const data = await request.formData();
	const body = {
		price: Number(data.get("price")),
		systemPct: Number(data.get("systemPct")),
		affiliatorPct: Number(data.get("affiliatorPct")),
		counselorPct: Number(data.get("counselorPct"))
	};
	await api.post("/fee-config", body);
	return { success: true };
} };

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	actions: actions,
	load: load
});

const index = 10;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-BEE-d38g.js')).default;
const server_id = "src/routes/(admin)/admin-fees/+page.server.ts";
const imports = ["_app/immutable/nodes/10.CgBH4ZPt.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/DPeSmUG1.js","_app/immutable/chunks/Tkiqu5QU.js","_app/immutable/chunks/Gu88EGLv.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/BF_8UxNX.js","_app/immutable/chunks/CNqBn8Bn.js","_app/immutable/chunks/DVhTEUKU.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=10-Bazu0z4U.js.map
