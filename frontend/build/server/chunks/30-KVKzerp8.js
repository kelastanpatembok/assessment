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
	const res = await fetch("http://localhost:2000/api/auth/login", {
		method: "POST",
		headers: { "Content-Type": "application/json" },
		body: JSON.stringify({
			username,
			password
		})
	});
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

const index = 30;
let component_cache;
const component = async () => component_cache ??= (await import('./_page.svelte-DT-jGo46.js')).default;
const server_id = "src/routes/login/+page.server.ts";
const imports = ["_app/immutable/nodes/30.BfiE4z6W.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/DPeSmUG1.js","_app/immutable/chunks/Tkiqu5QU.js","_app/immutable/chunks/Gu88EGLv.js","_app/immutable/chunks/xihTtKlq.js","_app/immutable/chunks/BF_8UxNX.js","_app/immutable/chunks/CNqBn8Bn.js","_app/immutable/chunks/DVhTEUKU.js"];
const stylesheets = [];
const fonts = [];

export { component, fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=30-KVKzerp8.js.map
