import { redirect } from '@sveltejs/kit';

export function requireRole(locals: App.Locals, ...roles: string[]) {
  if (!locals.user) redirect(302, '/login');
  if (!roles.includes(locals.user.role)) redirect(302, '/login');
}
