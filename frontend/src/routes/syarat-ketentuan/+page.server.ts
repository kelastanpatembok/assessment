import { getAuthProfile } from '$lib/server/profile';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
	if (!locals.user) return { user: null, profile: null };
	const profile = await getAuthProfile(locals.user.userId, locals.token ?? '');
	return { user: locals.user, profile };
};
