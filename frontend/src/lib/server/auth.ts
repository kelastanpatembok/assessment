import { redirect } from '@sveltejs/kit';

export function requireRole(locals: App.Locals, ...roles: string[]) {
  if (!locals.user) redirect(302, '/signin');
  const userRole = locals.user.role.toLowerCase();
  const allowedRoles = roles.map(r => r.toLowerCase());
  if (!allowedRoles.includes(userRole)) redirect(302, '/signin');
}
