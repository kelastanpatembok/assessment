<script lang="ts">
  /* Hallmark · genre: editorial · macrostructure: Narrative Workflow ·
   * theme: Linen-warm (custom: cream paper · terracotta accent · warm-brown ink) ·
   * enrichment: none (typography + proof panel) · nav: N6 Masthead · footer: Ft1 Mast-headed ·
   * audience: schools / psychologists / general public · use: login (primary) + learn (secondary) ·
   * tone: warm · formal Indonesian */
</script>

<svelte:head>
  <title>Asesmen — Platform Asesmen Psikometri</title>
  <meta
    name="description"
    content="Platform asesmen psikometri untuk sekolah, psikolog, dan masyarakat — tes kepribadian, minat karier, dan kecerdasan yang tervalidasi secara ilmiah."
  />
</svelte:head>

<div class="landing">
  <header class="mast">
    <div class="mast-inner">
      <p class="mast-line">Asesmen psikometri untuk Indonesia</p>
      <p class="mast-name">Asesmen</p>
      <nav class="mast-nav" aria-label="Navigasi utama">
        <a href="#layanan">Layanan</a>
        <a href="#instrumen">Instrumen</a>
        <a href="#alur">Alur</a>
        <a href="/login" class="mast-cta">Masuk&nbsp;→</a>
      </nav>
    </div>
    <hr class="mast-rule" aria-hidden="true" />
  </header>

  <main>
    <section class="hero" id="beranda">
      <div class="hero-copy">
        <h1>Memahami potensi. <em>Melangkah dengan yakin.</em></h1>
        <p class="hero-lede">
          Sekolah menilai potensi para siswanya, psikolog mendampingi kliennya, dan setiap orang
          mengenal dirinya lebih dalam — melalui tes kepribadian, minat karier, dan kecerdasan yang
          tervalidasi secara ilmiah.
        </p>
        <div class="hero-cta">
          <a href="/login" class="btn btn-primary">Masuk ke Platform</a>
          <a href="#layanan" class="link-arrow">Pelajari Layanan&nbsp;↓</a>
        </div>
        <ul class="who-strip">
          <li>
            <span class="who-k">Sekolah</span>
            <span class="who-v">menilai potensi siswa</span>
          </li>
          <li>
            <span class="who-k">Psikolog</span>
            <span class="who-v">mendampingi klien</span>
          </li>
          <li>
            <span class="who-k">Masyarakat</span>
            <span class="who-v">mengenal diri sendiri</span>
          </li>
        </ul>
      </div>

      <aside class="hero-panel" id="instrumen">
        <p class="panel-title">Instrumen yang tersedia</p>
        <ul class="instruments">
          <li class="inst">
            <span class="inst-code">DISC</span>
            <span class="inst-name">Tes kepribadian</span>
          </li>
          <li class="inst">
            <span class="inst-code">Holland RIASEC</span>
            <span class="inst-name">Tes minat karier</span>
          </li>
          <li class="inst">
            <span class="inst-code">PAPI Kostick</span>
            <span class="inst-name">Tes kepribadian kerja</span>
          </li>
          <li class="inst">
            <span class="inst-code">IQ CFIT</span>
            <span class="inst-name">Tes kecerdasan</span>
          </li>
          <li class="inst">
            <span class="inst-code">IQ IST</span>
            <span class="inst-name">Tes kecerdasan</span>
          </li>
        </ul>
      </aside>
    </section>

    <section class="stages" id="layanan">
      <header class="stages-head">
        <h2>Melayani tiga tujuan.</h2>
        <p class="stages-lede">
          Satu platform, tiga kebutuhan yang berbeda. Kami hadir untuk setiap langkah — dari sekolah
          hingga keluarga.
        </p>
      </header>

      <article class="stage">
        <div class="stage-head">
          <span class="stage-num" aria-hidden="true">01</span>
          <div class="stage-title">
            <h3>Sekolah</h3>
            <p class="stage-sub">Penilaian potensi untuk para siswa</p>
          </div>
          <span class="status status-on">Tersedia</span>
        </div>
        <div class="stage-body">
          <p>
            Sekolah dan guru bimbingan konseling menyelenggarakan asesmen psikologi bagi siswa secara
            terjadwal — mulai dari penjadwalan tes, pemantauan pengerjaan, hingga interpretasi hasil
            yang dapat ditindaklanjuti.
          </p>
          <ul class="stage-list">
            <li>Jadwalkan tes per kelas atau per angkatan</li>
            <li>Pantau pengerjaan dan kelengkapan tiap siswa</li>
            <li>Akses hasil beserta interpretasi untuk tiap siswa</li>
          </ul>
        </div>
      </article>

      <article class="stage">
        <div class="stage-head">
          <span class="stage-num" aria-hidden="true">02</span>
          <div class="stage-title">
            <h3>Psikolog &amp; Konsultan</h3>
            <p class="stage-sub">Asesmen klien untuk praktik profesional</p>
          </div>
          <span class="status status-on">Tersedia</span>
        </div>
        <div class="stage-body">
          <p>
            Psikolog dan afiliator menggunakan instrumen untuk menilai kecerdasan, kepribadian, dan
            karakteristik kerja klien — dengan hasil yang terstruktur untuk mendukung rekomendasi
            profesional.
          </p>
          <ul class="stage-list">
            <li>Daftarkan klien dan kelola riwayat asesmen</li>
            <li>Ukur kecerdasan (CFIT, IST) dan kepribadian (DISC, PAPI)</li>
            <li>Unduh hasil dalam bentuk laporan</li>
          </ul>
        </div>
      </article>

      <article class="stage">
        <div class="stage-head">
          <span class="stage-num" aria-hidden="true">03</span>
          <div class="stage-title">
            <h3>Masyarakat Umum</h3>
            <p class="stage-sub">Mengenal diri sendiri, secara mandiri</p>
          </div>
          <span class="status status-soon">Dalam pengembangan</span>
        </div>
        <div class="stage-body">
          <p>
            Ke depan, setiap orang dapat mengikuti tes untuk memahami kepribadian, minat, dan potensi
            dirinya — tanpa perlu terdaftar di sekolah atau berstatus klien. Layanan ini sedang kami
            kembangkan.
          </p>
          <ul class="stage-list">
            <li>Ikuti tes secara mandiri dari mana saja</li>
            <li>Terima hasil yang dapat dimaknai dengan pendampingan</li>
          </ul>
          <p class="stage-note">
            Sementara itu, Anda dapat mencoba layanan sekolah atau psikolog yang telah tersedia.
          </p>
        </div>
      </article>
    </section>

    <section class="alur" id="alur">
      <header class="alur-head">
        <h2>Bagaimana cara kerjanya.</h2>
      </header>
      <ol class="steps">
        <li class="step">
          <span class="step-num" aria-hidden="true">1.0</span>
          <div class="step-copy">
            <h3>Pendaftaran</h3>
            <p>
              Sekolah atau psikolog mendaftar, membuat akun, menyiapkan daftar siswa atau klien, dan
              menetapkan jadwal pengerjaan tes.
            </p>
          </div>
        </li>
        <li class="step">
          <span class="step-num" aria-hidden="true">2.0</span>
          <div class="step-copy">
            <h3>Pengerjaan</h3>
            <p>
              Siswa atau klien mengerjakan tes sesuai jadwal yang telah ditetapkan. Setiap jawaban
              tersimpan dengan aman dan rahasia.
            </p>
          </div>
        </li>
        <li class="step">
          <span class="step-num" aria-hidden="true">3.0</span>
          <div class="step-copy">
            <h3>Hasil &amp; interpretasi</h3>
            <p>
              Skor diolah secara ilmiah dan disajikan sebagai laporan hasil beserta interpretasi untuk
              tiap instrumen.
            </p>
          </div>
        </li>
      </ol>
      <div class="alur-cta">
        <a href="/login" class="btn btn-primary">Masuk ke Platform</a>
      </div>
    </section>

    <section class="closing">
      <h2>Siap mengenal diri lebih dalam?</h2>
      <p>
        Masuk ke platform untuk memulai — bagi sekolah, psikolog, maupun siswa yang telah terdaftar.
      </p>
      <a href="/login" class="btn btn-primary">Masuk ke Platform</a>
      <a href="#beranda" class="link-arrow">Kembali ke atas&nbsp;↑</a>
    </section>
  </main>

  <footer class="foot">
    <hr class="foot-rule" aria-hidden="true" />
    <p class="foot-name">Asesmen</p>
    <p class="foot-tagline">Asesmen psikometri yang adil, akurat, dan bermartabat.</p>
    <p class="foot-copy">Melayani sekolah, psikolog, dan masyarakat Indonesia.</p>
    <p class="foot-copy">©&nbsp;2026 Asesmen</p>
  </footer>
