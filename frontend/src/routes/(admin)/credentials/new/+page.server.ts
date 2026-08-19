import { createApiClient } from '$lib/api/index';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals, url }) => {
  const api = createApiClient(locals.token);

  const assignmentId = url.searchParams.get('assignmentId');

  const [categoriesRaw, assignmentsRaw] = await Promise.allSettled([
    api.get('/test-categories'),
    assignmentId ? api.get('/test-assignments') : Promise.resolve(null)
  ]);

  const categories = categoriesRaw.status === 'fulfilled' && Array.isArray(categoriesRaw.value)
    ? categoriesRaw.value.map((c: any) => ({ id: c.id, name: c.name, slug: c.slug, tests: Array.isArray(c.tests) ? c.tests : [] }))
    : [];

  let presetAssignment = null;
  if (assignmentId && assignmentsRaw.status === 'fulfilled' && Array.isArray(assignmentsRaw.value)) {
    const match = assignmentsRaw.value.find((a: any) => String(a.id) === assignmentId);
    if (match && match.school && match.category) {
      presetAssignment = {
        id: match.id,
        schoolId: match.school.id,
        categoryId: match.category.id,
        school: { id: match.school.id, name: match.school.name },
        category: { id: match.category.id, name: match.category.name, slug: match.category.slug },
        status: match.active ? 'aktif' : 'nonaktif',
        startDate: match.windowStart ?? '',
        endDate: match.windowEnd ?? ''
      };
    }
  }

  return {
    categories,
    presetAssignment,
    token: locals.token,
  };
};
