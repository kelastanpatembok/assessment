<script lang="ts">
  let { data } = $props();

  let total = $derived(
    data.fees?.reduce((sum: number, f: any) => sum + (f.affiliatorFee ?? 0), 0) ?? 0
  );
</script>

<svelte:head><title>Dashboard Afiliator — Asesmen</title></svelte:head>

<div class="fdash">
  <section class="fdash-hero">
    <p class="fdash-kicker">Panel Afiliator</p>
    <h2 class="fdash-title">Ringkasan komisi.</h2>
    <p class="fdash-lede">Pantau pendapatan komisi dari klien yang Anda kelola.</p>
  </section>

  <article class="fcard">
    <p class="fcard-label">Total Komisi</p>
    <p class="fcard-num">Rp {total.toLocaleString('id-ID')}</p>
    <p class="fcard-sub">Akumulasi komisi dari seluruh asesmen klien</p>
  </article>

  <section class="quick">
    <h3 class="quick-title">Akses cepat</h3>
    <div class="quick-grid">
      <a href="/afiliator-fees" class="qa">
        <span class="qa-label">Lihat Rincian Komisi</span>
        <span class="qa-sub">Rekap komisi per siswa</span>
      </a>
    </div>
  </section>
</div>

<style>
  .fdash {
    display: grid;
    gap: clamp(1.5rem, 3vw, 2.25rem);
  }

  .fdash-hero {
    max-width: 40rem;
  }

  .fdash-kicker {
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-accent-deep);
    margin: 0 0 0.5rem;
  }

  .fdash-title {
    font-family: var(--lp-font-display);
    font-size: clamp(1.7rem, 3vw + 0.6rem, 2.3rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1.12;
    margin: 0 0 0.6rem;
  }

  .fdash-lede {
    color: var(--lp-ink-2);
    margin: 0;
  }

  .fcard {
    max-width: 26rem;
    border: 1px solid var(--lp-rule);
    border-radius: 1.25rem;
    background: var(--lp-tint-amber);
    padding: 1.6rem 1.75rem;
    display: grid;
    gap: 0.4rem;
  }

  .fcard-label {
    font-size: 0.8rem;
    font-weight: 650;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    color: var(--lp-ink-2);
    margin: 0;
  }

  .fcard-num {
    font-family: var(--lp-font-display);
    font-size: clamp(2rem, 4vw, 2.8rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1;
    margin: 0;
    font-variant-numeric: tabular-nums;
  }

  .fcard-sub {
    color: var(--lp-muted);
    font-size: 0.85rem;
    margin: 0;
  }

  .quick {
    display: grid;
    gap: 1rem;
  }

  .quick-title {
    font-family: var(--lp-font-display);
    font-size: 1.4rem;
    font-weight: 560;
    letter-spacing: -0.01em;
    margin: 0;
  }

  .quick-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(15rem, 1fr));
    gap: 1rem;
  }

  .qa {
    display: grid;
    gap: 0.35rem;
    border: 1px solid var(--lp-rule);
    border-radius: 1.25rem;
    background: var(--lp-tint-sage);
    padding: 1.25rem;
    text-decoration: none;
    transition: transform 160ms var(--lp-ease-out), border-color 160ms var(--lp-ease-out);
  }

  .qa:hover {
    transform: translateY(-2px);
    border-color: var(--lp-rule-2);
  }

  .qa-label {
    font-weight: 650;
    color: var(--lp-ink);
  }

  .qa-sub {
    color: var(--lp-muted);
    font-size: 0.85rem;
  }
</style>
