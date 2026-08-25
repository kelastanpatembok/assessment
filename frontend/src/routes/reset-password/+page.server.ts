import { fail, redirect } from '@sveltejs/kit';
import { PUBLIC_AUTH_URL } from '$env/static/public';
import type { Actions, PageServerLoad } from './$types';

const AUTH_BASE = (PUBLIC_AUTH_URL || 'http://127.0.0.1:1007/api').replace(/\/+$/, '');

export const load: PageServerLoad = ({ url }) => ({ token: url.searchParams.get('token') ?? '' });

export const actions: Actions = {
  default: async ({ request, fetch }) => {
    const form = await request.formData();
    const token = String(form.get('token') ?? '');
    const newPassword = String(form.get('newPassword') ?? '');
    if (!token || newPassword.length < 8) return fail(400, { error: 'Gunakan kata sandi minimal 8 karakter.' });
    try {
      const response = await fetch(`${AUTH_BASE}/auth/reset-password`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ token, newPassword }) });
      if (!response.ok) return fail(400, { error: 'Tautan tidak valid atau sudah kedaluwarsa. Minta tautan baru.' });
    } catch { return fail(500, { error: 'Pengaturan ulang belum dapat diproses. Silakan coba lagi.' }); }
    redirect(303, '/signin');
  }
};
