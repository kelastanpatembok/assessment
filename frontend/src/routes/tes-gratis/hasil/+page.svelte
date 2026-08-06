<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { page } from '$app/stores';

  type Trait = { key: string; label: string; value: number; level: string; description: string };
  type Result = { headline: string; traits: Trait[] };

  let result = $state<Result | null>(null);
  let ready = $state(false);
  let saved = $state(false);
  let copied = $state(false);
  let barWidths = $state<Record<string, number>>({});

  const isSaved = $derived($page.url.searchParams.get('saved') === '1');

  onMount(() => {
    const raw = sessionStorage.getItem('big5_result');
    if (raw) {
      try {
        result = JSON.parse(raw);
      } catch {
        result = null;
      }
    }
    saved = isSaved;
    if (!result && !saved) {
      goto('/tes-gratis');
      return;
    }
    ready = true;
    requestAnimationFrame(() => {
      if (result) {
        const widths: Record<string, number> = {};
        for (const t of result.traits) widths[t.key] = t.value;
        barWidths = widths;
      }
    });
  });

  const shareText = $derived(
    result
      ? `Hasil tes kepribadianku: ${result.headline} — coba tes gratisnya juga di Asesmen.`
      : ''
  );

  async function copyShare() {
    try {
      await navigator.clipboard.writeText(shareText);
      copied = true;
      setTimeout(() => (copied = false), 2500);
    } catch {
      // Clipboard unavailable — the text is visible on screen regardless.
    }
  }
</script>

<svelte:head>
  <title>Hasil Tes — Asesmen</title>
</svelte:head>

<div class="hasil">
  {#if !ready}
    <p class="lp-lead hasil-status">Memuat hasil…</p>
  {:else if result}
    <header class="hasil-head">
      <p class="lp-kicker">Hasil tes kepribadian</p>
      <h1 class="lp-display hasil-title">{result.headline}</h1>
      <p class="lp-lead hasil-lede">
        Berdasarkan jawabanmu, inilah gambaran umum kepribadianmu. Hasil ini untuk eksplorasi diri, bukan diagnosis
        klinis.
      </p>
    </header>

    <div class="hasil-bars">
      {#each result.traits as t}
        <div class="hbar">
          <div class="hbar-top">
            <span class="hbar-label">{t.label}</span>
            <span class="lp-muted hbar-meta">{t.level} · {Math.round(t.value)}</span>
          </div>
          <div class="lp-bar">
            <div style:width="{barWidths[t.key] ?? 0}%"></div>
          </div>
          <p class="lp-lead hbar-desc">{t.description}</p>
        </div>
      {/each}
    </div>

    <div class="lp-card-tint lp-card-pad hasil-share">
      <p class="hasil-share-text">{shareText}</p>
      <button type="button" class="lp-btn lp-btn-outline" onclick={copyShare}>
        {copied ? 'Tersalin' : 'Salin untuk Dibagikan'}
      </button>
    </div>

    <section class="lp-card-tint lp-card-pad hasil-saved-box">
      <p>{saved ? 'Hasilmu sudah tersimpan di akunmu dan dapat dilihat kembali.' : 'Hasil tesmu sudah lengkap.'}</p>
      <div class="hasil-links">
        <a href="/" class="lp-btn lp-btn-primary">Kembali ke Beranda</a>
      </div>
    </section>
  {:else}
    <div class="hasil-saved">
      <h1 class="lp-display hasil-title">Hasilmu telah tersimpan.</h1>
      <p>Silakan masuk kembali untuk melihat hasil kepribadianmu.</p>
      <a href="/signin" class="lp-btn lp-btn-primary">Masuk</a>
    </div>
  {/if}
</div>

<style>
  .hasil {
    max-width: 42rem;
    margin-inline: auto;
    padding: clamp(2rem, 6vw, 3.5rem) clamp(1.25rem, 4vw, 2rem) 3rem;
  }

  .hasil-status {
    padding: 2rem 0;
  }

  .hasil-title {
    font-size: clamp(2rem, 6vw, 2.9rem);
    line-height: 1.1;
    margin: 0 0 0.9rem;
  }

  .hasil-lede {
    font-size: 1.02rem;
    margin: 0 0 2.25rem;
  }

  .hasil-bars {
    display: grid;
    gap: 1.5rem;
  }

  .hbar-top {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 1rem;
    margin-bottom: 0.5rem;
  }

  .hbar-label {
    font-weight: 650;
  }

  .hbar-meta {
    font-size: 0.82rem;
    font-variant-numeric: tabular-nums;
    white-space: nowrap;
  }

  .hbar-desc {
    font-size: 0.9rem;
    margin: 0.5rem 0 0;
  }

  .hasil-share {
    margin-top: 2.5rem;
  }

  .hasil-share-text {
    font-family: var(--lp-font-display);
    font-style: italic;
    font-size: 1.05rem;
    margin: 0 0 1rem;
  }

  .hasil-saved-box {
    margin-top: 1rem;
    display: grid;
    gap: 1rem;
  }

  .hasil-saved-box p {
    margin: 0;
  }

  .hasil-links {
    display: flex;
    flex-wrap: wrap;
    gap: 0.75rem;
  }
</style>
