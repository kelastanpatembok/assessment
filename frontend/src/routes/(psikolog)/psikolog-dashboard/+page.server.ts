import { createApiClient } from '$lib/api/index';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const students = await api.get('/students').catch(() => []);
  return { students: Array.isArray(students) ? students : [] };
};

export const actions: Actions = {
  search: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const formData = await request.formData();
    const query = String(formData.get('query') ?? '').trim();
    if (query.length < 2) return { query: '', matches: [] };
    const matches = await api.get(`/psikolog/search?query=${encodeURIComponent(query)}`).catch(() => []);
    return { query, matches: Array.isArray(matches) ? matches : [] };
  },
};
