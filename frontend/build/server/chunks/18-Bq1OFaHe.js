import { c as createApiClient } from './api-D-Ap1lTF.js';
import { f as fail } from './index-BQZSrJq2.js';
import './index-DBqjc0Yf.js';

//#region src/routes/(counselor)/counselor-students/+page.server.ts
var load = async ({ locals }) => {
	const students = await createApiClient(locals.token).get("/students").catch(() => []);
	return { students: Array.isArray(students) ? students : [] };
};
var actions = {
	create: async ({ request, locals }) => {
		const api = createApiClient(locals.token);
		const data = await request.formData();
		const body = {
			username: data.get("username"),
			email: data.get("email"),
			password: data.get("password"),
			name: data.get("name")
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

const index = 18;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-Fk5knA3b.js')).default;
const server_id = "src/routes/(counselor)/counselor-students/+page.server.ts";
const imports = ["_app/immutable/nodes/18.CF5Z4tNV.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/DPeSmUG1.js","_app/immutable/chunks/Tkiqu5QU.js","_app/immutable/chunks/Gu88EGLv.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/BF_8UxNX.js","_app/immutable/chunks/CNqBn8Bn.js","_app/immutable/chunks/DVhTEUKU.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=18-Bq1OFaHe.js.map
