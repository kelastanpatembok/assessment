import { c as createApiClient } from './api-DMwaKFMh.js';
import { f as fail } from './index-BQZSrJq2.js';
import './public-BeDJ_vVj.js';
import './index-DBqjc0Yf.js';

//#region src/routes/(admin)/admin-categories/+page.server.ts
var load = async ({ locals }) => {
	const categories = await createApiClient(locals.token).get("/test-categories").catch(() => []);
	return { categories: Array.isArray(categories) ? categories : [] };
};
var actions = {
	create: async ({ request, locals }) => {
		const api = createApiClient(locals.token);
		const data = await request.formData();
		const body = {
			name: data.get("name"),
			slug: data.get("slug"),
			price: Number(data.get("price") || 0),
			tests: data.getAll("tests"),
			active: true
		};
		if (!body.name) return fail(400, { error: "Nama kategori wajib diisi" });
		await api.post("/test-categories", body);
		return { success: true };
	},
	update: async ({ request, locals }) => {
		const api = createApiClient(locals.token);
		const data = await request.formData();
		const id = data.get("id");
		const body = {
			name: data.get("name"),
			slug: data.get("slug"),
			price: Number(data.get("price") || 0),
			tests: data.getAll("tests"),
			active: true
		};
		if (!body.name) return fail(400, { error: "Nama kategori wajib diisi" });
		await api.put(`/test-categories/${id}`, body);
		return { success: true };
	},
	delete: async ({ request, locals }) => {
		const api = createApiClient(locals.token);
		const data = await request.formData();
		await api.delete(`/test-categories/${data.get("id")}`);
		return { success: true };
	}
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	actions: actions,
	load: load
});

const index = 8;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-DJ13iJYi.js')).default;
const server_id = "src/routes/(admin)/admin-categories/+page.server.ts";
const imports = ["_app/immutable/nodes/8.CNQaaNK-.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/DO4JpYBh.js","_app/immutable/chunks/DW31PRUZ.js","_app/immutable/chunks/qcwd0ctL.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/CWqowtwQ.js","_app/immutable/chunks/s5vJXri2.js","_app/immutable/chunks/BA3ZsZfN.js","_app/immutable/chunks/D079eXbb.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=8-BZMEcEj3.js.map
