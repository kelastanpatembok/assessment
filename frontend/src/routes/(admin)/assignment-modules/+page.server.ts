import { createApiClient } from '$lib/api/index';
import type { PageServerLoad } from './$types';

const TEST_LABELS: Record<string, string> = {
	disc: 'DISC',
	holland: 'Holland RIASEC',
	papi: 'PAPI Kostick',
	cfit: 'IQ CFIT',
	ist: 'IQ IST'
};

export const load: PageServerLoad = async ({ locals }) => {
	const api = createApiClient(locals.token);

	const [assignmentsRaw, discRaw, hollandRaw, papiRaw, cfitRaw, istRaw] = await Promise.allSettled([
		api.get('/test-assignments'),
		api.get('/disc/results'),
		api.get('/holland/results'),
		api.get('/papi/results'),
		api.get('/cfit/results'),
		api.get('/ist/results')
	]);

	const assignments = assignmentsRaw.status === 'fulfilled' && Array.isArray(assignmentsRaw.value) ? assignmentsRaw.value : [];
	const resultCollections = {
		disc: discRaw.status === 'fulfilled' && Array.isArray(discRaw.value) ? discRaw.value : [],
		holland: hollandRaw.status === 'fulfilled' && Array.isArray(hollandRaw.value) ? hollandRaw.value : [],
		papi: papiRaw.status === 'fulfilled' && Array.isArray(papiRaw.value) ? papiRaw.value : [],
		cfit: cfitRaw.status === 'fulfilled' && Array.isArray(cfitRaw.value) ? cfitRaw.value : [],
		ist: istRaw.status === 'fulfilled' && Array.isArray(istRaw.value) ? istRaw.value : []
	};

	return {
		assignments: assignments.map((assignment: any) => {
			const tests: string[] = Array.isArray(assignment.category?.tests) ? assignment.category.tests : [];
			const resultCount = tests.reduce((total, testKey) => {
				const results = resultCollections[testKey as keyof typeof resultCollections] ?? [];
				return total + results.filter((result: any) => result.assignmentId === assignment.id).length;
			}, 0);

			return {
				id: assignment.id,
				schoolName: assignment.school?.name || '-',
				categoryName: assignment.category?.name || '-',
				tests: tests.map((test) => ({
					key: test,
					label: TEST_LABELS[test] || test.toUpperCase()
				})),
				active: Boolean(assignment.active),
				windowStart: assignment.windowStart ?? null,
				windowEnd: assignment.windowEnd ?? null,
				resultCount
			};
		})
	};
};
