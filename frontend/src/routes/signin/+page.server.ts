import { redirect, fail } from '@sveltejs/kit';
import { PUBLIC_AUTH_URL } from '$env/static/public';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals, fetch, cookies }) => {
  if (locals.user && locals.token) {
    // hooks.server.ts can only decode the cookie, not verify its signature, so
    // a stale token (e.g. after a deploy rotated JWT_SECRET) still populates
    // locals.user. Verify against the auth service before trusting it —
    // otherwise a stale cookie bounces users off the login page forever.
    try {
      const res = await fetch(`${PUBLIC_AUTH_URL}/auth/session`, {
        headers: { Authorization: `Bearer ${locals.token}` },
      });
      if (res.ok) redirect(302, '/');
      cookies.delete('assessment_token', { path: '/' });
    } catch {
      // auth unreachable: show the login form rather than redirecting blindly.
    }
  }
  return {};
};

export const actions: Actions = {
  default: async ({ request, cookies }) => {
    const data = await request.formData();
    const username = data.get('username') as string;
    const password = data.get('password') as string;

    if (!username || !password) {
      return fail(400, { error: 'Username dan password wajib diisi' });
    }

    let res;
    try {
      console.log('Fetching', `${PUBLIC_AUTH_URL}/auth/login`);
      res = await fetch(`${PUBLIC_AUTH_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ username, password }),
      });
    } catch (e) {
      console.error('Fetch error:', e);
      return fail(500, { error: 'Terjadi kesalahan sistem' });
    }

    if (!res.ok) {
      if (res.status === 409) {
        return fail(409, {
          error: 'Akun masih aktif di perangkat lain. Keluar terlebih dahulu dari perangkat tersebut.'
        });
      }
      return fail(401, { error: 'Kredensial tidak valid' });
    }

    const json = await res.json();
    const token: string = json.token;
    if (!token) {
      return fail(401, { error: 'Kredensial tidak valid' });
    }

    cookies.set('assessment_token', token, {
      httpOnly: true,
      path: '/',
      maxAge: 86400,
      sameSite: 'lax',
    });

    redirect(302, '/');
  },
};
