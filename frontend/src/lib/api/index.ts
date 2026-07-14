import { PUBLIC_API_URL } from '$env/static/public';
import { env } from '$env/dynamic/public';

// Debug logging for both static and dynamic env
console.log('Static env debug:', {
  PUBLIC_API_URL,
  typeof_PUBLIC_API_URL: typeof PUBLIC_API_URL,
  is_undefined: PUBLIC_API_URL === undefined,
  is_empty: PUBLIC_API_URL === '',
});

console.log('Dynamic env debug:', {
  env_PUBLIC_API_URL: env.PUBLIC_API_URL,
  all_dynamic_env: env
});

// In server-side context, we might need to access process.env directly
let processEnvApiUrl: string | undefined;
try {
  processEnvApiUrl = (globalThis as any).process?.env?.PUBLIC_API_URL;
} catch (e) {
  processEnvApiUrl = undefined;
}

console.log('Process env debug:', {
  process_env_PUBLIC_API_URL: processEnvApiUrl,
  globalThis_has_process: typeof (globalThis as any).process !== 'undefined'
});

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
    } catch (e) {
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

export function createApiClient(token: string | null) {
  // Try multiple sources for the API URL - prioritize server-side process.env for SSR
  const base = processEnvApiUrl || PUBLIC_API_URL || env.PUBLIC_API_URL || 'http://127.0.0.1:2001/api';
  
  // Debug the actual base URL being used AND the token
  console.log('API Client created with:', {
    base_url: base,
    source_used: processEnvApiUrl ? 'process.env' : PUBLIC_API_URL ? 'static_env' : env.PUBLIC_API_URL ? 'dynamic_env' : 'fallback',
    has_token: !!token,
    token_length: token?.length || 0,
    token_preview: token ? `${token.substring(0, 20)}...` : 'null'
  });
  
  const headers: Record<string, string> = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  return {
    get: (path: string) => {
      console.log(`Making GET request to: ${base}${path}`);
      return fetch(`${base}${path}`, { headers }).then(handleResponse).catch(error => {
        console.error(`GET ${path} failed:`, error.message);
        throw error;
      });
    },
    // For binary responses (e.g. PDF downloads) that need the Authorization header,
    // which a plain <a href> can't attach.
    getBlob: async (path: string): Promise<Blob> => {
      console.log(`Making GET (blob) request to: ${base}${path}`);
      const response = await fetch(`${base}${path}`, { headers: { Authorization: headers['Authorization'] } });
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      return response.blob();
    },
    post: (path: string, body: unknown) => {
      console.log(`Making POST request to: ${base}${path}`);
      return fetch(`${base}${path}`, { method: 'POST', headers, body: JSON.stringify(body) }).then(handleResponse).catch(error => {
        console.error(`POST ${path} failed:`, error.message);
        throw error;
      });
    },
    put: (path: string, body: unknown) => {
      console.log(`Making PUT request to: ${base}${path}`);
      return fetch(`${base}${path}`, { method: 'PUT', headers, body: JSON.stringify(body) }).then(handleResponse).catch(error => {
        console.error(`PUT ${path} failed:`, error.message);
        throw error;
      });
    },
    delete: (path: string) => {
      console.log(`Making DELETE request to: ${base}${path}`);
      return fetch(`${base}${path}`, { method: 'DELETE', headers }).then(response => {
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }
        return response.ok;
      }).catch(error => {
        console.error(`DELETE ${path} failed:`, error.message);
        throw error;
      });
    },
  };
}
