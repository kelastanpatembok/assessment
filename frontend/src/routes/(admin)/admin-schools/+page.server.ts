import { createApiClient } from '$lib/api/index';
import { fail, redirect } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const schools = await api.get('/schools').catch(() => []);
  return { schools: Array.isArray(schools) ? schools : [] };
};

export const actions: Actions = {
  create: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const name = data.get('schoolName') as string;
    const address = data.get('address') as string;
    const city = data.get('city') as string;
    const province = data.get('province') as string;
    if (!name) return fail(400, { error: 'Nama sekolah wajib diisi' });
    await api.post('/schools', { name, address, city, province });
    return { success: true };
  },
  update: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const id = data.get('id') as string;
    const name = data.get('schoolName') as string;
    const address = data.get('address') as string;
    if (!name) return fail(400, { error: 'Nama sekolah wajib diisi' });
    await api.put(`/schools/${id}`, { name, address });
    return { success: true };
  },
  delete: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const id = data.get('id') as string;
    await api.delete(`/schools/${id}`);
    return { success: true };
  },
};
