<script lang="ts">
  import SiteHeader from '$lib/components/site/SiteHeader.svelte';
  import SiteFooter from '$lib/components/site/SiteFooter.svelte';

  let { status, error } = $props<{
    status: number;
    error: Error;
  }>();

  const isNotFound = $derived(status === 404);

  const title = $derived(
    isNotFound
      ? 'Halaman tidak ditemukan'
      : status === 403
        ? 'Akses ditolak'
        : status >= 500
          ? 'Terjadi kesalahan'
          : 'Permintaan tidak valid'
  );

  const message = $derived(
    isNotFound
      ? 'Alamat yang kamu buka mungkin sudah dipindahkan, dihapus, atau memang tidak pernah ada.'
      : status === 403
        ? 'Kamu tidak memiliki izin untuk membuka halaman ini.'
        : status >= 500
          ? 'Maaf, ada masalah di sisi kami. Silakan coba lagi sebentar lagi — jika terus berlanjut, hubungi admin sekolah atau tim asesmen.'
          : 'Permintaan yang kamu kirim tidak dapat diproses. Silakan coba lagi.'
  );
</script>

<svelte:head>
  <title>{title} — Asesmen</title>
</svelte:head>

<div class="err">
  <SiteHeader />

  <main class="err-main">
    <div class="err-card">
      <p class="err-kicker">{status}</p>
      <h1>{title}</h1>
      <p class="err-lede">{message}</p>

      <div class="err-actions">
        <a href="/" class="err-cta">Kembali ke Beranda</a>
        <button type="button" class="err-back" onclick={() => history.back()}>Muat ulang halaman</button>
      </div>

      {#if import.meta.env.DEV && error}
        <details class="err-details">
          <summary>Detail teknis (mode pengembangan)</summary>
          <pre>{error.message}</pre>
        </details>
      {/if}
    </div>
  </main>

  <SiteFooter />
</div>

<style>
  .err {
    background: var(--lp-paper);
    color: var(--lp-ink);
    font-family: Figtree, ui-sans-serif, system-ui, sans-serif;
    font-size: 1rem;
    line-height: 1.6;
    min-height: 100dvh;
    display: flex;
    flex-direction: column;
    -webkit-font-smoothing: antialiased;
  }

  .err-main {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: clamp(2rem, 6vw, 3.5rem) clamp(1.25rem, 4vw, 2rem) 3rem;
  }

  .err-card {
    max-width: 32rem;
    width: 100%;
    text-align: center;
  }

  .err-kicker {
    font-size: clamp(3rem, 10vw, 4.5rem);
    font-family: var(--lp-font-display);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1;
    color: var(--lp-accent);
    margin: 0 0 1rem;
  }

  .err-card h1 {
    font-family: var(--lp-font-display);
    font-size: clamp(1.8rem, 5vw, 2.3rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1.12;
    margin: 0 0 0.9rem;
  }

  .err-lede {
    color: var(--lp-ink-2);
    max-width: 28rem;
    margin: 0 auto 2rem;
  }

  .err-actions {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: center;
    gap: 0.75rem;
  }

  .err-cta {
    display: inline-flex;
    align-items: center;
    min-height: 3rem;
    padding: 0.7rem 1.5rem;
    border-radius: 999px;
    background: var(--lp-accent-bg);
    color: var(--lp-ink);
    border: 1px solid var(--lp-accent-bg);
    font-weight: 650;
    text-decoration: none;
    white-space: nowrap;
    transition: background-color 200ms var(--lp-ease-out), transform 200ms var(--lp-ease-out);
  }

  .err-cta:hover {
    background: var(--lp-accent);
    transform: translateY(-1px);
  }

  .err-back {
    min-height: 3rem;
    padding: 0.7rem 1.25rem;
    border-radius: 999px;
    background: transparent;
    color: var(--lp-ink-2);
    border: 1px solid var(--lp-rule-2);
    font-weight: 600;
    cursor: pointer;
    transition: border-color 200ms var(--lp-ease-out), color 200ms var(--lp-ease-out);
  }

  .err-back:hover {
    color: var(--lp-ink);
    border-color: var(--lp-ink-2);
  }

  .err-details {
    margin: 1.75rem auto 0;
    text-align: left;
    max-width: 32rem;
    color: var(--lp-muted);
    font-size: 0.82rem;
  }

  .err-details summary {
    cursor: pointer;
  }

  .err-details pre {
    white-space: pre-wrap;
    word-break: break-word;
    background: var(--lp-paper-2);
    border: 1px solid var(--lp-rule);
    border-radius: 0.625rem;
    padding: 0.9rem 1rem;
    margin: 0.6rem 0 0;
    color: var(--lp-ink-2);
  }

  .err :global(a):focus-visible,
  .err :global(button):focus-visible {
    outline: 2px solid var(--lp-focus);
    outline-offset: 3px;
  }
</style>
