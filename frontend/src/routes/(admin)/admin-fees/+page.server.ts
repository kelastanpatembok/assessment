import { createApiClient } from '$lib/api/index';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const config = await api.get('/fee-config').catch(() => null);
  return { config };
};

export const actions: Actions = {
  update: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const body = {
      price: Number(data.get('price')),
      systemPct: Number(data.get('systemPct')),
      affiliatorPct: Number(data.get('affiliatorPct')),
      counselorPct: Number(data.get('counselorPct')),
    };
    await api.post('/fee-config', body);
    return { success: true };
  },
};
