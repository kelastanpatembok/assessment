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

  let hollandCode = $derived(r?.hollandCode ?? dimensions.slice(0, 3).map(d => d.key).join(''));
  let maxVal = $derived(Math.max(...dimensions.map(d => d.value), 1));
</script>

<svelte:head><title>Hasil Holland RIASEC</title></svelte:head>

<div class="flex max-w-2xl flex-col gap-6">
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
        <Badge class="text-lg px-3">{hollandCode}</Badge>
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

  {#if r?.type1Name}
    <Card>
      <CardHeader>
        <CardTitle class="text-base">{r.type1} — {r.type1Name}</CardTitle>
      </CardHeader>
      {#if r.type1Desc}
        <CardContent>
          <p class="text-muted-foreground text-sm leading-relaxed">{r.type1Desc}</p>
        </CardContent>
      {/if}
    </Card>
  {/if}

  <a href="/student-dashboard" class="text-primary text-sm hover:underline">← Kembali ke Dashboard</a>
</div>
