<script lang="ts">
  import PapiRadarChart from '$lib/components/PapiRadarChart.svelte';

  let { data } = $props();
  let r = $derived(data.result);

  type TraitDetail = {
    traitCode: string;
    traitName: string;
    score: number;
    description?: string;
    band: 'TINGGI' | 'RENDAH';
    bandText?: string;
  };

  // Real POLA DASAR category grouping (docs/papi-result.xls, tab "POLA DASAR").
  const CATEGORIES: { label: string; traits: string[] }[] = [
    { label: 'Arah Kerja', traits: ['N', 'G', 'A'] },
    { label: 'Kepemimpinan', traits: ['L', 'P', 'I'] },
    { label: 'Aktivitas', traits: ['T', 'V'] },
    { label: 'Sikap Sosial', traits: ['X', 'S', 'B', 'O'] },
    { label: 'Gaya Kerja', traits: ['R', 'D', 'C'] },
    { label: 'Temperamen', traits: ['Z', 'E', 'K'] },
    { label: 'Kepengikutan', traits: ['F', 'W'] },
  ];

  const MAX_SCORE = 9; // each of the 20 traits is chosen in exactly 9 of the 90 pairs

  let traitDetails: TraitDetail[] = $derived(r?.traitDetails ?? []);
  let byCode = $derived(new Map(traitDetails.map((t) => [t.traitCode, t])));

  let groupedCategories = $derived(
    CATEGORIES.map((cat) => ({
      ...cat,
      traits: cat.traits.map((code) => byCode.get(code)).filter((t): t is TraitDetail => !!t),
    }))
  );
</script>

<svelte:head><title>Hasil PAPI Kostick</title></svelte:head>

<div class="lp-wrap flex flex-col gap-6">
  <nav aria-label="Breadcrumb" class="lp-crumbs">
    <a href="/student-dashboard">Dashboard</a>
    <span aria-hidden="true">/</span>
    <span>Hasil Tes PAPI Kostick</span>
  </nav>

  <header class="flex flex-col gap-1">
    <p class="lp-kicker">Profil Kepribadian Kerja PAPI Kostick</p>
    <h2 class="lp-display text-3xl sm:text-4xl">Hasil Tes PAPI Kostick</h2>
    <p class="lp-lead text-sm">{r?.studentName} · {r?.schoolName ?? '-'}</p>
  </header>

  <div class="lp-card lp-card-pad flex flex-col gap-3">
    <div class="flex flex-col gap-0.5">
      <h3 class="text-base font-semibold">Diagram Profil PAPI Kostick</h3>
      <p class="lp-muted text-xs">Psikogram 20 trait kepribadian pada skala 0–9, mengikuti susunan lembar PAPI Kostick.</p>
    </div>
    <div class="mx-auto w-full max-w-2xl">
      <PapiRadarChart {traitDetails} />
    </div>
  </div>

  <div class="lp-card lp-card-pad flex flex-col gap-4">
    <h3 class="text-base font-semibold">Profil Skor (0–9 per trait)</h3>
    <div class="flex flex-col gap-4">
      {#each groupedCategories as cat}
        <div>
          <p class="lp-muted mb-2 text-xs font-semibold uppercase tracking-wide">{cat.label}</p>
          <div class="flex flex-col gap-2">
            {#each cat.traits as t}
              <div>
                <div class="mb-1 flex items-baseline justify-between text-sm">
                  <span class="font-medium">{t.traitCode} — {t.traitName}</span>
                  <span class="lp-muted text-xs">{t.score}</span>
                </div>
                <div class="lp-bar">
                  <div
                    style="width: {Math.round((t.score / MAX_SCORE) * 100)}%; background: {t.band === 'TINGGI'
                      ? 'var(--lp-accent)'
                      : 'var(--lp-least)'}"
                  ></div>
                </div>
              </div>
            {/each}
          </div>
        </div>
      {/each}
    </div>
  </div>

  <div class="flex flex-col gap-3">
    <h3 class="lp-display text-xl">Uraian Per Trait</h3>
    {#each traitDetails as t}
      <div class="lp-card lp-card-pad flex flex-col gap-2">
        <div class="flex flex-wrap items-center justify-between gap-2">
          <div class="flex items-center gap-2">
            <span class="lp-chip">{t.traitCode}</span>
            <h4 class="text-base font-semibold">{t.traitName}</h4>
          </div>
          <span class="lp-chip {t.band === 'TINGGI' ? 'lp-chip-strong' : ''}">
            {t.band === 'TINGGI' ? 'Tinggi' : 'Rendah'} ({t.score})
          </span>
        </div>
        <div class="flex flex-col gap-2 text-sm">
          {#if t.description}
            <p class="lp-lead leading-relaxed">{t.description}</p>
          {/if}
          {#if t.bandText}
            <p class="leading-relaxed">{t.bandText}</p>
          {/if}
        </div>
      </div>
    {/each}
  </div>

</div>
