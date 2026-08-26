<script lang="ts">

  let { data } = $props();
  let r = $derived(data.result);

  function dimColor(key: string): string {
    return {
      R: 'var(--lp-dim-d)',
      I: 'var(--lp-dim-c)',
      A: 'var(--lp-dim-i)',
      S: 'var(--lp-dim-s)',
      E: 'var(--lp-accent)',
      C: 'var(--lp-least)',
    }[key] ?? 'var(--lp-accent)';
  }

  let dimensions = $derived([
    { key: 'R', label: 'Realistic',      value: r?.rscore ?? 0 },
    { key: 'I', label: 'Investigative',  value: r?.iscore ?? 0 },
    { key: 'A', label: 'Artistic',       value: r?.ascore ?? 0 },
    { key: 'S', label: 'Social',         value: r?.sscore ?? 0 },
    { key: 'E', label: 'Enterprising',   value: r?.escore ?? 0 },
    { key: 'C', label: 'Conventional',   value: r?.cscore ?? 0 },
  ].sort((a, b) => b.value - a.value));

  let hollandCode = $derived(r?.hollandCode ?? dimensions.slice(0, 2).map((d) => d.key).join(''));
  let maxVal = $derived(Math.max(...dimensions.map((d) => d.value), 1));

  type TopType = {
    key: string;
    name: string;
    description?: string;
    characteristics?: string;
    strengths?: string;
    weaknesses?: string;
    jobMatch?: string;
  };

  let topTypes = $derived<TopType[]>(
    [
      r?.type1 && {
        key: r.type1,
        name: r.type1Name,
        description: r.type1Description,
        characteristics: r.type1Characteristics,
        strengths: r.type1Strengths,
        weaknesses: r.type1Weaknesses,
        jobMatch: r.type1JobMatch,
      },
      r?.type2 && {
        key: r.type2,
        name: r.type2Name,
        description: r.type2Description,
        characteristics: r.type2Characteristics,
        strengths: r.type2Strengths,
        weaknesses: r.type2Weaknesses,
        jobMatch: r.type2JobMatch,
      },
    ].filter(Boolean) as TopType[]
  );
</script>

<svelte:head><title>Hasil Holland RIASEC</title></svelte:head>

<div class="lp-wrap flex flex-col gap-6">
  <nav aria-label="Breadcrumb" class="lp-crumbs">
    <a href="/student-dashboard">Dashboard</a>
    <span aria-hidden="true">/</span>
    <span>Hasil Tes Holland RIASEC</span>
  </nav>

  <header class="flex flex-col gap-1">
    <p class="lp-kicker">Profil Minat Karir RIASEC</p>
    <h2 class="lp-display text-3xl sm:text-4xl">Hasil Tes Holland RIASEC</h2>
    <p class="lp-lead text-sm">{r?.studentName} · {r?.schoolName ?? '-'}</p>
  </header>

  <div class="lp-card lp-card-pad flex flex-wrap items-center justify-between gap-3">
    <div class="flex flex-col gap-0.5">
      <p class="lp-kicker">Kode Holland</p>
      <h3 class="lp-display text-2xl">{hollandCode}</h3>
    </div>
    <span class="lp-chip lp-chip-strong">RIASEC</span>
  </div>

  <div class="lp-card lp-card-pad flex flex-col gap-3">
    <h3 class="text-base font-semibold">Skor Per Dimensi</h3>
    {#each dimensions as d}
      <div>
        <div class="mb-1 flex items-baseline justify-between text-sm">
          <span class="font-medium">{d.key} — {d.label}</span>
          <span class="lp-muted">{d.value}</span>
        </div>
        <div class="lp-bar">
          <div style="width: {Math.round((d.value / maxVal) * 100)}%; background: {dimColor(d.key)}"></div>
        </div>
      </div>
    {/each}
  </div>

  {#each topTypes as t, i}
    <div class="lp-card lp-card-pad flex flex-col gap-3">
      <div class="flex flex-wrap items-center gap-2">
        <span class="lp-chip">Tipe {i + 1}</span>
        <h3 class="text-base font-semibold">
          <span style="color: {dimColor(t.key)}">{t.key}</span> — {t.name}
        </h3>
      </div>
      <div class="flex flex-col gap-3 text-sm">
        {#if t.description}
          <p class="lp-lead leading-relaxed">{t.description}</p>
        {/if}
        {#if t.characteristics}
          <div>
            <p class="mb-1 font-medium">Karakter</p>
            <p class="lp-lead whitespace-pre-line leading-relaxed">{t.characteristics}</p>
          </div>
        {/if}
        {#if t.strengths}
          <div>
            <p class="mb-1 font-medium">Kelebihan</p>
            <p class="lp-lead whitespace-pre-line leading-relaxed">{t.strengths}</p>
          </div>
        {/if}
        {#if t.weaknesses}
          <div>
            <p class="mb-1 font-medium">Kelemahan</p>
            <p class="lp-lead whitespace-pre-line leading-relaxed">{t.weaknesses}</p>
          </div>
        {/if}
        {#if t.jobMatch}
          <div>
            <p class="mb-1 font-medium">Job Match</p>
            <p class="lp-lead whitespace-pre-line leading-relaxed">{t.jobMatch}</p>
          </div>
        {/if}
      </div>
    </div>
  {/each}

</div>
