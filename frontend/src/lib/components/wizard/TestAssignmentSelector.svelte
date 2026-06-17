<script lang="ts">
	import { Input } from '$lib/components/ui/input';

	/**
	 * TestAssignment interface matches the shape of data from +page.server.ts
	 */
	interface TestAssignment {
		id: number;
		schoolId: number;
		categoryId: number;
		school: {
			id: number;
			name: string;
		};
		category: {
			id: number;
			name: string;
			slug: string;
		};
		status: string;
		startDate: string;
		endDate: string;
	}

	/**
	 * Component props
	 * - assignments: list of active test assignments loaded from API
	 * - selected: the currently selected assignment (two-way binding)
	 */
	interface Props {
		assignments: TestAssignment[];
		selected: TestAssignment | null;
	}

	let { assignments = [], selected = $bindable(null) }: Props = $props();

	// ==================== Filter State ====================
	let schoolFilter = $state('');
	let categoryFilter = $state('');

	// ==================== Computed Filters ====================

	/**
	 * Filters assignments based on school name and category filters
	 * Case-insensitive substring matching
	 */
	let filteredAssignments = $derived.by(() => {
		return assignments.filter((assignment) => {
			const schoolMatch = assignment.school.name
				.toLowerCase()
				.includes(schoolFilter.toLowerCase());
			const categoryMatch = assignment.category.name
				.toLowerCase()
				.includes(categoryFilter.toLowerCase());
			return schoolMatch && categoryMatch;
		});
	});

	// ==================== Utility Functions ====================

	/**
	 * Format date string to readable format (DD/MM/YYYY)
	 */
	function formatDate(dateString: string): string {
		try {
			const date = new Date(dateString);
			return date.toLocaleDateString('id-ID', {
				year: 'numeric',
				month: '2-digit',
				day: '2-digit'
			});
		} catch {
			return dateString;
		}
	}

	/**
	 * Handle assignment selection via radio button
	 */
	function handleSelect(assignment: TestAssignment) {
		selected = assignment;
	}
</script>

<div class="flex flex-col gap-4">
	<!-- Filter Inputs -->
	<div class="grid grid-cols-1 gap-4 md:grid-cols-2">
		<div class="flex flex-col gap-2">
			<label for="school-filter" class="text-sm font-medium">
				Cari Sekolah
			</label>
			<Input
				id="school-filter"
				type="text"
				placeholder="Nama sekolah..."
				bind:value={schoolFilter}
			/>
		</div>
		<div class="flex flex-col gap-2">
			<label for="category-filter" class="text-sm font-medium">
				Cari Kategori Tes
			</label>
			<Input
				id="category-filter"
				type="text"
				placeholder="Kategori tes..."
				bind:value={categoryFilter}
			/>
		</div>
	</div>

	<!-- Assignment Table -->
	<div class="rounded-lg border border-border overflow-hidden">
		{#if filteredAssignments.length === 0}
			<div class="p-8 text-center">
				<p class="text-muted-foreground text-sm">
					{assignments.length === 0
						? 'Tidak ada penugasan tes aktif saat ini'
						: 'Tidak ada penugasan yang cocok dengan filter'}
				</p>
			</div>
		{:else}
			<table class="w-full text-sm">
				<thead class="bg-muted border-b border-border">
					<tr>
						<th class="w-12 px-4 py-3 text-left font-semibold">Pilih</th>
						<th class="px-4 py-3 text-left font-semibold">Nama Sekolah</th>
						<th class="px-4 py-3 text-left font-semibold">Kategori Tes</th>
						<th class="px-4 py-3 text-left font-semibold">Tanggal Mulai</th>
						<th class="px-4 py-3 text-left font-semibold">Tanggal Berakhir</th>
					</tr>
				</thead>
				<tbody>
					{#each filteredAssignments as assignment (assignment.id)}
						<tr
							class="border-b border-border hover:bg-muted/50 transition-colors cursor-pointer"
							onclick={() => handleSelect(assignment)}
						>
							<td class="px-4 py-3">
								<input
									type="radio"
									name="assignment"
									value={assignment.id}
									checked={selected?.id === assignment.id}
									onchange={() => handleSelect(assignment)}
									class="w-4 h-4"
								/>
							</td>
							<td class="px-4 py-3">
								<div class="font-medium">{assignment.school.name}</div>
							</td>
							<td class="px-4 py-3">
								<div class="text-muted-foreground">{assignment.category.name}</div>
							</td>
							<td class="px-4 py-3">
								<div class="text-muted-foreground">{formatDate(assignment.startDate)}</div>
							</td>
							<td class="px-4 py-3">
								<div class="text-muted-foreground">{formatDate(assignment.endDate)}</div>
							</td>
						</tr>
					{/each}
				</tbody>
			</table>
		{/if}
	</div>

	<!-- Selection Status -->
	{#if selected}
		<div class="rounded-lg bg-primary/10 p-4">
			<p class="text-sm font-medium">
				<span class="text-primary">Dipilih:</span>
				{selected.school.name} - {selected.category.name}
			</p>
		</div>
	{/if}
</div>

<style>
	/* Tailwind handles all styling via class directives */
</style>

