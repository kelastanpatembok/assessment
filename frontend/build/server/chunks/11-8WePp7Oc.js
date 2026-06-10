import { c as createApiClient } from './api-D-Ap1lTF.js';
import { f as fail } from './index-BQZSrJq2.js';
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
		const schoolName = data.get("schoolName");
		const address = data.get("address");
		if (!schoolName) return fail(400, { error: "Nama sekolah wajib diisi" });
		await api.post("/schools", {
			schoolName,
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
const component = async () => component_cache ??= (await import('./_page.svelte-BAuHmyMc.js')).default;
const server_id = "src/routes/(admin)/admin-schools/+page.server.ts";
const imports = ["_app/immutable/nodes/11.DtEeupLG.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/DPeSmUG1.js","_app/immutable/chunks/Tkiqu5QU.js","_app/immutable/chunks/Gu88EGLv.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/BF_8UxNX.js","_app/immutable/chunks/CNqBn8Bn.js","_app/immutable/chunks/DVhTEUKU.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=11-8WePp7Oc.js.map
