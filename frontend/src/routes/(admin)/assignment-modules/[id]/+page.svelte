<script lang="ts">
	let { data } = $props();

	function formatDate(value: string | null) {
		if (!value) return '-';
		try {
			return new Date(value).toLocaleString('id-ID');
		} catch {
			return value;
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
