import type { Handle } from '@sveltejs/kit';

function decodeJwtPayload(token: string): Record<string, unknown> | null {
  try {
    const parts = token.split('.');
    if (parts.length !== 3) return null;
    const payload = parts[1].replace(/-/g, '+').replace(/_/g, '/');
    const padded = payload + '='.repeat((4 - (payload.length % 4)) % 4);
    const decoded = atob(padded);
    return JSON.parse(decoded);
  } catch {
    return null;
  }
}

export const handle: Handle = async ({ event, resolve }) => {
  const token = event.cookies.get('assessment_token') ?? null;

  event.locals.user = null;
  event.locals.token = null;

  if (token) {
    const payload = decodeJwtPayload(token);
    if (payload) {
      const exp = payload['exp'] as number | undefined;
      if (!exp || exp * 1000 > Date.now()) {
        const userId = payload['sub'] as string;
        const username = payload['username'] as string;
        const role = payload['role'] as string;
        if (userId && username && role) {
          event.locals.user = { userId, username, role };
          event.locals.token = token;
        }
      } else {
        event.cookies.delete('assessment_token', { path: '/' });
      }
    }
  }

  const response = await resolve(event);

  // Never cache HTML pages (or __data.json / actions). Immutable assets under
  // /_app/ already carry far-future immutable cache headers; but the HTML shell
  // must always be revalidated, otherwise a browser keeps serving a cached
  // HTML page whose hashed asset references point at chunks a newer deploy has
  // removed -> hydration fails -> the SvelteKit error page flashes after the
  // page renders ("correct page then 500").
  if (!event.url.pathname.startsWith('/_app/')) {
    response.headers.set('Cache-Control', 'no-store');
  }

  return response;
};
