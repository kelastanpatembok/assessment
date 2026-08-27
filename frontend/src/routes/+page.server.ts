import { redirect } from '@sveltejs/kit';
import { getProfile } from '$lib/server/profile';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
	// Anonymous visitors see the public landing page.
	if (!locals.user) return { user: null, profile: null };

	// Role users go straight to their panel.
	const roles = locals.user.roles.map((role) => role.toLowerCase());
	const role = locals.user.role;
	// A multi-role account lands on its highest-authority workspace, while the
	// account menu still offers every permitted dashboard.
	if (roles.includes('superadmin')) redirect(302, '/admin-dashboard');
	if (roles.includes('gurubk')) redirect(302, '/counselor-dashboard');
	if (roles.includes('psikolog')) redirect(302, '/psikolog-dashboard');
	if (roles.includes('afiliator')) redirect(302, '/afiliator-dashboard');
	if (role === 'superadmin') redirect(302, '/admin-dashboard');
	if (role === 'gurubk') redirect(302, '/counselor-dashboard');
	if (role === 'afiliator') redirect(302, '/afiliator-dashboard');
	if (role === 'psikolog') redirect(302, '/psikolog-dashboard');
	if (role === 'siswa') redirect(302, '/student-dashboard');
	if (role === 'pic') redirect(302, '/profil');

	// Free/member users get a personalized landing page.
	const profile = await getProfile(locals.user.userId, locals.token ?? '');
	return { user: locals.user, profile };
};
