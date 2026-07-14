import { requireRole } from '$lib/server/auth';
import type { LayoutServerLoad } from './$types';

// The +layout@.svelte reset in this group swaps out the sidebar shell for
// the distraction-free exam chrome — but resetting the *component* tree
// also drops enforcement of (student)/+layout.server.ts's auth guard for
// routes nested here. Re-run it explicitly so exam routes stay protected
// regardless of that inheritance quirk.
export const load: LayoutServerLoad = async ({ locals }) => {
  requireRole(locals, 'siswa');
  return { user: locals.user };
};
