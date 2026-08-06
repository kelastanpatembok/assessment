import { createApiClient } from '$lib/api/index';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const summary = await api.get('/fees/summary/afiliator').catch(() => null);
  return { totalShare: summary?.totalShare ?? 0 };
};
