import { createApiClient } from '$lib/api/index';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const [schools, users] = await Promise.allSettled([
    api.get('/schools'),
    api.get('/users'),
  ]);
  return {
    schoolCount: schools.status === 'fulfilled' ? (schools.value?.length ?? 0) : 0,
    userCount: users.status === 'fulfilled' ? (users.value?.length ?? 0) : 0,
  };
};
