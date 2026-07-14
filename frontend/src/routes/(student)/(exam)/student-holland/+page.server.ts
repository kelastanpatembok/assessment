import { createApiClient } from '$lib/api/index';
import { redirect, fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const check = await api.get('/holland/check').catch(() => null);
  if (!check?.canTake) {
    const hasResult = await api.get('/holland/result/me').then(() => true).catch(() => false);
    if (hasResult) redirect(302, '/student-holland/result');
    return { questions: [], unavailable: true, assignmentId: null };
  }

  const questions = await api.get('/holland/questions').catch(() => []);
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

    // Convert q{questionId}_score form fields to [{questionId, score}]
    const answers: { questionId: number; score: number }[] = [];
    for (const [k, v] of data.entries()) {
      const m = k.match(/^q(\d+)_score$/);
      if (m) answers.push({ questionId: Number(m[1]), score: Number(v) });
    }

    if (answers.length === 0) return fail(422, { error: 'Harap isi semua jawaban' });

    const result = await api.post('/holland/submit', { assignmentId, answers });
    if (result?.code === 'INTERNAL_SERVER_ERROR' || result?.error) {
      return fail(422, { error: result.message ?? result.error ?? 'Gagal mengirim jawaban' });
    }
    redirect(302, '/student-holland/result');
  },
};
