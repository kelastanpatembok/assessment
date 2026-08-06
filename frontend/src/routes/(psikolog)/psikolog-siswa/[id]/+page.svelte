<script lang="ts">
  let { data } = $props();
  let s = $derived(data.student);

  const testLabels: Record<string, string> = {
    disc: 'Tes Kepribadian DISC',
    holland: 'Tes Minat Holland',
    papi: 'Tes PAPI Kostick',
    cfit: 'Tes IQ CFIT',
    ist: 'Tes IQ IST',
  };

  function parseJson(json: string | null | undefined): any {
    if (!json) return null;
    try {
      return JSON.parse(json);
    } catch {
      return null;
    }
  }

  function fmtDate(v: string | null | undefined): string {
    if (!v) return '-';
    const d = new Date(v);
    return isNaN(d.getTime()) ? '-' : d.toLocaleDateString('id-ID', { day: 'numeric', month: 'long', year: 'numeric' });
  }

  const difTraits = $derived((() => {
    const parsed = parseJson(data.disc?.difProfileTraits);
    return Array.isArray(parsed) ? parsed : [];
  })());

  const hollandScores = $derived([
    { label: 'R', value: data.holland?.rScore ?? 0, name: data.holland?.type1Name ?? '' },
    { label: 'I', value: data.holland?.iScore ?? 0 },
    { label: 'A', value: data.holland?.aScore ?? 0 },
    { label: 'S', value: data.holland?.sScore ?? 0 },
    { label: 'E', value: data.holland?.eScore ?? 0 },
    { label: 'C', value: data.holland?.cScore ?? 0 },
  ]);
  const hollandMax = $derived(Math.max(...hollandScores.map((x: any) => x.value), 1));

  const papiTraits = $derived(data.papi?.traitDetails ?? []);

  const istSubtests = $derived((() => {
    const map = parseJson(data.ist?.subtestScores);
    if (!map || typeof map !== 'object') return [];
    return Object.entries(map).map(([code, v]: any) => ({
      code,
      raw: v?.raw ?? '-',
      wert: v?.wert ?? '-',
    }));
  })());

  function barWidth(value: number, max: number) {
    return max > 0 ? Math.round((value / max) * 100) : 0;
  }
</script>

<svelte:head><title>{s?.name ?? 'Peserta'} — Hasil Asesmen</title></svelte:head>

