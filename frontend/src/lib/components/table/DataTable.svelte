<script lang="ts">
	import { page } from '$app/state';
	import { goto } from '$app/navigation';
	import { totalPages } from '$lib/table/helpers';
	import type { Snippet } from 'svelte';
	import type { SortOrder, TableColumn, TableState } from '$lib/table/types';

	let {
		mode = 'server',
		columns,
		table,
		searchable = true,
		searchPlaceholder = 'Cari...',
		emptyText = 'Tidak ada data',
		rowKey = (item: Record<string, any>, index: number) => `${index}`,
		sizeOptions = [10, 25, 50],
		cell,
		empty
	}: {
		mode?: 'server' | 'client';
		columns: TableColumn[];
		table: TableState;
		searchable?: boolean;
		searchPlaceholder?: string;
		emptyText?: string;
		rowKey?: (item: Record<string, any>, index: number) => string | number;
		sizeOptions?: number[];
		cell?: Snippet<[TableColumn, Record<string, any>]>;
		empty?: Snippet;
	} = $props();

	// ---- client-side mode state (server mode reads `table` directly) ----
	const initialItems = table.items;
	const initialSize = table.size;
	let clientItems = $state<Record<string, any>[]>(initialItems);
	let clientPage = $state(0);
	let clientSearch = $state('');
	let clientSize = $state(initialSize);
	let clientSort = $state('');
	let clientOrder = $state<SortOrder>('asc');

	$effect(() => {
		clientItems = table.items;
	});

	const displaySearch = $derived(mode === 'server' ? table.search : clientSearch);
	const displayPage = $derived(mode === 'server' ? table.page : clientPage);
	const displaySize = $derived(mode === 'server' ? table.size : clientSize);
	const displaySort = $derived(mode === 'server' ? table.sort : clientSort);
	const displayOrder = $derived(mode === 'server' ? table.order : clientOrder);

	const filtered = $derived.by(() => {
		if (mode !== 'client') return clientItems;
		const q = clientSearch.trim().toLowerCase();
		let rows = clientItems;
		if (q) {
			rows = rows.filter((item) =>
				columns.some((col) => {
					const value = item[col.key];
					return value != null && String(value).toLowerCase().includes(q);
				})
			);
		}
		if (clientSort) {
			const direction = clientOrder === 'asc' ? 1 : -1;
			rows = [...rows].sort((a, b) => {
				const av = a[clientSort];
				const bv = b[clientSort];
				if (av == null && bv == null) return 0;
				if (av == null) return -1 * direction;
				if (bv == null) return 1 * direction;
				if (typeof av === 'number' && typeof bv === 'number') {
					return av === bv ? 0 : av < bv ? -1 * direction : 1 * direction;
				}
				return String(av).localeCompare(String(bv), 'id', { numeric: true }) * direction;
			});
		}
		return rows;
	});

	const displayTotal = $derived(mode === 'server' ? table.total : filtered.length);
	const pageCount = $derived(totalPages(displayTotal, displaySize));

	const displayItems = $derived.by(() => {
		if (mode !== 'client') return table.items;
		const start = clientPage * clientSize;
		return filtered.slice(start, start + clientSize);
	});

	const from = $derived(displayTotal === 0 ? 0 : displayPage * displaySize + 1);
	const to = $derived(Math.min((displayPage + 1) * displaySize, displayTotal));

	/**
	 * Builds a navigation href from the CURRENT page URL, preserving any extra
	 * query params (role / tab / status filters) while updating the table
	 * params. Missing fields fall back to the table's current values.
	 */
	function hrefFor(patch: Partial<{ page: number; size: number; search: string; sort: string; order: SortOrder }>): string {
		const q = new URLSearchParams(page.url.searchParams);
		q.set('page', String(patch.page ?? 0));
		if (patch.size) q.set('size', String(patch.size));
		else q.set('size', String(displaySize));
		if (patch.search !== undefined) {
			if (patch.search) q.set('search', patch.search);
			else q.delete('search');
		} else {
			q.set('search', displaySearch);
		}
		if (patch.sort) q.set('sort', patch.sort);
		else if (displaySort) q.set('sort', displaySort);
		else q.delete('sort');
		q.set('order', patch.order ?? displayOrder);
		const qs = q.toString();
		return qs ? `${page.url.pathname}?${qs}` : page.url.pathname;
	}

	function sortField(col: TableColumn): string {
		return col.sortKey ?? col.key;
	}

	function toggleHref(col: TableColumn): string {
		const field = sortField(col);
		const order: SortOrder = displaySort === field && displayOrder === 'asc' ? 'desc' : 'asc';
		return hrefFor({ sort: field, order, page: 0 });
	}

	function sortArrow(col: TableColumn): string {
		const field = sortField(col);
		if (displaySort !== field) return '';
		return displayOrder === 'asc' ? ' ↑' : ' ↓';
	}

	function clientToggleSort(col: TableColumn) {
		const field = sortField(col);
		if (clientSort === field) {
			clientOrder = clientOrder === 'asc' ? 'desc' : 'asc';
		} else {
			clientSort = field;
			clientOrder = 'asc';
		}
		clientPage = 0;
	}

	function pageHref(page: number): string {
		return hrefFor({ page });
	}

	function changeSize(size: number) {
		if (mode === 'server') {
			goto(hrefFor({ size, page: 0 }));
		} else {
			clientSize = size;
			clientPage = 0;
		}
	}

	function classForAlign(col: TableColumn): string {
		if (col.align === 'right') return 'text-right';
		if (col.align === 'center') return 'text-center';
		return 'text-left';
	}

	const hideClass = (col: TableColumn) =>
		col.hideBelow === 'sm' ? ' hidden sm:table-cell' : col.hideBelow === 'md' ? ' hidden md:table-cell' : '';
