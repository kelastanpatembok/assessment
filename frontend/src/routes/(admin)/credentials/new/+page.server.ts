import { createApiClient } from '$lib/api/index';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);

  const today = new Date().toISOString().split('T')[0];

  const assignments = await api
    .get(`/test-assignments?status=aktif&endDate>=${today}`)
    .catch(() => []);

  return {
    assignments: Array.isArray(assignments) ? assignments : [],
  };
};
