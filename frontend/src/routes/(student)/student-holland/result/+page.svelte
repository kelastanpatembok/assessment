<script lang="ts">
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Badge } from '$lib/components/ui/badge/index.js';

  let { data } = $props();
  let r = $derived(data.result);

  const dimColors: Record<string, string> = {
    R: 'bg-orange-500', I: 'bg-blue-500', A: 'bg-purple-500',
    S: 'bg-green-500', E: 'bg-yellow-500', C: 'bg-gray-500',
  };

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

<div class="flex max-w-2xl flex-col gap-6">
  <nav aria-label="Breadcrumb" class="text-muted-foreground flex items-center gap-1.5 text-sm">
    <a href="/student-dashboard" class="hover:text-foreground hover:underline">Dashboard</a>
    <span aria-hidden="true">/</span>
    <span class="text-foreground">Hasil Tes Holland RIASEC</span>
  </nav>

  <div>
    <h2 class="text-2xl font-bold">Hasil Tes Holland RIASEC</h2>
    <p class="text-muted-foreground mt-1 text-sm">
      {r?.studentName} · {r?.schoolName ?? '-'}
    </p>
  </div>

  <Card>
    <CardHeader>
      <div class="flex items-center gap-3">
        <CardTitle>Kode Holland</CardTitle>
        <Badge class="px-3 text-lg">{hollandCode}</Badge>
      </div>
    </CardHeader>
  </Card>

  <Card>
    <CardHeader><CardTitle class="text-base">Skor Per Dimensi</CardTitle></CardHeader>
    <CardContent>
      <div class="flex flex-col gap-3">
        {#each dimensions as d}
          <div>
            <div class="mb-1 flex justify-between text-sm">
              <span class="font-medium">{d.key} — {d.label}</span>
              <span class="text-muted-foreground">{d.value}</span>
            </div>
            <div class="bg-muted h-3 w-full overflow-hidden rounded-full">
              <div
                class="h-full rounded-full {dimColors[d.key] ?? 'bg-primary'}"
                style="width: {Math.round((d.value / maxVal) * 100)}%"
              ></div>
            </div>
          </div>
        {/each}
      </div>
    </CardContent>
  </Card>

  {#each topTypes as t, i}
    <Card>
      <CardHeader>
        <div class="flex items-center gap-2">
          <Badge variant="outline">Tipe {i + 1}</Badge>
          <CardTitle class="text-base">{t.key} — {t.name}</CardTitle>
        </div>
      </CardHeader>
      <CardContent class="flex flex-col gap-4 text-sm">
        {#if t.description}
          <p class="text-muted-foreground leading-relaxed">{t.description}</p>
        {/if}
        {#if t.characteristics}
          <div>
            <p class="mb-1 font-medium">Karakter</p>
            <p class="text-muted-foreground whitespace-pre-line leading-relaxed">{t.characteristics}</p>
          </div>
        {/if}
        {#if t.strengths}
          <div>
            <p class="mb-1 font-medium">Kelebihan</p>
            <p class="text-muted-foreground whitespace-pre-line leading-relaxed">{t.strengths}</p>
          </div>
        {/if}
        {#if t.weaknesses}
          <div>
            <p class="mb-1 font-medium">Kelemahan</p>
            <p class="text-muted-foreground whitespace-pre-line leading-relaxed">{t.weaknesses}</p>
          </div>
        {/if}
        {#if t.jobMatch}
          <div>
            <p class="mb-1 font-medium">Job Match</p>
            <p class="text-muted-foreground whitespace-pre-line leading-relaxed">{t.jobMatch}</p>
          </div>
        {/if}
      </CardContent>
    </Card>
  {/each}
</div>
