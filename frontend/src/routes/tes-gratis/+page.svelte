<script lang="ts">
  import { PUBLIC_API_URL } from '$env/static/public';
</script>

<svelte:head>
  <title>Tes Gratis — Asesmen</title>
</svelte:head>

<div class="intro">
  <div class="intro-card">
    <p class="intro-kicker">Tes kepribadian singkat</p>
    <h1>Kenali potensi dirimu dalam tiga menit.</h1>
    <p class="intro-lede">
      Tiga puluh pertanyaan sederhana tentang keseharianmu. Tanpa jawaban benar atau salah — cukup
      jawab dengan jujur, dan lihat gambaran kepribadianmu seketika.
    </p>

    <ul class="intro-points">
      <li><span class="pt-dot" aria-hidden="true"></span>30 pertanyaan singkat</li>
      <li><span class="pt-dot" aria-hidden="true"></span>Hasil instan yang bisa dibagikan</li>
      <li><span class="pt-dot" aria-hidden="true"></span>Gratis, tanpa kartu pembayaran</li>
    </ul>

    <a href="/tes-gratis/soal" class="intro-cta">Mulai Tes Gratis</a>
    <p class="intro-note">Sekitar 3–5 menit · tersimpan jika kamu membuat akun</p>
  </div>
</div>

<style>
  .intro {
    max-width: 48rem;
    margin-inline: auto;
    padding: clamp(2rem, 7vw, 4rem) clamp(1.25rem, 4vw, 2rem);
    text-align: center;
  }

  .intro-card {
    max-width: 34rem;
    margin-inline: auto;
  }

  .intro-kicker {
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-accent-deep);
    margin: 0 0 1rem;
  }

  .intro h1 {
    font-family: var(--lp-font-display);
    font-size: clamp(2.1rem, 6vw, 3rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1.12;
    margin: 0 0 1.1rem;
    overflow-wrap: anywhere;
  }

  .intro-lede {
    color: var(--lp-ink-2);
    font-size: 1.05rem;
    margin: 0 auto 1.75rem;
    max-width: 30rem;
  }

  .intro-points {
    list-style: none;
    margin: 0 auto 2rem;
    padding: 0;
    max-width: 24rem;
  }

  .intro-points li {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 0.6rem;
    padding: 0.35rem 0;
    font-weight: 600;
    font-size: 0.95rem;
  }

  .pt-dot {
    width: 0.5rem;
    height: 0.5rem;
    border-radius: 999px;
    background: var(--lp-accent);
    flex: none;
  }

  .intro-cta {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 3.25rem;
    padding: 0.8rem 2.2rem;
    border-radius: 999px;
    background: var(--lp-accent-bg);
    color: var(--lp-ink);
    border: 1px solid var(--lp-accent-bg);
    font-weight: 650;
    white-space: nowrap;
    transition: background-color 200ms var(--lp-ease-out), transform 200ms var(--lp-ease-out);
  }

  .intro-cta:hover {
    background: var(--lp-accent);
    transform: translateY(-1px);
  }

  .intro-cta:active {
    transform: translateY(0);
  }

  .intro-note {
    color: var(--lp-muted);
    font-size: 0.82rem;
    margin: 1.1rem 0 0;
  }
</style>
