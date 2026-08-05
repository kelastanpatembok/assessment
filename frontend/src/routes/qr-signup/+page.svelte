<script lang="ts">
	import { enhance } from '$app/forms';
	import { INDONESIAN_PROVINCES } from '$lib/data/indonesian-provinces';
	import { Button } from '$lib/components/ui/button/index.js';
	import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
	import { Input } from '$lib/components/ui/input/index.js';

	let { form } = $props();
	let loading = $state(false);

	let values = $derived({
		name: form?.values?.name ?? '',
		email: form?.values?.email ?? '',
		whatsappNumber: form?.values?.whatsappNumber ?? '',
		province: form?.values?.province ?? ''
	});
</script>

<svelte:head>
	<title>Daftar Akun Baru - Assessment</title>
</svelte:head>

<div class="flex min-h-screen items-center justify-center bg-gradient-to-br from-slate-50 to-slate-100 px-4 py-8">
	<Card class="w-full max-w-2xl">
		<CardHeader>
			<CardTitle class="text-2xl">Daftar Akun Baru</CardTitle>
			<CardDescription>Isi data diri Anda untuk membuat akun</CardDescription>
		</CardHeader>
		<CardContent>
			<form
				method="POST"
				use:enhance={() => {
					loading = true;
					return async ({ update }) => {
						loading = false;
						await update();
					};
				}}
				class="space-y-4"
			>
				{#if form?.error}
					<div class="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
						{form.error}
					</div>
				{/if}

				<Input
					id="name"
					name="name"
					type="text"
					placeholder="Nama lengkap"
					required
					disabled={loading}
					value={values.name}
				/>

				<Input
					id="email"
					name="email"
					type="email"
					placeholder="Email"
					required
					disabled={loading}
					value={values.email}
				/>

				<Input
					id="password"
					name="password"
					type="password"
					placeholder="Password (minimal 6 karakter)"
					required
					minlength={6}
					disabled={loading}
				/>

				<Input
					id="whatsappNumber"
					name="whatsappNumber"
					type="tel"
					placeholder="Nomor WhatsApp (62812345678)"
					required
					disabled={loading}
					value={values.whatsappNumber}
				/>

				<select
					id="province"
					name="province"
					required
					disabled={loading}
					class="w-full rounded-md border bg-white px-3 py-2 text-sm"
				>
					<option value="">Pilih Provinsi</option>
					{#each INDONESIAN_PROVINCES as province}
						<option value={province} selected={province === values.province}>{province}</option>
					{/each}
				</select>

				<Button type="submit" class="w-full" disabled={loading}>
					{loading ? 'Membuat akun...' : 'Daftar'}
				</Button>
			</form>

			<p class="mt-6 text-center text-sm text-slate-600">
				Sudah punya akun?
				<a href="/signin" class="font-medium text-blue-600 hover:underline">Masuk</a>
			</p>
		</CardContent>
	</Card>
</div>
