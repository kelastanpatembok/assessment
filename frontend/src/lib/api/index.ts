import { PUBLIC_API_URL } from '$env/static/public';

export function createApiClient(token: string | null) {
  const base = PUBLIC_API_URL;
  const headers: Record<string, string> = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  return {
    get: (path: string) => fetch(`${base}${path}`, { headers }).then(r => r.json()),
    post: (path: string, body: unknown) =>
      fetch(`${base}${path}`, { method: 'POST', headers, body: JSON.stringify(body) }).then(r => r.json()),
    put: (path: string, body: unknown) =>
      fetch(`${base}${path}`, { method: 'PUT', headers, body: JSON.stringify(body) }).then(r => r.json()),
    delete: (path: string) =>
      fetch(`${base}${path}`, { method: 'DELETE', headers }).then(r => r.ok),
  };
}
