import { redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

// Backward-compatible alias: /login now lives at /signin.
export const load: PageServerLoad = () => {
  redirect(302, '/signin');
};
