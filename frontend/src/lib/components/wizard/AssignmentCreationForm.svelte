<script lang="ts">
	import { Input } from '$lib/components/ui/input';
	import { Label } from '$lib/components/ui/label';

	interface School {
		id: number;
		name: string;
	}

	interface TestCategory {
		id: number;
		name: string;
		slug: string;
	}

	interface AssignmentForm {
		schoolId: number | null;
		categoryId: number | null;
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

	// School search state
	let searchTerm = $state('');
	let showDropdown = $state(false);
	let filteredSchools = $derived(
		schools.filter(school => 
			school.name.toLowerCase().includes(searchTerm.toLowerCase())
		)
	);

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

	function getSelectedSchoolName(): string {
		const school = schools.find(s => s.id === form.schoolId);
		return school?.name || '';
	}

	function getSelectedCategoryName(): string {
		const category = categories.find(c => c.id === form.categoryId);
		return category?.name || '';
	}

	function handleSchoolInput(event: Event) {
		const target = event.target as HTMLInputElement;
		searchTerm = target.value;
		showDropdown = true;
		
		// Clear selection if search term doesn't match selected school
		if (form.schoolId) {
			const selectedSchool = schools.find(s => s.id === form.schoolId);
			if (selectedSchool && !selectedSchool.name.toLowerCase().includes(searchTerm.toLowerCase())) {
				form.schoolId = null;
			}
		}
	}

	function selectSchool(school: School) {
		form.schoolId = school.id;
		searchTerm = school.name;
		showDropdown = false;
	}

	function handleSchoolFocus() {
		showDropdown = true;
		// If there's a selected school, show its name in search
		if (form.schoolId && !searchTerm) {
			searchTerm = getSelectedSchoolName();
		}
	}

	function handleSchoolBlur() {
		// Delay hiding dropdown to allow click on option
		setTimeout(() => {
			showDropdown = false;
			
			// If no school is selected and search term exists, clear it
			if (!form.schoolId) {
				searchTerm = '';
			}
		}, 150);
	}
</script>

<div class="space-y-6">
	<!-- School Selection -->
	<div class="space-y-2 relative">
		<Label for="school">Pilih Sekolah</Label>
		<div class="relative">
			<input 
				id="school" 
				type="text"
				bind:value={searchTerm}
				oninput={handleSchoolInput}
				onfocus={handleSchoolFocus}
				onblur={handleSchoolBlur}
				placeholder="Cari sekolah..."
				class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
			/>
			
			{#if showDropdown && searchTerm}
				<div class="absolute z-10 w-full mt-1 bg-background border border-input rounded-md shadow-lg max-h-60 overflow-y-auto">
					{#if filteredSchools.length > 0}
						{#each filteredSchools as school (school.id)}
							<button
								type="button"
								class="w-full px-3 py-2 text-left text-sm hover:bg-muted focus:bg-muted focus:outline-none border-b border-border last:border-b-0"
								onclick={() => selectSchool(school)}
							>
								{school.name}
							</button>
						{/each}
					{:else}
						<div class="px-3 py-2 text-sm text-muted-foreground">
							Tidak ditemukan sekolah yang sesuai
						</div>
					{/if}
				</div>
			{/if}
		</div>
		{#if errors.schoolId}
			<p class="text-sm text-destructive">{errors.schoolId}</p>
		{/if}
	</div>

	<!-- Test Category Selection -->
	<div class="space-y-2">
		<Label for="category">Kategori Tes</Label>
		<select 
			id="category" 
			bind:value={form.categoryId}
			class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
		>
			<option value={null}>-- Pilih Kategori Tes --</option>
			{#each categories as category (category.id)}
				<option value={category.id}>{category.name}</option>
			{/each}
		</select>
		{#if errors.categoryId}
			<p class="text-sm text-destructive">{errors.categoryId}</p>
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
	{#if form.schoolId && form.categoryId}
		<div class="rounded-lg bg-muted p-4">
			<h3 class="font-semibold text-sm mb-2">Ringkasan Penugasan</h3>
			<div class="space-y-1 text-sm">
				<p><span class="font-medium">Sekolah:</span> {getSelectedSchoolName()}</p>
				<p><span class="font-medium">Kategori:</span> {getSelectedCategoryName()}</p>
				<p><span class="font-medium">Periode:</span> {form.startDate} s/d {form.endDate}</p>
			</div>
		</div>
	{/if}
</div>