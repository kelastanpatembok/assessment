<script lang="ts">
  import { onMount } from 'svelte';
  import { renderCertificate, type CertificateInput } from '$lib/certificate/render.js';
  import {
    contentUrl,
    initialsFor,
    listCertificates,
    recordCertificate,
    uploadCertificateImage,
    type CertificateView
  } from '$lib/certificate/certificate.js';

  let {
    testKey,
    testName,
    testDescription,
    resultLabel,
    resultLines,
    studentId,
    studentName,
    avatarUrl = null
  }: {
    testKey: 'disc' | 'holland' | 'papi' | 'cfit' | 'ist';
    testName: string;
    testDescription: string;
    resultLabel: string;
    resultLines: string[];
    studentId: string | undefined;
    studentName: string;
    avatarUrl?: string | null;
  } = $props();

  let view = $state<CertificateView | null>(null);
  let status = $state<'loading' | 'ready' | 'error'>('loading');
  let error = $state<string | null>(null);
  let downloading = $state(false);

  function slug(text: string): string {
    return text
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '')
      .slice(0, 48) || 'sertifikat';
  }

  async function generate() {
    status = 'loading';
    error = null;
    try {
      const input: CertificateInput = {
        testKey,
        testName,
        testDescription,
        resultLabel,
        resultLines,
        studentName,
        avatarUrl,
        initials: initialsFor(studentName),
        studentId
      };
      const blob = await renderCertificate(input);
      if (!studentId) throw new Error('Identitas siswa tidak tersedia');
      const uploaded = await uploadCertificateImage(blob, {
        ownerId: studentId,
        testKey
      });
      let recorded = uploaded;
      try {
        recorded = await recordCertificate(testKey, uploaded.storageKey);
      } catch {
        // Recording failed (e.g. session edge) — still usable via the returned key.
      }
      view = recorded;
      status = 'ready';
    } catch (e) {
      error = e instanceof Error ? e.message : 'Terjadi kesalahan saat membuat sertifikat';
      status = 'error';
    }
  }

  onMount(async () => {
    const existing = await listCertificates(testKey).catch(() => [] as CertificateView[]);
    if (existing.length > 0) {
      view = existing[0];
      status = 'ready';
    } else {
      await generate();
    }
  });

  async function download() {
    if (!view || downloading) return;
    downloading = true;
    try {
      const res = await fetch(view.url);
      const blob = await res.blob();
      const ext = blob.type === 'image/webp' ? 'webp' : 'png';
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `${slug(studentName)}-${testKey}-sertifikat.${ext}`;
      document.body.appendChild(a);
      a.click();
      a.remove();
      URL.revokeObjectURL(url);
    } finally {
      downloading = false;
    }
  }
</script>

<section class="cert">
  <div class="cert-head">
    <div>
      <p class="lp-kicker">Sertifikat</p>
      <h3 class="lp-display text-2xl">Sertifikat Penyelesaian</h3>
    </div>
    {#if view}
      <span class="lp-chip lp-chip-strong">Terbit</span>
    {/if}
  </div>

  <div class="lp-card cert-card">
    {#if status === 'loading'}
      <div class="cert-state">
        <p class="lp-lead text-sm">Menghasilkan sertifikat Anda…</p>
        <div class="lp-progress cert-progress"><div style="width: 100%"></div></div>
      </div>
    {:else if status === 'error'}
      <div class="cert-state">
        <p class="lp-error">{error}</p>
        <button type="button" class="lp-btn lp-btn-outline lp-btn-sm" onclick={generate}>Coba Lagi</button>
      </div>
    {:else if view}
      <div class="cert-grid">
        <a href={view.url} target="_blank" rel="noopener" class="cert-thumb" title="Buka sertifikat">
          <img src={contentUrl(view.storageKey)} alt={`Sertifikat ${testName}`} loading="lazy" />
        </a>
        <div class="cert-actions">
          <div class="cert-meta">
            <p class="lp-muted text-xs">Tes</p>
            <p class="font-semibold">{testName}</p>
          </div>
          <div class="cert-meta">
            <p class="lp-muted text-xs">Nomor</p>
            <p class="font-mono text-sm">{view.storageKey.split('/').pop()?.replace(/\.[a-z]+$/i, '')}</p>
          </div>
          <div class="cert-btn-row">
            <a href={view.url} class="lp-btn lp-btn-outline" target="_blank" rel="noopener">Lihat</a>
            <button type="button" class="lp-btn lp-btn-primary" onclick={download} disabled={downloading}>
              {downloading ? 'Mengunduh…' : 'Unduh Sertifikat'}
            </button>
          </div>
        </div>
      </div>
    {/if}
  </div>
</section>

<style>
  .cert {
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .cert-head {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 1rem;
  }

  .cert-card {
    padding: clamp(1rem, 3vw, 1.5rem);
  }

  .cert-state {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    padding: 0.5rem 0;
  }

  .cert-progress {
    max-width: 20rem;
  }

  .cert-progress > div {
    width: 40%;
    animation: cert-shimmer 1.1s var(--lp-ease-out) infinite;
  }

  @keyframes cert-shimmer {
    0% { transform: translateX(-100%); }
    100% { transform: translateX(200%); }
  }

  .cert-grid {
    display: grid;
    grid-template-columns: minmax(0, 1fr);
    gap: 1.25rem;
    align-items: start;
  }

  .cert-thumb {
    display: block;
    border-radius: 0.9rem;
    overflow: hidden;
    border: 1px solid var(--lp-rule-2);
    background: var(--lp-paper-2);
    line-height: 0;
  }

  .cert-thumb img {
    width: 100%;
    height: auto;
    aspect-ratio: 1600 / 1132;
    object-fit: cover;
    display: block;
  }

  .cert-actions {
    display: flex;
    flex-direction: column;
    gap: 0.9rem;
  }

  .cert-meta {
    display: flex;
    flex-direction: column;
    gap: 0.15rem;
  }

  .cert-btn-row {
    display: flex;
    flex-wrap: wrap;
    gap: 0.6rem;
    margin-top: 0.25rem;
  }

  @media (min-width: 40rem) {
    .cert-grid {
      grid-template-columns: minmax(0, 1.6fr) minmax(0, 1fr);
    }
  }
</style>
