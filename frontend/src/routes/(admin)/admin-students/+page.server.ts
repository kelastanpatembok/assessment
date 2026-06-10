import { createApiClient } from '$lib/api/index';
import { fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const [students, schools, categories] = await Promise.allSettled([
    api.get('/students'),
    api.get('/schools'),
    api.get('/test-categories'),
  ]);
  return {
    students: students.status === 'fulfilled' && Array.isArray(students.value) ? students.value : [],
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
  delete: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    await api.delete(`/students/${data.get('id')}`);
    return { success: true };
  },
};
