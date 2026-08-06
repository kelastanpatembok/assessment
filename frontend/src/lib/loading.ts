import { writable } from 'svelte/store';

// Global in-flight request counter that drives the top loading bar in the
// root layout. Every backend/process call that should feel "in motion" hooks
// into this: the shared API client (createApiClient) and any page-level
// fetch() calls go through trackedFetch(), while SvelteKit client-side
// navigations and use:enhance form submissions are covered by the $navigating
// store in +layout.svelte. When the counter is > 0 the bar is visible.
export const pendingRequests = writable(0);

let inFlight = 0;

export function beginRequest() {
  inFlight += 1;
  pendingRequests.set(inFlight);
}

export function endRequest() {
  inFlight = Math.max(0, inFlight - 1);
  pendingRequests.set(inFlight);
}

// fetch wrapper that marks a request as in-flight for the whole network round
// trip (headers + body), so the bar covers the actual wait, not just the call.
export async function trackedFetch(
  input: RequestInfo | URL,
  init?: RequestInit
): Promise<Response> {
  beginRequest();
  try {
    return await fetch(input, init);
  } finally {
    endRequest();
  }
}
