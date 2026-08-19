<script lang="ts">
  import type { Action } from 'svelte/action';
  import { SITE_URL, SITE_NAME, SITE_DESCRIPTION, OG_IMAGE, OG_LOCALE } from '$lib/site.js';
  import heroPhoto from '$lib/assets/psikolog.webp';
  import SiteFooter from '$lib/components/site/SiteFooter.svelte';
  import SiteHeader from '$lib/components/site/SiteHeader.svelte';

  let { data } = $props();
  const signedIn = $derived(!!data.user);

  /* Hallmark · genre: editorial-warm · macrostructure: Split Studio (diptych hero + tinted feature panels)
   * theme: studied-DNA (source: jenjang.com — public competitor reference) adapted warm:
   *   pastel-tint card system · pill buttons · audience-pill band · one-shot reveal
   * audience: schools / psychologists / general public · use: login (primary) + learn (secondary)
   * tone: warm · formal Indonesian
   * nav: sticky warm header (wordmark + links + Masuk pill) · footer: Ft1 Mast-headed */

  const reveal: Action = (node) => {
    if (typeof window === 'undefined') return;
    if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;
    node.classList.add('reveal');
    const io = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          node.classList.add('reveal-in');
          io.disconnect();
        }
      },
      { threshold: 0.12 }
    );
    io.observe(node);
    return { destroy: () => io.disconnect() };
  };
</script>

<svelte:head>
  <title>Asesmen — Platform Asesmen Psikometri</title>
  <meta name="description" content={SITE_DESCRIPTION} />
  <meta property="og:title" content="Asesmen — Platform Asesmen Psikometri" />
  <meta property="og:description" content={SITE_DESCRIPTION} />
  <meta property="og:url" content={SITE_URL} />
  <meta property="og:type" content="website" />
  <meta property="og:locale" content={OG_LOCALE} />
  <meta property="og:site_name" content={SITE_NAME} />
  <meta property="og:image" content={OG_IMAGE} />
  <meta property="og:image:width" content="1200" />
  <meta property="og:image:height" content="630" />
  <meta name="twitter:card" content="summary_large_image" />
  <meta name="twitter:title" content="Asesmen — Platform Asesmen Psikometri" />
  <meta name="twitter:description" content={SITE_DESCRIPTION} />
  <meta name="twitter:image" content={OG_IMAGE} />
</svelte:head>

