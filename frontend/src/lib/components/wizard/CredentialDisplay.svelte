<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import { cn } from '$lib/utils';

	/**
	 * Credential interface matching the response DTO from backend
	 */
	interface Credential {
		username: string;
		password: string; // plaintext, for display/export only
		authUserId: string;
		createdAt: string;
	}

	/**
	 * Component props
	 * - credentials: list of generated credentials
	 * - schoolName: name of the school for this batch
	 * - testCategory: name of the test category for this batch
	 */
	interface Props {
		credentials: Credential[];
		schoolName: string;
		testCategory: string;
	}

	let { credentials = [], schoolName = '', testCategory = '' }: Props = $props();

	// ==================== State ====================
	let showPasswords = $state(false);
	let copiedIndex = $state<number | null>(null);
	let copyTimeout: NodeJS.Timeout | null = null;

	// ==================== Computed Properties ====================
	let credentialCount = $derived(credentials.length);

	// ==================== Copy to Clipboard ====================
	/**
	 * Copy password to clipboard and show success feedback
	 */
	async function copyToClipboard(password: string, index: number) {
		try {
			await navigator.clipboard.writeText(password);

			// Show success state
			copiedIndex = index;

			// Clear timeout if one already exists
			if (copyTimeout) {
				clearTimeout(copyTimeout);
			}

			// Auto-dismiss after 2 seconds
			copyTimeout = setTimeout(() => {
				copiedIndex = null;
			}, 2000);
		} catch (error) {
			console.error('Failed to copy to clipboard:', error);
			// TODO: Show error toast notification when toast component is available
		}
	}

	// ==================== Export Functions ====================
	/**
	 * Generate CSV content with RFC 4180 compliance
	 * Headers: username, password, school_name, test_category, created_date
	 */
	function generateCSV(): string {
		const headers = ['username', 'password', 'school_name', 'test_category', 'created_date'];
		const rows = credentials.map((cred) => [
			escapeCSV(cred.username),
			escapeCSV(cred.password),
			escapeCSV(schoolName),
			escapeCSV(testCategory),
			escapeCSV(new Date(cred.createdAt).toISOString().split('T')[0])
		]);

		return [headers, ...rows].map((row) => row.join(',')).join('\n');
	}

	/**
	 * Escape CSV field values according to RFC 4180
	 * - Wrap in quotes if contains comma, quote, or newline
	 * - Double internal quotes
	 */
	function escapeCSV(value: string): string {
		if (value.includes(',') || value.includes('"') || value.includes('\n')) {
			return `"${value.replace(/"/g, '""')}"`;
		}
		return value;
	}

	/**
	 * Download CSV file
	 */
	function downloadCSV() {
		const csv = generateCSV();
		const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
		const link = document.createElement('a');
		const url = URL.createObjectURL(blob);

		// Generate filename: credentials_{schoolCode}_{testCode}_{timestamp}.csv
		const now = new Date();
		const timestamp = now.toISOString().replace(/[-:T.]/g, '').substring(0, 14); // YYYYMMDDHHmmss
		const filename = `credentials_${timestamp}.csv`;

		link.setAttribute('href', url);
		link.setAttribute('download', filename);
		link.style.visibility = 'hidden';

		document.body.appendChild(link);
		link.click();
		document.body.removeChild(link);

		// TODO: Show success toast notification when toast component is available
	}

	/**
	 * Open print-optimized view in new window
	 * Data passed via sessionStorage for print view to retrieve
	 */
	function openPrintView() {
		// Store credentials data in sessionStorage for the print window to access
		const printData = {
			credentials,
			schoolName,
			testCategory,
			generatedAt: new Date().toISOString()
		};

		sessionStorage.setItem('printCredentials', JSON.stringify(printData));

		// Open new window to print view
		const printWindow = window.open('/admin/credentials/print', 'credentialsPrint', 'width=1000,height=800');

		if (printWindow) {
			printWindow.focus();
		} else {
			console.error('Failed to open print window');
			// TODO: Show error toast notification when toast component is available
		}
	}

	// ==================== Cleanup ====================
	$effect(() => {
		return () => {
			if (copyTimeout) {
				clearTimeout(copyTimeout);
			}
		};
	});
</script>

