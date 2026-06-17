import { c as createApiClient } from './api-DMwaKFMh.js';
import './public-BeDJ_vVj.js';

//#region src/routes/(student)/student-dashboard/+page.server.ts
var load = async ({ locals }) => {
	const api = createApiClient(locals.token);
	const [disc, holland, papi, cfit, ist] = await Promise.allSettled([
		api.get("/disc/check"),
		api.get("/holland/check"),
		api.get("/papi/check"),
		api.get("/cfit/check"),
		api.get("/ist/check")
	]);
	function resolveStatus(result) {
		if (result.status === "rejected") return {
			available: false,
			completed: false
		};
		const v = result.value;
		if (!v || v.code) return {
			available: false,
			completed: false
		};
		return {
			available: v?.canTake ?? false,
			completed: false
		};
	}
	return { tests: [
		{
			key: "disc",
			label: "DISC",
			href: "/student-disc",
			...resolveStatus(disc)
		},
		{
			key: "holland",
			label: "Holland RIASEC",
			href: "/student-holland",
			...resolveStatus(holland)
		},
		{
			key: "papi",
			label: "PAPI Kostick",
			href: "/student-papi",
			...resolveStatus(papi)
		},
		{
			key: "cfit",
			label: "IQ CFIT",
			href: "/student-cfit",
			...resolveStatus(cfit)
		},
		{
			key: "ist",
			label: "IQ IST",
			href: "/student-ist",
			...resolveStatus(ist)
		}
	] };
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	load: load
});

const index = 22;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-DtSvXTd1.js')).default;
const server_id = "src/routes/(student)/student-dashboard/+page.server.ts";
const imports = ["_app/immutable/nodes/22.DxTBy1TV.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/oRCf_x52.js","_app/immutable/chunks/CWqowtwQ.js","_app/immutable/chunks/BA3ZsZfN.js","_app/immutable/chunks/s5vJXri2.js","_app/immutable/chunks/D079eXbb.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=22-Bt6ks22X.js.map
