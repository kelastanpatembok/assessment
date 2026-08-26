import { createApiClient } from '$lib/api/index';
import { error } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals, url }) => {
  const assignment = url.searchParams.get('assignment');
  if (!assignment) throw error(400, 'Penugasan laporan tidak ditemukan');
  const api = createApiClient(locals.token);
  const me = await api.get('/users/me');
  const report = await api.get(`/psychological-reports/${assignment}/${me.authUserId}`);
  return { assignment, studentId: me.authUserId, report, token: locals.token };
};
