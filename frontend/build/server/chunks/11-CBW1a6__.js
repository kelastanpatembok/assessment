import { c as createApiClient } from './api-DMwaKFMh.js';
import { f as fail } from './index-BQZSrJq2.js';
import './public-BeDJ_vVj.js';
import './index-DBqjc0Yf.js';

//#region src/routes/(admin)/admin-schools/+page.server.ts
var load = async ({ locals }) => {
	const schools = await createApiClient(locals.token).get("/schools").catch(() => []);
	return { schools: Array.isArray(schools) ? schools : [] };
};
var actions = {
	create: async ({ request, locals }) => {
		const api = createApiClient(locals.token);
		const data = await request.formData();
		const name = data.get("schoolName");
		const address = data.get("address");
		const city = data.get("city");
		const province = data.get("province");
		if (!name) return fail(400, { error: "Nama sekolah wajib diisi" });
		await api.post("/schools", {
			name,
			address,
			city,
			province
		});
		return { success: true };
	},
	update: async ({ request, locals }) => {
		const api = createApiClient(locals.token);
		const data = await request.formData();
		const id = data.get("id");
		const name = data.get("schoolName");
		const address = data.get("address");
		if (!name) return fail(400, { error: "Nama sekolah wajib diisi" });
		await api.put(`/schools/${id}`, {
			name,
			address
		});
		return { success: true };
	},
	delete: async ({ request, locals }) => {
		const api = createApiClient(locals.token);
		const id = (await request.formData()).get("id");
		await api.delete(`/schools/${id}`);
		return { success: true };
	}
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	actions: actions,
	load: load
});

const index = 11;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-wZsWMh7L.js')).default;
const server_id = "src/routes/(admin)/admin-schools/+page.server.ts";
const imports = ["_app/immutable/nodes/11.BqGsofQA.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/DO4JpYBh.js","_app/immutable/chunks/DW31PRUZ.js","_app/immutable/chunks/qcwd0ctL.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/CWqowtwQ.js","_app/immutable/chunks/s5vJXri2.js","_app/immutable/chunks/BA3ZsZfN.js","_app/immutable/chunks/D079eXbb.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=11-CBW1a6__.js.map
