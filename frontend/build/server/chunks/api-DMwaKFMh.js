import { P as PUBLIC_API_URL } from './public-BeDJ_vVj.js';

//#region src/lib/api/index.ts
function createApiClient(token) {
	const base = PUBLIC_API_URL;
	const headers = { "Content-Type": "application/json" };
	if (token) headers["Authorization"] = `Bearer ${token}`;
	return {
		get: (path) => fetch(`${base}${path}`, { headers }).then((r) => r.json()),
		post: (path, body) => fetch(`${base}${path}`, {
			method: "POST",
			headers,
			body: JSON.stringify(body)
		}).then((r) => r.json()),
		put: (path, body) => fetch(`${base}${path}`, {
			method: "PUT",
			headers,
			body: JSON.stringify(body)
		}).then((r) => r.json()),
		delete: (path) => fetch(`${base}${path}`, {
			method: "DELETE",
			headers
		}).then((r) => r.ok)
	};
}

export { createApiClient as c };
//# sourceMappingURL=api-DMwaKFMh.js.map