<div class="landing">
  <SiteHeader user={data.user} profile={data.profile} />

  <section class="audience-band" aria-label="Pengguna platform">
    <div class="audience-inner">
      <div class="audience-pills">
        <a href="#sekolah" class="apill apill-on">
          <span class="apill-label">Sekolah</span>
          <span class="apill-sub">menilai potensi siswa</span>
        </a>
        <a href="#psikolog" class="apill apill-on">
          <span class="apill-label">Psikolog</span>
          <span class="apill-sub">asesmen klien profesional</span>
        </a>
        <a href="#masyarakat" class="apill apill-on">
          <span class="apill-label">Masyarakat</span>
          <span class="apill-sub">mengenal diri sendiri</span>
        </a>
      </div>
    </div>
  </section>

  <main>
    <section class="hero" id="beranda">
      <img
        class="hero-photo"
        src={heroPhoto}
        alt="Seorang psikolog profesional sedang tersenyum ramah"
        width="1536"
        height="1024"
        fetchpriority="high"
      />
      <div class="hero-copy">
        <h1>Memahami potensi. <em>Melangkah dengan yakin.</em></h1>
        <p class="hero-lede">
          Sekolah menilai potensi para siswanya, psikolog mendampingi kliennya, dan setiap orang
          mengenal dirinya lebih dalam — melalui tes kepribadian, minat karier, dan kecerdasan yang
          tervalidasi secara ilmiah.
        </p>
        <div class="hero-cta">
          <a href={signedIn ? '/tes-gratis' : '/signin'} class="btn btn-primary">
            {signedIn ? 'Ikuti Tes Gratis' : 'Masuk ke Platform'}
          </a>
          <a href="#layanan" class="btn btn-ghost">Pelajari Layanan</a>
        </div>
      </div>
    </section>

    <section class="instruments" id="instrumen">
      <ul class="inst-grid">
        <li class="icard icard-amber">
          <span class="icode">DISC</span>
          <span class="iname">Profil kepribadian</span>
          <span class="idesc">Empat dimensi perilaku (D–I–S–C) yang mengungkap gaya komunikasi dan cara mengambil keputusan.</span>
        </li>
        <li class="icard icard-sage">
          <span class="icode">Holland RIASEC</span>
          <span class="iname">Minat karier</span>
          <span class="idesc">Enam tipe minat (R–I–A–S–E–C) untuk memetakan arah studi dan profesi yang paling sesuai.</span>
        </li>
        <li class="icard icard-clay">
          <span class="icode">PAPI Kostick</span>
          <span class="iname">Kepribadian kerja</span>
          <span class="idesc">Dua puluh dimensi karakteristik yang menggambarkan perilaku dan gaya bekerja seseorang.</span>
        </li>
        <li class="icard icard-cold">
          <span class="icode">IQ CFIT</span>
          <span class="iname">Tes kecerdasan</span>
          <span class="idesc">Empat subtes bebas budaya yang mengukur kemampuan penalaran nonverbal.</span>
        </li>
        <li class="icard icard-grey">
          <span class="icode">IQ IST</span>
          <span class="iname">Tes kecerdasan</span>
          <span class="idesc">Sembilan subtes yang mengukur berbagai kemampuan intelektual secara menyeluruh.</span>
        </li>
      </ul>
    </section>

    <section class="free-cta">
      <div class="free-cta-card">
        <div class="free-cta-copy">
          <h2>Penasaran dengan kepribadianmu?</h2>
          <p class="free-cta-text">
            Daftar dengan email, lalu mulai — 30 pertanyaan singkat dengan hasil instan.
          </p>
        </div>
        <a href={signedIn ? '/tes-gratis' : '/signup'} class="btn btn-primary free-cta-btn">Ikuti Tes Gratis</a>
      </div>
    </section>

    <section class="stages" id="layanan">
      <header class="stages-head" use:reveal>
        <h2>Melayani tiga tujuan.</h2>
        <p class="stages-lede">
          Satu platform, tiga kebutuhan yang berbeda. Kami hadir untuk setiap langkah — dari sekolah
          hingga keluarga.
        </p>
      </header>

      <article class="spanel spanel-amber" id="sekolah" use:reveal>
        <div class="spanel-top">
          <span class="stage-num" aria-hidden="true">01</span>
          <div class="spanel-title">
            <h3>Sekolah</h3>
            <p class="stage-sub">Penilaian potensi untuk para siswa</p>
          </div>
        </div>
        <div class="spanel-body">
          <p>
            Sekolah dan guru bimbingan konseling menyelenggarakan asesmen psikologi bagi siswa secara
            terjadwal — mulai dari penjadwalan tes, pemantauan pengerjaan, hingga interpretasi hasil
            yang dapat ditindaklanjuti.
          </p>
          <ul class="spanel-list">
            <li>Jadwalkan tes per kelas atau per angkatan</li>
            <li>Pantau pengerjaan dan kelengkapan tiap siswa</li>
            <li>Akses hasil beserta interpretasi untuk tiap siswa</li>
          </ul>
        </div>
      </article>

      <article class="spanel spanel-sage" id="psikolog" use:reveal>
        <div class="spanel-top">
          <span class="stage-num" aria-hidden="true">02</span>
          <div class="spanel-title">
            <h3>Psikolog &amp; Konsultan</h3>
            <p class="stage-sub">Asesmen klien untuk praktik profesional</p>
          </div>
        </div>
        <div class="spanel-body">
          <p>
            Psikolog dan afiliator menggunakan instrumen untuk menilai kecerdasan, kepribadian, dan
            karakteristik kerja klien — dengan hasil yang terstruktur untuk mendukung rekomendasi
            profesional.
          </p>
          <ul class="spanel-list">
            <li>Daftarkan klien dan kelola riwayat asesmen</li>
            <li>Ukur kecerdasan (CFIT, IST) dan kepribadian (DISC, PAPI)</li>
            <li>Unduh hasil dalam bentuk laporan</li>
          </ul>
        </div>
      </article>

      <article class="spanel spanel-grey" id="masyarakat" use:reveal>
        <div class="spanel-top">
          <span class="stage-num" aria-hidden="true">03</span>
          <div class="spanel-title">
            <h3>Masyarakat Umum</h3>
            <p class="stage-sub">Mengenal diri sendiri, secara mandiri</p>
          </div>
        </div>
        <div class="spanel-body">
          <p>
            Setiap orang kini dapat mengikuti tes untuk memahami kepribadian, minat, dan potensi
            dirinya — tanpa perlu terdaftar di sekolah atau berstatus klien. Mulailah dengan Tes
            Kepribadian Gratis yang tersedia untuk semua.
          </p>
          <ul class="spanel-list">
            <li>Ikuti tes secara mandiri dari mana saja</li>
            <li>Terima hasil yang dapat dimaknai dengan pendampingan</li>
          </ul>
          <div class="spanel-note">
            <p>Mulai sekarang — tidak perlu mendaftar di sekolah.</p>
            <a href={signedIn ? '/tes-gratis' : '/signup'} class="btn btn-ghost btn-sm">Coba Tes Gratis</a>
          </div>
        </div>
      </article>
    </section>

    <section class="alur" id="alur">
      <header class="alur-head" use:reveal>
        <h2>Bagaimana cara kerjanya.</h2>
      </header>
      <ol class="step-grid">
        <li class="scard" use:reveal>
          <span class="step-num" aria-hidden="true">1.0</span>
          <h3>Pendaftaran</h3>
          <p>
            Sekolah atau psikolog mendaftar, membuat akun, menyiapkan daftar siswa atau klien, dan
            menetapkan jadwal pengerjaan tes.
          </p>
        </li>
        <li class="scard" use:reveal>
          <span class="step-num" aria-hidden="true">2.0</span>
          <h3>Pengerjaan</h3>
          <p>
            Siswa atau klien mengerjakan tes sesuai jadwal yang telah ditetapkan. Setiap jawaban
            tersimpan dengan aman dan rahasia.
          </p>
        </li>
        <li class="scard" use:reveal>
          <span class="step-num" aria-hidden="true">3.0</span>
          <h3>Hasil &amp; interpretasi</h3>
          <p>
            Skor diolah secara ilmiah dan disajikan sebagai laporan hasil beserta interpretasi untuk
            tiap instrumen.
          </p>
        </li>
      </ol>
      <div class="alur-cta">
        <a href={signedIn ? '/tes-gratis' : '/signin'} class="btn btn-primary">Masuk ke Platform</a>
      </div>
    </section>

    <section class="faq" id="faq">
      <header class="faq-head" use:reveal>
        <h2>Pertanyaan yang sering diajukan.</h2>
      </header>
      <div class="faq-list">
        <details class="fitem" use:reveal>
          <summary>Bagaimana cara sekolah memulai menggunakan platform?</summary>
          <p>
            Sekolah menghubungi administrator untuk pendaftaran, kemudian menetapkan jadwal asesmen
            dan mendaftarkan siswa melalui akun guru bimbingan konseling.
          </p>
        </details>
        <details class="fitem" use:reveal>
          <summary>Apakah hasil tes dapat digunakan untuk keperluan profesional psikolog?</summary>
          <p>
            Ya. Instrumen disajikan dengan skor mentah dan interpretasi yang terstruktur, sehingga
            dapat menjadi bahan bagi psikolog atau konsultan dalam menyusun rekomendasi.
          </p>
        </details>
        <details class="fitem" use:reveal>
          <summary>Bagaimana platform menjaga kerahasiaan data siswa dan klien?</summary>
          <p>
            Data pribadi dan hasil asesmen disimpan secara terpisah, hanya dapat diakses oleh pihak
            yang berwenang, dan tidak digunakan untuk keperluan lain tanpa persetujuan.
          </p>
        </details>
        <details class="fitem" use:reveal>
          <summary>Apakah layanan untuk masyarakat umum sudah tersedia?</summary>
          <p>
            Belum. Layanan mandiri untuk masyarakat umum sedang dalam pengembangan dan akan diumumkan
            melalui laman ini.
          </p>
        </details>
        <details class="fitem" use:reveal>
          <summary>Perangkat apa saja yang dibutuhkan untuk mengerjakan tes?</summary>
          <p>
            Cukup perangkat dengan akses internet dan peramban web terkini — komputer, laptop, atau
            ponsel. Tidak diperlukan pemasangan aplikasi.
          </p>
        </details>
      </div>
    </section>

    <section class="closing" use:reveal>
      <h2>Siap mengenal diri lebih dalam?</h2>
      <p>
        Masuk ke platform untuk memulai — bagi sekolah, psikolog, maupun siswa yang telah terdaftar.
      </p>
      <a href="/signin" class="btn btn-primary">Masuk ke Platform</a>
    </section>
  </main>

  <SiteFooter />
