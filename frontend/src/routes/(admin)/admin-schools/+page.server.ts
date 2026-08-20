import { createApiClient } from '$lib/api/index';
import { buildQuery, normalizePage, parseTableParams } from '$lib/table/helpers';
import { fail, redirect } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals, url }) => {
  const api = createApiClient(locals.token);
  const params = parseTableParams(url, { size: 10, sort: 'name', order: 'asc' });
  const schools = await api.get(`/schools?${buildQuery(params)}`).catch(() => null);
  const table = normalizePage(schools, params.size);
  const [usersRaw, picEntries] = await Promise.all([
    api.get('/users').catch(() => []),
    Promise.all(
      table.items.map(async (school: any) => [
        school.id,
        await api.get(`/schools/${school.id}/pics`).catch(() => [])
      ] as const)
    )
  ]);
  return {
    base: url.pathname,
    table,
    users: Array.isArray(usersRaw) ? usersRaw : [],
    picsBySchool: Object.fromEntries(picEntries),
  };
};

export const actions: Actions = {
  create: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const name = data.get('schoolName') as string;
    const address = data.get('address') as string;
    const city = data.get('city') as string;
    const province = data.get('province') as string;
    const email = data.get('email') as string;
    if (!name) return fail(400, { error: 'Nama sekolah wajib diisi' });
    try {
      await api.post('/schools', { name, address, city, province, email });
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
    const email = data.get('email') as string;
    if (!name) return fail(400, { error: 'Nama sekolah wajib diisi' });
    try {
      await api.put(`/schools/${id}`, { name, address, email });
    } catch (e) {
      return fail(502, { error: errorMessage(e, 'Gagal memperbarui sekolah. Silakan coba lagi.') });
    }
    return { success: true };
  },
  addPic: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const schoolId = String(data.get('schoolId') ?? '');
    const authUserId = String(data.get('authUserId') ?? '');
    if (!schoolId || !authUserId) return fail(400, { error: 'Pilih akun PIC sekolah' });
    try {
      await api.post(`/schools/${schoolId}/pics`, { authUserId, isPrimary: data.get('isPrimary') === 'on' });
    } catch (e) {
      return fail(400, { error: errorMessage(e, 'Gagal menambahkan PIC sekolah.') });
    }
    return { success: true };
  },
  setPrimaryPic: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    await api.put(`/schools/${data.get('schoolId')}/pics/${encodeURIComponent(String(data.get('authUserId')))}/primary`, {});
    return { success: true };
  },
  removePic: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    await api.delete(`/schools/${data.get('schoolId')}/pics/${encodeURIComponent(String(data.get('authUserId')))}`);
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
