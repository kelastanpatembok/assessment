<script lang="ts">
	import { Input } from '$lib/components/ui/input';
	import { Label } from '$lib/components/ui/label';
	import { cn } from '$lib/utils';

	interface TestAssignment {
		id: number;
		school: {
			id: number;
			name: string;
		};
		category: {
			id: number;
			name: string;
			slug: string;
		};
	}

	interface Props {
		pattern: { schoolCode: string; testCode: string; preview: string };
		count: number;
		assignment: TestAssignment;
	}

	const PATTERN_REGEX = /^[A-Za-z0-9_]+$/;
	const MAX_CODE_LENGTH = 10;
	const MIN_COUNT = 1;
	const MAX_COUNT = 500;

	let { pattern, count, assignment }: Props = $props();

	// Validation functions
	const isValidCode = (code: string): boolean => {
		return code.length > 0 && code.length <= MAX_CODE_LENGTH && PATTERN_REGEX.test(code);
	};

	const isValidCount = (n: number): boolean => {
		return Number.isInteger(n) && n >= MIN_COUNT && n <= MAX_COUNT;
	};

	// Derive default codes from assignment on mount
	let defaultSchoolCode = $state<string>('');
	let defaultTestCode = $state<string>('');

	$effect(() => {
		if (assignment) {
			// Extract first 10 alphanumeric chars from school name, convert to uppercase
			defaultSchoolCode = (assignment.school.name.match(/[A-Za-z0-9]/g) || [])
				.slice(0, MAX_CODE_LENGTH)
				.join('')
				.toUpperCase();

			// Extract first 10 alphanumeric chars from category slug
			defaultTestCode = (assignment.category.slug.match(/[A-Za-z0-9_]/g) || [])
				.slice(0, MAX_CODE_LENGTH)
				.join('')
				.toUpperCase();

			// Initialize pattern if empty
			if (!pattern.schoolCode) {
				pattern.schoolCode = defaultSchoolCode;
			}
			if (!pattern.testCode) {
				pattern.testCode = defaultTestCode;
			}
		}
	});

	// Generate preview usernames
	let previewUsernames = $derived.by(() => {
		if (!isValidCode(pattern.schoolCode) || !isValidCode(pattern.testCode) || !isValidCount(count)) {
			return null;
		}

		const prefix = `${pattern.schoolCode}_${pattern.testCode}_`;
		const first = `${prefix}001`;
		const last = `${prefix}${String(count).padStart(3, '0')}`;

		return { first, last };
	});

	// Validation states
	let schoolCodeError = $derived.by(() => {
		if (!pattern.schoolCode) return null;
		if (pattern.schoolCode.length > MAX_CODE_LENGTH) {
			return `School code must be at most ${MAX_CODE_LENGTH} characters`;
		}
		if (!PATTERN_REGEX.test(pattern.schoolCode)) {
			return 'School code can only contain letters, numbers, and underscores';
		}
		return null;
	});

	let testCodeError = $derived.by(() => {
		if (!pattern.testCode) return null;
		if (pattern.testCode.length > MAX_CODE_LENGTH) {
			return `Test code must be at most ${MAX_CODE_LENGTH} characters`;
		}
		if (!PATTERN_REGEX.test(pattern.testCode)) {
			return 'Test code can only contain letters, numbers, and underscores';
		}
		return null;
	});

	let countError = $derived.by(() => {
		if (count === null || count === undefined) return null;
		if (!Number.isInteger(count)) {
			return 'Student count must be a whole number';
		}
		if (count < MIN_COUNT) {
			return `Student count must be at least ${MIN_COUNT}`;
		}
		if (count > MAX_COUNT) {
			return `Student count must not exceed ${MAX_COUNT}`;
		}
		return null;
	});

	// Check if all validations pass
	let isValid = $derived.by(() => {
		return (
			isValidCode(pattern.schoolCode) &&
			isValidCode(pattern.testCode) &&
			isValidCount(count) &&
			!schoolCodeError &&
			!testCodeError &&
			!countError
		);
	});
</script>

