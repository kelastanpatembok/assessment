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
    <p class="hasil-status">Memuat hasil…</p>
  {:else if result}
    <header class="hasil-head">
      <p class="hasil-kicker">Hasil tes kepribadian</p>
      <h1>{result.headline}</h1>
      <p class="hasil-lede">
        Berdasarkan jawabanmu, inilah gambaran umum kepribadianmu. Hasil ini untuk eksplorasi diri,
        bukan diagnosis klinis.
      </p>
    </header>

    <div class="hasil-bars">
      {#each result.traits as t}
        <div class="hbar">
          <div class="hbar-top">
            <span class="hbar-label">{t.label}</span>
            <span class="hbar-meta">{t.level} · {Math.round(t.value)}</span>
          </div>
          <div class="hbar-track">
            <div class="hbar-fill" style:width="{barWidths[t.key] ?? 0}%"></div>
          </div>
          <p class="hbar-desc">{t.description}</p>
        </div>
      {/each}
    </div>

    <div class="hasil-share">
      <p class="hasil-share-text">{shareText}</p>
      <button type="button" class="hasil-copy" onclick={copyShare}>
        {copied ? 'Tersalin' : 'Salin untuk Dibagikan'}
      </button>
    </div>

    <section class="hasil-saved-box">
      <p>{saved ? 'Hasilmu sudah tersimpan di akunmu dan dapat dilihat kembali.' : 'Hasil tesmu sudah lengkap.'}</p>
      <div class="hasil-links">
        <a href="/" class="hasil-cta">Kembali ke Beranda</a>
      </div>
    </section>
  {:else}
    <div class="hasil-saved">
      <h1>Hasilmu telah tersimpan.</h1>
      <p>Silakan masuk kembali untuk melihat hasil kepribadianmu.</p>
      <a href="/signin" class="hasil-cta">Masuk</a>
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
    color: var(--lp-ink-2);
    padding: 2rem 0;
  }

  .hasil-kicker {
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-accent-deep);
    margin: 0 0 0.75rem;
  }

  .hasil-head h1,
  .hasil-saved h1 {
    font-family: var(--lp-font-display);
    font-size: clamp(2rem, 6vw, 2.9rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1.1;
    margin: 0 0 0.9rem;
    overflow-wrap: anywhere;
  }

  .hasil-lede {
    color: var(--lp-ink-2);
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
    color: var(--lp-muted);
    font-size: 0.82rem;
    font-variant-numeric: tabular-nums;
    white-space: nowrap;
  }

  .hbar-track {
    height: 10px;
    border-radius: 999px;
    background: var(--lp-paper-2);
    border: 1px solid var(--lp-rule);
    overflow: hidden;
  }

  .hbar-fill {
    height: 100%;
    border-radius: 999px;
    background: var(--lp-accent);
    transition: width 700ms var(--lp-ease-out);
  }

  .hbar-desc {
    color: var(--lp-ink-2);
    font-size: 0.9rem;
    margin: 0.5rem 0 0;
  }

  .hasil-share {
    margin-top: 2.5rem;
    padding: 1.25rem 1.5rem;
    border: 1px solid var(--lp-rule);
    border-radius: 1.25rem;
    background: var(--lp-paper-2);
  }

  .hasil-share-text {
    font-family: var(--lp-font-display);
    font-style: italic;
    font-size: 1.05rem;
    margin: 0 0 1rem;
  }

  .hasil-copy {
    min-height: 3rem;
    padding: 0.6rem 1.4rem;
    border-radius: 999px;
    border: 1px solid var(--lp-rule-2);
    background: var(--lp-paper);
    color: var(--lp-ink);
    font-weight: 650;
    cursor: pointer;
    transition: background-color 200ms var(--lp-ease-out), border-color 200ms var(--lp-ease-out);
  }

  .hasil-copy:hover {
    border-color: var(--lp-accent);
    background: var(--lp-accent-bg);
  }

  .hasil-saved-box {
    margin-top: 2.5rem;
    background: var(--lp-paper-2);
    border: 1px solid var(--lp-rule);
    border-radius: 1.25rem;
    padding: 1.5rem;
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

  .hasil-cta {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 3.25rem;
    padding: 0.8rem 2rem;
    border-radius: 999px;
    background: var(--lp-accent-bg);
    color: var(--lp-ink);
    border: 1px solid var(--lp-accent-bg);
    font-weight: 650;
    white-space: nowrap;
    cursor: pointer;
    transition: background-color 200ms var(--lp-ease-out), transform 200ms var(--lp-ease-out);
  }

  .hasil-cta:hover {
    background: var(--lp-accent);
    transform: translateY(-1px);
  }
</style>
