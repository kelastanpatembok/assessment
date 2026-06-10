import { c as createApiClient } from './api-D-Ap1lTF.js';

//#region src/routes/(afiliator)/afiliator-dashboard/+page.server.ts
var load = async ({ locals }) => {
	return { fees: await createApiClient(locals.token).get("/fees/me").catch(() => null) };
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	load: load
});

const index = 14;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-CZcnsZwf.js')).default;
const server_id = "src/routes/(afiliator)/afiliator-dashboard/+page.server.ts";
const imports = ["_app/immutable/nodes/14.BGwE9b7W.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/BF_8UxNX.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=14-DJd-i0DD.js.map
