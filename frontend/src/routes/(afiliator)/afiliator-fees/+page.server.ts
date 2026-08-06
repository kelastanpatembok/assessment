import { createApiClient } from '$lib/api/index';
import { buildQuery, normalizePage, parseTableParams } from '$lib/table/helpers';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals, url }) => {
  const api = createApiClient(locals.token);
  const params = parseTableParams(url, { size: 10, sort: 'createdAt', order: 'desc' });
  const [feesRaw, summaryRaw] = await Promise.allSettled([
    api.get(`/fees/my?${buildQuery(params)}`),
    api.get('/fees/summary/afiliator')
  ]);
  return {
    base: url.pathname,
    table: normalizePage(feesRaw.status === 'fulfilled' ? feesRaw.value : null, params.size),
    totalShare: summaryRaw.status === 'fulfilled' ? (summaryRaw.value as any)?.totalShare ?? 0 : 0,
  };
};
