import { createApiClient } from '$lib/api/index';
import { redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const result = await api.get('/disc/result/me').catch(() => null);
  if (!result) redirect(302, '/student-disc');
  return { result };
};
