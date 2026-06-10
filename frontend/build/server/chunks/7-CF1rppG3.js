import { c as createApiClient } from './api-D-Ap1lTF.js';
import { f as fail } from './index-BQZSrJq2.js';
import './index-DBqjc0Yf.js';

//#region src/routes/(admin)/admin-assignments/+page.server.ts
var load = async ({ locals }) => {
	const api = createApiClient(locals.token);
	const [assignments, schools, categories] = await Promise.allSettled([
		api.get("/test-assignments"),
		api.get("/schools"),
		api.get("/test-categories")
	]);
	return {
		assignments: assignments.status === "fulfilled" && Array.isArray(assignments.value) ? assignments.value : [],
		schools: schools.status === "fulfilled" && Array.isArray(schools.value) ? schools.value : [],
		categories: categories.status === "fulfilled" && Array.isArray(categories.value) ? categories.value : []
	};
};
var actions = {
	create: async ({ request, locals }) => {
		const api = createApiClient(locals.token);
		const data = await request.formData();
		const body = {
			schoolId: data.get("schoolId"),
			categoryId: data.get("categoryId"),
			startDate: data.get("startDate"),
			endDate: data.get("endDate"),
			certificateEnabled: data.get("certificateEnabled") === "on"
		};
		if (!body.schoolId || !body.categoryId) return fail(400, { error: "Sekolah dan kategori wajib dipilih" });
		await api.post("/test-assignments", body);
		return { success: true };
	},
	delete: async ({ request, locals }) => {
		const api = createApiClient(locals.token);
		const data = await request.formData();
		await api.delete(`/test-assignments/${data.get("id")}`);
		return { success: true };
	}
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	actions: actions,
	load: load
});

const index = 7;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-BU3F_Oun.js')).default;
const server_id = "src/routes/(admin)/admin-assignments/+page.server.ts";
const imports = ["_app/immutable/nodes/7.Z4eTqZAN.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/DPeSmUG1.js","_app/immutable/chunks/Tkiqu5QU.js","_app/immutable/chunks/Gu88EGLv.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/BF_8UxNX.js","_app/immutable/chunks/BEpGnm7N.js","_app/immutable/chunks/DVhTEUKU.js","_app/immutable/chunks/CNqBn8Bn.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=7-CF1rppG3.js.map
