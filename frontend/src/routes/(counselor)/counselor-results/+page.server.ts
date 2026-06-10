import { createApiClient } from '$lib/api/index';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals, url }) => {
  const api = createApiClient(locals.token);
  const tab = url.searchParams.get('tab') ?? 'disc';

  const [disc, holland, papi, cfit, ist] = await Promise.allSettled([
    api.get('/disc/results'),
    api.get('/holland/results'),
    api.get('/papi/results'),
    api.get('/cfit/results'),
    api.get('/ist/results'),
  ]);

  return {
    tab,
    disc: disc.status === 'fulfilled' && Array.isArray(disc.value) ? disc.value : [],
    holland: holland.status === 'fulfilled' && Array.isArray(holland.value) ? holland.value : [],
    papi: papi.status === 'fulfilled' && Array.isArray(papi.value) ? papi.value : [],
    cfit: cfit.status === 'fulfilled' && Array.isArray(cfit.value) ? cfit.value : [],
    ist: ist.status === 'fulfilled' && Array.isArray(ist.value) ? ist.value : [],
  };
};
