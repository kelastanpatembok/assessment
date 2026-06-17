import { a as PUBLIC_AUTH_URL } from './public-BeDJ_vVj.js';
import { f as fail, r as redirect } from './index-BQZSrJq2.js';
import './index-DBqjc0Yf.js';

//#region src/routes/login/+page.server.ts
var load = async ({ locals }) => {
	if (locals.user) redirect(302, "/");
	return {};
};
var actions = { default: async ({ request, cookies }) => {
	const data = await request.formData();
	const username = data.get("username");
	const password = data.get("password");
	if (!username || !password) return fail(400, { error: "Username dan password wajib diisi" });
	let res;
	try {
		console.log("Fetching", `${PUBLIC_AUTH_URL}/auth/login`);
		res = await fetch(`${PUBLIC_AUTH_URL}/auth/login`, {
			method: "POST",
			headers: { "Content-Type": "application/json" },
			body: JSON.stringify({
				username,
				password
			})
		});
	} catch (e) {
		console.error("Fetch error:", e);
		return fail(500, { error: "Terjadi kesalahan sistem" });
	}
	if (!res.ok) return fail(401, { error: "Kredensial tidak valid" });
	const token = (await res.json()).token;
	if (!token) return fail(401, { error: "Kredensial tidak valid" });
	cookies.set("assessment_token", token, {
		httpOnly: true,
		path: "/",
		maxAge: 86400,
		sameSite: "lax"
	});
	redirect(302, "/");
} };

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	actions: actions,
	load: load
});

const index = 31;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-CsU7FZ-m.js')).default;
const server_id = "src/routes/login/+page.server.ts";
const imports = ["_app/immutable/nodes/31.CVT3zHZ8.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/DO4JpYBh.js","_app/immutable/chunks/DW31PRUZ.js","_app/immutable/chunks/qcwd0ctL.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/CWqowtwQ.js","_app/immutable/chunks/s5vJXri2.js","_app/immutable/chunks/BA3ZsZfN.js","_app/immutable/chunks/D079eXbb.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=31-CMlaSWXR.js.map
