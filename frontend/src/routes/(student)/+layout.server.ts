import { requireRole } from '$lib/server/auth';
import { getProfile } from '$lib/server/profile';
import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ locals }) => {
  requireRole(locals, 'siswa');
  if (!locals.user) return { user: null, profile: null };
  const profile = await getProfile(locals.user.userId, locals.token ?? '');
  return { user: locals.user, profile };
};
