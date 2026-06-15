import type { PageServerLoad } from './$types';
import { createApiClient } from '$lib/api';

export const load: PageServerLoad = async ({ locals }) => {
    const api = createApiClient(locals.token);
    const summary = await api.get('/dashboard/summary');
    
    return {
        summary
    };
};
