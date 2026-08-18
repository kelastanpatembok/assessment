import { error } from '@sveltejs/kit';
import { createApiClient } from '$lib/api/index';
import type { PageServerLoad } from './$types';

const TEST_LABELS: Record<string, string> = {
	disc: 'DISC',
	holland: 'Holland RIASEC',
	papi: 'PAPI Kostick',
	cfit: 'IQ CFIT',
	ist: 'IQ IST',
	epps: 'EPPS'
};

function summarizeResult(testKey: string, result: Record<string, any>): string {
	switch (testKey) {
		case 'disc':
			return result.profileTitle || result.difKey || '-';
		case 'holland':
			return result.hollandCode || [result.type1, result.type2].filter(Boolean).join('') || '-';
		case 'papi':
			return 'Trait score tersedia';
		case 'cfit':
			return result.iqScore ? `IQ ${result.iqScore}` : result.totalScore ? `Skor ${result.totalScore}` : '-';
		case 'ist':
			return result.iqScore ? `IQ ${result.iqScore}` : result.totalWert ? `Wert ${result.totalWert}` : '-';
		case 'epps':
			return result.consistencyRaw !== undefined
				? `Konsistensi ${result.consistencyRaw}/15`
				: '-';
		default:
			return '-';
	}
}

export const load: PageServerLoad = async ({ params, locals }) => {
	const assignmentId = Number(params.id);
	if (Number.isNaN(assignmentId)) {
		throw error(404, 'Penugasan tidak ditemukan');
	}

	const api = createApiClient(locals.token);
	const [assignmentsRaw, discRaw, hollandRaw, papiRaw, cfitRaw, istRaw, eppsRaw, credentialBatchesRaw] = await Promise.allSettled([
		api.get('/test-assignments'),
		api.get('/disc/results'),
		api.get('/holland/results'),
		api.get('/papi/results'),
		api.get('/cfit/results'),
		api.get('/ist/results'),
		api.get('/epps/results'),
		api.get(`/credentials/batches?testAssignmentId=${assignmentId}`)
	]);

	const assignments = assignmentsRaw.status === 'fulfilled' && Array.isArray(assignmentsRaw.value) ? assignmentsRaw.value : [];
	const assignment = assignments.find((item: any) => item.id === assignmentId);

	if (!assignment) {
		throw error(404, 'Penugasan tidak ditemukan');
	}

	const resultCollections = {
		disc: discRaw.status === 'fulfilled' && Array.isArray(discRaw.value) ? discRaw.value : [],
		holland: hollandRaw.status === 'fulfilled' && Array.isArray(hollandRaw.value) ? hollandRaw.value : [],
		papi: papiRaw.status === 'fulfilled' && Array.isArray(papiRaw.value) ? papiRaw.value : [],
		cfit: cfitRaw.status === 'fulfilled' && Array.isArray(cfitRaw.value) ? cfitRaw.value : [],
		ist: istRaw.status === 'fulfilled' && Array.isArray(istRaw.value) ? istRaw.value : [],
		epps: eppsRaw.status === 'fulfilled' && Array.isArray(eppsRaw.value) ? eppsRaw.value : []
	};

	const tests: string[] = Array.isArray(assignment.category?.tests) ? assignment.category.tests : [];

	const moduleTests = tests.map((testKey) => {
		const results = (resultCollections[testKey as keyof typeof resultCollections] ?? []).filter(
			(result: any) => result.assignmentId === assignmentId
		);

		return {
			key: testKey,
			label: TEST_LABELS[testKey] || testKey.toUpperCase(),
			resultCount: results.length,
			recentResults: results
				.sort((a: any, b: any) => {
					const aTime = a.completedAt ? new Date(a.completedAt).getTime() : 0;
					const bTime = b.completedAt ? new Date(b.completedAt).getTime() : 0;
					return bTime - aTime;
				})
				.slice(0, 8)
				.map((result: any) => ({
					id: result.id,
					studentName: result.studentName || '-',
					schoolName: result.schoolName || '-',
					completedAt: result.completedAt ?? null,
					summary: summarizeResult(testKey, result)
				}))
		};
	});

	const totalResults = moduleTests.reduce((sum, test) => sum + test.resultCount, 0);

	const credentialBatches =
		credentialBatchesRaw.status === 'fulfilled' && Array.isArray(credentialBatchesRaw.value)
			? credentialBatchesRaw.value.map((batch: any) => ({
					id: batch.id,
					credentialCount: batch.credentialCount,
					pdfFilename: batch.pdfFilename,
					generatedBy: batch.generatedBy,
					createdAt: batch.createdAt
				}))
			: [];

	return {
		assignment: {
			id: assignment.id,
			schoolName: assignment.school?.name || '-',
			categoryName: assignment.category?.name || '-',
			categorySlug: assignment.category?.slug || '-',
			active: Boolean(assignment.active),
			windowStart: assignment.windowStart ?? null,
			windowEnd: assignment.windowEnd ?? null
		},
		moduleTests,
		totalResults,
		credentialBatches,
		token: locals.token
	};
};
