import { createApiClient } from '$lib/api/index';
import { fail, redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const check = await api.get('/epps/check').catch(() => null);
  if (check?.completed) redirect(302, '/student-epps/result');
  if (!check?.canTake) return { unavailable: true, assignmentId: null };
  return { unavailable: false, assignmentId: check.assignmentId ?? null };
};

export const actions: Actions = {
  default: async ({ request, locals }) => {
    const data = await request.formData();
    const answers = Array.from(data.entries())
      .map(([key, value]) => {
        const match = /^answer_(\d+)$/.exec(key);
        return match ? { no: Number(match[1]), choice: String(value) } : null;
      })
      .filter((answer): answer is { no: number; choice: string } => answer !== null);
    if (answers.length !== 225) return fail(422, { error: 'Harap jawab seluruh 225 pernyataan EPPS.' });
    const gender = String(data.get('gender') ?? '');
    try {
      await createApiClient(locals.token).post('/epps/submit', {
        assignmentId: Number(data.get('assignmentId') ?? 0), gender, answers
      });
    } catch (error) {
      return fail(422, { error: error instanceof Error ? error.message : 'Gagal mengirim jawaban EPPS.' });
    }
    redirect(302, '/student-epps/result');
  }
};
