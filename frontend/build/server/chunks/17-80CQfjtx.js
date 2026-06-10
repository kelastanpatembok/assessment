import { c as createApiClient } from './api-D-Ap1lTF.js';

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

const index = 17;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-DvHcNyAG.js')).default;
const server_id = "src/routes/(counselor)/counselor-results/+page.server.ts";
const imports = ["_app/immutable/nodes/17.ByWMJD_n.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/BF_8UxNX.js","_app/immutable/chunks/CNqBn8Bn.js","_app/immutable/chunks/DVhTEUKU.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=17-80CQfjtx.js.map
