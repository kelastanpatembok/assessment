import { createApiClient } from '$lib/api/index';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const fees = await api.get('/fees/me').catch(() => null);
  return { fees };
};
