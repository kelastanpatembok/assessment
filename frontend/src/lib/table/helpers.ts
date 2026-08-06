import type { SortOrder, TableParams, TableState } from './types';

/**
 * Shared helpers for the server-driven DataTable. The pattern is:
 *
 * 1. `+page.server.ts` reads the table params straight from `url.searchParams`
 *    with `parseTableParams`, appends them to the API call with `buildQuery`,
 *    and normalizes the response with `normalizePage`.
 * 2. The page renders <DataTable> with that state plus `base` (the current
 *    pathname) so search / sort / pagination can build navigation links.
 */

export interface TableDefaults {
	size: number;
	sort: string;
	order: SortOrder;
}

export function parseTableParams(url: URL, defaults: TableDefaults) {
	const pageRaw = Number(url.searchParams.get('page'));
	const sizeRaw = Number(url.searchParams.get('size'));
	const sort = url.searchParams.get('sort') ?? defaults.sort;
	const orderRaw = url.searchParams.get('order');
	return {
		page: Number.isInteger(pageRaw) && pageRaw >= 0 ? pageRaw : 0,
		size: Number.isInteger(sizeRaw) && sizeRaw >= 1 ? sizeRaw : defaults.size,
		search: url.searchParams.get('search') ?? '',
		sort,
		order: orderRaw === 'desc' ? ('desc' as const) : ('asc' as const)
	};
}

/** Query string appended to the API endpoint for the current table params. */
export function buildQuery(params: TableParams): string {
	const q = new URLSearchParams();
	q.set('page', String(params.page ?? 0));
	q.set('size', String(params.size ?? 10));
	if (params.search) q.set('search', params.search);
	if (params.sort) q.set('sort', params.sort);
	q.set('order', params.order ?? 'asc');
	return q.toString();
}

/**
 * Normalizes either the server envelope ({ items, page, size, totalElements })
 * or a plain array (legacy/back-compat endpoint) into a TableState.
 */
export function normalizePage<T = Record<string, any>>(
	response: unknown,
	size: number,
	fallback: T[] = []
): TableState {
	const items = Array.isArray(response) ? response : (response as any)?.items;
	if (!Array.isArray(items)) {
		return {
			items: fallback as Record<string, any>[],
			page: 0,
			size,
			total: (fallback as any[]).length,
			search: '',
			sort: '',
			order: 'asc'
		};
	}
	const envelope = (response as any) ?? {};
	return {
		items: items as Record<string, any>[],
		page: Number.isInteger(envelope.page) && envelope.page >= 0 ? envelope.page : 0,
		size: envelope.size ?? size,
		total: typeof envelope.totalElements === 'number' ? envelope.totalElements : items.length,
		search: '',
		sort: '',
		order: 'asc'
	};
}

/**
 * Builds a navigation href on `base` preserving the current table params and
 * applying `patch`. Changing search/size resets the page to zero unless an
 * explicit page is given.
 */
export function tableHref(base: string, current: TableParams, patch: Partial<TableParams> = {}): string {
	const q = new URLSearchParams();
	const merged = { ...current, ...patch };
	q.set('page', String(merged.page ?? 0));
	q.set('size', String(merged.size ?? 10));
	if (merged.search) q.set('search', merged.search);
	if (merged.sort) q.set('sort', merged.sort);
	q.set('order', merged.order ?? 'asc');
	const qs = q.toString();
	return qs ? `${base}?${qs}` : base;
}

export function totalPages(total: number, size: number): number {
	return Math.max(1, Math.ceil(total / Math.max(1, size)));
}
