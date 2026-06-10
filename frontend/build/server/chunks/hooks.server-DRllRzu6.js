//#region src/hooks.server.ts
function decodeJwtPayload(token) {
	try {
		const parts = token.split(".");
		if (parts.length !== 3) return null;
		const payload = parts[1].replace(/-/g, "+").replace(/_/g, "/");
		const padded = payload + "=".repeat((4 - payload.length % 4) % 4);
		const decoded = atob(padded);
		return JSON.parse(decoded);
	} catch {
		return null;
	}
}
var handle = async ({ event, resolve }) => {
	const token = event.cookies.get("assessment_token") ?? null;
	event.locals.user = null;
	event.locals.token = null;
	if (token) {
		const payload = decodeJwtPayload(token);
		if (payload) {
			const exp = payload["exp"];
			if (!exp || exp * 1e3 > Date.now()) {
				const userId = payload["sub"];
				const username = payload["username"];
				const role = payload["role"];
				if (userId && username && role) {
					event.locals.user = {
						userId,
						username,
						role
					};
					event.locals.token = token;
				}
			} else event.cookies.delete("assessment_token", { path: "/" });
		}
	}
	return resolve(event);
};

export { handle };
//# sourceMappingURL=hooks.server-DRllRzu6.js.map
