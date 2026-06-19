<script lang="ts">
	import { onMount } from 'svelte';

	/**
	 * Credential interface matching the response DTO from backend
	 */
	interface Credential {
		username: string;
		password: string;
		authUserId: string;
		createdAt: string;
	}

	/**
	 * Print data interface passed from CredentialDisplay component
	 */
	interface PrintData {
		credentials: Credential[];
		schoolName: string;
		testCategory: string;
		generatedAt: string;
	}

	// ==================== State ====================
	let printData = $state<PrintData | null>(null);
	let error = $state<string | null>(null);

	// ==================== Lifecycle ====================
	onMount(() => {
		try {
			// Retrieve credentials from sessionStorage
			const storedData = sessionStorage.getItem('printCredentials');

			if (!storedData) {
				error = 'No credentials data found. Please generate credentials first.';
				return;
			}

			printData = JSON.parse(storedData);

			// Clean up sessionStorage after retrieving
			sessionStorage.removeItem('printCredentials');

			// Auto-trigger print dialog after data is loaded
			setTimeout(() => {
				window.print();
			}, 100);
		} catch (err) {
			error = `Failed to load credentials: ${err instanceof Error ? err.message : 'Unknown error'}`;
			console.error('Print page error:', err);
		}
	});

	// ==================== Helper Functions ====================
	/**
	 * Paginate credentials into groups of 30 rows per page (A4 optimized)
	 */
	function paginate(credentials: Credential[], itemsPerPage: number = 30): Credential[][] {
		const pages: Credential[][] = [];
		for (let i = 0; i < credentials.length; i += itemsPerPage) {
			pages.push(credentials.slice(i, i + itemsPerPage));
		}
		return pages;
	}

	/**
	 * Format date to readable format
	 */
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
</script>

<svelte:head>
	<title>Print Credentials</title>
</svelte:head>

{#if error}
	<div class="p-8 text-center">
		<h1 class="text-2xl font-bold text-red-600 mb-4">Error Loading Credentials</h1>
		<p class="text-gray-600 mb-4">{error}</p>
		<button
			onclick={() => window.close()}
			class="px-4 py-2 bg-blue-600 text-white rounded hover:bg-blue-700"
		>
			Close Window
		</button>
	</div>
{:else if !printData}
	<div class="p-8 text-center">
		<p class="text-gray-600">Loading credentials...</p>
	</div>
{:else}
	<!-- Print-Optimized Document -->
	<div id="print-document" class="print-document">
		{#each paginate(printData.credentials, 30) as page, pageIndex}
			<div class="page">
				<!-- Page Header -->
				<div class="page-header">
					<h1 class="school-name">{printData.schoolName}</h1>
					<h2 class="test-category">{printData.testCategory}</h2>
					<p class="generated-date">Generated on {formatDate(printData.generatedAt)}</p>
				</div>

				<!-- Credentials Table -->
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
							{@const globalIndex = pageIndex * 30 + rowIndex + 1}
							<tr class="credential-row">
								<td class="col-no">{globalIndex}</td>
								<td class="col-username">{credential.username}</td>
								<td class="col-password">{credential.password}</td>
							</tr>
						{/each}
					</tbody>
				</table>

				<!-- Page Footer -->
				<div class="page-footer">
					<p class="footer-text">Page {pageIndex + 1} of {Math.ceil(printData.credentials.length / 30)}</p>
				</div>
			</div>
		{/each}
	</div>
{/if}

<style>
	:global {
		/* Print media query - apply only when printing */
		@media print {
			/* Page setup */
			@page {
				size: A4;
				margin: 1cm;
			}

			/* Hide non-print elements */
			.no-print {
				display: none !important;
			}

			/* Body and general print styles */
			body {
				margin: 0;
				padding: 0;
				font-family: 'Segoe UI', Arial, sans-serif;
				font-size: 11pt;
				color: #333;
				background: white;
			}

			/* Page break control */
			.page {
				page-break-after: always;
				page-break-inside: avoid;
			}

			.page:last-child {
				page-break-after: auto;
			}

			/* Prevent table rows from splitting across pages */
			tr {
				page-break-inside: avoid;
			}

			/* Prevent orphaned/widowed lines */
			h1,
			h2,
			h3,
			p {
				page-break-inside: avoid;
				page-break-after: avoid;
			}

			/* Table styling for print */
			table {
				width: 100%;
				border-collapse: collapse;
				page-break-inside: avoid;
			}

			th,
			td {
				border: 1px solid #333;
				padding: 8px;
				text-align: left;
				page-break-inside: avoid;
			}

			th {
				background-color: #e9ecef;
				font-weight: bold;
			}

			/* Remove background colors and shadows for print */
			.card,
			.container {
				box-shadow: none;
				background: white;
			}
		}

		/* Screen media - for preview before printing */
		@media screen {
			body {
				background-color: #f5f5f5;
				padding: 20px;
			}

			.page {
				background: white;
				margin: 0 auto 20px;
				padding: 40px;
				box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
				max-width: 21cm;
			}
		}
	}

	/* Print document container */
	:global(#print-document) {
		width: 100%;
	}

	/* Page styles */
	:global(.page) {
		width: 210mm;
		height: 297mm;
		display: flex;
		flex-direction: column;
		font-family: 'Segoe UI', Arial, sans-serif;
	}

	/* Page header */
	:global(.page-header) {
		text-align: center;
		margin-bottom: 20px;
		padding-bottom: 15px;
		border-bottom: 2px solid #333;
	}

	:global(.school-name) {
		font-size: 18pt;
		font-weight: bold;
		margin: 0 0 5px 0;
		color: #333;
	}

	:global(.test-category) {
		font-size: 14pt;
		font-weight: 600;
		margin: 0 0 5px 0;
		color: #555;
	}

	:global(.generated-date) {
		font-size: 10pt;
		color: #888;
		margin: 5px 0 0 0;
	}

	/* Credentials table */
	:global(.credentials-table) {
		width: 100%;
		border-collapse: collapse;
		margin: 15px 0;
		flex-grow: 1;
		font-size: 10pt;
	}

	:global(.credentials-table thead) {
		background-color: #e9ecef;
	}

	:global(.credentials-table th) {
		border: 1px solid #333;
		padding: 8px;
		text-align: left;
		font-weight: bold;
		font-size: 10pt;
		color: #333;
	}

	:global(.credentials-table td) {
		border: 1px solid #ccc;
		padding: 6px 8px;
		font-size: 10pt;
		height: 24px;
		vertical-align: middle;
		word-break: break-word;
	}

	:global(.credential-row) {
		page-break-inside: avoid;
	}

	:global(.credential-row:nth-child(even)) {
		background-color: #f9f9f9;
	}

	:global(.col-no) {
		width: 40px;
		text-align: center;
	}

	:global(.col-username) {
		width: 45%;
		font-family: 'Courier New', monospace;
	}

	:global(.col-password) {
		width: 45%;
		font-family: 'Courier New', monospace;
	}

	/* Page footer */
	:global(.page-footer) {
		text-align: center;
		padding-top: 10px;
		margin-top: 15px;
		border-top: 1px solid #ccc;
		font-size: 9pt;
		color: #666;
	}

	:global(.footer-text) {
		margin: 0;
	}

	/* Error and loading states */
	:global(.error-container) {
		padding: 40px 20px;
		text-align: center;
		font-family: Arial, sans-serif;
	}

	:global(.error-message) {
		color: #d32f2f;
		font-size: 14pt;
		margin-bottom: 20px;
	}

	:global(.loading-message) {
		color: #666;
		font-size: 12pt;
	}
</style>
