<script lang="ts">
	import { onMount } from 'svelte';
	import MapUsers from '$lib/components/map-users.svelte';
	import { Button } from '$lib/components/ui/button/index.js';
	import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
	import { trackedFetch } from '$lib/loading.js';

	type User = {
		id: string;
		name: string;
		email?: string;
		province?: string | null;
		whatsappNumber?: string | null;
	};

	type SortMode = 'count-desc' | 'count-asc' | 'name-asc' | 'name-desc';

	let users = $state<User[]>([]);
	let loading = $state(false);
	let loadError = $state('');
	let selectedProvince = $state<string | null>(null);
	let sortBy = $state<SortMode>('count-desc');
	let signupUrl = $state('');
	let qrCodeUrl = $state('');
	let copied = $state(false);

	function buildSignupUrl() {
		if (typeof window === 'undefined') return;
		signupUrl = `${window.location.origin}/qr-signup`;
		qrCodeUrl = `https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=${encodeURIComponent(signupUrl)}`;
	}

	async function fetchUsers() {
		loading = true;
		loadError = '';

		try {
			const response = await trackedFetch(`/qr-code/users?ts=${Date.now()}`, {
				cache: 'no-store'
			});
			if (!response.ok) {
				throw new Error(`HTTP ${response.status}`);
			}

			users = await response.json();
		} catch (error) {
			console.error('Failed to fetch users:', error);
			loadError = 'Gagal memuat daftar pengguna';
		} finally {
			loading = false;
		}
	}

	const provinceCounts = $derived.by(() => {
		const grouped = users.reduce<Record<string, number>>((acc, user) => {
			if (user.province) {
				acc[user.province] = (acc[user.province] || 0) + 1;
			}
			return acc;
		}, {});

		const items = Object.entries(grouped) as [string, number][];
		return items.sort((a, b) => {
			if (sortBy === 'count-desc') return b[1] - a[1];
			if (sortBy === 'count-asc') return a[1] - b[1];
			if (sortBy === 'name-asc') return a[0].localeCompare(b[0]);
			return b[0].localeCompare(a[0]);
		});
	});

	const provinceUsers = $derived(
		selectedProvince ? users.filter((user) => user.province === selectedProvince) : []
	);

	function copyUrl() {
		if (!signupUrl) return;
		navigator.clipboard.writeText(signupUrl);
		copied = true;
		setTimeout(() => {
			copied = false;
		}, 2000);
	}

	function downloadQr() {
		if (!qrCodeUrl) return;
		const link = document.createElement('a');
		link.href = qrCodeUrl;
		link.download = 'qr-code-registrasi.png';
		document.body.appendChild(link);
		link.click();
		document.body.removeChild(link);
	}

	onMount(() => {
		buildSignupUrl();
		fetchUsers();

		const interval = setInterval(fetchUsers, 5000);
		return () => clearInterval(interval);
	});
</script>

<svelte:head>
	<title>QR Code Registrasi - Assessment</title>
</svelte:head>