</div>

<style>
  .landing {
    /* Warm editorial palette — scoped to the landing page. */
    --lp-paper: oklch(0.965 0.015 75);
    --lp-paper-2: oklch(0.94 0.02 75);
    --lp-ink: oklch(0.24 0.025 55);
    --lp-ink-2: oklch(0.4 0.02 55);
    --lp-muted: oklch(0.45 0.02 55);
    --lp-rule: oklch(0.86 0.02 75);
    --lp-rule-2: oklch(0.78 0.025 75);
    --lp-accent: oklch(0.6 0.14 42);
    --lp-accent-deep: oklch(0.44 0.12 38);
    --lp-focus: oklch(0.55 0.15 40);
    --lp-font-display: 'Fraunces Variable', Georgia, serif;
    --lp-maxw: 75rem;
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

  .landing :global(.mast),
  .landing :global(.hero),
  .landing :global(.stages),
  .landing :global(.alur),
  .landing :global(.closing),
  .landing :global(.foot) {
    width: 100%;
  }

  .landing :global(.mast-inner),
  .landing :global(.hero),
  .landing :global(.stages-head),
  .landing :global(.stage),
  .landing :global(.alur-head),
  .landing :global(.steps),
  .landing :global(.alur-cta),
  .landing :global(.closing),
  .landing :global(.foot) {
    max-width: var(--lp-maxw);
    margin-inline: auto;
    padding-inline: clamp(1.25rem, 4vw, 2.5rem);
  }

  /* ---------- Nav · N6 masthead ---------- */

  .mast {
    text-align: center;
  }

  .mast-inner {
    padding-top: clamp(1.5rem, 3vw, 2.25rem);
    padding-bottom: clamp(1rem, 2vw, 1.5rem);
  }

  .mast-line {
    font-size: 0.68rem;
    font-weight: 600;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-muted);
    margin: 0 0 0.4rem;
  }

  .mast-name {
    font-family: var(--lp-font-display);
    font-size: clamp(1.9rem, 4vw, 2.5rem);
    font-weight: 620;
    letter-spacing: -0.02em;
    line-height: 1;
    margin: 0 0 0.75rem;
  }

  .mast-nav {
    display: inline-flex;
    flex-wrap: wrap;
    justify-content: center;
    align-items: baseline;
    gap: clamp(1rem, 3vw, 2.25rem);
  }

  .mast-nav a {
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.14em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-ink-2);
    padding-block: 0.75rem;
    background-image: linear-gradient(var(--lp-accent-deep), var(--lp-accent-deep));
    background-size: 0 1px;
    background-repeat: no-repeat;
    background-position: 50% 100%;
    transition: color 150ms var(--lp-ease-out), background-size 200ms var(--lp-ease-out);
    white-space: nowrap;
  }

  .mast-nav a:hover {
    color: var(--lp-ink);
    background-size: 100% 1px;
  }

  .mast-cta {
    color: var(--lp-accent-deep) !important;
  }

  .mast-rule {
    border: 0;
    border-top: 1px solid var(--lp-rule-2);
    border-bottom: 1px solid var(--lp-rule-2);
    height: 3px;
    margin: 0;
  }

  /* ---------- Hero · H2 split diptych ---------- */

  .hero {
    display: grid;
    grid-template-columns: minmax(0, 7fr) minmax(0, 5fr);
    gap: clamp(2rem, 5vw, 4.5rem);
    align-items: center;
    padding-block: clamp(3.5rem, 8vw, 6.5rem) clamp(3rem, 7vw, 5rem);
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
    max-width: 58ch;
    margin: 0 0 1.75rem;
  }

  .hero-cta {
    display: flex;
    flex-wrap: wrap;
    align-items: center;
    gap: 1.5rem;
    margin-bottom: 2.5rem;
  }

  .btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 3rem;
    padding: 0.75rem 1.5rem;
    border-radius: 0.375rem;
    font-weight: 600;
    letter-spacing: 0.01em;
    cursor: pointer;
    white-space: nowrap;
    transition: background-color 200ms var(--lp-ease-out), transform 200ms var(--lp-ease-out);
  }

  .btn-primary {
    background: var(--lp-ink);
    color: var(--lp-paper);
  }

  .btn-primary:hover {
    background: var(--lp-accent-deep);
    transform: translateY(-1px);
  }

  .btn-primary:active {
    transform: translateY(0);
  }

  .link-arrow {
    color: var(--lp-accent-deep);
    font-weight: 600;
    padding-block: 0.75rem;
    background-image: linear-gradient(var(--lp-accent-deep), var(--lp-accent-deep));
    background-size: 100% 1px;
    background-repeat: no-repeat;
    background-position: 50% 100%;
    transition: color 150ms var(--lp-ease-out), background-size 200ms var(--lp-ease-out);
    white-space: nowrap;
  }

  .link-arrow:hover {
    color: var(--lp-ink);
    background-size: 0 1px;
  }

  .who-strip {
    list-style: none;
    margin: 0;
    padding: 0;
    display: flex;
    flex-wrap: wrap;
    gap: 0;
    border-top: 1px solid var(--lp-rule);
    border-bottom: 1px solid var(--lp-rule);
  }

  .who-strip li {
    flex: 1 1 0;
    min-width: 0;
    padding: 1rem 1.25rem 1rem 0;
  }

  .who-strip li + li {
    border-left: 1px solid var(--lp-rule);
    padding-left: 1.25rem;
  }

  .who-k {
    display: block;
    font-weight: 650;
    font-size: 0.95rem;
    margin-bottom: 0.15rem;
  }

  .who-v {
    display: block;
    color: var(--lp-muted);
    font-size: 0.82rem;
    line-height: 1.45;
  }

  .hero-panel {
    background: var(--lp-paper-2);
    border: 1px solid var(--lp-rule);
    padding: clamp(1.5rem, 3vw, 2.25rem);
  }

  .panel-title {
    font-size: 0.68rem;
    font-weight: 600;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-muted);
    margin: 0 0 1.25rem;
    display: flex;
    align-items: center;
    gap: 0.6rem;
  }

  .panel-title::before {
    content: '';
    width: 0.5rem;
    height: 0.5rem;
    background: var(--lp-accent);
    flex: none;
  }

  .instruments {
    list-style: none;
    margin: 0;
    padding: 0;
  }

  .inst {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 1rem;
    padding-block: 0.8rem;
    border-top: 1px solid var(--lp-rule);
  }

  .inst-code {
    font-family: var(--lp-font-display);
    font-size: 1.05rem;
    font-weight: 580;
    letter-spacing: -0.01em;
  }

  .inst-name {
    color: var(--lp-ink-2);
    font-size: 0.85rem;
    text-align: right;
  }

  /* ---------- Stages · Narrative Workflow (the three goals) ---------- */

  .stages {
    padding-block: clamp(3.5rem, 8vw, 6rem) clamp(3rem, 7vw, 5rem);
  }

  .stages-head {
    margin-bottom: clamp(2.5rem, 5vw, 4rem);
  }

  .stages-head h2,
  .alur-head h2,
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

  .stage {
    border-top: 1px solid var(--lp-rule-2);
    padding-block: clamp(2rem, 4vw, 3rem);
    display: grid;
    grid-template-columns: minmax(0, 1fr);
    gap: 1.5rem;
  }

  .stage:last-child {
    border-bottom: 1px solid var(--lp-rule-2);
  }

  .stage-head {
    display: flex;
    flex-wrap: wrap;
    align-items: flex-start;
    gap: 1.25rem 2rem;
  }

  .stage-num {
    font-family: var(--lp-font-display);
    font-size: clamp(2.5rem, 5vw, 3.5rem);
    font-weight: 440;
    font-style: italic;
    line-height: 0.9;
    color: var(--lp-accent-deep);
    flex: none;
  }

  .stage-title {
    flex: 1 1 0;
    min-width: 12rem;
  }

  .stage-title h3 {
    font-family: var(--lp-font-display);
    font-size: clamp(1.45rem, 2vw + 1rem, 2rem);
    font-weight: 560;
    letter-spacing: -0.01em;
    line-height: 1.15;
    margin: 0.35rem 0 0.35rem;
  }

  .stage-sub {
    color: var(--lp-muted);
    font-size: 0.9rem;
    margin: 0;
  }

  .status {
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    padding: 0.4rem 0.75rem;
    border: 1px solid var(--lp-rule-2);
    border-radius: 0.25rem;
    white-space: nowrap;
  }

  .status::before {
    content: '';
    width: 0.4rem;
    height: 0.4rem;
    border-radius: 999px;
    flex: none;
  }

  .status-on {
    color: var(--lp-accent-deep);
    border-color: var(--lp-accent);
  }

  .status-on::before {
    background: var(--lp-accent);
  }

  .status-soon {
    color: var(--lp-muted);
  }

  .status-soon::before {
    background: var(--lp-rule-2);
  }

  .stage-body {
    max-width: 62ch;
    color: var(--lp-ink-2);
    margin-top: 0.25rem;
  }

  .stage-body > p {
    margin: 0 0 1rem;
  }

  .stage-list {
    list-style: none;
    margin: 0 0 1rem;
    padding: 0;
  }

  .stage-list li {
    position: relative;
    padding-left: 1.5rem;
    margin-bottom: 0.5rem;
  }

  .stage-list li::before {
    content: '';
    position: absolute;
    left: 0.1rem;
    top: 0.6em;
    width: 0.55rem;
    height: 0.55rem;
    background: var(--lp-accent);
    transform: rotate(45deg);
  }

  .stage-note {
    color: var(--lp-muted);
    font-size: 0.92rem;
    font-style: italic;
    border-top: 1px solid var(--lp-rule);
    padding-top: 1rem;
  }

  /* ---------- Alur · F4 step sequence ---------- */

  .alur {
    background: var(--lp-paper-2);
    border-top: 1px solid var(--lp-rule);
    border-bottom: 1px solid var(--lp-rule);
    padding-block: clamp(3.5rem, 8vw, 6rem) clamp(3rem, 7vw, 4.5rem);
  }

  .alur-head {
    margin-bottom: clamp(2rem, 4vw, 3rem);
  }

  .steps {
    list-style: none;
    margin: 0;
    padding: 0;
    counter-reset: step;
  }

  .step {
    display: grid;
    grid-template-columns: minmax(0, 1fr);
    gap: 0.75rem;
    padding-block: 1.75rem;
    border-top: 1px solid var(--lp-rule);
  }

  .steps li:first-child {
    border-top: 0;
  }

  .step-num {
    font-family: var(--lp-font-display);
    font-size: 1.4rem;
    font-weight: 460;
    font-style: italic;
    color: var(--lp-accent-deep);
    line-height: 1;
  }

  .step-copy h3 {
    font-size: 1.1rem;
    font-weight: 650;
    letter-spacing: -0.01em;
    margin: 0 0 0.4rem;
  }

  .step-copy p {
    color: var(--lp-ink-2);
    max-width: 60ch;
    margin: 0;
  }

  .alur-cta {
    display: flex;
    justify-content: center;
    padding-top: clamp(2rem, 4vw, 3rem);
  }

  /* ---------- Closing CTA ---------- */

  .closing {
    text-align: center;
    padding-block: clamp(4rem, 9vw, 7rem);
  }

  .closing h2 {
    margin-bottom: 1rem;
  }

  .closing p {
    color: var(--lp-ink-2);
    max-width: 52ch;
    margin: 0 auto 2rem;
  }

  .closing .btn {
    margin-bottom: 1.5rem;
  }

  .closing .link-arrow {
    display: inline-block;
    margin-inline: auto;
  }

  /* ---------- Footer · Ft1 mast-headed ---------- */

  .foot {
    padding-block: 0 3rem;
    text-align: center;
  }

  .foot-rule {
    border: 0;
    border-top: 1px solid var(--lp-rule-2);
    margin: 0 0 clamp(2.25rem, 5vw, 3.5rem);
  }

  .foot-name {
    font-family: var(--lp-font-display);
    font-size: 1.9rem;
    font-weight: 620;
    letter-spacing: -0.02em;
    line-height: 1;
    margin: 0 0 0.6rem;
  }

  .foot-tagline {
    font-family: var(--lp-font-display);
    font-style: italic;
    font-size: 1.05rem;
    color: var(--lp-ink-2);
    margin: 0 0 1.25rem;
  }

  .foot-copy {
    color: var(--lp-muted);
    font-size: 0.85rem;
    margin: 0 0 0.25rem;
  }

  /* ---------- Focus & accessibility ---------- */

  .landing :global(a):focus-visible,
  .landing :global(button):focus-visible {
    outline: 2px solid var(--lp-focus);
    outline-offset: 3px;
  }

  @media (hover: none), (pointer: coarse) {
    .btn {
      min-height: 3.25rem;
    }

    .mast-nav a {
      padding-block: 0.9rem;
    }
  }

  /* ---------- Responsive ---------- */

  @media (max-width: 56rem) {
    .hero {
      grid-template-columns: minmax(0, 1fr);
    }

    .hero-panel {
      order: 2;
    }
  }

  @media (max-width: 40rem) {
    .mast-nav a:not(.mast-cta) {
      display: none;
    }

    .mast-nav {
      gap: 0;
    }

    .hero h1 {
      font-size: clamp(2.35rem, 10vw, 3rem);
    }

    .hero-cta {
      flex-direction: column;
      align-items: flex-start;
      gap: 0.5rem;
    }

    .who-strip {
      display: block;
    }

    .who-strip li {
      padding: 0.9rem 0;
    }

    .who-strip li + li {
      border-left: 0;
      border-top: 1px solid var(--lp-rule);
      padding-left: 0;
    }

    .stage-head {
      flex-direction: column;
      gap: 0.5rem;
    }

    .stage-title h3 {
      margin-top: 0.25rem;
    }
  }
</style>
