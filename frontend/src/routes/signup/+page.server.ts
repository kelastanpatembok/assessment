import { fail, redirect } from '@sveltejs/kit';
import { PUBLIC_AUTH_URL, PUBLIC_PROFILE_URL } from '$env/static/public';
import type { Actions, PageServerLoad } from './$types';

const AUTH_BASE = (PUBLIC_AUTH_URL || 'http://127.0.0.1:1007/api').replace(/\/+$/, '');
const PROFILE_BASE = (PUBLIC_PROFILE_URL || 'http://127.0.0.1:1008/api').replace(/\/+$/, '');

export const load: PageServerLoad = async ({ locals, fetch, cookies }) => {
  if (locals.user && locals.token) {
    // Same as signin: hooks can only decode the cookie, not verify the
    // signature — verify against the auth service so a stale token (post-deploy
    // JWT rotation) can't bounce users off the signup page forever.
    try {
      const res = await fetch(`${AUTH_BASE}/auth/session`, {
        headers: { Authorization: `Bearer ${locals.token}` },
      });
      if (res.ok) redirect(302, '/tes-gratis');
      cookies.delete('assessment_token', { path: '/' });
    } catch {
      // auth unreachable: show the signup form rather than redirecting blindly.
    }
  }
  return {};
};

export const actions: Actions = {
  default: async ({ request, cookies }) => {
    const form = await request.formData();
    const name = (form.get('name') as string)?.trim() ?? '';
    const email = (form.get('email') as string)?.trim() ?? '';
    const password = (form.get('password') as string) ?? '';
    const agree = (form.get('agree') as string) ?? '';

    if (!name || !email || !password) {
      return fail(400, { error: 'Lengkapi seluruh kolom yang wajib diisi.' });
    }
    if (password.length < 6) {
      return fail(400, { error: 'Kata sandi minimal 6 karakter.' });
    }
    if (agree !== 'yes') {
      return fail(400, { error: 'Anda harus menyetujui Syarat & Ketentuan untuk mendaftar.' });
    }

    // No separate username: the account username is the email address itself.
    let token: string;
    let userId: string;
    try {
      const params = new URLSearchParams({
        username: email,
        email,
        password,
        name,
        platformId: 'assessment'
      });
      const res = await fetch(`${AUTH_BASE}/auth/register?${params.toString()}`, { method: 'POST' });
      if (!res.ok) {
        const data = await res.json().catch(() => null);
        throw new Error(
          data?.message || data?.error || 'Pendaftaran gagal. Username atau email mungkin sudah dipakai.'
        );
      }
      const json = await res.json();
      token = json.token;
      userId = json.user?.id;
    } catch (e) {
      return fail(409, { error: e instanceof Error ? e.message : 'Pendaftaran gagal' });
    }
    if (!token || !userId) {
      return fail(409, { error: 'Pendaftaran gagal. Silakan coba lagi.' });
    }

    // Persist the profile part (name) into the reusable `profile` domain,
    // mirroring how the profile page updates a user. Best-effort: the profile
    // domain also hydrates identity from auth on read, so a failed write here
    // must not block account creation.
    try {
      await fetch(`${PROFILE_BASE}/users/${encodeURIComponent(userId)}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
        body: JSON.stringify({ name })
      });
    } catch {
      // ignored — profile hydrates from auth lazily
    }

    cookies.set('assessment_token', token, {
      httpOnly: true,
      path: '/',
      maxAge: 86400,
      sameSite: 'lax'
    });

    redirect(302, '/tes-gratis');
  }
};
