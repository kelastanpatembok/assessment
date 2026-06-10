import { createApiClient } from '$lib/api/index';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  const api = createApiClient(locals.token);
  const students = await api.get('/students').catch(() => []);
  return { studentCount: Array.isArray(students) ? students.length : 0 };
};
