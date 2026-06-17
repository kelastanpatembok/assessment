import { c as createApiClient } from './api-DMwaKFMh.js';
import './public-BeDJ_vVj.js';

//#region src/routes/(admin)/credentials/new/+page.server.ts
var load = async ({ locals }) => {
	const api = createApiClient(locals.token);
	const today = (/* @__PURE__ */ new Date()).toISOString().split("T")[0];
	const assignments = await api.get(`/test-assignments?status=aktif&endDate>=${today}`).catch(() => []);
	return { assignments: Array.isArray(assignments) ? assignments : [] };
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	load: load
});

const index = 14;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-FthgtzAf.js')).default;
const server_id = "src/routes/(admin)/credentials/new/+page.server.ts";
const imports = ["_app/immutable/nodes/14.DoF969ny.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/qcwd0ctL.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/CWqowtwQ.js"];
const stylesheets = ["_app/immutable/assets/14.x1XGuNl0.css"];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=14-DQXvHXk9.js.map
