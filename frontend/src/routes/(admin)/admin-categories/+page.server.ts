import { createApiClient } from '$lib/api/index';
import { buildQuery, normalizePage, parseTableParams } from '$lib/table/helpers';
import { fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals, url }) => {
  const api = createApiClient(locals.token);
  const params = parseTableParams(url, { size: 10, sort: 'name', order: 'asc' });
  const categories = await api.get(`/test-categories?${buildQuery(params)}`).catch(() => null);
  return {
    base: url.pathname,
    table: normalizePage(categories, params.size),
  };
};

export const actions: Actions = {
  create: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const body = {
      name: data.get('name'),
      slug: data.get('slug'),
      price: Number(data.get('price') || 0),
      tests: data.getAll('tests'),
      active: true,
    };
    if (!body.name) return fail(400, { error: 'Nama kategori wajib diisi' });
    await api.post('/test-categories', body);
    return { success: true };
  },
  update: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const id = data.get('id') as string;
    const body = {
      name: data.get('name'),
      slug: data.get('slug'),
      price: Number(data.get('price') || 0),
      tests: data.getAll('tests'),
      active: true,
    };
    if (!body.name) return fail(400, { error: 'Nama kategori wajib diisi' });
    await api.put(`/test-categories/${id}`, body);
    return { success: true };
  },
  delete: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    await api.delete(`/test-categories/${data.get('id')}`);
    return { success: true };
  },
};