<div class="min-h-screen bg-gradient-to-br from-slate-50 to-slate-100 px-4 py-8">
	<div class="mx-auto grid max-w-7xl gap-6 lg:grid-cols-8">
		<div class="lg:col-span-5">
			<Card class="h-[72vh] overflow-hidden">
				<CardHeader>
					<CardTitle class="text-2xl">Peta Pengguna</CardTitle>
					<CardDescription>Lokasi pengguna berdasarkan provinsi</CardDescription>
				</CardHeader>
				<CardContent class="h-[calc(72vh-5rem)] p-0">
					<MapUsers {users} {selectedProvince} onProvinceClick={(province) => (selectedProvince = province)} />
				</CardContent>
			</Card>
		</div>

		<div class="flex flex-col gap-6 lg:col-span-3">
			<Card>
				<CardHeader>
					<CardTitle class="text-lg">QR Code Registrasi</CardTitle>
					<CardDescription>Bagikan tautan ini untuk pendaftaran pengguna baru</CardDescription>
				</CardHeader>
				<CardContent class="space-y-4">
					<div class="flex justify-center rounded-xl bg-slate-50 p-4">
						{#if qrCodeUrl}
							<img src={qrCodeUrl} alt="QR Code registrasi" class="h-56 w-56 object-contain" />
						{:else}
							<div class="flex h-56 w-56 items-center justify-center text-sm text-slate-500">
								Menyiapkan QR code...
							</div>
						{/if}
					</div>

					<div class="rounded-lg border bg-slate-50 p-3 text-sm break-all">{signupUrl || 'Menyiapkan URL...'}</div>

					<div class="flex gap-2">
						<Button class="flex-1" type="button" onclick={copyUrl}>
							{copied ? 'Tersalin' : 'Salin URL'}
						</Button>
						<Button class="flex-1" type="button" variant="outline" onclick={downloadQr}>
							Unduh QR
						</Button>
					</div>
				</CardContent>
			</Card>

			<Card class="min-h-[28rem]">
				<CardHeader>
					<CardTitle class="text-lg">Statistik Pengguna</CardTitle>
					<CardDescription>
						{#if selectedProvince}
							Daftar pengguna di {selectedProvince}
						{:else}
							Distribusi pengguna per provinsi
						{/if}
					</CardDescription>
				</CardHeader>
				<CardContent class="space-y-4">
					{#if loadError}
						<div class="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
							{loadError}
						</div>
					{/if}

					{#if !selectedProvince}
						<div class="flex items-center justify-between rounded-lg border bg-slate-50 px-4 py-3">
							<span class="text-sm font-medium text-slate-600">Total Pengguna</span>
							<span class="text-2xl font-bold text-emerald-600">{users.length}</span>
						</div>

						<div class="space-y-3">
							<select bind:value={sortBy} class="w-full rounded-md border bg-white px-3 py-2 text-sm">
								<option value="count-desc">Terbanyak</option>
								<option value="count-asc">Tersedikit</option>
								<option value="name-asc">A-Z</option>
								<option value="name-desc">Z-A</option>
							</select>

							<div class="max-h-80 space-y-2 overflow-y-auto pr-1">
								{#each provinceCounts as [province, count]}
									<button
										type="button"
										class="flex w-full items-center justify-between rounded-lg border bg-white px-3 py-2 text-left hover:bg-slate-50"
										onclick={() => (selectedProvince = province)}
									>
										<span class="text-sm text-slate-700">{province}</span>
										<span class="rounded bg-emerald-100 px-2 py-1 text-xs font-semibold text-emerald-700">
											{count}
										</span>
									</button>
								{/each}

								{#if !provinceCounts.length && !loading}
									<div class="rounded-lg border border-dashed px-4 py-6 text-center text-sm text-slate-500">
										Belum ada data provinsi pengguna.
									</div>
								{/if}
							</div>
						</div>
					{:else}
						<div class="flex items-center justify-between">
							<Button type="button" variant="outline" onclick={() => (selectedProvince = null)}>
								Kembali
							</Button>
							<div class="text-sm font-semibold text-slate-700">{selectedProvince}</div>
						</div>

						<div class="max-h-96 space-y-2 overflow-y-auto pr-1">
							{#each provinceUsers as user}
								<div class="rounded-lg border bg-slate-50 px-3 py-2">
									<div class="font-semibold text-slate-800">{user.name}</div>
									{#if user.whatsappNumber}
										<div class="text-sm text-slate-600">{user.whatsappNumber}</div>
									{/if}
								</div>
							{/each}

							{#if !provinceUsers.length}
								<div class="rounded-lg border border-dashed px-4 py-6 text-center text-sm text-slate-500">
									Belum ada pengguna di provinsi ini.
								</div>
							{/if}
						</div>
					{/if}
				</CardContent>
			</Card>
		</div>
	</div>
</div>
