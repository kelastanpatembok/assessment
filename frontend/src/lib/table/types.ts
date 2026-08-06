export type SortOrder = 'asc' | 'desc';

/** Normalized pagination/search/sort state shared by server and client modes. */
export interface TableState {
	items: Record<string, any>[];
	/** zero-based page number */
	page: number;
	size: number;
	total: number;
	search: string;
	sort: string;
	order: SortOrder;
}

export interface TableColumn {
	/** stable key used for sorting (falls back to `sortKey`) and cell lookup */
	key: string;
	label: string;
	sortable?: boolean;
	/** server-side sort field when different from `key` (e.g. key "Nama" -> sort "name") */
	sortKey?: string;
	align?: 'left' | 'right' | 'center';
	headerClass?: string;
	cellClass?: string;
	/** hide the column below the given Tailwind breakpoint for narrow screens */
	hideBelow?: 'sm' | 'md';
}

export interface TableParams {
	page?: number;
	size?: number;
	search?: string;
	sort?: string;
	order?: SortOrder;
}
