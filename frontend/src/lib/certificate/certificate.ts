import { trackedFetch } from '$lib/loading.js';

/**
 * Certificate persistence helpers.
 *
 * The generated PNG is uploaded to the storage domain (/api/storage/objects,
 * routed by the gateway to the S3-backed photos service) and the resulting
 * storage key is recorded against the student via the backend
 * POST /certificates. Recording/listing goes through the same-origin
 * SvelteKit endpoint /certificates (this app's server layer) so the httpOnly
 * JWT cookie never has to be exposed to the browser.
 */

export type CertificateView = {
  testType: string;
  storageKey: string;
  url: string;
  createdAt: string | null;
};

export function contentUrl(storageKey: string): string {
  return `/api/storage/content/${storageKey}`;
}

/** Uploads the rendered certificate PNG to the storage domain. */
export async function uploadCertificateImage(
  blob: Blob,
  opts: { ownerId: string; testKey: string }
): Promise<CertificateView> {
  const form = new FormData();
  form.append('file', blob, 'certificate.png');
  form.append('owner_id', opts.ownerId);
  form.append('namespace', 'certificates');
  form.append('reference_id', opts.testKey);
  const res = await trackedFetch('/api/storage/objects', { method: 'POST', body: form });
  if (!res.ok) throw new Error('Gagal menyimpan gambar sertifikat');
  const data = await res.json();
  return {
    testType: opts.testKey,
    storageKey: data.key as string,
    url: contentUrl(data.key as string),
    createdAt: data.created_at ?? null
  };
}

/** Returns the current student's certificates, optionally filtered by test. */
export async function listCertificates(testKey?: string): Promise<CertificateView[]> {
  const qs = testKey ? `?test=${encodeURIComponent(testKey)}` : '';
  const res = await trackedFetch(`/certificates${qs}`);
  if (!res.ok) return [];
  return res.json();
}

/** Records a generated certificate against the current student. */
export async function recordCertificate(
  testKey: string,
  storageKey: string
): Promise<CertificateView> {
  const res = await trackedFetch('/certificates', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ testType: testKey, storageKey })
  });
  if (!res.ok) throw new Error('Gagal mendaftarkan sertifikat');
  return res.json();
}

export function initialsFor(name: string | null | undefined): string {
  if (!name) return '?';
  const parts = name.trim().split(/\s+/).filter(Boolean);
  if (parts.length === 0) return '?';
  const initials = parts.slice(0, 2).map((part) => part.charAt(0)).join('');
  return initials.toUpperCase() || '?';
}