<div class="space-y-6">
	<!-- Summary Header -->
	<div class="rounded-lg border border-border bg-card p-6">
		<div class="flex items-center justify-between mb-2">
			<h2 class="text-2xl font-bold text-foreground">
				Generated {credentialCount} Credentials
			</h2>
		</div>
		<div class="space-y-1">
			<p class="text-sm text-muted-foreground">
				<span class="font-semibold">School:</span> {schoolName}
			</p>
			<p class="text-sm text-muted-foreground">
				<span class="font-semibold">Test Category:</span> {testCategory}
			</p>
			<p class="text-sm text-muted-foreground">
				<span class="font-semibold">Generated:</span> {new Date().toLocaleString('id-ID')}
			</p>
		</div>
	</div>

	<!-- Show/Hide Password Toggle -->
	<div class="flex items-center justify-between">
		<button
			onclick={() => (showPasswords = !showPasswords)}
			class="flex items-center gap-2 text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
		>
			<svg
				xmlns="http://www.w3.org/2000/svg"
				viewBox="0 0 24 24"
				fill="none"
				stroke="currentColor"
				stroke-width="2"
				stroke-linecap="round"
				stroke-linejoin="round"
				class="h-4 w-4"
			>
				{#if showPasswords}
					<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
					<circle cx="12" cy="12" r="3"></circle>
				{:else}
					<path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
					<line x1="1" y1="1" x2="23" y2="23"></line>
				{/if}
			</svg>
			{showPasswords ? 'Hide Passwords' : 'Show Passwords'}
		</button>

		<div class="flex gap-2">
			<Button
				onclick={downloadCSV}
				variant="outline"
				class="flex items-center gap-2"
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="2"
					stroke-linecap="round"
					stroke-linejoin="round"
					class="h-4 w-4"
				>
					<path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
					<polyline points="7 10 12 15 17 10"></polyline>
					<line x1="12" y1="15" x2="12" y2="3"></line>
				</svg>
				Export as CSV
			</Button>

			<Button
				onclick={openPrintView}
				variant="outline"
				class="flex items-center gap-2"
			>
				<svg
					xmlns="http://www.w3.org/2000/svg"
					viewBox="0 0 24 24"
					fill="none"
					stroke="currentColor"
					stroke-width="2"
					stroke-linecap="round"
					stroke-linejoin="round"
					class="h-4 w-4"
				>
					<polyline points="6 9 6 2 18 2 18 9"></polyline>
					<path d="M6 18H4a2 2 0 0 1-2-2v-5a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2h-2"></path>
					<rect x="6" y="14" width="12" height="8"></rect>
				</svg>
				Print Credentials
			</Button>
		</div>
	</div>

	<!-- Credentials Table -->
	<div class="rounded-lg border border-border overflow-hidden">
		{#if credentials.length === 0}
			<div class="p-8 text-center">
				<p class="text-muted-foreground text-sm">No credentials to display</p>
			</div>
		{:else}
			<div class="overflow-x-auto">
				<table class="w-full text-sm">
					<thead class="bg-muted border-b border-border">
						<tr>
							<th class="px-4 py-3 text-left font-semibold">No.</th>
							<th class="px-4 py-3 text-left font-semibold">Username</th>
							<th class="px-4 py-3 text-left font-semibold">Password</th>
							<th class="px-4 py-3 text-left font-semibold">Action</th>
						</tr>
					</thead>
					<tbody>
						{#each credentials as credential, index (credential.authUserId)}
							<tr class="border-b border-border hover:bg-muted/50 transition-colors">
								<td class="px-4 py-3 text-muted-foreground font-medium">
									{index + 1}
								</td>
								<td class="px-4 py-3">
									<div class="font-mono text-sm">{credential.username}</div>
								</td>
								<td class="px-4 py-3">
									<div class="font-mono text-sm">
										{showPasswords ? credential.password : '••••••••'}
									</div>
								</td>
								<td class="px-4 py-3">
									<button
										onclick={() => copyToClipboard(credential.password, index)}
										class={cn(
											'inline-flex items-center gap-1 px-3 py-2 rounded-md text-sm font-medium transition-all',
											copiedIndex === index
												? 'bg-green-100 text-green-700'
												: 'bg-muted text-muted-foreground hover:bg-muted hover:text-foreground'
										)}
										type="button"
									>
										<svg
											xmlns="http://www.w3.org/2000/svg"
											viewBox="0 0 24 24"
											fill="none"
											stroke="currentColor"
											stroke-width="2"
											stroke-linecap="round"
											stroke-linejoin="round"
											class="h-4 w-4"
										>
											{#if copiedIndex === index}
												<polyline points="20 6 9 17 4 12"></polyline>
											{:else}
												<rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect>
												<path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path>
											{/if}
										</svg>
										{copiedIndex === index ? 'Copied!' : 'Copy'}
									</button>
								</td>
							</tr>
						{/each}
					</tbody>
				</table>
			</div>
		{/if}
	</div>

	<!-- Empty State -->
	{#if credentials.length === 0}
		<div class="flex flex-col items-center justify-center gap-4 rounded-lg border border-border/50 bg-muted/30 p-12">
			<svg
				xmlns="http://www.w3.org/2000/svg"
				viewBox="0 0 24 24"
				fill="none"
				stroke="currentColor"
				stroke-width="2"
				stroke-linecap="round"
				stroke-linejoin="round"
				class="h-12 w-12 text-muted-foreground/50"
			>
				<path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L2 12V2h10l8.59 8.59a2 2 0 0 1 0 2.82z"></path>
				<line x1="7" y1="7" x2="7.01" y2="7"></line>
			</svg>
			<div class="text-center">
				<p class="text-sm font-medium text-muted-foreground">No credentials generated</p>
				<p class="text-xs text-muted-foreground/75">Generate credentials to display them here</p>
			</div>
		</div>
	{/if}

	<!-- Footer Info -->
	<div class="rounded-lg bg-muted/50 p-4">
		<p class="text-xs text-muted-foreground">
			💡 <span class="font-medium">Tip:</span> Keep these credentials secure. Students will need their username and password to access the test assignment.
		</p>
	</div>
</div>

<style>
	/* Tailwind handles all styling via class directives */
</style>
