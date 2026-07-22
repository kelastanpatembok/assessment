import { createApiClient } from '$lib/api/index';
import { fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);

  const [disc, holland, papi, cfit, ist] = await Promise.allSettled([
    api.get('/disc/check'),
    api.get('/holland/check'),
    api.get('/papi/check'),
    api.get('/cfit/check'),
    api.get('/ist/check'),
  ]);

  function resolveStatus(result: PromiseSettledResult<any>) {
    if (result.status === 'rejected') return { available: false, completed: false, windowStart: null, windowEnd: null };
    const v = result.value;
    if (!v || v.code) return { available: false, completed: false, windowStart: null, windowEnd: null };
    return {
      available: v?.canTake ?? false,
      completed: v?.completed ?? false,
      windowStart: v?.windowStart ?? null,
      windowEnd: v?.windowEnd ?? null,
    };
  }

  return {
    tests: [
      { key: 'disc', label: 'DISC', href: '/student-disc', ...resolveStatus(disc) },
      { key: 'holland', label: 'Holland RIASEC', href: '/student-holland', ...resolveStatus(holland) },
      { key: 'papi', label: 'PAPI Kostick', href: '/student-papi', ...resolveStatus(papi) },
      { key: 'cfit', label: 'IQ CFIT', href: '/student-cfit', ...resolveStatus(cfit) },
      { key: 'ist', label: 'IQ IST', href: '/student-ist', ...resolveStatus(ist) },
    ],
  };
};

export const actions: Actions = {
  // Dev-only (button is hidden outside dev mode; backend also gates this
  // behind app.dev-tools-enabled) — clears the caller's own result for one
  // instrument so it can be retaken while testing.
  clear: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const testKey = data.get('testKey');
    if (typeof testKey !== 'string') return fail(400, { error: 'Missing testKey' });

    try {
      await api.delete(`/dev/results/${testKey}`);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Gagal menghapus hasil';
      return fail(422, { error: message });
    }
    return { cleared: testKey };
  },
};
