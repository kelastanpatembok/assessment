<script lang="ts">
  import { PUBLIC_API_URL } from '$env/static/public';
</script>

<svelte:head>
  <title>Tes Gratis — Asesmen</title>
</svelte:head>

<div class="intro">
  <div class="intro-card">
    <p class="lp-kicker">Tes kepribadian singkat</p>
    <h1 class="lp-display intro-title">Kenali potensi dirimu dalam tiga menit.</h1>
    <p class="lp-lead intro-lede">
      Tiga puluh pertanyaan sederhana tentang keseharianmu. Tanpa jawaban benar atau salah — cukup jawab dengan jujur,
      dan lihat gambaran kepribadianmu seketika.
    </p>

    <ul class="intro-points">
      <li><span class="lp-dot" aria-hidden="true"></span>30 pertanyaan singkat</li>
      <li><span class="lp-dot" aria-hidden="true"></span>Hasil instan yang bisa dibagikan</li>
      <li><span class="lp-dot" aria-hidden="true"></span>Gratis, tanpa kartu pembayaran</li>
    </ul>

    <a href="/tes-gratis/soal" class="lp-btn lp-btn-primary lp-btn-lg intro-cta">Mulai Tes Gratis</a>
    <p class="lp-muted intro-note">Sekitar 3–5 menit · hasil tersimpan otomatis di akunmu</p>
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

  .intro-title {
    font-size: clamp(2.1rem, 6vw, 3rem);
    line-height: 1.12;
    margin: 0 0 1.1rem;
  }

  .intro-lede {
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

  .intro-cta {
    white-space: nowrap;
  }

  .intro-note {
    font-size: 0.82rem;
    margin: 1.1rem 0 0;
  }
</style>
