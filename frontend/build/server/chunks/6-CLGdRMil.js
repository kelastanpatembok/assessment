import { r as redirect } from './index-BQZSrJq2.js';
import './index-DBqjc0Yf.js';

//#region src/routes/+page.server.ts
var load = async ({ locals }) => {
	if (!locals.user) redirect(302, "/login");
	const role = locals.user.role;
	if (role === "superadmin") redirect(302, "/admin-dashboard");
	if (role === "gurubk") redirect(302, "/counselor-dashboard");
	if (role === "afiliator") redirect(302, "/afiliator-dashboard");
	if (role === "siswa") redirect(302, "/student-dashboard");
	redirect(302, "/login");
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	load: load
});

const index = 6;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-BP2EdQl3.js')).default;
const server_id = "src/routes/+page.server.ts";
const imports = ["_app/immutable/nodes/6.vjNvf7Gx.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/xihTtKlq.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=6-CLGdRMil.js.map
