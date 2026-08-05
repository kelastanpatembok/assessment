import { redirect } from '@sveltejs/kit';
import { getProfile } from '$lib/server/profile';
import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ locals }) => {
	if (!locals.user) redirect(302, '/signup');
	const profile = await getProfile(locals.user.userId, locals.token ?? '');
	return { user: locals.user, profile };
};