<div class="pdetail">
  <nav aria-label="Breadcrumb" class="pdetail-crumbs">
    <a href="/psikolog-dashboard">Dashboard Psikolog</a>
    <span aria-hidden="true">/</span>
    <span>{s?.name ?? 'Peserta'}</span>
  </nav>

  <header class="pdetail-head">
    <div class="pdetail-ava">{(s?.name ?? s?.username ?? '?').charAt(0).toUpperCase()}</div>
    <div class="pdetail-id">
      <p class="pdetail-kicker">Peserta Asesmen</p>
      <h2 class="pdetail-name">{s?.name ?? '—'}</h2>
      <p class="pdetail-sub">@{s?.username} · {s?.school?.name ?? '—'}</p>
    </div>
    <span class="pdetail-role">Siswa</span>
  </header>

  <section class="pdetail-results">
    <h3 class="pdetail-section">Hasil Asesmen</h3>

    {#if data.disc}
      <article class="pcard">
        <div class="pcard-top">
          <h4 class="pcard-title">{testLabels.disc}</h4>
          <span class="pcard-date">{fmtDate(data.disc.completedAt ?? data.disc.createdAt)}</span>
        </div>
        {#if data.disc.profileTitle}
          <div class="pcard-kicker">Profil kepribadian</div>
          <p class="pcard-big">{data.disc.profileTitle}</p>
        {/if}
        {#if difTraits.length > 0}
          <div class="pcard-chips">
            {#each difTraits as t}
              <span class="pcard-chip">{t}</span>
            {/each}
          </div>
        {/if}
        {#if data.disc.profileDesc}
          <p class="pcard-text">{data.disc.profileDesc}</p>
        {/if}
        {#if data.disc.jobRecommendations}
          <p class="pcard-text pcard-muted"><strong>Rekomendasi karier:</strong> {data.disc.jobRecommendations}</p>
        {/if}
      </article>
    {/if}

    {#if data.holland}
      <article class="pcard">
        <div class="pcard-top">
          <h4 class="pcard-title">{testLabels.holland}</h4>
          <span class="pcard-date">{fmtDate(data.holland.completedAt)}</span>
        </div>
        <div class="pcard-kicker">Kode minat: <strong>{data.holland.hollandCode ?? '—'}</strong></div>
        <div class="pcard-bars">
          {#each hollandScores as x}
            <div class="pcard-bar">
              <div class="pcard-bar-label">
                <span><strong>{x.label}</strong>{x.name ? ` · ${x.name}` : ''}</span>
                <span>{x.value}</span>
              </div>
              <div class="lp-bar"><div style="width: {barWidth(x.value, hollandMax)}%; background: var(--lp-accent)"></div></div>
            </div>
          {/each}
        </div>
        {#if data.holland.type1Description}
          <p class="pcard-text">{data.holland.type1Description}</p>
        {/if}
        {#if data.holland.type1JobMatch}
          <p class="pcard-text pcard-muted"><strong>Pekerjaan cocok:</strong> {data.holland.type1JobMatch}</p>
        {/if}
      </article>
    {/if}

    {#if data.papi}
      <article class="pcard">
        <div class="pcard-top">
          <h4 class="pcard-title">{testLabels.papi}</h4>
          <span class="pcard-date">{fmtDate(data.papi.completedAt)}</span>
        </div>
        {#if papiTraits.length > 0}
          <div class="pcard-bars">
            {#each papiTraits as t}
              <div class="pcard-bar">
                <div class="pcard-bar-label">
                  <span><strong>{t.traitCode}</strong> · {t.traitName}</span>
                  <span>{t.score}</span>
                </div>
                <div class="lp-bar"><div style="width: {barWidth(t.score, 12)}%; background: var(--lp-accent)"></div></div>
                {#if t.bandText}
                  <p class="pcard-band">{t.bandText}</p>
                {/if}
              </div>
            {/each}
          </div>
        {/if}
      </article>
    {/if}

    {#if data.cfit}
      <article class="pcard">
        <div class="pcard-top">
          <h4 class="pcard-title">{testLabels.cfit}</h4>
          <span class="pcard-date">{fmtDate(data.cfit.completedAt)}</span>
        </div>
        <div class="pcard-stats">
          <div class="pcard-stat">
            <span class="pcard-stat-label">Skor IQ</span>
            <span class="pcard-stat-num">{data.cfit.iqScore ?? '—'}</span>
          </div>
          <div class="pcard-stat">
            <span class="pcard-stat-label">Skor Mentah (RS)</span>
            <span class="pcard-stat-num">{data.cfit.totalScore ?? '—'}</span>
          </div>
        </div>
        {#if data.cfit.category}
          <p class="pcard-text pcard-muted"><strong>Kategori:</strong> {data.cfit.category}</p>
        {/if}
        {#if data.cfit.description}
          <p class="pcard-text">{data.cfit.description}</p>
        {/if}
      </article>
    {/if}

    {#if data.ist}
      <article class="pcard">
        <div class="pcard-top">
          <h4 class="pcard-title">{testLabels.ist}</h4>
          <span class="pcard-date">{fmtDate(data.ist.completedAt)}</span>
        </div>
        <div class="pcard-stats">
          <div class="pcard-stat">
            <span class="pcard-stat-label">Skor IQ</span>
            <span class="pcard-stat-num">{data.ist.iqScore ?? '—'}</span>
          </div>
          <div class="pcard-stat">
            <span class="pcard-stat-label">Kategori</span>
            <span class="pcard-stat-num pcard-stat-num-sm">{data.ist.iqCategory ?? '—'}</span>
          </div>
          <div class="pcard-stat">
            <span class="pcard-stat-label">Total Wert</span>
            <span class="pcard-stat-num">{data.ist.totalWert ?? '—'}</span>
          </div>
        </div>
        {#if istSubtests.length > 0}
          <div class="pcard-bars">
            {#each istSubtests as sub}
              <div class="pcard-bar">
                <div class="pcard-bar-label">
                  <span><strong>{sub.code}</strong></span>
                  <span>Wert {sub.wert} · Raw {sub.raw}</span>
                </div>
              </div>
            {/each}
          </div>
        {/if}
      </article>
    {/if}

    {#if !data.disc && !data.holland && !data.papi && !data.cfit && !data.ist}
      <p class="pdetail-empty">Peserta ini belum mengerjakan asesmen apa pun.</p>
    {/if}
  </section>

  {#if data.certificates.length > 0}
    <section class="pdetail-certs">
      <h3 class="pdetail-section">Sertifikat</h3>
      <div class="pdetail-cert-grid">
        {#each data.certificates as cert}
          <a class="pdetail-cert" href={cert.url} target="_blank" rel="noopener" title="Buka sertifikat">
            <span class="pdetail-cert-thumb">
              <img src={cert.url} alt={testLabels[cert.testType] ?? 'Sertifikat'} loading="lazy" />
            </span>
            <span class="pdetail-cert-name">{testLabels[cert.testType] ?? cert.testType}</span>
            <span class="pdetail-cert-dl">Lihat / Unduh</span>
          </a>
        {/each}
      </div>
    </section>
  {/if}
</div>

<style>
  .pdetail {
    display: grid;
    gap: clamp(1.5rem, 3vw, 2.25rem);
  }

  .pdetail-crumbs {
    display: flex;
    gap: 0.5rem;
    font-size: 0.82rem;
    color: var(--lp-muted);
  }

  .pdetail-crumbs a {
    color: var(--lp-accent-deep);
    font-weight: 600;
    text-decoration: none;
  }

  .pdetail-crumbs a:hover {
    text-decoration: underline;
  }

  .pdetail-head {
    display: flex;
    align-items: center;
    gap: 1.1rem;
  }

  .pdetail-ava {
    width: 3.5rem;
    height: 3.5rem;
    border-radius: 999px;
    background: var(--lp-accent-bg);
    color: var(--lp-ink);
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    font-size: 1.4rem;
    flex: none;
  }

  .pdetail-id {
    display: grid;
    gap: 0.1rem;
    min-width: 0;
  }

  .pdetail-kicker {
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-accent-deep);
    margin: 0;
  }

  .pdetail-name {
    font-family: var(--lp-font-display);
    font-size: clamp(1.5rem, 3vw, 2rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1.12;
    margin: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .pdetail-sub {
    color: var(--lp-muted);
    margin: 0;
    font-size: 0.9rem;
  }

  .pdetail-role {
    margin-left: auto;
    font-size: 0.72rem;
    font-weight: 650;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    color: var(--lp-accent-deep);
    border: 1px solid var(--lp-rule-2);
    border-radius: 999px;
    padding: 0.3rem 0.8rem;
    flex: none;
  }

  .pdetail-results,
  .pdetail-certs {
    display: grid;
    gap: 1rem;
  }

  .pdetail-section {
    font-family: var(--lp-font-display);
    font-size: 1.4rem;
    font-weight: 560;
    letter-spacing: -0.01em;
    margin: 0;
  }

  .pcard {
    display: grid;
    gap: 0.6rem;
    border: 1px solid var(--lp-rule);
    border-radius: 1.25rem;
    background: var(--lp-paper);
    padding: 1.4rem 1.5rem;
  }

  .pcard-top {
    display: flex;
    align-items: baseline;
    justify-content: space-between;
    gap: 1rem;
  }

  .pcard-title {
    font-weight: 650;
    font-size: 1.05rem;
    margin: 0;
  }

  .pcard-date {
    font-size: 0.78rem;
    color: var(--lp-muted);
    white-space: nowrap;
  }

  .pcard-kicker {
    font-size: 0.8rem;
    color: var(--lp-ink-2);
  }

  .pcard-big {
    font-family: var(--lp-font-display);
    font-size: 1.5rem;
    font-weight: 560;
    margin: 0;
  }

  .pcard-chips {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
  }

  .pcard-chip {
    font-size: 0.78rem;
    font-weight: 650;
    padding: 0.25rem 0.7rem;
    border-radius: 999px;
    background: var(--lp-tint-amber);
    color: var(--lp-ink);
  }

  .pcard-text {
    margin: 0;
    color: var(--lp-ink-2);
    line-height: 1.6;
  }

  .pcard-muted {
    color: var(--lp-muted);
    font-size: 0.9rem;
  }

  .pcard-bars {
    display: grid;
    gap: 0.7rem;
  }

  .pcard-bar {
    display: grid;
    gap: 0.25rem;
  }

  .pcard-bar-label {
    display: flex;
    justify-content: space-between;
    gap: 1rem;
    font-size: 0.85rem;
    color: var(--lp-ink-2);
  }

  .pcard-band {
    margin: 0;
    font-size: 0.8rem;
    color: var(--lp-muted);
  }

  .pcard-stats {
    display: flex;
    flex-wrap: wrap;
    gap: 0.8rem;
  }

  .pcard-stat {
    display: grid;
    gap: 0.1rem;
    border: 1px solid var(--lp-rule);
    border-radius: 0.9rem;
    padding: 0.7rem 1rem;
    background: var(--lp-tint-grey);
    min-width: 7rem;
  }

  .pcard-stat-label {
    font-size: 0.72rem;
    font-weight: 650;
    letter-spacing: 0.05em;
    text-transform: uppercase;
    color: var(--lp-ink-2);
  }

  .pcard-stat-num {
    font-family: var(--lp-font-display);
    font-size: 1.6rem;
    font-weight: 560;
    line-height: 1;
  }

  .pcard-stat-num-sm {
    font-size: 1.05rem;
  }

  .pdetail-empty {
    margin: 0;
    padding: 1.5rem;
    border: 1px dashed var(--lp-rule-2);
    border-radius: 1.25rem;
    color: var(--lp-muted);
    text-align: center;
  }

  .pdetail-cert-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(10rem, 1fr));
    gap: 1rem;
  }

  .pdetail-cert {
    display: grid;
    gap: 0.4rem;
    border: 1px solid var(--lp-rule);
    border-radius: 1rem;
    padding: 0.75rem;
    text-decoration: none;
    transition: transform 160ms var(--lp-ease-out), border-color 160ms var(--lp-ease-out);
  }

  .pdetail-cert:hover {
    transform: translateY(-2px);
    border-color: var(--lp-rule-2);
  }

  .pdetail-cert-thumb {
    aspect-ratio: 16 / 11;
    border-radius: 0.6rem;
    overflow: hidden;
    background: var(--lp-tint-grey);
  }

  .pdetail-cert-thumb img {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .pdetail-cert-name {
    font-size: 0.85rem;
    font-weight: 650;
    color: var(--lp-ink);
  }

  .pdetail-cert-dl {
    font-size: 0.78rem;
    color: var(--lp-accent-deep);
  }
</style>
