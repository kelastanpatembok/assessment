<script lang="ts">
	let { data } = $props();

	type AssignmentRow = (typeof data.assignments)[number];
	type SortKey = 'schoolName' | 'categoryName' | 'windowStart' | 'windowEnd' | 'resultCount';
	type SortDirection = 'asc' | 'desc';

	const PAGE_SIZE = 10;

	let searchQuery = $state('');
	let statusFilter = $state<'all' | 'active' | 'inactive'>('all');
	let testFilter = $state('all');
	let sortKey = $state<SortKey>('windowStart');
	let sortDirection = $state<SortDirection>('desc');
	let currentPage = $state(1);

	function formatDate(value: string | null) {
		if (!value) return '-';
		try {
			return new Date(value).toLocaleDateString('id-ID');
		} catch {
			return value;
		}
	}

	function getSortValue(assignment: AssignmentRow, key: SortKey) {
		if (key === 'resultCount') return assignment.resultCount;
		if (key === 'windowStart' || key === 'windowEnd') {
			return assignment[key] ? new Date(assignment[key] ?? '').getTime() : 0;
		}
		return assignment[key].toLocaleLowerCase();
	}

	function toggleSort(nextKey: SortKey) {
		if (sortKey === nextKey) {
			sortDirection = sortDirection === 'asc' ? 'desc' : 'asc';
			return;
		}

		sortKey = nextKey;
		sortDirection = nextKey === 'resultCount' ? 'desc' : 'asc';
	}

	function sortLabel(key: SortKey) {
		if (sortKey !== key) return '';
		return sortDirection === 'asc' ? ' ↑' : ' ↓';
	}

	const testOptions = $derived.by(() => {
		const tests = new Map<string, string>();

		for (const assignment of data.assignments) {
			for (const test of assignment.tests) {
				if (!tests.has(test.key)) {
					tests.set(test.key, test.label);
				}
			}
		}

		return Array.from(tests.entries())
			.map(([key, label]) => ({ key, label }))
			.sort((left, right) => left.label.localeCompare(right.label, 'id-ID'));
	});

	const filteredAssignments = $derived.by(() => {
		const query = searchQuery.trim().toLowerCase();

		return data.assignments
			.filter((assignment) => {
				if (statusFilter === 'active' && !assignment.active) return false;
				if (statusFilter === 'inactive' && assignment.active) return false;
				if (testFilter !== 'all' && !assignment.tests.some((test) => test.key === testFilter)) return false;
				if (!query) return true;

				const haystack = [
					assignment.id,
					assignment.schoolName,
					assignment.categoryName,
					assignment.tests.map((test) => test.label).join(' ')
				]
					.join(' ')
					.toLowerCase();

				return haystack.includes(query);
			})
			.sort((left, right) => {
				const leftValue = getSortValue(left, sortKey);
				const rightValue = getSortValue(right, sortKey);

				if (leftValue < rightValue) return sortDirection === 'asc' ? -1 : 1;
				if (leftValue > rightValue) return sortDirection === 'asc' ? 1 : -1;
				return left.schoolName.localeCompare(right.schoolName, 'id-ID');
			});
	});

	const totalPages = $derived.by(() => Math.max(1, Math.ceil(filteredAssignments.length / PAGE_SIZE)));

	$effect(() => {
		searchQuery;
		statusFilter;
		testFilter;
		sortKey;
		sortDirection;
		currentPage = 1;
	});

	$effect(() => {
		if (currentPage > totalPages) {
			currentPage = totalPages;
		}
	});

	const pageRange = $derived.by(() => {
		if (filteredAssignments.length === 0) {
			return { from: 0, to: 0 };
		}

		const from = (currentPage - 1) * PAGE_SIZE + 1;
		const to = Math.min(currentPage * PAGE_SIZE, filteredAssignments.length);
		return { from, to };
	});

	const paginatedAssignments = $derived.by(() => {
		const start = (currentPage - 1) * PAGE_SIZE;
		return filteredAssignments.slice(start, start + PAGE_SIZE);
	});

	const summary = $derived.by(() => {
		const activeCount = data.assignments.filter((assignment) => assignment.active).length;
		const totalResults = data.assignments.reduce((sum, assignment) => sum + assignment.resultCount, 0);

		return {
			totalAssignments: data.assignments.length,
			activeCount,
			totalResults
		};
	});
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
			<p class="mt-2 text-2xl font-semibold">{summary.totalAssignments}</p>
		</div>
		<div class="bg-card border-border rounded-xl border p-4">
			<p class="text-muted-foreground text-sm">Modul aktif</p>
			<p class="mt-2 text-2xl font-semibold">{summary.activeCount}</p>
		</div>
		<div class="bg-card border-border rounded-xl border p-4">
			<p class="text-muted-foreground text-sm">Total hasil masuk</p>
			<p class="mt-2 text-2xl font-semibold">{summary.totalResults}</p>
		</div>
	</div>

	{#if data.assignments.length === 0}
		<div class="bg-card border-border rounded-xl border p-6 text-sm text-muted-foreground">
			Belum ada penugasan yang bisa dijadikan modul.
		</div>
	{:else}
		<div class="bg-card border-border rounded-2xl border p-5">
			<div class="space-y-5">
				<div class="flex flex-col gap-3 lg:flex-row lg:items-end lg:justify-between">
					<div>
						<h3 class="text-lg font-semibold">Daftar Modul</h3>
						<p class="text-muted-foreground text-sm">
							Tabel ini dibuat untuk volume data besar, jadi pencarian, filter, urutan, dan paging ada di satu tempat.
						</p>
					</div>
					<div class="text-muted-foreground text-sm">
						Menampilkan {pageRange.from}-{pageRange.to} dari {filteredAssignments.length} modul
					</div>
				</div>

				<div class="grid gap-3 lg:grid-cols-[minmax(0,2fr),220px,220px]">
					<label class="space-y-2">
						<span class="text-sm font-medium">Cari modul</span>
						<input
							bind:value={searchQuery}
							type="search"
							placeholder="Cari sekolah, kategori, ID, atau nama tes"
							class="border-input bg-background ring-offset-background placeholder:text-muted-foreground focus-visible:ring-ring flex h-11 w-full rounded-lg border px-3 py-2 text-sm outline-none focus-visible:ring-2"
						/>
					</label>

					<label class="space-y-2">
						<span class="text-sm font-medium">Status</span>
						<select
							bind:value={statusFilter}
							class="border-input bg-background ring-offset-background focus-visible:ring-ring h-11 w-full rounded-lg border px-3 text-sm outline-none focus-visible:ring-2"
						>
							<option value="all">Semua status</option>
							<option value="active">Aktif</option>
							<option value="inactive">Nonaktif</option>
						</select>
					</label>

					<label class="space-y-2">
						<span class="text-sm font-medium">Tes</span>
						<select
							bind:value={testFilter}
							class="border-input bg-background ring-offset-background focus-visible:ring-ring h-11 w-full rounded-lg border px-3 text-sm outline-none focus-visible:ring-2"
						>
							<option value="all">Semua tes</option>
							{#each testOptions as test}
								<option value={test.key}>{test.label}</option>
							{/each}
						</select>
					</label>
				</div>

				<div class="overflow-x-auto">
					<table class="w-full min-w-[1080px] border-separate border-spacing-0">
						<thead>
							<tr class="bg-muted/40">
								<th class="border-border border-b px-4 py-3 text-left text-sm font-semibold">ID</th>
								<th class="border-border border-b px-4 py-3 text-left text-sm font-semibold">
									<button type="button" class="hover:text-foreground transition-colors" onclick={() => toggleSort('schoolName')}>
										Sekolah{sortLabel('schoolName')}
									</button>
								</th>
								<th class="border-border border-b px-4 py-3 text-left text-sm font-semibold">
									<button type="button" class="hover:text-foreground transition-colors" onclick={() => toggleSort('categoryName')}>
										Kategori{sortLabel('categoryName')}
									</button>
								</th>
								<th class="border-border border-b px-4 py-3 text-left text-sm font-semibold">Tes</th>
								<th class="border-border border-b px-4 py-3 text-left text-sm font-semibold">
									<button type="button" class="hover:text-foreground transition-colors" onclick={() => toggleSort('windowStart')}>
										Mulai{sortLabel('windowStart')}
									</button>
								</th>
								<th class="border-border border-b px-4 py-3 text-left text-sm font-semibold">
									<button type="button" class="hover:text-foreground transition-colors" onclick={() => toggleSort('windowEnd')}>
										Selesai{sortLabel('windowEnd')}
									</button>
								</th>
								<th class="border-border border-b px-4 py-3 text-left text-sm font-semibold">Status</th>
								<th class="border-border border-b px-4 py-3 text-left text-sm font-semibold">
									<button type="button" class="hover:text-foreground transition-colors" onclick={() => toggleSort('resultCount')}>
										Hasil{sortLabel('resultCount')}
									</button>
								</th>
								<th class="border-border border-b px-4 py-3 text-left text-sm font-semibold">Aksi</th>
							</tr>
						</thead>
						<tbody>
							{#if paginatedAssignments.length === 0}
								<tr>
									<td colspan="9" class="text-muted-foreground px-4 py-8 text-center text-sm">
										Tidak ada modul yang cocok dengan filter saat ini.
									</td>
								</tr>
							{:else}
								{#each paginatedAssignments as assignment}
									<tr class="hover:bg-muted/20 transition-colors">
										<td class="border-border border-b px-4 py-4 align-top text-sm font-medium">{assignment.id}</td>
										<td class="border-border border-b px-4 py-4 align-top">
											<div class="font-medium">{assignment.schoolName}</div>
										</td>
										<td class="border-border border-b px-4 py-4 align-top text-sm">{assignment.categoryName}</td>
										<td class="border-border border-b px-4 py-4 align-top">
											<div class="flex flex-wrap gap-2">
												{#each assignment.tests as test}
													<span class="bg-secondary text-secondary-foreground rounded-full px-2.5 py-1 text-xs font-medium">
														{test.label}
													</span>
												{/each}
											</div>
										</td>
										<td class="border-border border-b px-4 py-4 align-top text-sm">{formatDate(assignment.windowStart)}</td>
										<td class="border-border border-b px-4 py-4 align-top text-sm">{formatDate(assignment.windowEnd)}</td>
										<td class="border-border border-b px-4 py-4 align-top">
											<span class={assignment.active ? 'text-green-600 text-sm font-medium' : 'text-muted-foreground text-sm'}>
												{assignment.active ? 'Aktif' : 'Nonaktif'}
											</span>
										</td>
										<td class="border-border border-b px-4 py-4 align-top text-sm font-medium">{assignment.resultCount}</td>
										<td class="border-border border-b px-4 py-4 align-top">
											<a
												href={`/assignment-modules/${assignment.id}`}
												class="bg-primary text-primary-foreground hover:bg-primary/90 inline-flex h-10 items-center rounded-lg px-4 text-sm font-medium transition-colors"
											>
												Buka
											</a>
										</td>
									</tr>
								{/each}
							{/if}
						</tbody>
					</table>
				</div>

				<div class="flex flex-col gap-3 border-t pt-4 sm:flex-row sm:items-center sm:justify-between">
					<div class="text-muted-foreground text-sm">
						Halaman {currentPage} dari {totalPages}
					</div>
					<div class="flex flex-wrap gap-2">
						<button
							type="button"
							class="border-input bg-background hover:bg-accent disabled:text-muted-foreground disabled:hover:bg-background h-10 rounded-lg border px-3 text-sm transition-colors disabled:cursor-not-allowed"
							onclick={() => (currentPage = 1)}
							disabled={currentPage === 1}
						>
							Awal
						</button>
						<button
							type="button"
							class="border-input bg-background hover:bg-accent disabled:text-muted-foreground disabled:hover:bg-background h-10 rounded-lg border px-3 text-sm transition-colors disabled:cursor-not-allowed"
							onclick={() => (currentPage = Math.max(1, currentPage - 1))}
							disabled={currentPage === 1}
						>
							Sebelumnya
						</button>
						<button
							type="button"
							class="border-input bg-background hover:bg-accent disabled:text-muted-foreground disabled:hover:bg-background h-10 rounded-lg border px-3 text-sm transition-colors disabled:cursor-not-allowed"
							onclick={() => (currentPage = Math.min(totalPages, currentPage + 1))}
							disabled={currentPage === totalPages}
						>
							Berikutnya
						</button>
						<button
							type="button"
							class="border-input bg-background hover:bg-accent disabled:text-muted-foreground disabled:hover:bg-background h-10 rounded-lg border px-3 text-sm transition-colors disabled:cursor-not-allowed"
							onclick={() => (currentPage = totalPages)}
							disabled={currentPage === totalPages}
						>
							Akhir
						</button>
					</div>
				</div>
			</div>
		</div>
	{/if}
</div>
