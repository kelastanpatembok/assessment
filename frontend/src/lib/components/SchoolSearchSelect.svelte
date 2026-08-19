<script lang="ts">
	import { Combobox } from 'bits-ui';
	import { createApiClient } from '$lib/api';

	interface School {
		id: number;
		name: string;
		npsn?: string;
		city?: string;
		province?: string;
	}

	interface Props {
		token: string | null;
		/** Bound school id (null = none selected). */
		value?: number | null;
		/** When set, renders a hidden <input name={name}> for form POSTs. */
		name?: string;
		placeholder?: string;
		required?: boolean;
		/** Allow clearing the selection (default true). */
		allowClear?: boolean;
		error?: string;
		/** Called with the chosen school. */
		onselect?: (school: School) => void;
	}

	let {
		token,
		value = $bindable(),
		name,
		placeholder = 'Cari sekolah...',
		required = false,
		allowClear = true,
		error,
		onselect
	}: Props = $props();

	let inputText = $state('');
	let open = $state(false);
	let results = $state<School[]>([]);
	let searching = $state(false);
	let searchTimer: ReturnType<typeof setTimeout> | null = null;

	// On mount, if a school is already selected (edit modals), load its name so
	// the input shows the current value instead of an empty box.
	$effect(() => {
		if (value != null && !inputText) {
			loadSchoolById(value);
		}
	});

	function loadSchoolById(id: number) {
		const api = createApiClient(token);
		api.get(`/schools/${id}`)
			.then((school: any) => {
				if (school?.name) {
					inputText = school.name;
					onselect?.({ id: school.id, name: school.name });
				}
			})
			.catch(() => {});
	}

	async function runSearch(query: string) {
		searching = true;
		try {
			const api = createApiClient(token);
			const q = query.trim();
			const url = q ? `/schools?search=${encodeURIComponent(q)}&size=20&sort=name&order=asc` : '/schools?size=20&sort=name&order=asc';
			const data = await api.get(url);
			// Paginated response envelope: { items, page, size, totalElements }.
			results = Array.isArray(data) ? data : (data?.items ?? []);
		} catch {
			results = [];
		} finally {
			searching = false;
		}
	}

	function handleInputChange(event: Event) {
		const value = (event.currentTarget as HTMLInputElement).value;
		inputText = value;
		if (value == null || value === '') {
			results = [];
			open = true;
			return;
		}
		if (searchTimer) clearTimeout(searchTimer);
		searchTimer = setTimeout(() => {
			runSearch(inputText);
			open = true;
		}, 300);
	}

	function handleOpen() {
		open = true;
		if (inputText.trim() === '') {
			// Fresh browse: show the first page of schools so the field isn't empty.
			runSearch('');
		}
	}

	function handleValueChange(selectedValue: string) {
		const school = results.find((s) => String(s.id) === selectedValue);
		if (school) {
			value = school.id;
			inputText = school.name;
			onselect?.(school);
		}
		open = false;
	}

	function clearSelection() {
		value = null;
		inputText = '';
		results = [];
	}
</script>

{#if name}
	<input type="hidden" {name} value={value ?? ''} />
{/if}

<Combobox.Root
	type="single"
	value={value != null ? String(value) : ''}
	onValueChange={handleValueChange}
	bind:open={open}
	inputValue={inputText}
	items={results.map((s) => ({ value: String(s.id), label: s.name }))}
	loop
>
	<div class="relative">
		<div class="relative">
			<Combobox.Input
				{placeholder}
				{required}
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
			{#if value != null && allowClear}
				<button
					type="button"
					aria-label="Hapus pilihan sekolah"
					onclick={clearSelection}
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
				{#if searching}
					<div class="px-3 py-2 text-sm text-muted-foreground">Mencari...</div>
				{:else if results.length > 0}
					<p class="px-3 py-1 text-xs text-muted-foreground">
						{results.length} sekolah ditemukan
					</p>
					{#each results as school (school.id)}
						<Combobox.Item
							value={String(school.id)}
							label={school.name}
							class="w-full px-3 py-2 text-left text-sm hover:bg-muted focus:bg-muted focus:outline-none"
						>
							{#snippet children({ selected })}
								<span class="flex items-center justify-between gap-2">
									<span class="flex flex-col">
										<span class="truncate">{school.name}</span>
										{#if school.city || school.province}
											<span class="text-muted-foreground text-xs truncate">
												{[school.city, school.province].filter(Boolean).join(', ')}
											</span>
										{/if}
									</span>
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
{#if error}
	<p class="text-sm text-destructive">{error}</p>
{/if}
