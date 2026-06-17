import { c as createApiClient } from './api-DMwaKFMh.js';
import './public-BeDJ_vVj.js';

//#region src/routes/(counselor)/counselor-results/+page.server.ts
var load = async ({ locals, url }) => {
	const api = createApiClient(locals.token);
	const tab = url.searchParams.get("tab") ?? "disc";
	const [disc, holland, papi, cfit, ist] = await Promise.allSettled([
		api.get("/disc/results"),
		api.get("/holland/results"),
		api.get("/papi/results"),
		api.get("/cfit/results"),
		api.get("/ist/results")
	]);
	return {
		tab,
		disc: disc.status === "fulfilled" && Array.isArray(disc.value) ? disc.value : [],
		holland: holland.status === "fulfilled" && Array.isArray(holland.value) ? holland.value : [],
		papi: papi.status === "fulfilled" && Array.isArray(papi.value) ? papi.value : [],
		cfit: cfit.status === "fulfilled" && Array.isArray(cfit.value) ? cfit.value : [],
		ist: ist.status === "fulfilled" && Array.isArray(ist.value) ? ist.value : []
	};
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	load: load
});

const index = 18;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-BZ0A0raf.js')).default;
const server_id = "src/routes/(counselor)/counselor-results/+page.server.ts";
const imports = ["_app/immutable/nodes/18.Dl9EyJhe.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/s5vJXri2.js","_app/immutable/chunks/CWqowtwQ.js","_app/immutable/chunks/BA3ZsZfN.js","_app/immutable/chunks/D079eXbb.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=18-0zTctrD0.js.map
