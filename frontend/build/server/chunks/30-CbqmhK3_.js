import { c as createApiClient } from './api-DMwaKFMh.js';
import { r as redirect } from './index-BQZSrJq2.js';
import './public-BeDJ_vVj.js';
import './index-DBqjc0Yf.js';

//#region src/routes/(student)/student-papi/result/+page.server.ts
var load = async ({ locals }) => {
	const result = await createApiClient(locals.token).get("/papi/result/me").catch(() => null);
	if (!result) redirect(302, "/student-papi");
	return { result };
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	load: load
});

const index = 30;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-QGjs0XWR.js')).default;
const server_id = "src/routes/(student)/student-papi/result/+page.server.ts";
const imports = ["_app/immutable/nodes/30.Ce7FmcbG.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/D079eXbb.js","_app/immutable/chunks/CWqowtwQ.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=30-CbqmhK3_.js.map
