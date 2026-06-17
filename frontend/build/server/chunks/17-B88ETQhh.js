import { c as createApiClient } from './api-DMwaKFMh.js';
import './public-BeDJ_vVj.js';

//#region src/routes/(counselor)/counselor-dashboard/+page.server.ts
var load = async ({ locals }) => {
	return { summary: await createApiClient(locals.token).get("/dashboard/summary") };
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	load: load
});

const index = 17;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-CNC0kAYt.js')).default;
const server_id = "src/routes/(counselor)/counselor-dashboard/+page.server.ts";
const imports = ["_app/immutable/nodes/17.CDriSKNH.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/D079eXbb.js","_app/immutable/chunks/CWqowtwQ.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=17-B88ETQhh.js.map
