import { redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ cookies }) => {
  cookies.delete('assessment_token', { path: '/' });
  redirect(302, '/login');
};
