import { requireRole } from '$lib/server/auth';
import type { LayoutServerLoad } from './$types';

export const load: LayoutServerLoad = async ({ locals }) => {
  requireRole(locals, 'siswa');
  return { user: locals.user };
};
