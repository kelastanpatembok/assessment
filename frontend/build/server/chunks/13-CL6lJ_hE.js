import { c as createApiClient } from './api-DMwaKFMh.js';
import { f as fail } from './index-BQZSrJq2.js';
import './public-BeDJ_vVj.js';
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
	update: async ({ request, locals }) => {
		const api = createApiClient(locals.token);
		const data = await request.formData();
		const id = data.get("id");
		const password = data.get("password");
		const body = {
			name: data.get("name"),
			email: data.get("email"),
			schoolId: data.get("schoolId") ? Number(data.get("schoolId")) : null
		};
		if (password && password.trim()) body.password = password;
		const result = await api.put(`/users/${id}`, body);
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
const component = async () => component_cache ??= (await import('./_page.svelte-4qH5-jfu.js')).default;
const server_id = "src/routes/(admin)/admin-users/+page.server.ts";
const imports = ["_app/immutable/nodes/13.B7zveMWa.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/DO4JpYBh.js","_app/immutable/chunks/DW31PRUZ.js","_app/immutable/chunks/qcwd0ctL.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/CWqowtwQ.js","_app/immutable/chunks/oRCf_x52.js","_app/immutable/chunks/BA3ZsZfN.js","_app/immutable/chunks/s5vJXri2.js","_app/immutable/chunks/D079eXbb.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=13-CL6lJ_hE.js.map
