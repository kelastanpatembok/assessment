import { createApiClient } from '$lib/api/index.js';
import { json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';

// Same-origin proxy for certificate persistence. Keeps the httpOnly JWT on
// the server: the backend POST /certificates stores the record under the
// authenticated user's id, so a student can only ever register their own
// certificates. GET lists the current student's certificates.

export const GET: RequestHandler = async ({ locals, url }) => {
  if (!locals.token) return json([], { status: 401 });
  const api = createApiClient(locals.token);
  const list = await api.get('/certificates/mine');
  const test = url.searchParams.get('test');
  const filtered = test
    ? list.filter((c: { testType: string }) => c.testType === test)
    : list;
  return json(filtered);
};

export const POST: RequestHandler = async ({ request, locals }) => {
  if (!locals.token) return json({ error: 'Unauthorized' }, { status: 401 });
  const { testType, storageKey } = (await request.json()) as {
    testType?: string;
    storageKey?: string;
  };
  if (!testType || !storageKey) {
    return json({ error: 'testType dan storageKey wajib diisi' }, { status: 400 });
  }
  const api = createApiClient(locals.token);
  try {
    const view = await api.post('/certificates', { testType, storageKey });
    return json(view);
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Gagal mendaftarkan sertifikat';
    return json({ error: message }, { status: 422 });
  }
};
