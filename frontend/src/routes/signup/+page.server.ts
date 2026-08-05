import { fail, redirect } from '@sveltejs/kit';
import { PUBLIC_AUTH_URL } from '$env/static/public';
import type { Actions, PageServerLoad } from './$types';

const AUTH_BASE = (PUBLIC_AUTH_URL || 'http://127.0.0.1:1007/api').replace(/\/+$/, '');

export const load: PageServerLoad = async ({ locals }) => {
  if (locals.user) redirect(302, '/tes-gratis');
  return {};
};

export const actions: Actions = {
  default: async ({ request, cookies }) => {
    const form = await request.formData();
    const name = (form.get('name') as string)?.trim() ?? '';
    const email = (form.get('email') as string)?.trim() ?? '';
    const password = (form.get('password') as string) ?? '';

    if (!name || !email || !password) {
      return fail(400, { error: 'Lengkapi seluruh kolom yang wajib diisi.' });
    }
    if (password.length < 6) {
      return fail(400, { error: 'Kata sandi minimal 6 karakter.' });
    }

    // No separate username: the account username is the email address itself.
    let token: string;
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
      token = (await res.json()).token;
    } catch (e) {
      return fail(409, { error: e instanceof Error ? e.message : 'Pendaftaran gagal' });
    }
    if (!token) {
      return fail(409, { error: 'Pendaftaran gagal. Silakan coba lagi.' });
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
