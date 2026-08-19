<script lang="ts">
	import { Input } from '$lib/components/ui/input';
	import { Label } from '$lib/components/ui/label';
	import SchoolSearchSelect from '$lib/components/SchoolSearchSelect.svelte';
	import { TEST_METHODS, TEST_METHOD_LABELS, methodLabel } from '$lib/test-methods';

	interface TestCategory {
		id: number;
		name: string;
		slug: string;
		tests: string[];
	}

	interface AssignmentForm {
		schoolId: number | null;
		tests: string[];
		startDate: string;
		endDate: string;
	}

	interface Props {
		token: string | null;
		categories: TestCategory[];
		form: AssignmentForm;
		errors?: { [key: string]: string };
		onselect?: (school: { id: number; name: string }) => void;
	}

	let { token, categories = [], form = $bindable(), errors = {}, onselect }: Props = $props();

	let selectedSchoolName = $state('');

	function handleSchoolSelect(school: { id: number; name: string }) {
		form.schoolId = school.id;
		selectedSchoolName = school.name;
		onselect?.(school);
	}

	// Test method selection: canonical methods plus any extra test keys found in
	// the estate's categories, in canonical display order.
	const methodOptions = $derived.by(() => {
		const keys = new Set<string>(TEST_METHODS.map((m) => m.key));
		for (const c of categories) {
			for (const t of c.tests ?? []) keys.add(t);
		}
		const canonical = TEST_METHODS.filter((m) => keys.has(m.key));
		const extras = [...keys]
			.filter((k) => !TEST_METHOD_LABELS[k])
			.sort((a, b) => a.localeCompare(b))
			.map((key) => ({ key, label: methodLabel(key) }));
		return [...canonical, ...extras];
	});

	const allSelected = $derived(
		methodOptions.length > 0 && form.tests.length === methodOptions.length
	);

	function toggleAll() {
		form.tests = allSelected ? [] : methodOptions.map((m) => m.key);
	}

	function toggleMethod(key: string) {
		if (form.tests.includes(key)) {
			form.tests = form.tests.filter((k) => k !== key);
		} else {
			form.tests = [...form.tests, key];
		}
	}

	const selectedMethodLabels = $derived(
		form.tests.map((k) => methodLabel(k)).join(', ')
	);

	// Existing category whose tests exactly match the selection (used for a
	// preview hint; the actual resolve/create happens on submit in the parent).
	const matchedCategory = $derived.by(() => {
		if (form.tests.length === 0) return null;
		const sorted = [...form.tests].sort().join('|');
		return (
			categories.find((c) => [...(c.tests ?? [])].sort().join('|') === sorted) ?? null
		);
	});

	// Auto-set default dates (today + 30 days from now)
	$effect(() => {
		if (!form.startDate) {
			const today = new Date();
			form.startDate = today.toISOString().split('T')[0];
		}
		if (!form.endDate) {
			const future = new Date();
			future.setDate(future.getDate() + 30);
			form.endDate = future.toISOString().split('T')[0];
		}
	});
</script>

<div class="space-y-6">
	<!-- School Selection -->
	<div class="space-y-2">
		<Label>Pilih Sekolah</Label>
		<SchoolSearchSelect {token} bind:value={form.schoolId} onselect={handleSchoolSelect} placeholder="Cari atau pilih sekolah..." error={errors.schoolId} />
	</div>

	<!-- Test Methods Selection -->
	<div class="space-y-2">
		<div class="flex items-center justify-between">
			<Label>Metode Tes</Label>
			{#if form.tests.length > 0}
				<span class="text-xs text-muted-foreground">
					{form.tests.length}/{methodOptions.length} dipilih
				</span>
			{/if}
		</div>
		<div class="border-input rounded-md border p-3">
			<label class="flex cursor-pointer items-center gap-2.5 py-1">
				<input
					type="checkbox"
					class="size-4 accent-primary"
					checked={allSelected}
					onchange={toggleAll}
				/>
				<span class="text-sm font-medium">Semua Metode</span>
			</label>
			<div class="border-t border-border mt-2 pt-2 grid grid-cols-1 gap-1 sm:grid-cols-2">
				{#each methodOptions as method (method.key)}
					<label class="flex cursor-pointer items-center gap-2.5 py-1">
						<input
							type="checkbox"
							class="size-4 accent-primary"
							checked={form.tests.includes(method.key)}
							onchange={() => toggleMethod(method.key)}
						/>
						<span class="text-sm">{method.label}</span>
					</label>
				{/each}
			</div>
		</div>
		{#if errors.tests}
			<p class="text-sm text-destructive">{errors.tests}</p>
		{/if}
	</div>

	<!-- Date Range -->
	<div class="grid grid-cols-1 gap-4 md:grid-cols-2">
		<div class="space-y-2">
			<Label for="start-date">Tanggal Mulai</Label>
			<Input
				id="start-date"
				type="date"
				bind:value={form.startDate}
			/>
			{#if errors.startDate}
				<p class="text-sm text-destructive">{errors.startDate}</p>
			{/if}
		</div>

		<div class="space-y-2">
			<Label for="end-date">Tanggal Berakhir</Label>
			<Input
				id="end-date"
				type="date"
				bind:value={form.endDate}
			/>
			{#if errors.endDate}
				<p class="text-sm text-destructive">{errors.endDate}</p>
			{/if}
		</div>
	</div>

	<!-- Preview/Summary -->
	{#if form.schoolId && form.tests.length > 0}
		<div class="rounded-lg bg-muted p-4">
			<h3 class="font-semibold text-sm mb-2">Ringkasan Penugasan</h3>
			<div class="space-y-1 text-sm">
				<p><span class="font-medium">Sekolah:</span> {selectedSchoolName}</p>
				<p><span class="font-medium">Metode:</span> {selectedMethodLabels}</p>
				{#if matchedCategory}
					<p>
						<span class="font-medium">Kategori:</span> {matchedCategory.name}
					</p>
				{:else}
					<p>
						<span class="font-medium">Kategori:</span>
						<span class="text-muted-foreground">kombinasi kustom — akan dibuat otomatis</span>
					</p>
				{/if}
				<p><span class="font-medium">Periode:</span> {form.startDate} s/d {form.endDate}</p>
			</div>
		</div>
	{/if}
</div>
