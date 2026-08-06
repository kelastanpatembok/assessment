import { createApiClient } from '$lib/api/index';
import { buildQuery, normalizePage, parseTableParams } from '$lib/table/helpers';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals, url }) => {
	const api = createApiClient(locals.token);
	const params = parseTableParams(url, { size: 10, sort: 'windowStart', order: 'desc' });
	const status = url.searchParams.get('status') ?? '';
	const active = status === 'active' ? true : status === 'inactive' ? false : undefined;

	const [summariesRaw, summaryRaw] = await Promise.allSettled([
		api.get(
			`/assignment-summaries?${buildQuery(params)}${active === undefined ? '' : `&active=${active}`}`
		),
		api.get('/assignment-summaries/summary')
	]);

	return {
		token: locals.token,
		base: url.pathname,
		status,
		table: normalizePage(summariesRaw.status === 'fulfilled' ? summariesRaw.value : null, params.size),
		summary: summaryRaw.status === 'fulfilled' && summaryRaw.value
			? summaryRaw.value
			: { totalAssignments: 0, activeAssignments: 0, totalResults: 0 }
	};
};
