import { c as createApiClient } from './api-D-Ap1lTF.js';
import { f as fail } from './index-BQZSrJq2.js';
import './index-DBqjc0Yf.js';

//#region src/routes/(admin)/admin-students/+page.server.ts
var load = async ({ locals }) => {
	const api = createApiClient(locals.token);
	const [students, schools, categories] = await Promise.allSettled([
		api.get("/students"),
		api.get("/schools"),
		api.get("/test-categories")
	]);
	return {
		students: students.status === "fulfilled" && Array.isArray(students.value) ? students.value : [],
		schools: schools.status === "fulfilled" && Array.isArray(schools.value) ? schools.value : [],
		categories: categories.status === "fulfilled" && Array.isArray(categories.value) ? categories.value : []
	};
};
var actions = {
	create: async ({ request, locals }) => {
		const api = createApiClient(locals.token);
		const data = await request.formData();
		const body = {
			username: data.get("username"),
			email: data.get("email"),
			password: data.get("password"),
			name: data.get("name"),
			schoolId: data.get("schoolId"),
			categoryId: data.get("categoryId")
		};
		const result = await api.post("/students", body);
		if (result?.error) return fail(400, { error: result.error });
		return { success: true };
	},
	delete: async ({ request, locals }) => {
		const api = createApiClient(locals.token);
		const data = await request.formData();
		await api.delete(`/students/${data.get("id")}`);
		return { success: true };
	}
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	actions: actions,
	load: load
});

const index = 12;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-5qexxPLF.js')).default;
const server_id = "src/routes/(admin)/admin-students/+page.server.ts";
const imports = ["_app/immutable/nodes/12.DpgE35_-.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/DPeSmUG1.js","_app/immutable/chunks/Tkiqu5QU.js","_app/immutable/chunks/Gu88EGLv.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/BF_8UxNX.js","_app/immutable/chunks/CNqBn8Bn.js","_app/immutable/chunks/DVhTEUKU.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=12-CfuawpLQ.js.map
