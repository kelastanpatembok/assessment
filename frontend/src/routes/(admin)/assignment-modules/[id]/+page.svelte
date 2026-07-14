<script lang="ts">
	import { createApiClient } from '$lib/api/index';
	import { downloadBlob } from '$lib/utils';

	let { data } = $props();
	let downloadingBatchId = $state<number | null>(null);
	let downloadError = $state<string | null>(null);

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
			<div class="overflow-x-auto">
				<table class="w-full text-sm">
					<thead class="bg-muted/60 border-border border-b">
						<tr>
							<th class="px-3 py-2 text-left font-semibold">Dibuat</th>
							<th class="px-3 py-2 text-left font-semibold">Jumlah</th>
							<th class="px-3 py-2 text-left font-semibold">Oleh</th>
							<th class="px-3 py-2 text-left font-semibold">Aksi</th>
						</tr>
					</thead>
					<tbody>
						{#each data.credentialBatches as batch}
							<tr class="border-border border-b">
								<td class="px-3 py-3">{formatDate(batch.createdAt)}</td>
								<td class="px-3 py-3">{batch.credentialCount} siswa</td>
								<td class="px-3 py-3">{batch.generatedBy}</td>
								<td class="px-3 py-3">
									<button
										type="button"
										onclick={() => handleDownloadBatch(batch.id, batch.pdfFilename)}
										disabled={downloadingBatchId === batch.id}
										class="bg-secondary hover:bg-secondary/80 disabled:opacity-50 inline-flex h-9 items-center rounded-lg px-3 text-sm font-medium transition-colors"
									>
										{downloadingBatchId === batch.id ? 'Mengunduh...' : 'Unduh PDF'}
									</button>
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
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
					<div class="overflow-x-auto">
						<table class="w-full text-sm">
							<thead class="bg-muted/60 border-border border-b">
								<tr>
									<th class="px-3 py-2 text-left font-semibold">Siswa</th>
									<th class="px-3 py-2 text-left font-semibold">Sekolah</th>
									<th class="px-3 py-2 text-left font-semibold">Ringkasan</th>
									<th class="px-3 py-2 text-left font-semibold">Selesai</th>
								</tr>
							</thead>
							<tbody>
								{#each moduleTest.recentResults as result}
									<tr class="border-border border-b">
										<td class="px-3 py-3">{result.studentName}</td>
										<td class="px-3 py-3">{result.schoolName}</td>
										<td class="px-3 py-3">{result.summary}</td>
										<td class="px-3 py-3">{formatDate(result.completedAt)}</td>
									</tr>
								{/each}
							</tbody>
						</table>
					</div>
				{/if}
			</section>
		{/each}
	</div>
</div>
