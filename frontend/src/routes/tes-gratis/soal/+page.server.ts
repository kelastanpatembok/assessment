import { fail } from '@sveltejs/kit';
import type { Actions } from './$types';

const API_BASE = (process.env.PUBLIC_API_URL || 'http://127.0.0.1:1005/api').replace(/\/+$/, '');

export const actions: Actions = {
  /** Persists the finished quiz to the logged-in user's account. */
  save: async ({ request, locals }) => {
    if (!locals.token) {
      return fail(401, { error: 'Sesi berakhir. Silakan masuk kembali.' });
    }
    const form = await request.formData();
    const answersRaw = (form.get('answers') as string) ?? '';
    let answers: unknown;
    try {
      answers = JSON.parse(answersRaw);
    } catch {
      return fail(400, { error: 'Jawaban tidak ditemukan.' });
    }

    let result: unknown;
    try {
      const res = await fetch(`${API_BASE}/big5/save`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${locals.token}` },
        body: JSON.stringify(answers)
      });
      if (!res.ok) {
        const data = await res.json().catch(() => null);
        throw new Error(data?.message || 'Gagal menyimpan hasil');
      }
      result = await res.json();
    } catch (e) {
      return fail(502, { error: e instanceof Error ? e.message : 'Gagal menyimpan hasil' });
    }

    return result;
  }
};
