import { createApiClient } from '$lib/api/index';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);

  const [schoolsRaw, categoriesRaw] = await Promise.allSettled([
    api.get('/schools'),
    api.get('/test-categories')
  ]);

  const schools = schoolsRaw.status === 'fulfilled' && Array.isArray(schoolsRaw.value) 
    ? schoolsRaw.value.map((s: any) => ({ id: s.id, name: s.name })) 
    : [];

  const categories = categoriesRaw.status === 'fulfilled' && Array.isArray(categoriesRaw.value)
    ? categoriesRaw.value.map((c: any) => ({ id: c.id, name: c.name, slug: c.slug }))
    : [];

  return {
    schools,
    categories,
    token: locals.token,
  };
};
