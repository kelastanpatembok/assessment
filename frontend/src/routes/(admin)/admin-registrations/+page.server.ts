import { requireRole } from '$lib/server/auth';
import { createApiClient } from '$lib/api/index';
import { fail } from '@sveltejs/kit';
import type { PageServerLoad, Actions } from './$types';

export const load: PageServerLoad = async ({ locals, url }) => {
  requireRole(locals, 'superadmin');
  const api = createApiClient(locals.token ?? null);

  const page = url.searchParams.get('page') || '1';
  const search = url.searchParams.get('search') || '';
  const status = url.searchParams.get('status') || '';

  const params = new URLSearchParams({ page, size: '25' });
  if (search) params.set('search', search);
  if (status) params.set('status', status);

  const result = await api.get(`/registrations?${params}`).catch(() => ({ items: [], total: 0, page: 0, size: 25 }));

  const profile = await import('$lib/server/profile').then(m =>
    m.getProfile(locals.user!.userId, locals.token ?? '')
  );

  return {
    user: locals.user,
    profile,
    registrations: result?.items ?? [],
    total: result?.total ?? 0,
    currentPage: Number(page),
    search,
    status,
  };
};

export const actions: Actions = {
  updateStatus: async ({ request, locals }) => {
    requireRole(locals, 'superadmin');
    const api = createApiClient(locals.token ?? null);
    const data = await request.formData();
    const id = data.get('id')?.toString();
    const status = data.get('status')?.toString();
    const notes = data.get('notes')?.toString();

    if (!id) return fail(400, { error: 'ID tidak valid' });

    try {
      await api.put(`/registrations/${id}`, { status, notes });
    } catch (e: any) {
      return fail(422, { error: e.message || 'Gagal mengupdate status' });
    }
  },

  delete: async ({ request, locals }) => {
    requireRole(locals, 'superadmin');
    const api = createApiClient(locals.token ?? null);
    const data = await request.formData();
    const id = data.get('id')?.toString();

    if (!id) return fail(400, { error: 'ID tidak valid' });

    try {
      await api.delete(`/registrations/${id}`);
    } catch (e: any) {
      return fail(422, { error: e.message || 'Gagal menghapus pendaftaran' });
    }
  },
};
