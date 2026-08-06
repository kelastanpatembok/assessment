import { env } from '$env/dynamic/public';
import { fail, redirect } from '@sveltejs/kit';
import type { Actions, PageServerLoad } from './$types';

const PHONE_REGEX = /^(\+62|0|62)[0-9]{9,12}$/;
const authBaseUrl = env.PUBLIC_AUTH_URL || 'http://127.0.0.1:1007/api';

export const load: PageServerLoad = async ({ locals }) => {
	if (locals.user) {
		redirect(302, '/');
	}

	return {};
};

export const actions: Actions = {
	default: async ({ request, cookies }) => {
		const data = await request.formData();
		const name = String(data.get('name') ?? '').trim();
		const email = String(data.get('email') ?? '').trim();
		const password = String(data.get('password') ?? '');
		const whatsappNumber = String(data.get('whatsappNumber') ?? '').trim();
		const province = String(data.get('province') ?? '').trim();

		if (!name || !email || !password || !whatsappNumber || !province) {
			return fail(400, {
				error: 'Semua field wajib diisi',
				values: { name, email, whatsappNumber, province }
			});
		}

		if (password.length < 6) {
			return fail(400, {
				error: 'Password minimal 6 karakter',
				values: { name, email, whatsappNumber, province }
			});
		}

		if (!PHONE_REGEX.test(whatsappNumber.replace(/\s/g, ''))) {
			return fail(400, {
				error: 'Nomor WhatsApp tidak valid',
				values: { name, email, whatsappNumber, province }
			});
		}

		const params = new URLSearchParams({
			email,
			password,
			name,
			whatsappNumber,
			province
		});

		let response: Response;
		try {
			response = await fetch(`${authBaseUrl}/auth/register-with-profile?${params.toString()}`, {
				method: 'POST'
			});
		} catch (error) {
			console.error('Failed to register with profile:', error);
			return fail(500, {
				error: 'Terjadi kesalahan sistem',
				values: { name, email, whatsappNumber, province }
			});
		}

		if (!response.ok) {
			let message = 'Gagal membuat akun';
			try {
				const json = await response.json();
				if (json?.message) {
					message = json.message;
				}
			} catch {
				// keep default message
			}

			return fail(response.status, {
				error: message,
				values: { name, email, whatsappNumber, province }
			});
		}

		const json = await response.json();
		const token = json?.token;

		if (!token) {
			return fail(500, {
				error: 'Token login tidak tersedia',
				values: { name, email, whatsappNumber, province }
			});
		}

		cookies.set('assessment_token', token, {
			httpOnly: true,
			path: '/',
			maxAge: 86400,
			sameSite: 'lax'
		});

		redirect(302, '/');
	}
};
