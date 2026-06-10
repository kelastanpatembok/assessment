import { createApiClient } from '$lib/api/index';
import { fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const students = await api.get('/students').catch(() => []);
  return { students: Array.isArray(students) ? students : [] };
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
