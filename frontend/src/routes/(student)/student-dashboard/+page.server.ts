import { createApiClient } from '$lib/api/index';
import type { PageServerLoad } from './$types';

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
    if (result.status === 'rejected') return { available: false, completed: false };
    const v = result.value;
    if (!v || v.code) return { available: false, completed: false };
    return {
      available: v?.canTake ?? false,
      completed: v?.completed ?? false,
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
