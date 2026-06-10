import { r as redirect } from './index-BQZSrJq2.js';

//#region src/lib/server/auth.ts
function requireRole(locals, ...roles) {
	if (!locals.user) redirect(302, "/login");
	if (!roles.includes(locals.user.role)) redirect(302, "/login");
}

export { requireRole as r };
//# sourceMappingURL=auth-BBTIK97m.js.map
