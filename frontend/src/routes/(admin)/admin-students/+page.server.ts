import { createApiClient } from '$lib/api/index';
import { buildQuery, normalizePage, parseTableParams } from '$lib/table/helpers';
import { fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals, url }) => {
  const api = createApiClient(locals.token);
  const params = parseTableParams(url, { size: 10, sort: 'createdAt', order: 'desc' });
  const [students, schools, categories] = await Promise.allSettled([
    api.get(`/students?${buildQuery(params)}`),
    api.get('/schools'),
    api.get('/test-categories'),
  ]);
  return {
    base: url.pathname,
    table: normalizePage(students.status === 'fulfilled' ? students.value : null, params.size),
    schools: schools.status === 'fulfilled' && Array.isArray(schools.value) ? schools.value : [],
    categories: categories.status === 'fulfilled' && Array.isArray(categories.value) ? categories.value : [],
  };
};

export const actions: Actions = {
  create: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const body = {
      username: data.get('username'),
      email: data.get('email'),
      password: data.get('password'),
      name: data.get('name'),
      schoolId: data.get('schoolId'),
      categoryId: data.get('categoryId'),
    };
    const result = await api.post('/students', body);
    if (result?.error) return fail(400, { error: result.error });
    return { success: true };
  },
  update: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const id = data.get('id') as string;
    const body: Record<string, unknown> = { name: data.get('name'), email: data.get('email') };
    const schoolId = data.get('schoolId');
    if (schoolId) body.schoolId = schoolId;
    await api.put(`/students/${id}`, body);
    return { success: true };
  },
  delete: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    await api.delete(`/students/${data.get('id')}`);
    return { success: true };
  },
};
