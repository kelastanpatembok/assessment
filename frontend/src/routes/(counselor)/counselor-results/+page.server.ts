import { createApiClient } from '$lib/api/index';
import { buildQuery, normalizePage, parseTableParams } from '$lib/table/helpers';
import type { PageServerLoad } from './$types';

const ENDPOINTS = {
	disc: '/disc/results',
	holland: '/holland/results',
	papi: '/papi/results',
	cfit: '/cfit/results',
	ist: '/ist/results'
} as const;

export type ResultTab = keyof typeof ENDPOINTS;

export const load: PageServerLoad = async ({ locals, url }) => {
	const api = createApiClient(locals.token);
	const tab = (url.searchParams.get('tab') ?? 'disc') as ResultTab;
	const params = parseTableParams(url, { size: 10, sort: 'completedAt', order: 'desc' });

	const raw = await api.get(`${ENDPOINTS[tab] ?? ENDPOINTS.disc}?${buildQuery(params)}`).catch(() => null);

	return {
		base: url.pathname,
		tab,
		table: normalizePage(raw, params.size)
	};
};
