import { fail, redirect } from '@sveltejs/kit';
import { PUBLIC_AUTH_URL, PUBLIC_PROFILE_URL } from '$env/static/public';
import { getProfile } from '$lib/server/profile';
import type { Actions, PageServerLoad } from './$types';

const AUTH_BASE = (PUBLIC_AUTH_URL || 'http://127.0.0.1:1007/api').replace(/\/+$/, '');
const PROFILE_BASE = (PUBLIC_PROFILE_URL || 'http://127.0.0.1:1008/api').replace(/\/+$/, '');

export const load: PageServerLoad = async ({ locals }) => {
	if (!locals.user) redirect(302, '/signin');
	const profile = await getProfile(locals.user.userId, locals.token ?? '');
	return { user: locals.user, profile };
};

export const actions: Actions = {
	/** Update the profile name via the reusable `profile` domain. */
	name: async ({ request, locals }) => {
		if (!locals.user || !locals.token) return fail(401, { error: 'Sesi berakhir.' });
		const form = await request.formData();
		const name = (form.get('name') as string)?.trim() ?? '';
		if (!name) return fail(400, { error: 'Nama tidak boleh kosong.' });

		const res = await fetch(`${PROFILE_BASE}/users/${encodeURIComponent(locals.user.userId)}`, {
			method: 'PUT',
			headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${locals.token}` },
			body: JSON.stringify({ name })
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

	/**
	 * Upload the avatar file to the reusable `profile` domain (which proxies
	 * to the storage LXS), then profile stores the resulting URL. Profile owns
	 * avatar/cover now — auth is pure identity and no longer accepts uploads.
	 */
	avatar: async ({ request, locals }) => {
		if (!locals.user || !locals.token) return fail(401, { error: 'Sesi berakhir.' });
		const form = await request.formData();
		const file = form.get('file') as File | null;
		if (!file || file.size === 0) return fail(400, { error: 'Pilih file gambar terlebih dahulu.' });

		const userId = locals.user.userId;
		const fd = new FormData();
		fd.append('file', file);

		const res = await fetch(`${PROFILE_BASE}/users/${encodeURIComponent(userId)}/avatar`, {
			method: 'POST',
			headers: { Authorization: `Bearer ${locals.token}` },
			body: fd
		});
		if (!res.ok) return fail(500, { error: 'Gagal mengunggah foto profil. Silakan coba lagi.' });

		redirect(303, '/profil');
	}
};