</script>

<div class="dtable w-full">
	{#if searchable}
		<div class="mb-4">
			{#if mode === 'server'}
				<form method="get" action={page.url.pathname} class="flex w-full max-w-sm items-center gap-2">
					{#each [...page.url.searchParams.entries()] as [name, value] (name)}
						{#if name !== 'search' && name !== 'page' && name !== 'size' && name !== 'sort' && name !== 'order'}
							<input type="hidden" name={name} value={value} />
						{/if}
					{/each}
					<input type="hidden" name="size" value={table.size} />
					<input type="hidden" name="sort" value={table.sort} />
					<input type="hidden" name="order" value={table.order} />
					<input
						type="search"
						name="search"
						value={displaySearch}
						placeholder={searchPlaceholder}
						class="border-input bg-background ring-offset-background placeholder:text-muted-foreground focus-visible:ring-ring h-10 w-full rounded-lg border px-3 py-2 text-sm outline-none focus-visible:ring-2"
					/>
					<button
						type="submit"
						class="bg-primary text-primary-foreground hover:bg-primary/90 inline-flex h-10 shrink-0 items-center rounded-lg px-4 text-sm font-medium transition-colors"
					>
						Cari
					</button>
				</form>
			{:else}
				<input
					type="search"
					bind:value={clientSearch}
					placeholder={searchPlaceholder}
					class="border-input bg-background ring-offset-background placeholder:text-muted-foreground focus-visible:ring-ring h-10 w-full max-w-sm rounded-lg border px-3 py-2 text-sm outline-none focus-visible:ring-2"
				/>
			{/if}
		</div>
	{/if}

	<div class="overflow-x-auto">
		<table class="dtable w-full min-w-[640px] border-separate border-spacing-0 text-sm">
			<thead>
				<tr class="bg-muted/40">
					{#each columns as col}
						<th
							class="border-border border-b px-4 py-3 text-sm font-semibold {classForAlign(col)}{hideClass(col)}"
						>
							{#if col.sortable}
								{#if mode === 'server'}
									<a href={toggleHref(col)} class="hover:text-foreground inline-flex items-center transition-colors">
										{col.label}{sortArrow(col)}
									</a>
								{:else}
									<button type="button" class="hover:text-foreground transition-colors" onclick={() => clientToggleSort(col)}>
										{col.label}{sortArrow(col)}
									</button>
								{/if}
							{:else}
								{col.label}
							{/if}
						</th>
					{/each}
				</tr>
			</thead>
			<tbody>
				{#if displayItems.length === 0}
					<tr>
						<td colspan={columns.length} class="text-muted-foreground px-4 py-10 text-center">
							{#if empty}
								{@render empty()}
							{:else}
								{emptyText}
							{/if}
						</td>
					</tr>
				{:else}
					{#each displayItems as item, index (rowKey(item, index))}
						<tr class="even:bg-muted/25 hover:bg-muted/30 transition-colors">
							{#each columns as col}
								<td
									data-label={col.label}
									class="border-border border-b px-4 py-3 align-middle {classForAlign(col)}{hideClass(col)}"
								>
									{#if cell}
										{@render cell(col, item)}
									{:else}
										{item[col.key] ?? ''}
									{/if}
								</td>
							{/each}
						</tr>
					{/each}
				{/if}
			</tbody>
		</table>
	</div>

	<div class="mt-4 flex flex-col gap-3 border-t pt-4 sm:flex-row sm:items-center sm:justify-between">
		<p class="text-muted-foreground text-sm">
			{#if displayTotal === 0}
				Menampilkan 0 data
			{:else}
				Menampilkan {from}–{to} dari {displayTotal} data
			{/if}
		</p>

		<div class="flex flex-wrap items-center gap-3">
			<label class="text-muted-foreground flex items-center gap-2 text-sm">
				Per halaman
				<select
					value={displaySize}
					onchange={(e) => changeSize(Number((e.currentTarget as HTMLSelectElement).value))}
					class="border-input bg-background ring-offset-background focus-visible:ring-ring h-9 rounded-lg border px-2 text-sm outline-none focus-visible:ring-2"
				>
					{#each sizeOptions as opt}
						<option value={opt}>{opt}</option>
					{/each}
				</select>
			</label>

			<div class="flex flex-wrap items-center gap-2">
				<p class="text-muted-foreground text-sm">Halaman {displayPage + 1} dari {pageCount}</p>
				{#if mode === 'server'}
					<a
						href={pageHref(0)}
						aria-disabled={displayPage === 0}
						class="border-input bg-background hover:bg-accent aria-disabled:pointer-events-none aria-disabled:text-muted-foreground inline-flex h-9 items-center rounded-lg border px-3 text-sm transition-colors"
					>Awal</a>
					<a
						href={pageHref(Math.max(0, displayPage - 1))}
						aria-disabled={displayPage === 0}
						class="border-input bg-background hover:bg-accent aria-disabled:pointer-events-none aria-disabled:text-muted-foreground inline-flex h-9 items-center rounded-lg border px-3 text-sm transition-colors"
					>Sebelumnya</a>
					<a
						href={pageHref(Math.min(pageCount - 1, displayPage + 1))}
						aria-disabled={displayPage >= pageCount - 1}
						class="border-input bg-background hover:bg-accent aria-disabled:pointer-events-none aria-disabled:text-muted-foreground inline-flex h-9 items-center rounded-lg border px-3 text-sm transition-colors"
					>Berikutnya</a>
					<a
						href={pageHref(pageCount - 1)}
						aria-disabled={displayPage >= pageCount - 1}
						class="border-input bg-background hover:bg-accent aria-disabled:pointer-events-none aria-disabled:text-muted-foreground inline-flex h-9 items-center rounded-lg border px-3 text-sm transition-colors"
					>Akhir</a>
				{:else}
					<button
						type="button"
						onclick={() => (clientPage = 0)}
						disabled={clientPage === 0}
						class="border-input bg-background hover:bg-accent disabled:text-muted-foreground h-9 rounded-lg border px-3 text-sm transition-colors disabled:cursor-not-allowed"
					>Awal</button>
					<button
						type="button"
						onclick={() => (clientPage = Math.max(0, clientPage - 1))}
						disabled={clientPage === 0}
						class="border-input bg-background hover:bg-accent disabled:text-muted-foreground h-9 rounded-lg border px-3 text-sm transition-colors disabled:cursor-not-allowed"
					>Sebelumnya</button>
					<button
						type="button"
						onclick={() => (clientPage = Math.min(pageCount - 1, clientPage + 1))}
						disabled={clientPage >= pageCount - 1}
						class="border-input bg-background hover:bg-accent disabled:text-muted-foreground h-9 rounded-lg border px-3 text-sm transition-colors disabled:cursor-not-allowed"
					>Berikutnya</button>
					<button
						type="button"
						onclick={() => (clientPage = pageCount - 1)}
						disabled={clientPage >= pageCount - 1}
						class="border-input bg-background hover:bg-accent disabled:text-muted-foreground h-9 rounded-lg border px-3 text-sm transition-colors disabled:cursor-not-allowed"
					>Akhir</button>
				{/if}
			</div>
		</div>
	</div>
</div>

<style>
	/*
	 * Responsive tables: below 640px the header row disappears and every row
	 * becomes a stacked card with the column label shown before each value via
	 * the data-label attribute.
	 */
	@media (max-width: 640px) {
		.dtable table {
			min-width: 0;
		}
		.dtable thead {
			display: none;
		}
		.dtable tbody {
			display: flex;
			flex-direction: column;
			gap: 0.75rem;
		}
		.dtable tbody tr {
			display: block;
			border: 1px solid var(--color-border);
			border-radius: 0.75rem;
			padding: 0.25rem 0;
			background: var(--color-card);
		}
		.dtable tbody tr.even\:bg-muted\/25 {
			background: var(--color-card);
		}
		.dtable tbody td {
			display: flex;
			align-items: center;
			justify-content: space-between;
			gap: 1rem;
			border: none;
			padding: 0.5rem 0.75rem;
			text-align: right;
		}
		.dtable tbody td::before {
			content: attr(data-label);
			font-weight: 600;
			color: var(--color-muted-foreground);
			text-align: left;
			flex-shrink: 0;
		}
	}
</style>
