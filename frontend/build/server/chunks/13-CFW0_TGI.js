import { c as createApiClient } from './api-D-Ap1lTF.js';
import { f as fail } from './index-BQZSrJq2.js';
import './index-DBqjc0Yf.js';

//#region src/routes/(admin)/admin-users/+page.server.ts
var load = async ({ locals }) => {
	const api = createApiClient(locals.token);
	const [users, schools] = await Promise.allSettled([api.get("/users"), api.get("/schools")]);
	return {
		users: users.status === "fulfilled" && Array.isArray(users.value) ? users.value : [],
		schools: schools.status === "fulfilled" && Array.isArray(schools.value) ? schools.value : []
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
			role: data.get("role"),
			schoolId: data.get("schoolId") || null
		};
		const result = await api.post("/users", body);
		if (result?.error) return fail(400, { error: result.error });
		return { success: true };
	},
	delete: async ({ request, locals }) => {
		const api = createApiClient(locals.token);
		const id = (await request.formData()).get("id");
		await api.delete(`/users/${id}`);
		return { success: true };
	}
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	actions: actions,
	load: load
});

const index = 13;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-DNuhmPIJ.js')).default;
const server_id = "src/routes/(admin)/admin-users/+page.server.ts";
const imports = ["_app/immutable/nodes/13.CrTQs9FA.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/DPeSmUG1.js","_app/immutable/chunks/Tkiqu5QU.js","_app/immutable/chunks/Gu88EGLv.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/BF_8UxNX.js","_app/immutable/chunks/BEpGnm7N.js","_app/immutable/chunks/DVhTEUKU.js","_app/immutable/chunks/CNqBn8Bn.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=13-CFW0_TGI.js.map
