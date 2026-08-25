import { fail } from '@sveltejs/kit';
import { PUBLIC_AUTH_URL } from '$env/static/public';
import type { Actions } from './$types';

const AUTH_BASE = (PUBLIC_AUTH_URL || 'http://127.0.0.1:1007/api').replace(/\/+$/, '');

export const actions: Actions = {
  default: async ({ request, fetch }) => {
    const email = String((await request.formData()).get('email') ?? '').trim();
    if (!email) return fail(400, { error: 'Masukkan alamat email Anda.' });

    try {
      await fetch(`${AUTH_BASE}/auth/forgot-password`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email })
      });
    } catch {
      return fail(500, { error: 'Permintaan belum dapat diproses. Silakan coba lagi.' });
    }

    // Auth intentionally returns the same result for known and unknown emails.
    return { sent: true };
  }
};
