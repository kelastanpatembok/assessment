import { redirect } from '@sveltejs/kit';

export function requireRole(locals: App.Locals, ...roles: string[]) {
  if (!locals.user) redirect(302, '/signin');
  if (!locals.user.roles.some((role) => roles.includes(role))) redirect(302, '/signin');
}
