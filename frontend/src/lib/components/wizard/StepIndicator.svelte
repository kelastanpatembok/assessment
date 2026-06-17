<script lang="ts">
	interface Step {
		number: number;
		label: string;
	}

	interface Props {
		step: number; // Current step (1-3)
		steps?: Step[]; // Optional custom step labels
	}

	const defaultSteps: Step[] = [
		{ number: 1, label: 'Select Assignment' },
		{ number: 2, label: 'Configure Pattern' },
		{ number: 3, label: 'Display Credentials' }
	];

	let { step = 1, steps = [] }: Props = $props();

	// Use custom steps if provided, otherwise use defaults
	let displaySteps = $derived(steps && steps.length > 0 ? steps : defaultSteps);

	function isCompleted(stepNumber: number): boolean {
		return stepNumber < step;
	}

	function isActive(stepNumber: number): boolean {
		return stepNumber === step;
	}
</script>

<div class="w-full">
	<div class="flex items-center justify-between">
		{#each displaySteps as s, index (s.number)}
			<div class="flex flex-1 items-center">
				<!-- Step Circle -->
				<div
					class="relative flex h-10 w-10 items-center justify-center rounded-full border-2 font-semibold transition-all"
					class:border-primary={isActive(s.number) || isCompleted(s.number)}
					class:border-muted={!isActive(s.number) && !isCompleted(s.number)}
					class:bg-primary={isActive(s.number) || isCompleted(s.number)}
					class:bg-muted={!isActive(s.number) && !isCompleted(s.number)}
					class:text-primary-foreground={isActive(s.number) || isCompleted(s.number)}
					class:text-muted-foreground={!isActive(s.number) && !isCompleted(s.number)}
				>
					{#if isCompleted(s.number)}
						<svg
							xmlns="http://www.w3.org/2000/svg"
							viewBox="0 0 24 24"
							fill="none"
							stroke="currentColor"
							stroke-width="2"
							stroke-linecap="round"
							stroke-linejoin="round"
							class="h-5 w-5"
						>
							<polyline points="20 6 9 17 4 12"></polyline>
						</svg>
					{:else}
						{s.number}
					{/if}
				</div>

				<!-- Label -->
				<div class="ml-2 min-w-max">
					<p
						class="text-sm font-medium transition-all"
						class:text-primary={isActive(s.number) || isCompleted(s.number)}
						class:text-muted-foreground={!isActive(s.number) && !isCompleted(s.number)}
					>
						{s.label}
					</p>
				</div>

				<!-- Connector Line (not after last step) -->
				{#if index < displaySteps.length - 1}
					<div
						class="ml-2 flex-1 h-0.5 transition-all"
						class:bg-primary={isCompleted(s.number + 1)}
						class:bg-muted={!isCompleted(s.number + 1)}
					></div>
				{/if}
			</div>
		{/each}
	</div>
</div>

<style>
	/* Tailwind handles all styling via class directives */
</style>
