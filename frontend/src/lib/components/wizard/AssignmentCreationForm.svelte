<script lang="ts">
	import { Input } from '$lib/components/ui/input';
	import { Label } from '$lib/components/ui/label';
	import { Combobox } from 'bits-ui';
	import { TEST_METHODS, TEST_METHOD_LABELS, methodLabel } from '$lib/test-methods';

	interface School {
		id: number;
		name: string;
	}

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
		schools: School[];
		categories: TestCategory[];
		form: AssignmentForm;
		errors?: { [key: string]: string };
	}

	let { schools = [], categories = [], form = $bindable(), errors = {} }: Props = $props();

	// School combobox state: the input text drives filtering; the selection is
	// form.schoolId (string for bits-ui, number in the form).
	let inputText = $state('');
	let open = $state(false);

	const selectedSchool = $derived(schools.find((s) => s.id === form.schoolId) ?? null);

	const filteredSchools = $derived(
		schools.filter((s) => s.name.toLowerCase().includes(inputText.trim().toLowerCase()))
	);

	const comboboxItems = $derived(
		filteredSchools.map((s) => ({ value: String(s.id), label: s.name }))
	);

	function handleInputChange(event: Event) {
		const value = (event.currentTarget as HTMLInputElement).value;
		inputText = value;
		// Keep the form value honest: if the text no longer matches the selected
		// school, drop the selection instead of submitting a stale school.
		if (selectedSchool && !selectedSchool.name.toLowerCase().includes(value.trim().toLowerCase())) {
			form.schoolId = null;
		}
	}

	function handleOpen() {
		// Fresh browse: if the input just shows a selected school's name, clear
		// it so the full list is visible instead of a single filtered result.
		if (selectedSchool && inputText === selectedSchool.name) {
			inputText = '';
		}
		open = true;
	}

	function handleValueChange(value: string) {
		if (value) {
			const school = schools.find((s) => String(s.id) === value);
			if (school) {
				form.schoolId = school.id;
				inputText = school.name;
			}
		} else {
			form.schoolId = null;
			inputText = '';
		}
		open = false;
	}

	function clearSchool() {
		form.schoolId = null;
		inputText = '';
	}

	function getSelectedSchoolName(): string {
		return selectedSchool?.name ?? '';
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
		<Label for="school">Pilih Sekolah</Label>
		<Combobox.Root
			type="single"
			value={form.schoolId != null ? String(form.schoolId) : ''}
			onValueChange={handleValueChange}
			bind:open={open}
			inputValue={inputText}
			items={comboboxItems}
			loop
		>
			<div class="relative">
				<div class="relative">
					<Combobox.Input
						id="school"
						placeholder="Cari atau pilih sekolah..."
						oninput={handleInputChange}
						onfocus={handleOpen}
						onclick={handleOpen}
						class="flex h-10 w-full rounded-md border border-input bg-background pl-9 pr-8 py-2 text-sm ring-offset-background placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
					/>
					<svg
						class="pointer-events-none absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground"
						viewBox="0 0 20 20"
						fill="none"
						stroke="currentColor"
						stroke-width="1.6"
						stroke-linecap="round"
						stroke-linejoin="round"
						aria-hidden="true"
					>
						<circle cx="9" cy="9" r="6" />
						<line x1="14" y1="14" x2="17.5" y2="17.5" />
					</svg>
					{#if form.schoolId}
						<button
							type="button"
							aria-label="Hapus pilihan sekolah"
							onclick={clearSchool}
							class="absolute right-2 top-1/2 -translate-y-1/2 inline-flex h-6 w-6 items-center justify-center rounded-md text-muted-foreground hover:bg-muted hover:text-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
						>
							<svg
								class="h-3.5 w-3.5"
								viewBox="0 0 20 20"
								fill="none"
								stroke="currentColor"
								stroke-width="1.8"
								stroke-linecap="round"
								stroke-linejoin="round"
								aria-hidden="true"
							>
								<line x1="5" y1="5" x2="15" y2="15" />
								<line x1="15" y1="5" x2="5" y2="15" />
							</svg>
						</button>
					{/if}
				</div>

				<Combobox.ContentStatic class="absolute z-10 mt-1 w-full">
				<div class="bg-card border-border rounded-md border shadow-lg max-h-60 overflow-y-auto py-1">
					{#if filteredSchools.length > 0}
						<p class="px-3 py-1 text-xs text-muted-foreground">
							{filteredSchools.length} sekolah ditemukan
						</p>
						{#each filteredSchools as school (school.id)}
							<Combobox.Item
								value={String(school.id)}
								label={school.name}
								class="w-full px-3 py-2 text-left text-sm hover:bg-muted focus:bg-muted focus:outline-none"
							>
								{#snippet children({ selected })}
									<span class="flex items-center justify-between gap-2">
										<span class="truncate">{school.name}</span>
										{#if selected}
											<svg
												class="h-4 w-4 shrink-0 text-foreground"
												viewBox="0 0 20 20"
												fill="none"
												stroke="currentColor"
												stroke-width="2"
												stroke-linecap="round"
												stroke-linejoin="round"
												aria-hidden="true"
											>
												<polyline points="4 10.5 8.5 15 16 6" />
											</svg>
										{/if}
									</span>
								{/snippet}
							</Combobox.Item>
						{/each}
					{:else}
						<div class="px-3 py-2 text-sm text-muted-foreground">
							Tidak ditemukan sekolah yang sesuai
						</div>
					{/if}
				</div>
			</Combobox.ContentStatic>
			</div>
		</Combobox.Root>
		{#if errors.schoolId}
			<p class="text-sm text-destructive">{errors.schoolId}</p>
		{/if}
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
				<p><span class="font-medium">Sekolah:</span> {getSelectedSchoolName()}</p>
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
