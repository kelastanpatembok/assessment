import { fail, redirect } from '@sveltejs/kit';
import { PUBLIC_AUTH_URL } from '$env/static/public';
import type { Actions, PageServerLoad } from './$types';

const API_BASE = (process.env.PUBLIC_API_URL || 'http://127.0.0.1:1005/api').replace(/\/+$/, '');
const AUTH_BASE = (PUBLIC_AUTH_URL || 'http://127.0.0.1:1007/api').replace(/\/+$/, '');

export const load: PageServerLoad = async ({ locals }) => {
  return { user: locals.user };
};

async function saveResult(token: string, answers: string) {
  const res = await fetch(`${API_BASE}/big5/save`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` },
    body: answers
  });
  if (!res.ok) {
    const data = await res.json().catch(() => null);
    throw new Error(data?.message || 'Gagal menyimpan hasil');
  }
  return res.json();
}

export const actions: Actions = {
  /** Register a new free-user account, then persist the quiz result. */
  register: async ({ request, cookies }) => {
    const form = await request.formData();
    const name = (form.get('name') as string)?.trim() ?? '';
    const email = (form.get('email') as string)?.trim() ?? '';
    const username = (form.get('username') as string)?.trim() ?? '';
    const password = (form.get('password') as string) ?? '';
    const answers = (form.get('answers') as string) ?? '';

    if (!name || !email || !username || !password || !answers) {
      return fail(400, { error: 'Lengkapi seluruh kolom untuk menyimpan hasil.' });
    }
    if (password.length < 6) {
      return fail(400, { error: 'Kata sandi minimal 6 karakter.' });
    }

    let token: string;
    try {
      const params = new URLSearchParams({
        username,
        email,
        password,
        name,
        platformId: 'assessment'
      });
      const res = await fetch(`${AUTH_BASE}/auth/register?${params.toString()}`, { method: 'POST' });
      if (!res.ok) {
        const data = await res.json().catch(() => null);
        throw new Error(data?.message || data?.error || 'Pendaftaran gagal. Username mungkin sudah dipakai.');
      }
      const json = await res.json();
      token = json.token;
    } catch (e) {
      return fail(409, { error: e instanceof Error ? e.message : 'Pendaftaran gagal' });
    }

    try {
      await saveResult(token, answers);
    } catch (e) {
      return fail(500, { error: e instanceof Error ? e.message : 'Hasil gagal disimpan' });
    }

    cookies.set('assessment_token', token, {
      httpOnly: true,
      path: '/',
      maxAge: 86400,
      sameSite: 'lax'
    });

    redirect(302, '/tes-gratis/hasil?saved=1');
  },

  /** Persist the result for an already-logged-in user. */
  save: async ({ request, locals }) => {
    if (!locals.token) {
      return fail(401, { error: 'Silakan masuk terlebih dahulu.' });
    }
    const form = await request.formData();
    const answers = (form.get('answers') as string) ?? '';
    if (!answers) {
      return fail(400, { error: 'Jawaban tidak ditemukan.' });
    }
    try {
      await saveResult(locals.token, answers);
    } catch (e) {
      return fail(500, { error: e instanceof Error ? e.message : 'Hasil gagal disimpan' });
    }
    redirect(302, '/tes-gratis/hasil?saved=1');
  }
};
