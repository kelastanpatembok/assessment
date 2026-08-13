import { createApiClient } from '$lib/api/index';
import { redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';
export const load: PageServerLoad = async ({ locals }) => { const result = await createApiClient(locals.token).get('/epps/result/me').catch(() => null); if (!result) redirect(302, '/student-epps'); return { result }; };
