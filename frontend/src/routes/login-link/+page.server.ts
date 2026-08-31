import { fail, redirect } from '@sveltejs/kit';
import { PUBLIC_AUTH_URL } from '$env/static/public';
import type { Actions, PageServerLoad } from './$types';

const AUTH_BASE = (PUBLIC_AUTH_URL || 'http://127.0.0.1:1007/api').replace(/\/+$/, '');

export const load: PageServerLoad = async ({ url, cookies, fetch }) => {
  const token = url.searchParams.get('token') ?? '';

  // No token → show the "request a link" form.
  if (!token) return { token: '', sent: false, error: '' };

  // Token present → the user clicked the email link. Confirming mints a fresh
  // session and revokes the old one, then we land the user in the app.
  try {
    const response = await fetch(`${AUTH_BASE}/auth/login-link/confirm`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ token }),
    });
    if (!response.ok) {
      return { token: '', sent: false, error: 'Tautan masuk tidak valid atau sudah kedaluwarsa. Minta tautan baru.' };
    }
    const json = await response.json();
    const newToken: string = json.token;
    if (!newToken) {
      return { token: '', sent: false, error: 'Tautan masuk tidak valid atau sudah kedaluwarsa. Minta tautan baru.' };
    }
    cookies.set('assessment_token', newToken, {
      httpOnly: true,
      path: '/',
      maxAge: 86400,
      sameSite: 'lax',
    });
  } catch {
    return { token: '', sent: false, error: 'Masuk belum dapat diproses. Silakan coba lagi.' };
  }

  redirect(303, '/');
};

export const actions: Actions = {
  default: async ({ request, fetch }) => {
    const email = String((await request.formData()).get('email') ?? '').trim();
    if (!email) return fail(400, { error: 'Masukkan alamat email Anda.' });

    try {
      await fetch(`${AUTH_BASE}/auth/login-link`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email }),
      });
    } catch {
      return fail(500, { error: 'Permintaan belum dapat diproses. Silakan coba lagi.' });
    }

    // Auth intentionally returns the same result for known and unknown emails.
    return { sent: true };
  }
};
