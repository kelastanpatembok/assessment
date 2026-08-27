import { createApiClient } from '$lib/api/index';
import { fail, redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  if (!locals.token) redirect(302, '/signin');
  const requests = await createApiClient(locals.token).get('/onboarding/access-requests').catch(() => ({ items: [] }));
  return { requests: requests.items ?? [] };
};
export const actions: Actions = {
  request: async ({ request, locals }) => {
    if (!locals.token) return fail(401, { error: 'Silakan masuk kembali.' });
    const form = await request.formData();
    const requestedRole = String(form.get('requestedRole') ?? '');
    const schoolIdRaw = String(form.get('schoolId') ?? '');
    try {
      await createApiClient(locals.token).post('/onboarding/access-requests', {
        requesterName: String(form.get('requesterName') ?? ''), requesterEmail: String(form.get('requesterEmail') ?? ''),
        requestedRole, schoolId: schoolIdRaw ? Number(schoolIdRaw) : null, note: String(form.get('note') ?? '')
      });
      return { success: true };
    } catch (e) { return fail(400, { error: e instanceof Error ? e.message : 'Pengajuan belum dapat dikirim.' }); }
  }
};
