import { c as createApiClient } from './api-DMwaKFMh.js';
import './public-BeDJ_vVj.js';

//#region src/routes/(afiliator)/afiliator-dashboard/+page.server.ts
var load = async ({ locals }) => {
	return { fees: await createApiClient(locals.token).get("/fees/my").catch(() => null) };
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	load: load
});

const index = 15;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-CQdT977V.js')).default;
const server_id = "src/routes/(afiliator)/afiliator-dashboard/+page.server.ts";
const imports = ["_app/immutable/nodes/15.CCH-4S86.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/D079eXbb.js","_app/immutable/chunks/CWqowtwQ.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=15-DlJXJrB0.js.map
