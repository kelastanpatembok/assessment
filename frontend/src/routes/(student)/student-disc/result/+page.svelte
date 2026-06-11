<script lang="ts">
  import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '$lib/components/ui/card/index.js';
  import { Badge } from '$lib/components/ui/badge/index.js';

  let { data } = $props();
  let r = $derived(data.result);

  function barWidth(value: number, max: number) {
    return max > 0 ? Math.round((value / max) * 100) : 0;
  }

  let mostScores = $derived([
    { label: 'D', value: r?.dmost ?? 0 },
    { label: 'I', value: r?.imost ?? 0 },
    { label: 'S', value: r?.smost ?? 0 },
    { label: 'C', value: r?.cmost ?? 0 },
  ]);
  let leastScores = $derived([
    { label: 'D', value: r?.dleast ?? 0 },
    { label: 'I', value: r?.ileast ?? 0 },
    { label: 'S', value: r?.sleast ?? 0 },
    { label: 'C', value: r?.cleast ?? 0 },
  ]);
  let difScores = $derived([
    { label: 'D', value: r?.ddif ?? 0 },
    { label: 'I', value: r?.idif ?? 0 },
    { label: 'S', value: r?.sdif ?? 0 },
    { label: 'C', value: r?.cdif ?? 0 },
  ]);

  let maxMost = $derived(Math.max(...mostScores.map(s => s.value), 1));
  let maxLeast = $derived(Math.max(...leastScores.map(s => s.value), 1));
  let maxDif = $derived(Math.max(...difScores.map(s => Math.abs(s.value)), 1));

  const dimColors: Record<string, string> = {
    D: 'bg-red-500', I: 'bg-yellow-500', S: 'bg-green-500', C: 'bg-blue-500',
  };
</script>

<svelte:head><title>Hasil DISC</title></svelte:head>

<div class="flex max-w-2xl flex-col gap-6">
  <div>
    <h2 class="text-2xl font-bold">Hasil Tes DISC</h2>
    <p class="text-muted-foreground mt-1 text-sm">
      {r?.studentName} · {r?.schoolName ?? '-'}
    </p>
  </div>

  {#if r?.profileTitle}
    <Card>
      <CardHeader>
        <div class="flex items-start justify-between gap-2">
          <CardTitle>{r.profileTitle}</CardTitle>
          <Badge variant="outline">DISC</Badge>
        </div>
        <CardDescription class="mt-2 text-sm leading-relaxed">{r.profileDesc ?? ''}</CardDescription>
      </CardHeader>
    </Card>
  {/if}

  <div class="grid gap-4 sm:grid-cols-3">
    <Card>
      <CardHeader><CardTitle class="text-sm">MOST (Paling Tepat)</CardTitle></CardHeader>
      <CardContent>
        <div class="flex flex-col gap-3">
          {#each mostScores as s}
            <div>
              <div class="mb-1 flex justify-between text-xs">
                <span class="font-medium">{s.label}</span>
                <span class="text-muted-foreground">{s.value}</span>
              </div>
              <div class="bg-muted h-2 w-full overflow-hidden rounded-full">
                <div class="h-full rounded-full {dimColors[s.label] ?? 'bg-primary'}" style="width: {barWidth(s.value, maxMost)}%"></div>
              </div>
            </div>
          {/each}
        </div>
      </CardContent>
    </Card>

    <Card>
      <CardHeader><CardTitle class="text-sm">LEAST (Paling Tidak Tepat)</CardTitle></CardHeader>
      <CardContent>
        <div class="flex flex-col gap-3">
          {#each leastScores as s}
            <div>
              <div class="mb-1 flex justify-between text-xs">
                <span class="font-medium">{s.label}</span>
                <span class="text-muted-foreground">{s.value}</span>
              </div>
              <div class="bg-muted h-2 w-full overflow-hidden rounded-full">
                <div class="h-full rounded-full {dimColors[s.label] ?? 'bg-primary'}" style="width: {barWidth(s.value, maxLeast)}%"></div>
              </div>
            </div>
          {/each}
        </div>
      </CardContent>
    </Card>

    <Card>
      <CardHeader><CardTitle class="text-sm">DIF (Selisih)</CardTitle></CardHeader>
      <CardContent>
        <div class="flex flex-col gap-3">
          {#each difScores as s}
            <div>
              <div class="mb-1 flex justify-between text-xs">
                <span class="font-medium">{s.label}</span>
                <span class="text-muted-foreground">{s.value}</span>
              </div>
              <div class="bg-muted h-2 w-full overflow-hidden rounded-full">
                <div class="h-full rounded-full {s.value >= 0 ? (dimColors[s.label] ?? 'bg-primary') : 'bg-gray-400'}" style="width: {barWidth(Math.abs(s.value), maxDif)}%"></div>
              </div>
            </div>
          {/each}
        </div>
      </CardContent>
    </Card>
  </div>

  <div class="flex gap-3">
    <a href="/student-dashboard" class="text-primary text-sm hover:underline">← Kembali ke Dashboard</a>
  </div>
</div>
