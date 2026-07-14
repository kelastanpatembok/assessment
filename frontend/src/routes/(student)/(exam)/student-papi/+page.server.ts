import { createApiClient } from '$lib/api/index';
import { redirect, fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const check = await api.get('/papi/check').catch(() => null);
  if (check?.completed) {
    redirect(302, '/student-papi/result');
  }
  if (!check?.canTake) {
    const hasResult = await api.get('/papi/result/me').then(() => true).catch(() => false);
    if (hasResult) redirect(302, '/student-papi/result');
    return { pairs: [], unavailable: true, assignmentId: null };
  }

  const questions = await api.get('/papi/questions').catch(() => []);
  const arr = Array.isArray(questions) ? questions : [];

  // Group into pairs: each pair is two consecutive questions (a and b options)
  const pairs: { pairNo: number; stmtA: string; stmtB: string; traitA: string; traitB: string }[] = [];
  for (let i = 0; i < arr.length; i += 2) {
    const a = arr[i];
    const b = arr[i + 1];
    if (a && b) {
      pairs.push({ pairNo: i / 2 + 1, stmtA: a.statement, stmtB: b.statement, traitA: a.trait, traitB: b.trait });
    }
  }

  return { pairs, unavailable: false, assignmentId: check.assignmentId ?? null };
};

export const actions: Actions = {
  default: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();

    const assignmentId = Number(data.get('assignmentId') ?? 0);

    // Each pair: pair_1 = 'A' or 'B' → pairNo + chosenLetter
    const answers: { pairNo: number; chosenLetter: string }[] = [];
    for (const [k, v] of data.entries()) {
      const m = k.match(/^pair_(\d+)$/);
      if (m) answers.push({ pairNo: Number(m[1]), chosenLetter: v as string });
    }

    if (answers.length === 0) return fail(422, { error: 'Harap isi semua pasangan pernyataan' });

    try {
      await api.post('/papi/submit', { assignmentId, answers });
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Gagal mengirim jawaban';
      return fail(422, { error: message });
    }

    redirect(302, '/student-papi/result');
  },
};
