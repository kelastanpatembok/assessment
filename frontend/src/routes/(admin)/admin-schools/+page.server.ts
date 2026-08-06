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
    try {
      await api.post('/schools', { name, address, city, province });
    } catch (e) {
      return fail(502, { error: errorMessage(e, 'Gagal menyimpan sekolah. Silakan coba lagi.') });
    }
    return { success: true };
  },
  update: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const id = data.get('id') as string;
    const name = data.get('schoolName') as string;
    const address = data.get('address') as string;
    if (!name) return fail(400, { error: 'Nama sekolah wajib diisi' });
    try {
      await api.put(`/schools/${id}`, { name, address });
    } catch (e) {
      return fail(502, { error: errorMessage(e, 'Gagal memperbarui sekolah. Silakan coba lagi.') });
    }
    return { success: true };
  },
  delete: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const id = data.get('id') as string;
    try {
      await api.delete(`/schools/${id}`);
    } catch (e) {
      return fail(502, { error: errorMessage(e, 'Gagal menghapus sekolah. Silakan coba lagi.') });
    }
    return { success: true };
  },
};

function errorMessage(e: unknown, fallback: string): string {
  const message = e instanceof Error ? e.message : String(e);
  if (/^HTTP (502|503|504)/.test(message)) {
    return 'Layanan sedang sibuk. Silakan coba lagi sebentar lagi.';
  }
  if (/^HTTP 4/.test(message)) {
    return 'Data tidak dapat diproses. Periksa kembali isian atau muat ulang halaman.';
  }
  return fallback;
}