</div>

<style>
  .landing {
    /* Warm editorial palette + pastel-tint system (studied-DNA adaptation) */
    --lp-paper: oklch(0.972 0.012 75);
    --lp-paper-2: oklch(0.95 0.02 75);
    --lp-ink: oklch(0.24 0.025 55);
    --lp-ink-2: oklch(0.4 0.02 55);
    --lp-muted: oklch(0.43 0.02 55);
    --lp-rule: oklch(0.88 0.02 75);
    --lp-rule-2: oklch(0.79 0.025 75);
    --lp-accent: oklch(0.6 0.14 42);
    --lp-accent-deep: oklch(0.42 0.12 38);
    --lp-accent-bg: oklch(0.7 0.12 45);
    --lp-focus: oklch(0.55 0.15 40);
    /* Pastel tints — low chroma, warm family */
    --lp-tint-amber: oklch(0.965 0.035 78);
    --lp-tint-clay: oklch(0.962 0.03 55);
    --lp-tint-sage: oklch(0.958 0.028 145);
    --lp-tint-cold: oklch(0.96 0.018 220);
    --lp-tint-grey: oklch(0.952 0.014 70);
    --lp-font-display: 'Fraunces Variable', Georgia, serif;
    --lp-maxw: 64rem;
    --lp-ease-out: cubic-bezier(0.16, 1, 0.3, 1);

    background: var(--lp-paper);
    color: var(--lp-ink);
    font-family: Figtree, ui-sans-serif, system-ui, sans-serif;
    font-size: 1rem;
    line-height: 1.6;
    min-height: 100dvh;
    -webkit-font-smoothing: antialiased;
  }

  .landing a {
    color: inherit;
    text-decoration: none;
  }

  .landing :global(.audience-inner),
  .landing :global(.hero),
  .landing :global(.instruments),
  .landing :global(.free-cta),
  .landing :global(.stages-head),
  .landing :global(.spanel),
  .landing :global(.alur-head),
  .landing :global(.step-grid),
  .landing :global(.alur-cta),
  .landing :global(.faq-head),
  .landing :global(.faq-list),
  .landing :global(.closing) {
    max-width: var(--lp-maxw);
    margin-inline: auto;
    padding-inline: clamp(1.25rem, 4vw, 2.5rem);
  }

  /* ---------- Buttons · pill ---------- */

  .btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 3rem;
    padding: 0.7rem 1.6rem;
    border-radius: 0.625rem;
    font-weight: 600;
    letter-spacing: 0.01em;
    cursor: pointer;
    white-space: nowrap;
    transition: background-color 200ms var(--lp-ease-out), color 200ms var(--lp-ease-out),
      transform 200ms var(--lp-ease-out), border-color 200ms var(--lp-ease-out);
  }

  .btn-sm {
    min-height: 2.5rem;
    padding: 0.45rem 1.15rem;
    font-size: 0.9rem;
  }

  .btn-primary {
    background: var(--lp-accent-bg);
    color: var(--lp-ink);
    border: 1px solid var(--lp-accent-bg);
  }

  .btn-primary:hover {
    background: var(--lp-accent);
    border-color: var(--lp-accent);
    transform: translateY(-1px);
  }

  .btn-primary:active {
    transform: translateY(0);
  }

  .btn-ghost {
    background: transparent;
    color: var(--lp-ink);
    border: 1px solid var(--lp-rule-2);
  }

  .btn-ghost:hover {
    background: var(--lp-paper-2);
    border-color: var(--lp-ink-2);
  }

  .btn-ghost:active {
    transform: translateY(0);
  }

  /* ---------- Audience band · gradient pills ---------- */

  .audience-band {
    background: linear-gradient(
      90deg,
      var(--lp-tint-amber) 0%,
      var(--lp-tint-clay) 50%,
      var(--lp-tint-sage) 100%
    );
    border-bottom: 1px solid var(--lp-rule);
  }

  .audience-inner {
    padding-block: 1rem;
  }

  .audience-pills {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 0.75rem;
  }

  .apill {
    display: inline-flex;
    align-items: baseline;
    gap: 0.6rem;
    border-radius: 999px;
    padding: 0.6rem 1.25rem;
    border: 1px solid var(--lp-rule);
    background: transparent;
    color: var(--lp-ink);
    transition: background-color 200ms var(--lp-ease-out), border-color 200ms var(--lp-ease-out),
      opacity 200ms var(--lp-ease-out);
    white-space: nowrap;
  }

  .apill-on {
    background: var(--lp-paper);
    border-color: var(--lp-paper);
    box-shadow: 0 1px 2px oklch(0.3 0.03 40 / 0.08);
  }

  .apill-on:hover {
    border-color: var(--lp-accent);
  }

  .apill-label {
    font-weight: 650;
    font-size: 0.95rem;
  }

  .apill-sub {
    color: var(--lp-muted);
    font-size: 0.78rem;
  }

  /* ---------- Hero · H2 split diptych ---------- */

  .hero {
    display: grid;
    grid-template-columns: minmax(0, 5fr) minmax(0, 6fr);
    gap: clamp(2rem, 5vw, 4.5rem);
    align-items: center;
    padding-block: clamp(3.5rem, 8vw, 6rem) clamp(3rem, 7vw, 4.5rem);
  }

  .hero-photo {
    width: 100%;
    height: auto;
    display: block;
    object-fit: cover;
    object-position: center;
    -webkit-mask-image: linear-gradient(180deg, #000 55%, transparent 98%);
    mask-image: linear-gradient(180deg, #000 55%, transparent 98%);
  }

  .hero h1 {
    font-family: var(--lp-font-display);
    font-size: clamp(2.6rem, 5vw + 1rem, 4.4rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1.06;
    margin: 0 0 1.25rem;
    overflow-wrap: anywhere;
    min-width: 0;
  }

  .hero h1 em {
    font-style: italic;
    font-weight: 420;
    color: var(--lp-accent-deep);
  }

  .hero-lede {
    color: var(--lp-ink-2);
    font-size: 1.05rem;
    line-height: 1.65;
    max-width: 54ch;
    margin: 0 0 1.75rem;
  }

  .hero-cta {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 0.85rem;
  }

  .inst-grid {
    list-style: none;
    margin: 0;
    padding: 0;
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: 1rem;
  }

  .instruments {
    padding-block: clamp(0.5rem, 2vw, 1.5rem) clamp(2.5rem, 6vw, 4rem);
  }

  .icard {
    display: flex;
    flex-direction: column;
    gap: 0.45rem;
    border-radius: 1.25rem;
    padding: 1.15rem 1.25rem;
    border: 1px solid var(--lp-rule);
  }

  .icard-amber {
    background: var(--lp-tint-amber);
  }

  .icard-sage {
    background: var(--lp-tint-sage);
  }

  .icard-clay {
    background: var(--lp-tint-clay);
  }

  .icard-cold {
    background: var(--lp-tint-cold);
  }

  .icard-grey {
    background: var(--lp-tint-grey);
  }

  .icode {
    font-family: var(--lp-font-display);
    font-size: 1.05rem;
    font-weight: 580;
    letter-spacing: -0.01em;
    line-height: 1.1;
  }

  .iname {
    color: var(--lp-ink);
    font-weight: 650;
    font-size: 0.9rem;
    line-height: 1.35;
  }

  .idesc {
    color: var(--lp-ink-2);
    font-size: 0.8rem;
    line-height: 1.5;
  }

  /* ---------- Free-test CTA band ---------- */

  .free-cta {
    padding-bottom: clamp(1.5rem, 3vw, 2rem);
  }

  .free-cta-card {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    justify-content: space-between;
    gap: 1.5rem 2rem;
    background: linear-gradient(100deg, var(--lp-tint-amber) 0%, var(--lp-tint-clay) 100%);
    border: 1px solid var(--lp-rule);
    border-radius: 1.5rem;
    padding: clamp(1.75rem, 4vw, 2.5rem);
  }

  .free-cta-copy h2 {
    font-family: var(--lp-font-display);
    font-size: clamp(1.6rem, 3vw + 1rem, 2.2rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1.15;
    margin: 0 0 0.6rem;
    overflow-wrap: anywhere;
  }

  .free-cta-text {
    color: var(--lp-ink-2);
    margin: 0;
    max-width: 42ch;
  }

  .free-cta-btn {
    flex: none;
  }

  /* ---------- Stages · tinted panels ---------- */

  .stages {
    padding-block: clamp(1rem, 2vw, 1.5rem) clamp(3rem, 7vw, 5rem);
  }

  .stages-head {
    margin-bottom: clamp(2rem, 4vw, 3rem);
  }

  .stages-head h2,
  .alur-head h2,
  .faq-head h2,
  .closing h2 {
    font-family: var(--lp-font-display);
    font-size: clamp(1.9rem, 3vw + 1rem, 3rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1.12;
    margin: 0 0 0.75rem;
    overflow-wrap: anywhere;
    min-width: 0;
  }

  .stages-lede {
    color: var(--lp-ink-2);
    font-size: 1.05rem;
    max-width: 52ch;
    margin: 0;
  }

  .spanel {
    border-radius: 1.5rem;
    border: 1px solid var(--lp-rule);
    padding: clamp(1.75rem, 4vw, 2.5rem);
    margin-bottom: 1.25rem;
  }

  .spanel-amber {
    background: var(--lp-tint-amber);
  }

  .spanel-sage {
    background: var(--lp-tint-sage);
  }

  .spanel-grey {
    background: var(--lp-tint-grey);
  }

  .spanel-top {
    display: flex;
    flex-wrap: wrap;
    align-items: flex-start;
    gap: 1.25rem 2rem;
    margin-bottom: 1.25rem;
  }

  .stage-num {
    font-family: var(--lp-font-display);
    font-size: clamp(2rem, 4vw, 2.75rem);
    font-weight: 440;
    font-style: italic;
    line-height: 0.9;
    color: var(--lp-accent-deep);
    flex: none;
  }

  .spanel-title {
    flex: 1 1 0;
    min-width: 12rem;
  }

  .spanel-title h3 {
    font-family: var(--lp-font-display);
    font-size: clamp(1.4rem, 2vw + 1rem, 1.9rem);
    font-weight: 560;
    letter-spacing: -0.01em;
    line-height: 1.15;
    margin: 0.3rem 0 0.3rem;
  }

  .stage-sub {
    color: var(--lp-muted);
    font-size: 0.9rem;
    margin: 0;
  }

  .spanel-body {
    max-width: 62ch;
    color: var(--lp-ink-2);
  }

  .spanel-body > p {
    margin: 0 0 1rem;
  }

  .spanel-list {
    list-style: none;
    margin: 0 0 1rem;
    padding: 0;
  }

  .spanel-list li {
    position: relative;
    padding-left: 1.5rem;
    margin-bottom: 0.5rem;
  }

  .spanel-list li::before {
    content: '';
    position: absolute;
    left: 0.1rem;
    top: 0.6em;
    width: 0.5rem;
    height: 0.5rem;
    border-radius: 999px;
    background: var(--lp-accent);
  }

  .spanel-note {
    color: var(--lp-muted);
    font-size: 0.92rem;
    border-top: 1px solid var(--lp-rule);
    padding-top: 1rem;
    margin-top: 1rem;
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 0.75rem 1rem;
  }

  .spanel-note p {
    margin: 0;
  }

  /* ---------- Alur · step cards ---------- */

  .alur {
    background: var(--lp-paper-2);
    border-top: 1px solid var(--lp-rule);
    border-bottom: 1px solid var(--lp-rule);
    padding-block: clamp(3.5rem, 8vw, 6rem) clamp(3rem, 7vw, 4.5rem);
  }

  .alur-head {
    margin-bottom: clamp(2rem, 4vw, 3rem);
  }

  .step-grid {
    list-style: none;
    margin: 0;
    padding: 0;
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 1rem;
  }

  .scard {
    background: var(--lp-paper);
    border: 1px solid var(--lp-rule);
    border-radius: 1.5rem;
    padding: 1.75rem;
  }

  .scard .step-num {
    display: block;
    font-size: 1.35rem;
    margin-bottom: 1.1rem;
  }

  .scard h3 {
    font-size: 1.1rem;
    font-weight: 650;
    letter-spacing: -0.01em;
    margin: 0 0 0.5rem;
  }

  .scard p {
    color: var(--lp-ink-2);
    font-size: 0.95rem;
    margin: 0;
  }

  .alur-cta {
    display: flex;
    justify-content: center;
    padding-top: clamp(2rem, 4vw, 2.75rem);
  }

  /* ---------- FAQ ---------- */

  .faq {
    padding-block: clamp(3.5rem, 8vw, 6rem);
  }

  .faq-head {
    margin-bottom: clamp(1.75rem, 3vw, 2.5rem);
  }

  .fitem {
    border-top: 1px solid var(--lp-rule);
  }

  .fitem:last-child {
    border-bottom: 1px solid var(--lp-rule);
  }

  .fitem summary {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
    padding: 1.15rem 0;
    font-weight: 650;
    font-size: 1rem;
    cursor: pointer;
    list-style: none;
    min-height: 3rem;
  }

  .fitem summary::-webkit-details-marker {
    display: none;
  }

  .fitem summary::after {
    content: '+';
    font-family: var(--lp-font-display);
    font-size: 1.4rem;
    font-weight: 420;
    line-height: 1;
    color: var(--lp-accent-deep);
    flex: none;
    transition: transform 250ms var(--lp-ease-out);
  }

  .fitem[open] summary::after {
    transform: rotate(45deg);
  }

  .fitem p {
    color: var(--lp-ink-2);
    max-width: 60ch;
    margin: 0;
    padding: 0 0 1.25rem;
  }

  /* ---------- Closing CTA ---------- */

  .closing {
    text-align: center;
    padding-block: clamp(4rem, 9vw, 6.5rem) clamp(3.5rem, 8vw, 5.5rem);
  }

  .closing h2 {
    margin-bottom: 1rem;
  }

  .closing p {
    color: var(--lp-ink-2);
    max-width: 52ch;
    margin: 0 auto 2rem;
  }

  /* ---------- Reveal-on-scroll · one-shot ---------- */

  .landing :global(.reveal) {
    opacity: 0;
    transform: translateY(16px);
  }

  .landing :global(.reveal-in) {
    opacity: 1;
    transform: none;
    transition: opacity 0.5s var(--lp-ease-out), transform 0.5s var(--lp-ease-out);
  }

  /* ---------- Focus & accessibility ---------- */

  .landing :global(a):focus-visible,
  .landing :global(button):focus-visible,
  .landing :global(summary):focus-visible {
    outline: 2px solid var(--lp-focus);
    outline-offset: 3px;
  }

  @media (hover: none), (pointer: coarse) {
    .btn,
    .apill,
    .fitem summary {
      min-height: 3.25rem;
    }
  }

  /* ---------- Responsive ---------- */

  @media (max-width: 56rem) {
    .hero {
      grid-template-columns: minmax(0, 1fr);
    }

    .hero-photo {
      height: auto;
      max-height: 20rem;
      object-fit: cover;
      object-position: center 20%;
    }

    .step-grid {
      grid-template-columns: minmax(0, 1fr);
    }
  }

  @media (max-width: 40rem) {
    .hero h1 {
      font-size: clamp(2.35rem, 10vw, 3rem);
    }

    .hero-cta {
      flex-direction: column;
      align-items: stretch;
    }

    .hero-cta .btn {
      width: 100%;
    }

    .audience-pills {
      flex-direction: column;
      align-items: stretch;
    }

    .apill {
      justify-content: center;
    }

    .spanel-top {
      flex-direction: column;
      gap: 0.6rem;
    }

    .spanel-title h3 {
      margin-top: 0.25rem;
    }

    .free-cta-card {
      flex-direction: column;
      align-items: flex-start;
    }

    .free-cta-btn {
      width: 100%;
    }
  }
</style>
