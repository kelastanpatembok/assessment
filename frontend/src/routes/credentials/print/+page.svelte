<script lang="ts">
	import { onMount } from 'svelte';

	interface Credential {
		username: string;
		password: string;
		authUserId: string;
		createdAt: string;
	}

	interface PrintData {
		credentials: Credential[];
		schoolName: string;
		testCategory: string;
		generatedAt: string;
	}

	const ITEMS_PER_PAGE = 30;

	let printData = $state<PrintData | null>(null);
	let error = $state<string | null>(null);

	onMount(() => {
		try {
			const storedData = sessionStorage.getItem('printCredentials');

			if (!storedData) {
				error = 'No credentials data found. Please generate credentials first.';
				return;
			}

			printData = JSON.parse(storedData);
			sessionStorage.removeItem('printCredentials');

			setTimeout(() => {
				window.print();
			}, 100);
		} catch (err) {
			error = `Failed to load credentials: ${err instanceof Error ? err.message : 'Unknown error'}`;
			console.error('Print page error:', err);
		}
	});

	function paginate(credentials: Credential[], itemsPerPage: number = ITEMS_PER_PAGE): Credential[][] {
		const pages: Credential[][] = [];
		for (let i = 0; i < credentials.length; i += itemsPerPage) {
			pages.push(credentials.slice(i, i + itemsPerPage));
		}
		return pages;
	}

	function formatDate(dateString: string): string {
		try {
			const date = new Date(dateString);
			return date.toLocaleDateString('id-ID', {
				weekday: 'long',
				year: 'numeric',
				month: 'long',
				day: 'numeric',
				hour: '2-digit',
				minute: '2-digit'
			});
		} catch {
			return dateString;
		}
	}

	function buildDocumentTitle(data: PrintData): string {
		const stripSpaces = (value: string) => value.replace(/\s+/g, '');
		const date = new Date(data.generatedAt);
		const month = date.toLocaleDateString('id-ID', { month: 'long' });
		const year = date.getFullYear();
		return `${stripSpaces(data.schoolName)}-${stripSpaces(data.testCategory)}-${month}-${year}`;
	}
</script>

<svelte:head>
	<title>{printData ? buildDocumentTitle(printData) : 'Print Credentials'}</title>
</svelte:head>

{#if error}
	<div class="error-screen">
		<h1>Error Loading Credentials</h1>
		<p>{error}</p>
		<button type="button" onclick={() => window.close()}>Close Window</button>
	</div>
{:else if !printData}
	<div class="loading-screen">Loading credentials...</div>
{:else}
	<div class="print-shell">
		<div id="print-document" class="print-document">
			{#each paginate(printData.credentials) as page, pageIndex}
				<div class="page">
					<header class="page-header">
						<h1 class="school-name">{printData.schoolName}</h1>
						<h2 class="test-category">{printData.testCategory}</h2>
						<p class="generated-date">Generated on {formatDate(printData.generatedAt)}</p>
					</header>

					<table class="credentials-table">
						<thead>
							<tr>
								<th class="col-no">No.</th>
								<th class="col-username">Username</th>
								<th class="col-password">Password</th>
							</tr>
						</thead>
						<tbody>
							{#each page as credential, rowIndex}
								{@const globalIndex = pageIndex * ITEMS_PER_PAGE + rowIndex + 1}
								<tr class="credential-row">
									<td class="col-no">{globalIndex}</td>
									<td class="col-username">{credential.username}</td>
									<td class="col-password">{credential.password}</td>
								</tr>
							{/each}
						</tbody>
					</table>

					<footer class="page-footer">
						<p>Page {pageIndex + 1} of {Math.ceil(printData.credentials.length / ITEMS_PER_PAGE)}</p>
					</footer>
				</div>
			{/each}
		</div>
	</div>
{/if}

<style>
	:global(html, body) {
		margin: 0;
		padding: 0;
		background: #f3f4f6;
	}

	.error-screen,
	.loading-screen {
		min-height: 100vh;
		display: flex;
		flex-direction: column;
		align-items: center;
		justify-content: center;
		gap: 0.75rem;
		font-family: 'Segoe UI', Arial, sans-serif;
		color: #1f2937;
	}

	.error-screen button {
		border: 0;
		border-radius: 0.5rem;
		padding: 0.75rem 1rem;
		background: #111827;
		color: white;
		cursor: pointer;
	}

	.print-shell {
		padding: 20px;
	}

	.print-document {
		width: 100%;
	}

	.page {
		box-sizing: border-box;
		width: 210mm;
		min-height: 297mm;
		margin: 0 auto 20px;
		padding: 12mm 14mm;
		background: white;
		box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
		display: flex;
		flex-direction: column;
		font-family: 'Segoe UI', Arial, sans-serif;
		color: #1f2937;
	}

	.page-header {
		text-align: center;
		margin-bottom: 8mm;
		padding-bottom: 4mm;
		border-bottom: 1.5px solid #111827;
	}

	.school-name {
		margin: 0;
		font-size: 18pt;
		font-weight: 700;
	}

	.test-category {
		margin: 3mm 0 2mm;
		font-size: 13pt;
		font-weight: 600;
	}

	.generated-date {
		margin: 0;
		font-size: 9pt;
	}

	.credentials-table {
		width: 100%;
		border-collapse: collapse;
		table-layout: fixed;
		font-size: 9.5pt;
	}

	.credentials-table th,
	.credentials-table td {
		border: 1px solid #4b5563;
		padding: 2.5mm 2.8mm;
		text-align: left;
		vertical-align: middle;
		line-height: 1.15;
	}

	.credentials-table th {
		font-weight: 700;
		background: #f3f4f6;
	}

	.credentials-table td {
		height: 8.5mm;
	}

	.credential-row {
		page-break-inside: avoid;
	}

	.col-no {
		width: 9%;
		text-align: center;
	}

	.col-username,
	.col-password {
		font-family: 'Courier New', monospace;
	}

	.col-username {
		width: 53%;
	}

	.col-password {
		width: 38%;
	}

	.page-footer {
		margin-top: auto;
		padding-top: 4mm;
		border-top: 1px solid #d1d5db;
		text-align: center;
		font-size: 9pt;
		color: #6b7280;
	}

	.page-footer p {
		margin: 0;
	}

	@media print {
		@page {
			size: A4 portrait;
			margin: 0;
		}

		:global(html, body) {
			background: white;
		}

		.print-shell {
			padding: 0;
		}

		.page {
			width: 210mm;
			min-height: 297mm;
			margin: 0;
			padding: 12mm 14mm;
			box-shadow: none;
			page-break-after: always;
		}

		.page:last-child {
			page-break-after: auto;
		}
	}
</style>
