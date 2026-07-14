import { createApiClient } from '$lib/api/index';
import { redirect, fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

const SUBTESTS = ['SE','WA','AN','GE','RA','ZR','FA','WU','ME'];

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const check = await api.get('/ist/check').catch(() => null);
  if (!check?.canTake) {
    const hasResult = await api.get('/ist/result/me').then(() => true).catch(() => false);
    if (hasResult) redirect(302, '/student-ist/result');
    return { subtests: [], unavailable: true, assignmentId: null };
  }

  const subtestData = await Promise.allSettled(
    SUBTESTS.map(st => api.get(`/ist/questions?subtest=${st}`).then(q => ({ key: st, questions: q })))
  );

  const subtests = subtestData.map((r, i) => {
    const key = SUBTESTS[i];
    if (r.status === 'rejected' || !Array.isArray(r.value?.questions)) {
      return { key, label: key, questions: [] };
    }
    return { key, label: key, questions: r.value.questions };
  });

  return { subtests, unavailable: false, assignmentId: check.assignmentId ?? null };
};

export const actions: Actions = {
  default: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();

    const assignmentId = Number(data.get('assignmentId') ?? 0);

    // Parse ist_{subtestCode}_{itemNo} fields into IstSubtestAnswers list
    const subtestMap = new Map<string, { itemNo: number; answer: string }[]>();
    for (const [k, v] of data.entries()) {
      const m = k.match(/^ist_([A-Z]{2})_(\d+)$/);
      if (m) {
        const [, code, itemNo] = m;
        if (!subtestMap.has(code)) subtestMap.set(code, []);
        subtestMap.get(code)!.push({ itemNo: Number(itemNo), answer: v as string });
      }
    }

    const subtests = Array.from(subtestMap.entries()).map(([subtestCode, items]) => ({
      subtestCode,
      items: items.sort((a, b) => a.itemNo - b.itemNo),
    }));

    if (subtests.length === 0) return fail(422, { error: 'Harap isi semua jawaban' });

    const result = await api.post('/ist/submit', { assignmentId, subtests });
    if (result?.code === 'INTERNAL_SERVER_ERROR' || result?.error) {
      return fail(422, { error: result.message ?? result.error ?? 'Gagal mengirim jawaban' });
    }
    redirect(302, '/student-ist/result');
  },
};
