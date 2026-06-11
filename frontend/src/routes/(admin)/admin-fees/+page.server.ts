import { createApiClient } from '$lib/api/index';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const configs = await api.get('/fees/config').catch(() => []);
  const config = Array.isArray(configs) ? configs[0] ?? null : null;
  return { config };
};

export const actions: Actions = {
  update: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const body = {
      studentFee: Number(data.get('studentFee')),
      afiliatorSharePct: Number(data.get('afiliatorSharePct')),
      gurubkSharePct: Number(data.get('gurubkSharePct')),
      platformSharePct: Number(data.get('platformSharePct')),
    };
    await api.put('/fees/config', body);
    return { success: true };
  },
};
