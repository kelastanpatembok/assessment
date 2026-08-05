<script lang="ts">
  let { data } = $props();
</script>

<svelte:head><title>Dashboard Admin — Asesmen</title></svelte:head>

<div class="adash">
  <section class="adash-hero">
    <p class="adash-kicker">Panel Admin</p>
    <h2 class="adash-title">Ikhtisar platform.</h2>
    <p class="adash-lede">Ringkasan singkat sekolah dan pengguna yang terdaftar di Asesmen.</p>
  </section>

  <div class="kpi-grid">
    <article class="kpi kpi-amber">
      <p class="kpi-label">Total Sekolah</p>
      <p class="kpi-num">{data.schoolCount}</p>
      <p class="kpi-sub">Institusi pendidikan terdaftar</p>
    </article>
    <article class="kpi kpi-sage">
      <p class="kpi-label">Total Pengguna</p>
      <p class="kpi-num">{data.userCount}</p>
      <p class="kpi-sub">Akun di seluruh platform</p>
    </article>
  </div>

  <section class="quick">
    <h3 class="quick-title">Akses cepat</h3>
    <div class="quick-grid">
      <a href="/credentials/new" class="qa qa-amber">
        <span class="qa-label">Buat Kredensial</span>
        <span class="qa-sub">Generate kredensial siswa</span>
      </a>
      <a href="/admin-schools" class="qa qa-sage">
        <span class="qa-label">Kelola Sekolah</span>
        <span class="qa-sub">Tambah dan ubah sekolah</span>
      </a>
      <a href="/admin-users" class="qa qa-clay">
        <span class="qa-label">Kelola Pengguna</span>
        <span class="qa-sub">Atur akun guru BK &amp; psikolog</span>
      </a>
      <a href="/admin-assignments" class="qa qa-cold">
        <span class="qa-label">Kelola Penugasan</span>
        <span class="qa-sub">Jadwalkan tes per sekolah</span>
      </a>
    </div>
  </section>
</div>

<style>
  .adash {
    display: grid;
    gap: clamp(1.5rem, 3vw, 2.25rem);
  }

  .adash-hero {
    max-width: 40rem;
  }

  .adash-kicker {
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-accent-deep);
    margin: 0 0 0.5rem;
  }

  .adash-title {
    font-family: var(--lp-font-display);
    font-size: clamp(1.7rem, 3vw + 0.6rem, 2.3rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1.12;
    margin: 0 0 0.6rem;
  }

  .adash-lede {
    color: var(--lp-ink-2);
    margin: 0;
  }

  .kpi-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(13rem, 1fr));
    gap: 1rem;
  }

  .kpi {
    border: 1px solid var(--lp-rule);
    border-radius: 1.25rem;
    padding: 1.4rem 1.5rem;
    display: grid;
    gap: 0.35rem;
  }

  .kpi-amber { background: var(--lp-tint-amber); }
  .kpi-sage { background: var(--lp-tint-sage); }

  .kpi-label {
    font-size: 0.8rem;
    font-weight: 650;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    color: var(--lp-ink-2);
    margin: 0;
  }

  .kpi-num {
    font-family: var(--lp-font-display);
    font-size: clamp(2.2rem, 4vw, 3rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1;
    margin: 0;
    font-variant-numeric: tabular-nums;
  }

  .kpi-sub {
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
    padding: 1.25rem;
    text-decoration: none;
    transition: transform 160ms var(--lp-ease-out), border-color 160ms var(--lp-ease-out);
  }

  .qa:hover {
    transform: translateY(-2px);
    border-color: var(--lp-rule-2);
  }

  .qa-amber { background: var(--lp-tint-amber); }
  .qa-sage { background: var(--lp-tint-sage); }
  .qa-clay { background: var(--lp-tint-clay); }
  .qa-cold { background: var(--lp-tint-cold); }

  .qa-label {
    font-weight: 650;
    color: var(--lp-ink);
  }

  .qa-sub {
    color: var(--lp-muted);
    font-size: 0.85rem;
  }
</style>
