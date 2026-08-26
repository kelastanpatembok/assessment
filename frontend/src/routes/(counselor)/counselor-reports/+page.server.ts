import { createApiClient } from '$lib/api/index'; import type { PageServerLoad } from './$types';
export const load: PageServerLoad = async ({ locals }) => ({ reports: await createApiClient(locals.token).get('/psychological-reports'), token: locals.token });
