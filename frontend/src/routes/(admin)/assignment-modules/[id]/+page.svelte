<script lang="ts">
	import { createApiClient } from '$lib/api/index';
	import { downloadBlob } from '$lib/utils';
	import DataTable from '$lib/components/table/DataTable.svelte';
	import type { TableColumn, TableState } from '$lib/table/types';

	let { data } = $props();
	let downloadingBatchId = $state<number | null>(null);
	let downloadError = $state<string | null>(null);

	const batchColumns: TableColumn[] = [
		{ key: 'createdAt', label: 'Dibuat', sortable: true },
		{ key: 'credentialCount', label: 'Jumlah', sortable: true, align: 'right' },
		{ key: 'generatedBy', label: 'Oleh', hideBelow: 'sm' },
		{ key: 'actions', label: 'Aksi' }
	];

	const resultColumns: TableColumn[] = [
		{ key: 'studentName', label: 'Siswa', sortable: true },
		{ key: 'schoolName', label: 'Sekolah', hideBelow: 'sm' },
		{ key: 'summary', label: 'Ringkasan', hideBelow: 'sm' },
		{ key: 'completedAt', label: 'Selesai', sortable: true, hideBelow: 'sm' }
	];

	function clientTable(items: any[]): TableState {
		return { items, page: 0, size: 10, total: items.length, search: '', sort: '', order: 'asc' };
	}

	function formatDate(value: string | null) {
		if (!value) return '-';
		try {
			return new Date(value).toLocaleString('id-ID');
		} catch {
			return value;
		}
	}

	async function handleDownloadBatch(batchId: number, filename: string) {
		downloadingBatchId = batchId;
		downloadError = null;
		try {
			const api = createApiClient(data.token);
			const blob = await api.getBlob(`/credentials/batches/${batchId}/download`);
			downloadBlob(blob, filename);
		} catch (e) {
			downloadError = e instanceof Error ? e.message : 'Gagal mengunduh PDF kredensial';
		} finally {
			downloadingBatchId = null;
		}
	}
</script>

<svelte:head><title>Modul Penugasan #{data.assignment.id}</title></svelte:head>

<div class="space-y-6">
	<div class="space-y-2">
		<a href="/assignment-modules" class="text-muted-foreground hover:text-foreground text-sm transition-colors">
			&larr; Kembali ke Modul Penugasan
		</a>
		<h2 class="text-2xl font-bold">{data.assignment.schoolName}</h2>
		<p class="text-muted-foreground text-sm">
			{data.assignment.categoryName} ({data.assignment.categorySlug})
		</p>
	</div>

	<div class="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
		<div class="bg-card border-border rounded-xl border p-5">
			<p class="text-muted-foreground text-sm">ID penugasan</p>
			<p class="mt-2 text-3xl font-bold">{data.assignment.id}</p>
		</div>
		<div class="bg-card border-border rounded-xl border p-5">
			<p class="text-muted-foreground text-sm">Status</p>
			<p class="mt-2 text-3xl font-bold">{data.assignment.active ? 'Aktif' : 'Nonaktif'}</p>
		</div>
		<div class="bg-card border-border rounded-xl border p-5">
			<p class="text-muted-foreground text-sm">Tes dalam modul</p>
			<p class="mt-2 text-3xl font-bold">{data.moduleTests.length}</p>
		</div>
		<div class="bg-card border-border rounded-xl border p-5">
			<p class="text-muted-foreground text-sm">Total hasil masuk</p>
			<p class="mt-2 text-3xl font-bold">{data.totalResults}</p>
		</div>
	</div>

	<section class="bg-card border-border rounded-xl border p-6">
		<h3 class="text-lg font-semibold">Periode Penugasan</h3>
		<p class="text-muted-foreground mt-2 text-sm">
			{formatDate(data.assignment.windowStart)} - {formatDate(data.assignment.windowEnd)}
		</p>
	</section>

	<section class="bg-card border-border rounded-xl border p-6">
		<div class="mb-4 flex items-center justify-between gap-4">
			<div>
				<h3 class="text-lg font-semibold">Riwayat Kredensial</h3>
				<p class="text-muted-foreground text-sm">
					PDF kredensial (username + password) yang pernah dibuat untuk penugasan ini.
				</p>
			</div>
			<a
				href={`/credentials/new?assignmentId=${data.assignment.id}`}
				class="bg-primary text-primary-foreground hover:bg-primary/90 inline-flex h-10 shrink-0 items-center rounded-lg px-4 text-sm font-medium transition-colors"
			>
				Buat Kredensial Baru
			</a>
		</div>

		{#if downloadError}
			<p class="text-destructive mb-3 text-sm">{downloadError}</p>
		{/if}

		{#if data.credentialBatches.length === 0}
			<p class="text-muted-foreground text-sm">Belum ada kredensial yang pernah dibuat untuk penugasan ini.</p>
		{:else}
			<DataTable mode="client" columns={batchColumns} table={clientTable(data.credentialBatches)}>
				{#snippet cell(column, batch)}
					{#if column.key === 'createdAt'}
						<span>{formatDate(batch.createdAt)}</span>
					{:else if column.key === 'credentialCount'}
						<span class="font-medium">{batch.credentialCount} siswa</span>
					{:else if column.key === 'generatedBy'}
						<span class="text-muted-foreground">{batch.generatedBy}</span>
					{:else if column.key === 'actions'}
						<div class="flex items-center justify-end sm:justify-start">
							<button
								type="button"
								onclick={() => handleDownloadBatch(batch.id, batch.pdfFilename)}
								disabled={downloadingBatchId === batch.id}
								class="bg-secondary hover:bg-secondary/80 disabled:opacity-50 inline-flex h-9 items-center rounded-lg px-3 text-sm font-medium transition-colors"
							>
								{downloadingBatchId === batch.id ? 'Mengunduh...' : 'Unduh PDF'}
							</button>
						</div>
					{/if}
				{/snippet}
			</DataTable>
		{/if}
	</section>

	<div class="grid gap-6">
		{#each data.moduleTests as moduleTest}
			<section class="bg-card border-border rounded-xl border p-6">
				<div class="mb-4 flex items-center justify-between gap-4">
					<div>
						<h3 class="text-lg font-semibold">{moduleTest.label}</h3>
						<p class="text-muted-foreground text-sm">Hasil khusus untuk tes ini dalam penugasan #{data.assignment.id}</p>
					</div>
					<div class="text-right">
						<p class="text-muted-foreground text-sm">Hasil masuk</p>
						<p class="text-2xl font-bold">{moduleTest.resultCount}</p>
					</div>
				</div>

				{#if moduleTest.recentResults.length === 0}
					<p class="text-muted-foreground text-sm">Belum ada hasil untuk tes ini pada penugasan ini.</p>
				{:else}
					<DataTable mode="client" columns={resultColumns} table={clientTable(moduleTest.recentResults)}>
						{#snippet cell(column, result)}
							{#if column.key === 'studentName'}
								<span class="font-medium">{result.studentName}</span>
							{:else if column.key === 'schoolName'}
								<span class="text-muted-foreground">{result.schoolName}</span>
							{:else if column.key === 'summary'}
								<span>{result.summary}</span>
							{:else if column.key === 'completedAt'}
								<span class="text-muted-foreground">{formatDate(result.completedAt)}</span>
							{/if}
						{/snippet}
					</DataTable>
				{/if}
			</section>
		{/each}
	</div>
</div>
