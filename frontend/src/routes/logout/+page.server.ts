import { redirect } from '@sveltejs/kit';
import { PUBLIC_AUTH_URL } from '$env/static/public';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async ({ cookies, fetch }) => {
  const token = cookies.get('assessment_token');
  if (token) {
    // The browser cookie is only the client half of a session. Revoke the
    // server-side Auth session as well, otherwise single-session enforcement
    // would reject this user the next time they sign in.
    try {
      await fetch(`${PUBLIC_AUTH_URL}/auth/logout`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}` }
      });
    } catch {
      // Clearing the local cookie still lets the user leave even if Auth is
      // temporarily unavailable; the server session will expire normally.
    }
  }
  cookies.delete('assessment_token', { path: '/' });
  redirect(302, '/signin');
};
