import { createApiClient } from '$lib/api/index';
import { buildQuery, normalizePage, parseTableParams } from '$lib/table/helpers';
import { fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals, url }) => {
  const api = createApiClient(locals.token);
  const params = parseTableParams(url, { size: 10, sort: 'createdAt', order: 'desc' });
  const role = url.searchParams.get('role') ?? '';
  const usersEndpoint = `/users?${buildQuery(params)}${role ? `&role=${encodeURIComponent(role)}` : ''}`;

  const usersRaw = await api.get(usersEndpoint).catch(() => null);

  return {
    base: url.pathname,
    role,
    table: normalizePage(usersRaw, params.size),
    token: locals.token,
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
  update: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const id = data.get('id') as string;
    const password = data.get('password') as string;
    const body: Record<string, unknown> = {
      name: data.get('name'),
      email: data.get('email'),
      schoolId: data.get('schoolId') ? Number(data.get('schoolId')) : null,
    };
    if (password && password.trim()) body.password = password;
    const result = await api.put(`/users/${id}`, body);
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
