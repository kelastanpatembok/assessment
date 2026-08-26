import type { RequestHandler } from '@sveltejs/kit';
import { json } from '@sveltejs/kit';
import { env } from '$env/dynamic/public';
import { PUBLIC_API_URL } from '$env/static/public';

const BACKEND = PUBLIC_API_URL || env.PUBLIC_API_URL || 'http://localhost:2002/api';

export const POST: RequestHandler = async ({ request }) => {
  const body = await request.json().catch(() => ({}));
  const res = await fetch(`${BACKEND}/registrations`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });

  const data = await res.json().catch(() => ({ message: 'Gagal memproses pendaftaran.' }));
  return json(data, { status: res.status });
};
