import { fail } from '@sveltejs/kit';
import { createApiClient } from '$lib/api/index';
import { buildQuery, normalizePage, parseTableParams } from '$lib/table/helpers';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals, url }) => {
  const api = createApiClient(locals.token);
  const assignmentParams = parseTableParams(url, { size: 20, sort: 'windowStart', order: 'desc' });
  const historySearch = url.searchParams.get('historySearch')?.trim() ?? '';
  const selectedAssignmentId = Number(url.searchParams.get('assignmentId') ?? 0);
  const [assignmentsRaw, historyRaw, previewRaw] = await Promise.allSettled([
    api.get(`/assignment-summaries?${buildQuery(assignmentParams)}`),
    api.get(`/assessment-reports?page=0&size=25${historySearch ? `&search=${encodeURIComponent(historySearch)}` : ''}`),
    selectedAssignmentId > 0
      ? api.get(`/assessment-reports/preview/${selectedAssignmentId}`)
      : Promise.resolve(null)
  ]);
  return {
    token: locals.token,
    assignments: normalizePage(assignmentsRaw.status === 'fulfilled' ? assignmentsRaw.value : null, 20),
    history: normalizePage(historyRaw.status === 'fulfilled' ? historyRaw.value : null, 25),
    preview: previewRaw.status === 'fulfilled' ? previewRaw.value : null,
    previewError: previewRaw.status === 'rejected'
      ? (previewRaw.reason instanceof Error ? previewRaw.reason.message : 'Laporan belum dapat dibuat')
      : null,
    historySearch
  };
};

export const actions: Actions = {
  send: async ({ request, locals }) => {
    const api = createApiClient(locals.token);
    const data = await request.formData();
    const assignmentId = Number(data.get('assignmentId'));
    if (!assignmentId) return fail(400, { error: 'Pilih penugasan yang akan dikirim' });
    try {
      const delivery = await api.post(`/assessment-reports/send/${assignmentId}`, {});
      return { success: true, delivery };
    } catch (error) {
      return fail(400, { error: error instanceof Error ? error.message : 'Gagal mengirim laporan' });
    }
  }
};
