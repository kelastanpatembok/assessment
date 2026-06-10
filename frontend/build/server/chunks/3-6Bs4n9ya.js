import { r as requireRole } from './auth-BBTIK97m.js';
import './index-BQZSrJq2.js';
import './index-DBqjc0Yf.js';

//#region src/routes/(afiliator)/+layout.server.ts
var load = async ({ locals }) => {
	requireRole(locals, "afiliator", "superadmin");
	return { user: locals.user };
};

var _layout_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	load: load
});

const index = 3;
let component_cache;
const component = async () => component_cache ??= (await import('./_layout.svelte-DFa1PB5I.js')).default;
const server_id = "src/routes/(afiliator)/+layout.server.ts";
const imports = ["_app/immutable/nodes/3.Zdfz-LXA.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/CiDCULce.js","_app/immutable/chunks/Tkiqu5QU.js","_app/immutable/chunks/xihTtKlq.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _layout_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=3-6Bs4n9ya.js.map
