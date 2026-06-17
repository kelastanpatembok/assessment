import { r as redirect } from './index-BQZSrJq2.js';
import './index-DBqjc0Yf.js';

//#region src/routes/logout/+page.server.ts
var load = async ({ cookies }) => {
	cookies.delete("assessment_token", { path: "/" });
	redirect(302, "/login");
};

var _page_server_ts = /*#__PURE__*/Object.freeze({
	__proto__: null,
	load: load
});

const index = 32;
const server_id = "src/routes/logout/+page.server.ts";
const imports = [];
const stylesheets = [];
const fonts = [];

export { fonts, imports, index, _page_server_ts as server, server_id, stylesheets };
//# sourceMappingURL=32-BW5MxT0N.js.map
