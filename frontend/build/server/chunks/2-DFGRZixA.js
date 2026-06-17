import { r as requireRole } from './auth-BBTIK97m.js';
import './index-BQZSrJq2.js';
import './index-DBqjc0Yf.js';

//#region src/routes/(admin)/+layout.server.ts
var load = async ({ locals }) => {
	requireRole(locals, "superadmin");
	return { user: locals.user };
};

var _layout_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	load: load
});

const index = 2;
let component_cache;
const component = async () => component_cache ??= (await import('./_layout.svelte-DYDP6vKp.js')).default;
const server_id = "src/routes/(admin)/+layout.server.ts";
const imports = ["_app/immutable/nodes/2.CD-iH_FV.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/D4Y7i6ib.js","_app/immutable/chunks/DW31PRUZ.js","_app/immutable/chunks/xihTtKlq.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _layout_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=2-DFGRZixA.js.map
