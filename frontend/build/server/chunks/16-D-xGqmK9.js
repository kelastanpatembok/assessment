import { c as createApiClient } from './api-D-Ap1lTF.js';

//#region src/routes/(counselor)/counselor-dashboard/+page.server.ts
var load = async ({ locals }) => {
	const students = await createApiClient(locals.token).get("/students").catch(() => []);
	return { studentCount: Array.isArray(students) ? students.length : 0 };
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	load: load
});

const index = 16;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-CWP7-9vr.js')).default;
const server_id = "src/routes/(counselor)/counselor-dashboard/+page.server.ts";
const imports = ["_app/immutable/nodes/16.C8c5ke7H.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/BF_8UxNX.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=16-D-xGqmK9.js.map
