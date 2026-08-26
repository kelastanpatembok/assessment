import { createApiClient } from '$lib/api/index';
import { fail } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => ({ rules: await createApiClient(locals.token).get('/psychological-report-rules') });
export const actions: Actions = {
  save: async ({ request, locals }) => {
    const raw = String((await request.formData()).get('rules') ?? '');
    try { await createApiClient(locals.token).put('/psychological-report-rules', { rules: JSON.parse(raw) }); return { success: true }; }
    catch (e) { return fail(400, { error: e instanceof Error ? e.message : 'Rubrik tidak valid' }); }
  }
};
