<script lang="ts">
  import { enhance } from '$app/forms';
  import { dev } from '$app/environment';

  let { data } = $props();

  const dateFmt = new Intl.DateTimeFormat('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });

  const tints: Record<string, string> = {
    disc: 'amber',
    holland: 'sage',
    papi: 'clay',
    cfit: 'cold',
    ist: 'grey'
  };

  function formatWindow(windowStart: string | null, windowEnd: string | null): string | null {
    if (!windowStart && !windowEnd) return null;
    const start = windowStart ? dateFmt.format(new Date(windowStart)) : '?';
    const end = windowEnd ? dateFmt.format(new Date(windowEnd)) : '?';
    return `${start} – ${end}`;
  }
</script>

<svelte:head><title>Dashboard Siswa — Asesmen</title></svelte:head>

<div class="stdash">
  <section class="stdash-hero">
    <p class="stdash-kicker">Panel Siswa</p>
    <h2 class="stdash-title">Halo, selamat datang.</h2>
    <p class="stdash-lede">Pilih tes yang tersedia di bawah untuk mulai mengenal potensimu.</p>
  </section>

  <div class="stdash-grid">
    {#each data.tests as test}
      <article class="scard scard-{tints[test.key]}">
        <div class="scard-top">
          <span class="scard-code">{test.label}</span>
          <span
            class="scard-badge"
            class:done={test.completed}
            class:open={test.available && !test.completed}
            class:hold={!test.available && !test.completed}
          >
            {test.completed ? 'Selesai' : test.available ? 'Tersedia' : 'Belum Tersedia'}
          </span>
        </div>
        <p class="scard-desc">
          {test.completed
            ? 'Tes telah diselesaikan — lihat hasil dan interpretasinya.'
            : test.available
              ? 'Tes tersedia. Kamu bisa mengerjakannya sekarang.'
              : 'Tes belum dibuka untukmu oleh sekolah.'}
        </p>
        {#if !test.completed}
          {@const window = formatWindow(test.windowStart, test.windowEnd)}
          {#if window}
            <p class="scard-window">Periode: {window}</p>
          {/if}
        {/if}
        <div class="scard-actions">
          {#if test.completed}
            <a href="{test.href}/result" class="scard-btn">Lihat Hasil</a>
            {#if dev}
              <form
                method="POST"
                action="?/clear"
                use:enhance={() => async ({ update }) => { await update(); }}
              >
                <input type="hidden" name="testKey" value={test.key} />
                <button type="submit" class="scard-btn scard-btn-ghost scard-btn-dev">Clear</button>
              </form>
            {/if}
          {:else if test.available}
            <a href={test.href} class="scard-btn">Mulai Tes</a>
          {:else}
            <button type="button" disabled class="scard-btn scard-btn-off">Belum Tersedia</button>
          {/if}
        </div>
      </article>
    {/each}
  </div>
</div>

<style>
  .stdash {
    display: grid;
    gap: clamp(1.5rem, 3vw, 2.25rem);
  }

  .stdash-hero {
    max-width: 40rem;
  }

  .stdash-kicker {
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-accent-deep);
    margin: 0 0 0.5rem;
  }

  .stdash-title {
    font-family: var(--lp-font-display);
    font-size: clamp(1.7rem, 3vw + 0.6rem, 2.3rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1.12;
    margin: 0 0 0.6rem;
  }

  .stdash-lede {
    color: var(--lp-ink-2);
    margin: 0;
  }

  .stdash-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(15rem, 1fr));
    gap: 1rem;
  }

  .scard {
    display: flex;
    flex-direction: column;
    gap: 0.8rem;
    border: 1px solid var(--lp-rule);
    border-radius: 1.25rem;
    padding: 1.25rem;
  }

  .scard-amber { background: var(--lp-tint-amber); }
  .scard-sage { background: var(--lp-tint-sage); }
  .scard-clay { background: var(--lp-tint-clay); }
  .scard-cold { background: var(--lp-tint-cold); }
  .scard-grey { background: var(--lp-tint-grey); }

  .scard-top {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 0.75rem;
  }

  .scard-code {
    font-family: var(--lp-font-display);
    font-size: 1.1rem;
    font-weight: 580;
    letter-spacing: -0.01em;
    line-height: 1.15;
  }

  .scard-badge {
    flex: none;
    font-size: 0.66rem;
    font-weight: 650;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    padding: 0.25rem 0.6rem;
    border-radius: 999px;
    border: 1px solid var(--lp-rule-2);
    white-space: nowrap;
  }

  .scard-badge.done {
    color: var(--lp-accent-deep);
    border-color: var(--lp-accent);
    background: color-mix(in oklab, var(--lp-paper) 55%, transparent);
  }

  .scard-badge.open {
    color: var(--lp-ink);
    border-color: var(--lp-rule-2);
    background: color-mix(in oklab, var(--lp-paper) 55%, transparent);
  }

  .scard-badge.hold {
    color: var(--lp-muted);
  }

  .scard-desc {
    color: var(--lp-ink-2);
    font-size: 0.9rem;
    margin: 0;
  }

  .scard-window {
    color: var(--lp-muted);
    font-size: 0.8rem;
    margin: 0;
  }

  .scard-actions {
    margin-top: auto;
    display: flex;
    flex-wrap: wrap;
    gap: 0.6rem;
  }

  .scard-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 2.75rem;
    padding: 0.55rem 1.15rem;
    border-radius: 999px;
    background: var(--lp-accent-bg);
    color: var(--lp-ink);
    border: 1px solid var(--lp-accent-bg);
    font-weight: 650;
    font-size: 0.92rem;
    cursor: pointer;
    white-space: nowrap;
    text-decoration: none;
    transition: background-color 160ms var(--lp-ease-out), transform 160ms var(--lp-ease-out);
  }

  .scard-btn:hover {
    background: var(--lp-accent);
    transform: translateY(-1px);
  }

  .scard-btn-ghost {
    background: transparent;
    border-color: var(--lp-rule-2);
  }

  .scard-btn-ghost:hover {
    background: var(--lp-paper-2);
  }

  .scard-btn-dev {
    color: oklch(0.55 0.18 25);
  }

  .scard-btn-off {
    background: var(--lp-paper-2);
    border-color: var(--lp-rule);
    color: var(--lp-muted);
    cursor: not-allowed;
  }
</style>
