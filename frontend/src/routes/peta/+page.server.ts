import { createApiClient } from '$lib/api/index';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ url }) => {
  const search = url.searchParams.get('q')?.trim() ?? '';
  const points = await createApiClient(null)
    .get(`/public/schools/map${search ? `?search=${encodeURIComponent(search)}` : ''}`)
    .catch(() => ({ items: [] }));
  return { points: points.items ?? [], search };
};
