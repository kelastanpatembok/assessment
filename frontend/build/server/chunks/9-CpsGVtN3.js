import { c as createApiClient } from './api-DMwaKFMh.js';
import './public-BeDJ_vVj.js';

//#region src/routes/(admin)/admin-dashboard/+page.server.ts
var load = async ({ locals }) => {
	const api = createApiClient(locals.token);
	const [schools, users] = await Promise.allSettled([api.get("/schools"), api.get("/users")]);
	return {
		schoolCount: schools.status === "fulfilled" ? schools.value?.length ?? 0 : 0,
		userCount: users.status === "fulfilled" ? users.value?.length ?? 0 : 0
	};
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	load: load
});

const index = 9;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-BxrEPVvc.js')).default;
const server_id = "src/routes/(admin)/admin-dashboard/+page.server.ts";
const imports = ["_app/immutable/nodes/9.zro-EaOQ.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/D079eXbb.js","_app/immutable/chunks/CWqowtwQ.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=9-CpsGVtN3.js.map
