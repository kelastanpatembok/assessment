import { c as createApiClient } from './api-DMwaKFMh.js';
import './public-BeDJ_vVj.js';

//#region src/routes/(admin)/admin-fees/+page.server.ts
var load = async ({ locals }) => {
	const configs = await createApiClient(locals.token).get("/fees/config").catch(() => []);
	return { config: Array.isArray(configs) ? configs[0] ?? null : null };
};
var actions = { update: async ({ request, locals }) => {
	const api = createApiClient(locals.token);
	const data = await request.formData();
	const body = {
		studentFee: Number(data.get("studentFee")),
		afiliatorSharePct: Number(data.get("afiliatorSharePct")),
		gurubkSharePct: Number(data.get("gurubkSharePct")),
		platformSharePct: Number(data.get("platformSharePct"))
	};
	await api.put("/fees/config", body);
	return { success: true };
} };

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	actions: actions,
	load: load
});

const index = 10;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-DTAC5cBV.js')).default;
const server_id = "src/routes/(admin)/admin-fees/+page.server.ts";
const imports = ["_app/immutable/nodes/10.CggWfmzV.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/DO4JpYBh.js","_app/immutable/chunks/DW31PRUZ.js","_app/immutable/chunks/qcwd0ctL.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/CWqowtwQ.js","_app/immutable/chunks/s5vJXri2.js","_app/immutable/chunks/BA3ZsZfN.js","_app/immutable/chunks/D079eXbb.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=10-VqnmfAHc.js.map
