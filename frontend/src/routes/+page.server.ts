import { redirect } from '@sveltejs/kit';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ locals }) => {
  if (!locals.user) redirect(302, '/login');
  const role = locals.user.role;
  if (role === 'superadmin') redirect(302, '/admin-dashboard');
  if (role === 'gurubk') redirect(302, '/counselor-dashboard');
  if (role === 'afiliator') redirect(302, '/afiliator-dashboard');
  if (role === 'siswa') redirect(302, '/student-dashboard');
  redirect(302, '/login');
};
