import { c as createApiClient } from './api-DMwaKFMh.js';
import { f as fail } from './index-BQZSrJq2.js';
import './public-BeDJ_vVj.js';
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

const index = 19;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-C09Q-bEM.js')).default;
const server_id = "src/routes/(counselor)/counselor-students/+page.server.ts";
const imports = ["_app/immutable/nodes/19.AvQLnTVo.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/DO4JpYBh.js","_app/immutable/chunks/DW31PRUZ.js","_app/immutable/chunks/qcwd0ctL.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/CWqowtwQ.js","_app/immutable/chunks/s5vJXri2.js","_app/immutable/chunks/BA3ZsZfN.js","_app/immutable/chunks/D079eXbb.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=19-E7KxJpT-.js.map
