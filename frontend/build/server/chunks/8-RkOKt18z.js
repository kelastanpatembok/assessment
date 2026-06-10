import { c as createApiClient } from './api-D-Ap1lTF.js';
import { f as fail } from './index-BQZSrJq2.js';
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
			price: Number(data.get("price"))
		};
		if (!body.name) return fail(400, { error: "Nama kategori wajib diisi" });
		await api.post("/test-categories", body);
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
const component = async () => component_cache ??= (await import('./_page.svelte-CdPjq3Vl.js')).default;
const server_id = "src/routes/(admin)/admin-categories/+page.server.ts";
const imports = ["_app/immutable/nodes/8.DlHHYdZI.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/DPeSmUG1.js","_app/immutable/chunks/Tkiqu5QU.js","_app/immutable/chunks/Gu88EGLv.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/BF_8UxNX.js","_app/immutable/chunks/CNqBn8Bn.js","_app/immutable/chunks/DVhTEUKU.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=8-RkOKt18z.js.map
