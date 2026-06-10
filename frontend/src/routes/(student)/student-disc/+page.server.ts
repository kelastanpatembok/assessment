import { createApiClient } from '$lib/api/index';
import { redirect, fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);

  const check = await api.get('/disc/check').catch(() => null);
  if (!check?.canTake) {
    const hasResult = await api.get('/disc/result/me').then(() => true).catch(() => false);
    if (hasResult) redirect(302, '/student-disc/result');
    return { questions: [], unavailable: true, assignmentId: null };
  }

  const questions = await api.get('/disc/questions').catch(() => []);
  return {
    questions: Array.isArray(questions) ? questions : [],
    unavailable: false,
    assignmentId: check.assignmentId ?? null,
  };
};

export const actions: Actions = {
  default: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();

    const assignmentId = Number(data.get('assignmentId') ?? 0);

    // Parse b{blockNo}_most and b{blockNo}_least entries into DiscAnswerDto list
    const blocksMap = new Map<number, { mostItemNo?: number; leastItemNo?: number }>();
    for (const [k, v] of data.entries()) {
      const mostMatch = k.match(/^b(\d+)_most$/);
      const leastMatch = k.match(/^b(\d+)_least$/);
      if (mostMatch) {
        const bn = Number(mostMatch[1]);
        blocksMap.set(bn, { ...(blocksMap.get(bn) ?? {}), mostItemNo: Number(v) });
      } else if (leastMatch) {
        const bn = Number(leastMatch[1]);
        blocksMap.set(bn, { ...(blocksMap.get(bn) ?? {}), leastItemNo: Number(v) });
      }
    }

    const answers = Array.from(blocksMap.entries())
      .sort(([a], [b]) => a - b)
      .map(([blockNo, { mostItemNo, leastItemNo }]) => ({ blockNo, mostItemNo, leastItemNo }));

    if (answers.some(a => !a.mostItemNo || !a.leastItemNo)) {
      return fail(422, { error: 'Harap isi semua pilihan MOST dan LEAST' });
    }

    const result = await api.post('/disc/submit', { assignmentId, answers });
    if (result?.code === 'INTERNAL_SERVER_ERROR' || result?.error) {
      return fail(422, { error: result.message ?? result.error ?? 'Gagal mengirim jawaban' });
    }
    redirect(302, '/student-disc/result');
  },
};
