import { c as createApiClient } from './api-D-Ap1lTF.js';

//#region src/routes/(afiliator)/afiliator-fees/+page.server.ts
var load = async ({ locals }) => {
	const fees = await createApiClient(locals.token).get("/fees/me").catch(() => []);
	return { fees: Array.isArray(fees) ? fees : [] };
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	load: load
});

const index = 15;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-CXiYUuqt.js')).default;
const server_id = "src/routes/(afiliator)/afiliator-fees/+page.server.ts";
const imports = ["_app/immutable/nodes/15.BxJr5LPV.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/BF_8UxNX.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=15-D7_oxmDz.js.map
