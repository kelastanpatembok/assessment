import { PUBLIC_API_URL } from '$env/static/public';
import { env } from '$env/dynamic/public';

// On the server (SSR), the adapter may expose PUBLIC_API_URL via process.env;
// on the client it comes from the statically-baked PUBLIC_API_URL instead.
let processEnvApiUrl: string | undefined;
try {
  processEnvApiUrl = (globalThis as any).process?.env?.PUBLIC_API_URL;
} catch {
  processEnvApiUrl = undefined;
}

async function handleResponse(response: Response) {
  if (!response.ok) {
    let errorMessage = `HTTP ${response.status}: ${response.statusText}`;

    try {
      const contentType = response.headers.get('content-type');
      if (contentType && contentType.includes('application/json')) {
        const errorData = await response.json();
        if (errorData.message) {
          errorMessage = errorData.message;
        } else if (errorData.error) {
          errorMessage = errorData.error;
        }
      } else {
        const textError = await response.text();
        if (textError) {
          errorMessage = textError;
        }
      }
    } catch {
      // Keep the default HTTP error message if we can't parse the response
    }

    throw new Error(errorMessage);
  }

  const contentType = response.headers.get('content-type');
  if (contentType && contentType.includes('application/json')) {
    return response.json();
  } else {
    return response.text();
  }
}

function logError(kind: string, path: string, error: unknown) {
  const message = error instanceof Error ? error.message : String(error);
  console.error(`${kind} ${path} failed: ${message.slice(0, 500)}`);
}

export function createApiClient(token: string | null) {
  // Priority: server-side process.env (SSR), then static, then dynamic. The
  // fallback is a dev-only convenience and must not be relied on in prod.
  const base =
    processEnvApiUrl ||
    PUBLIC_API_URL ||
    env.PUBLIC_API_URL ||
    'http://127.0.0.1:1005/api';

  const headers: Record<string, string> = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  return {
    get: (path: string) =>
      fetch(`${base}${path}`, { headers })
        .then(handleResponse)
        .catch((error: unknown) => {
          logError('GET', path, error);
          throw error;
        }),
    // For binary responses (e.g. PDF downloads) that need the Authorization header,
    // which a plain <a href> can't attach.
    getBlob: async (path: string): Promise<Blob> => {
      const response = await fetch(`${base}${path}`, {
        headers: { Authorization: headers['Authorization'] }
      });
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      return response.blob();
    },
    post: (path: string, body: unknown) =>
      fetch(`${base}${path}`, { method: 'POST', headers, body: JSON.stringify(body) })
        .then(handleResponse)
        .catch((error: unknown) => {
          logError('POST', path, error);
          throw error;
        }),
    put: (path: string, body: unknown) =>
      fetch(`${base}${path}`, { method: 'PUT', headers, body: JSON.stringify(body) })
        .then(handleResponse)
        .catch((error: unknown) => {
          logError('PUT', path, error);
          throw error;
        }),
    delete: (path: string) =>
      fetch(`${base}${path}`, { method: 'DELETE', headers })
        .then((response) => {
          if (!response.ok) {
            throw new Error(`HTTP ${response.status}: ${response.statusText}`);
          }
          return response.ok;
        })
        .catch((error: unknown) => {
          logError('DELETE', path, error);
          throw error;
        })
  };
}
