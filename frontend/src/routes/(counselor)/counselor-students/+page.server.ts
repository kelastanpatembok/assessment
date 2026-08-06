import { createApiClient } from '$lib/api/index';
import { buildQuery, normalizePage, parseTableParams } from '$lib/table/helpers';
import { fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals, url }) => {
  const api = createApiClient(locals.token);
  const params = parseTableParams(url, { size: 10, sort: 'createdAt', order: 'desc' });
  const students = await api.get(`/students?${buildQuery(params)}`).catch(() => null);
  return {
    base: url.pathname,
    table: normalizePage(students, params.size),
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
