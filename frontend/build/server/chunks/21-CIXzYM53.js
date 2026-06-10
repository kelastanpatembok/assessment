import { c as createApiClient } from './api-D-Ap1lTF.js';

//#region src/routes/(student)/student-dashboard/+page.server.ts
var load = async ({ locals }) => {
	const api = createApiClient(locals.token);
	const [disc, holland, papi, cfit, ist] = await Promise.allSettled([
		api.get("/disc/assignment-check"),
		api.get("/holland/assignment-check"),
		api.get("/papi/assignment-check"),
		api.get("/cfit/assignment-check"),
		api.get("/ist/assignment-check")
	]);
	function resolveStatus(result) {
		if (result.status === "rejected") return {
			available: false,
			completed: false
		};
		const v = result.value;
		return {
			available: v?.available ?? false,
			completed: v?.completed ?? false
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

const index = 21;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-DQDFUXjF.js')).default;
const server_id = "src/routes/(student)/student-dashboard/+page.server.ts";
const imports = ["_app/immutable/nodes/21.duw1ZjdX.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/BF_8UxNX.js","_app/immutable/chunks/BEpGnm7N.js","_app/immutable/chunks/DVhTEUKU.js","_app/immutable/chunks/CNqBn8Bn.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=21-CIXzYM53.js.map