<div class="space-y-6">
	<!-- School Code Input -->
	<div class="space-y-2">
		<div class="flex items-center justify-between">
			<Label for="school-code" class="text-base font-semibold">School Code</Label>
			{#if pattern.schoolCode}
				<span class="text-xs text-muted-foreground">{pattern.schoolCode.length}/{MAX_CODE_LENGTH}</span>
			{/if}
		</div>
		<Input
			id="school-code"
			bind:value={pattern.schoolCode}
			placeholder="e.g., SCHOOL"
			maxlength={MAX_CODE_LENGTH}
			class={cn({
				'aria-invalid': schoolCodeError
			})}
			aria-invalid={schoolCodeError ? 'true' : 'false'}
		/>
		{#if schoolCodeError}
			<p class="text-sm text-destructive">{schoolCodeError}</p>
		{/if}
		<p class="text-xs text-muted-foreground">Alphanumeric and underscore only, max {MAX_CODE_LENGTH} chars</p>
	</div>

	<!-- Test Code Input -->
	<div class="space-y-2">
		<div class="flex items-center justify-between">
			<Label for="test-code" class="text-base font-semibold">Test Code</Label>
			{#if pattern.testCode}
				<span class="text-xs text-muted-foreground">{pattern.testCode.length}/{MAX_CODE_LENGTH}</span>
			{/if}
		</div>
		<Input
			id="test-code"
			bind:value={pattern.testCode}
			placeholder="e.g., IQ"
			maxlength={MAX_CODE_LENGTH}
			class={cn({
				'aria-invalid': testCodeError
			})}
			aria-invalid={testCodeError ? 'true' : 'false'}
		/>
		{#if testCodeError}
			<p class="text-sm text-destructive">{testCodeError}</p>
		{/if}
		<p class="text-xs text-muted-foreground">Alphanumeric and underscore only, max {MAX_CODE_LENGTH} chars</p>
	</div>

	<!-- Student Count Input -->
	<div class="space-y-2">
		<Label for="student-count" class="text-base font-semibold">Number of Students</Label>
		<Input
			id="student-count"
			type="number"
			bind:value={count}
			placeholder="Enter number between 1 and 500"
			min={MIN_COUNT}
			max={MAX_COUNT}
			class={cn({
				'aria-invalid': countError
			})}
			aria-invalid={countError ? 'true' : 'false'}
		/>
		{#if countError}
			<p class="text-sm text-destructive">{countError}</p>
		{/if}
		<p class="text-xs text-muted-foreground">Between {MIN_COUNT} and {MAX_COUNT} students</p>
	</div>

	<!-- Preview Section -->
	{#if previewUsernames}
		<div class="space-y-3 rounded-lg bg-muted p-4">
			<h3 class="text-sm font-semibold text-foreground">Username Preview</h3>
			<div class="space-y-2">
				<div class="flex flex-col space-y-1">
					<p class="text-xs text-muted-foreground">First username:</p>
					<p class="font-mono text-sm font-medium text-foreground">{previewUsernames.first}</p>
				</div>
				<div class="flex flex-col space-y-1">
					<p class="text-xs text-muted-foreground">Last username:</p>
					<p class="font-mono text-sm font-medium text-foreground">{previewUsernames.last}</p>
				</div>
				<div class="pt-2 border-t border-border">
					<p class="text-xs text-muted-foreground">Total usernames to generate: <span class="font-semibold text-foreground">{count}</span></p>
				</div>
			</div>
		</div>
	{:else if pattern.schoolCode || pattern.testCode || count}
		<div class="space-y-2 rounded-lg bg-muted/50 p-4">
			<p class="text-sm text-muted-foreground">Fix validation errors above to see preview</p>
		</div>
	{/if}

	<!-- Validation Summary -->
	<div class="space-y-2">
		<div class="flex items-center space-x-2">
			<div
				class={cn(
					'h-4 w-4 rounded-full border-2 transition-colors',
					isValidCode(pattern.schoolCode)
						? 'border-green-500 bg-green-500/10'
						: 'border-gray-300 bg-gray-50'
				)}
			></div>
			<span class="text-sm" class:text-green-600={isValidCode(pattern.schoolCode)} class:text-muted-foreground={!isValidCode(pattern.schoolCode)}>
				School code valid
			</span>
		</div>
		<div class="flex items-center space-x-2">
			<div
				class={cn(
					'h-4 w-4 rounded-full border-2 transition-colors',
					isValidCode(pattern.testCode)
						? 'border-green-500 bg-green-500/10'
						: 'border-gray-300 bg-gray-50'
				)}
			></div>
			<span class="text-sm" class:text-green-600={isValidCode(pattern.testCode)} class:text-muted-foreground={!isValidCode(pattern.testCode)}>
				Test code valid
			</span>
		</div>
		<div class="flex items-center space-x-2">
			<div
				class={cn(
					'h-4 w-4 rounded-full border-2 transition-colors',
					isValidCount(count)
						? 'border-green-500 bg-green-500/10'
						: 'border-gray-300 bg-gray-50'
				)}
			></div>
			<span class="text-sm" class:text-green-600={isValidCount(count)} class:text-muted-foreground={!isValidCount(count)}>
				Student count valid
			</span>
		</div>
	</div>

	<!-- Status Indicator -->
	{#if isValid}
		<div class="flex items-center space-x-2 rounded-lg bg-green-50 px-3 py-2">
			<svg
				xmlns="http://www.w3.org/2000/svg"
				viewBox="0 0 24 24"
				fill="none"
				stroke="currentColor"
				stroke-width="2"
				stroke-linecap="round"
				stroke-linejoin="round"
				class="h-4 w-4 text-green-600"
			>
				<polyline points="20 6 9 17 4 12"></polyline>
			</svg>
			<p class="text-sm font-medium text-green-700">All validations passed. Ready to generate!</p>
		</div>
	{/if}
</div>
