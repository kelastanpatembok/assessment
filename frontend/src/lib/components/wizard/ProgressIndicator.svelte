<script lang="ts">
	interface Props {
		current: number; // credentials created so far
		total: number; // target count
		isActive: boolean; // whether generation is in progress
	}

	let { current = 0, total = 0, isActive = false }: Props = $props();

	// Calculate percentage
	let percentage = $derived(total > 0 ? Math.round((current / total) * 100) : 0);

	// Ensure percentage doesn't exceed 100
	let displayPercentage = $derived(Math.min(percentage, 100));
</script>

<div class="w-full space-y-4 rounded-lg border border-border bg-card p-6">
	<!-- Progress Header -->
	<div class="flex items-center justify-between">
		<div class="flex items-center gap-3">
			<!-- Spinner Animation -->
			{#if isActive}
				<div class="relative h-6 w-6">
					<div
						class="absolute inset-0 rounded-full border-2 border-transparent border-t-primary border-r-primary"
						style="animation: spin 1s linear infinite;"
					></div>
				</div>
			{/if}
			<h3 class="text-sm font-semibold">
				{isActive ? 'Generating credentials...' : 'Generation complete'}
			</h3>
		</div>
		<div class="text-sm font-medium text-muted-foreground">
			{current} / {total}
		</div>
	</div>

	<!-- Progress Bar -->
	<div class="space-y-2">
		<div class="h-2 w-full overflow-hidden rounded-full bg-secondary">
			<div
				class="h-full rounded-full bg-primary transition-all duration-300 ease-out"
				style="width: {displayPercentage}%;"
			></div>
		</div>
		<div class="text-right text-xs text-muted-foreground">
			{displayPercentage}%
		</div>
	</div>
</div>

<style>
	@keyframes spin {
		to {
			transform: rotate(360deg);
		}
	}
</style>
