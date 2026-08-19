import { createApiClient } from '$lib/api/index';
import { buildQuery, normalizePage, parseTableParams } from '$lib/table/helpers';
import { fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals, url }) => {
  const api = createApiClient(locals.token);
  const params = parseTableParams(url, { size: 10, sort: 'windowStart', order: 'desc' });
  const [assignments, categories] = await Promise.allSettled([
    api.get(`/test-assignments?${buildQuery(params)}`),
    api.get('/test-categories'),
  ]);
  return {
    base: url.pathname,
    table: normalizePage(assignments.status === 'fulfilled' ? assignments.value : null, params.size),
    categories: categories.status === 'fulfilled' && Array.isArray(categories.value) ? categories.value : [],
    token: locals.token,
  };
};

export const actions: Actions = {
  create: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const body = {
      schoolId: data.get('schoolId'),
      categoryId: data.get('categoryId'),
      startDate: data.get('startDate'),
      endDate: data.get('endDate'),
      certificateEnabled: data.get('certificateEnabled') === 'on',
    };
    if (!body.schoolId || !body.categoryId) return fail(400, { error: 'Sekolah dan kategori wajib dipilih' });
    await api.post('/test-assignments', body);
    return { success: true };
  },
  update: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const id = data.get('id') as string;
    const body = {
      startDate: data.get('startDate'),
      endDate: data.get('endDate'),
      active: data.get('active') === 'on',
      certificateEnabled: data.get('certificateEnabled') === 'on',
    };
    await api.put(`/test-assignments/${id}`, body);
    return { success: true };
  },
  delete: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    await api.delete(`/test-assignments/${data.get('id')}`);
    return { success: true };
  },
};
