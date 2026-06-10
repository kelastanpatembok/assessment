//#region src/lib/api/index.ts
function createApiClient(token) {
	const base = "http://localhost:2002/api";
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
//# sourceMappingURL=api-D-Ap1lTF.js.map
