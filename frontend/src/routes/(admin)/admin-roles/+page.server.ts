import { createApiClient } from '$lib/api/index';
import { fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const roles = await api.get('/roles').catch(() => []);
  return { roles: Array.isArray(roles) ? roles : [], token: locals.token };
};

export const actions: Actions = {
  create: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    
    const id = data.get('id')?.toString();
    const displayName = data.get('displayName')?.toString();
    const description = data.get('description')?.toString();
    const permissionsStr = data.get('permissions')?.toString() || '[]';
    
    if (!id || !displayName) return fail(400, { error: 'ID dan Nama Role wajib diisi' });

    try {
      const permissions = JSON.parse(permissionsStr);
      await api.post('/roles', { id, displayName, description, permissions });
    } catch (e: any) {
      return fail(422, { error: e.message || 'Gagal membuat role' });
    }
  },
  
  update: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    
    const id = data.get('id')?.toString();
    const displayName = data.get('displayName')?.toString();
    const description = data.get('description')?.toString();
    const permissionsStr = data.get('permissions')?.toString() || '[]';
    
    if (!id || !displayName) return fail(400, { error: 'Nama Role wajib diisi' });

    try {
      const permissions = JSON.parse(permissionsStr);
      await api.put(`/roles/${id}`, { displayName, description, permissions });
    } catch (e: any) {
      return fail(422, { error: e.message || 'Gagal mengubah role' });
    }
  },

  delete: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const id = data.get('id')?.toString();
    
    if (!id) return fail(400, { error: 'ID Role tidak valid' });

    try {
      await api.delete(`/roles/${id}`);
    } catch (e: any) {
      return fail(422, { error: e.message || 'Gagal menghapus role' });
    }
  }
};
