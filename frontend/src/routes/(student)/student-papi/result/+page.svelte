<script lang="ts">
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Badge } from '$lib/components/ui/badge/index.js';

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
    { label: 'Sifat Sosial', traits: ['X', 'S', 'B', 'O'] },
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

<div class="flex max-w-2xl flex-col gap-6">
  <nav aria-label="Breadcrumb" class="text-muted-foreground flex items-center gap-1.5 text-sm">
    <a href="/student-dashboard" class="hover:text-foreground hover:underline">Dashboard</a>
    <span aria-hidden="true">/</span>
    <span class="text-foreground">Hasil Tes PAPI Kostick</span>
  </nav>

  <div>
    <h2 class="text-2xl font-bold">Hasil Tes PAPI Kostick</h2>
    <p class="text-muted-foreground mt-1 text-sm">
      {r?.studentName} · {r?.schoolName ?? '-'}
    </p>
  </div>

  <Card>
    <CardHeader><CardTitle class="text-base">Profil Skor (0–9 per trait)</CardTitle></CardHeader>
    <CardContent>
      <div class="flex flex-col gap-5">
        {#each groupedCategories as cat}
          <div>
            <p class="text-muted-foreground mb-2 text-xs font-semibold uppercase tracking-wide">{cat.label}</p>
            <div class="flex flex-col gap-2">
              {#each cat.traits as t}
                <div>
                  <div class="mb-1 flex items-center justify-between text-sm">
                    <span class="font-medium">{t.traitCode} — {t.traitName}</span>
                    <span class="text-muted-foreground text-xs">{t.score}/{MAX_SCORE}</span>
                  </div>
                  <div class="bg-muted h-2.5 w-full overflow-hidden rounded-full">
                    <div
                      class="h-full rounded-full {t.band === 'TINGGI' ? 'bg-primary' : 'bg-muted-foreground/50'}"
                      style="width: {Math.round((t.score / MAX_SCORE) * 100)}%"
                    ></div>
                  </div>
                </div>
              {/each}
            </div>
          </div>
        {/each}
      </div>
    </CardContent>
  </Card>

  <div class="flex flex-col gap-3">
    <h3 class="text-lg font-semibold">Uraian Per Trait</h3>
    {#each traitDetails as t}
      <Card>
        <CardHeader>
          <div class="flex items-center justify-between">
            <div class="flex items-center gap-2">
              <Badge variant="outline">{t.traitCode}</Badge>
              <CardTitle class="text-base">{t.traitName}</CardTitle>
            </div>
            <Badge class={t.band === 'TINGGI' ? '' : 'bg-muted-foreground/70'}>
              {t.band === 'TINGGI' ? 'Tinggi' : 'Rendah'} ({t.score}/{MAX_SCORE})
            </Badge>
          </div>
        </CardHeader>
        <CardContent class="flex flex-col gap-2 text-sm">
          {#if t.description}
            <p class="text-muted-foreground leading-relaxed">{t.description}</p>
          {/if}
          {#if t.bandText}
            <p class="leading-relaxed">{t.bandText}</p>
          {/if}
        </CardContent>
      </Card>
    {/each}
  </div>
</div>
