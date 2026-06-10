import { createApiClient } from '$lib/api/index';
import { fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const [assignments, schools, categories] = await Promise.allSettled([
    api.get('/test-assignments'),
    api.get('/schools'),
    api.get('/test-categories'),
  ]);
  return {
    assignments: assignments.status === 'fulfilled' && Array.isArray(assignments.value) ? assignments.value : [],
    schools: schools.status === 'fulfilled' && Array.isArray(schools.value) ? schools.value : [],
    categories: categories.status === 'fulfilled' && Array.isArray(categories.value) ? categories.value : [],
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
  delete: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    await api.delete(`/test-assignments/${data.get('id')}`);
    return { success: true };
  },
};
