import { c as createApiClient } from './api-D-Ap1lTF.js';
import { r as redirect } from './index-BQZSrJq2.js';
import './index-DBqjc0Yf.js';

//#region src/routes/(student)/student-holland/result/+page.server.ts
var load = async ({ locals }) => {
	const result = await createApiClient(locals.token).get("/holland/result/me").catch(() => null);
	if (!result) redirect(302, "/student-holland");
	return { result };
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	load: load
});

const index = 25;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-yWa6ieW4.js')).default;
const server_id = "src/routes/(student)/student-holland/result/+page.server.ts";
const imports = ["_app/immutable/nodes/25.8S9xXkXB.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/BF_8UxNX.js","_app/immutable/chunks/BEpGnm7N.js","_app/immutable/chunks/DVhTEUKU.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=25-D7l_h7ue.js.map
