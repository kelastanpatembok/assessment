import { fail, redirect } from '@sveltejs/kit';
import { PUBLIC_AUTH_URL } from '$env/static/public';
import { getAuthProfile } from '$lib/server/profile';
import type { Actions, PageServerLoad } from './$types';

const AUTH_BASE = (PUBLIC_AUTH_URL || 'http://127.0.0.1:1007/api').replace(/\/+$/, '');

export const load: PageServerLoad = async ({ locals }) => {
	if (!locals.user) redirect(302, '/signin');
	const profile = await getAuthProfile(locals.user.userId, locals.token ?? '');
	return { user: locals.user, profile };
};

export const actions: Actions = {
	name: async ({ request, locals }) => {
		if (!locals.user || !locals.token) return fail(401, { error: 'Sesi berakhir.' });
		const form = await request.formData();
		const name = (form.get('name') as string)?.trim() ?? '';
		if (!name) return fail(400, { error: 'Nama tidak boleh kosong.' });

		const params = new URLSearchParams({ name });
		const res = await fetch(`${AUTH_BASE}/users/${encodeURIComponent(locals.user.userId)}?${params}`, {
			method: 'PUT',
			headers: { Authorization: `Bearer ${locals.token}` }
		});
		if (!res.ok) return fail(500, { error: 'Gagal memperbarui nama. Silakan coba lagi.' });

		redirect(303, '/profil');
	},

	password: async ({ request, locals }) => {
		if (!locals.user || !locals.token) return fail(401, { error: 'Sesi berakhir.' });
		const form = await request.formData();
		const newPassword = (form.get('newPassword') as string) ?? '';
		const confirm = (form.get('confirmPassword') as string) ?? '';

		if (newPassword.length < 6) return fail(400, { error: 'Kata sandi baru minimal 6 karakter.' });
		if (newPassword !== confirm) return fail(400, { error: 'Konfirmasi kata sandi tidak sama.' });

		const params = new URLSearchParams({
			userId: locals.user.userId,
			newPassword
		});
		const res = await fetch(`${AUTH_BASE}/auth/change-password?${params}`, { method: 'PUT' });
		if (!res.ok) return fail(500, { error: 'Gagal mengubah kata sandi. Silakan coba lagi.' });

		return { ok: true };
	},

	avatar: async ({ request, locals }) => {
		if (!locals.user || !locals.token) return fail(401, { error: 'Sesi berakhir.' });
		const form = await request.formData();
		const file = form.get('file') as File | null;
		if (!file || file.size === 0) return fail(400, { error: 'Pilih file gambar terlebih dahulu.' });

		const fd = new FormData();
		fd.append('file', file);
		const res = await fetch(`${AUTH_BASE}/users/${encodeURIComponent(locals.user.userId)}/avatar`, {
			method: 'POST',
			headers: { Authorization: `Bearer ${locals.token}` },
			body: fd
		});
		if (!res.ok) return fail(500, { error: 'Gagal mengunggah foto profil. Silakan coba lagi.' });

		redirect(303, '/profil');
	}
};
