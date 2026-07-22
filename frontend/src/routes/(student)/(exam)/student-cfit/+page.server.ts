import { createApiClient } from '$lib/api/index';
import { redirect, fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const check = await api.get('/cfit/check').catch(() => null);
  if (!check?.canTake) {
    const hasResult = await api.get('/cfit/result/me').then(() => true).catch(() => false);
    if (hasResult) redirect(302, '/student-cfit/result');
    return { subtests: [], unavailable: true, assignmentId: null };
  }

  const questions = await api.get('/cfit/questions').catch(() => []);
  const arr = Array.isArray(questions) ? questions : [];

  const subtestMap: Record<string, any[]> = {};
  for (const q of arr) {
    const st = `tes_${q.subtestNo ?? 1}`;
    if (!subtestMap[st]) subtestMap[st] = [];
    subtestMap[st].push(q);
  }

  const subtests = ['tes_1','tes_2','tes_3','tes_4'].map((k, i) => ({
    key: k,
    label: `Subtes ${i + 1}`,
    subtestNo: i + 1,
    questions: subtestMap[k] ?? [],
  }));

  return { subtests, unavailable: false, assignmentId: check.assignmentId ?? null };
};

export const actions: Actions = {
  default: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();

    const assignmentId = Number(data.get('assignmentId') ?? 0);

    // Parse st{subtestNo}_q{itemNo} (radio, one value) and st{subtestNo}_q{itemNo}[]
    // (Subtest 2 checkboxes, up to two values sharing the same field name) into
    // CfitAnswerDto{subtestNo, itemNo, answers[]} entries.
    const answerMap = new Map<string, { subtestNo: number; itemNo: number; answers: string[] }>();
    for (const [k, v] of data.entries()) {
      const m = k.match(/^st(\d+)_q(\d+)(\[\])?$/);
      if (!m) continue;
      const subtestNo = Number(m[1]);
      const itemNo = Number(m[2]);
      const mapKey = `${subtestNo}_${itemNo}`;
      const entry = answerMap.get(mapKey) ?? { subtestNo, itemNo, answers: [] };
      entry.answers.push(v as string);
      answerMap.set(mapKey, entry);
    }
    const answers = Array.from(answerMap.values());

    if (answers.length === 0) return fail(422, { error: 'Harap isi semua jawaban' });

    try {
      const result = await api.post('/cfit/submit', { assignmentId, answers });
      if (result?.code === 'INTERNAL_SERVER_ERROR' || result?.error) {
        return fail(422, { error: result.message ?? result.error ?? 'Gagal mengirim jawaban' });
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Gagal mengirim jawaban';
      return fail(422, { error: message });
    }
    redirect(302, '/student-cfit/result');
  },
};
