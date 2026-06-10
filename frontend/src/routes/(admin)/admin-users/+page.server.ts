import { createApiClient } from '$lib/api/index';
import { fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const [users, schools] = await Promise.allSettled([
    api.get('/users'),
    api.get('/schools'),
  ]);
  return {
    users: users.status === 'fulfilled' && Array.isArray(users.value) ? users.value : [],
    schools: schools.status === 'fulfilled' && Array.isArray(schools.value) ? schools.value : [],
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
      role: data.get('role'),
      schoolId: data.get('schoolId') || null,
    };
    const result = await api.post('/users', body);
    if (result?.error) return fail(400, { error: result.error });
    return { success: true };
  },
  delete: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const id = data.get('id') as string;
    await api.delete(`/users/${id}`);
    return { success: true };
  },
};
