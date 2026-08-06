<script lang="ts">
	import { createApiClient } from '$lib/api/index';
	import { downloadBlob } from '$lib/utils';
	import DataTable from '$lib/components/table/DataTable.svelte';
	import type { TableColumn } from '$lib/table/types';

	const TEST_LABELS: Record<string, string> = {
		disc: 'DISC',
		holland: 'Holland RIASEC',
		papi: 'PAPI Kostick',
		cfit: 'IQ CFIT',
		ist: 'IQ IST'
	};

	let { data } = $props();
	let downloadingBatchId = $state<number | null>(null);
	let downloadError = $state<string | null>(null);

	const statusFilters = [
		{ value: '', label: 'Semua status' },
		{ value: 'active', label: 'Aktif' },
		{ value: 'inactive', label: 'Nonaktif' }
	];

	const columns: TableColumn[] = [
		{ key: 'id', label: 'ID', sortable: true, hideBelow: 'sm' },
		{ key: 'schoolName', label: 'Sekolah', sortable: true, sortKey: 'school.name' },
		{ key: 'categoryName', label: 'Kategori', sortable: true, sortKey: 'category.name', hideBelow: 'sm' },
		{ key: 'tests', label: 'Tes' },
		{ key: 'windowStart', label: 'Mulai', sortable: true, hideBelow: 'md' },
		{ key: 'windowEnd', label: 'Selesai', sortable: true, hideBelow: 'md' },
		{ key: 'active', label: 'Status', hideBelow: 'sm' },
		{ key: 'resultCount', label: 'Hasil', align: 'right' },
		{ key: 'actions', label: 'Aksi' }
	];

	function formatDate(value: string | null) {
		if (!value) return '-';
		try {
			return new Date(value).toLocaleDateString('id-ID');
		} catch {
			return value;
		}
	}

	async function handleDownloadBatch(batchId: number | null, filename: string | null) {
		if (!batchId) return;

		downloadingBatchId = batchId;
		downloadError = null;
		try {
			const api = createApiClient(data.token);
			const blob = await api.getBlob(`/credentials/batches/${batchId}/download`);
			downloadBlob(blob, filename ?? `kredensial-${batchId}.pdf`);
		} catch (e) {
			downloadError = e instanceof Error ? e.message : 'Gagal mengunduh PDF kredensial';
		} finally {
			downloadingBatchId = null;
		}
	}
</script>

<svelte:head><title>Modul Penugasan</title></svelte:head>

<div class="space-y-6">
	<div class="space-y-2">
		<h2 class="text-2xl font-bold">Modul Penugasan</h2>
		<p class="text-muted-foreground max-w-3xl text-sm">
			Organisasi modul berdasarkan penugasan yang benar-benar dibuat di sistem, bukan per jenis tes.
			Setiap modul penugasan merangkum sekolah, paket kategori, tes yang dibawa, dan hasil yang sudah masuk.
		</p>
	</div>

	<div class="grid gap-4 md:grid-cols-3">
		<div class="bg-card border-border rounded-xl border p-4">
			<p class="text-muted-foreground text-sm">Total modul</p>
			<p class="mt-2 text-2xl font-semibold">{data.summary.totalAssignments}</p>
		</div>
		<div class="bg-card border-border rounded-xl border p-4">
			<p class="text-muted-foreground text-sm">Modul aktif</p>
			<p class="mt-2 text-2xl font-semibold">{data.summary.activeAssignments}</p>
		</div>
		<div class="bg-card border-border rounded-xl border p-4">
			<p class="text-muted-foreground text-sm">Total hasil masuk</p>
			<p class="mt-2 text-2xl font-semibold">{data.summary.totalResults}</p>
		</div>
	</div>

	<div class="bg-card border-border rounded-2xl border p-5">
		<div class="mb-4 flex flex-wrap items-center justify-between gap-3">
			<div>
				<h3 class="text-lg font-semibold">Daftar Modul</h3>
				<p class="text-muted-foreground text-sm">Pencarian, filter, urutan, dan paging ditangani di server.</p>
			</div>
			<div class="flex flex-wrap gap-2">
				{#each statusFilters as sf}
					<a
						href={sf.value ? `?status=${sf.value}` : '?'}
						class={"inline-flex h-9 items-center rounded-lg px-3 text-sm font-medium transition-colors " +
							(data.status === sf.value
								? 'bg-primary text-primary-foreground'
								: 'border-input bg-background hover:bg-accent border')}
					>
						{sf.label}
					</a>
				{/each}
			</div>
		</div>

		{#if downloadError}
			<p class="text-destructive mb-3 text-sm">{downloadError}</p>
		{/if}

		<DataTable
			{columns}
			table={data.table}
			searchPlaceholder="Cari sekolah atau kategori..."
			emptyText="Tidak ada modul yang cocok."
			rowKey={(a: any) => a.id}
		>
			{#snippet cell(column, assignment)}
				{#if column.key === 'id'}
					<span class="text-muted-foreground">{assignment.id}</span>
				{:else if column.key === 'schoolName'}
					<span class="font-medium">{assignment.schoolName}</span>
				{:else if column.key === 'categoryName'}
					<span>{assignment.categoryName}</span>
				{:else if column.key === 'tests'}
					<div class="flex flex-wrap justify-end gap-1.5 sm:justify-start">
						{#each (assignment.tests ?? []) as testKey}
							<span class="bg-secondary text-secondary-foreground rounded-full px-2.5 py-1 text-xs font-medium">
								{TEST_LABELS[testKey] ?? String(testKey).toUpperCase()}
							</span>
						{/each}
					</div>
				{:else if column.key === 'windowStart'}
					<span class="text-muted-foreground">{formatDate(assignment.windowStart)}</span>
				{:else if column.key === 'windowEnd'}
					<span class="text-muted-foreground">{formatDate(assignment.windowEnd)}</span>
				{:else if column.key === 'active'}
					<span class={assignment.active ? 'text-green-600 text-sm font-medium' : 'text-muted-foreground text-sm'}>
						{assignment.active ? 'Aktif' : 'Nonaktif'}
					</span>
				{:else if column.key === 'resultCount'}
					<span class="font-medium">{assignment.resultCount}</span>
				{:else if column.key === 'actions'}
					<div class="flex flex-wrap justify-end gap-2 sm:justify-start">
						<a
							href={`/assignment-modules/${assignment.id}`}
							class="bg-primary text-primary-foreground hover:bg-primary/90 inline-flex h-10 items-center rounded-lg px-4 text-sm font-medium transition-colors"
						>
							Buka
						</a>
						{#if assignment.latestBatchId}
							<button
								type="button"
								onclick={() => handleDownloadBatch(assignment.latestBatchId, assignment.latestBatchFilename)}
								disabled={downloadingBatchId === assignment.latestBatchId}
								class="border-input bg-background hover:bg-accent disabled:opacity-50 inline-flex h-10 items-center rounded-lg border px-4 text-sm font-medium transition-colors"
							>
								{downloadingBatchId === assignment.latestBatchId ? 'Mengunduh...' : 'Unduh PDF'}
							</button>
						{/if}
					</div>
				{/if}
			{/snippet}
		</DataTable>
	</div>
</div>
