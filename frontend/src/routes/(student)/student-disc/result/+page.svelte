<script lang="ts">
  import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '$lib/components/ui/card/index.js';
  import { Badge } from '$lib/components/ui/badge/index.js';
  import DiscLineChart from '$lib/components/disc-line-chart/DiscLineChart.svelte';

  let { data } = $props();
  let r = $derived(data.result);

  // most/least/dif_profile_traits are stored as JSONB but serialized by
  // Jackson as plain strings (the Java field type is String, annotated only
  // for JDBC — Jackson has no idea it's JSON), so each needs its own parse.
  function parseTraits(json: string | null | undefined): string[] {
    if (!json) return [];
    try {
      const parsed = JSON.parse(json);
      return Array.isArray(parsed) ? parsed : [];
    } catch {
      return [];
    }
  }

  let mostTraits = $derived(parseTraits(r?.mostProfileTraits));
  let leastTraits = $derived(parseTraits(r?.leastProfileTraits));
  let difTraits = $derived(parseTraits(r?.difProfileTraits));

  function barWidth(value: number, max: number) {
    return max > 0 ? Math.round((value / max) * 100) : 0;
  }

  // Jackson's legacy bean-naming mangles getDMost()/getILeast()/etc by
  // lowercasing the entire leading run of uppercase letters, not just the
  // first — so the wire keys are "dmost"/"ileast"/etc, not "dMost"/"iLeast".
  // Matches the same lowercase keys counselor-results already reads.
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
          <div>
            <p class="text-muted-foreground text-xs">Kepribadian Asli / Sesungguhnya</p>
            <CardTitle>{r.profileTitle}</CardTitle>
          </div>
          <Badge variant="outline">DISC</Badge>
        </div>
        {#if difTraits.length > 0}
          <ul class="mt-3 flex flex-wrap gap-1.5">
            {#each difTraits as trait}
              <li class="bg-muted text-muted-foreground rounded-full px-2.5 py-0.5 text-xs">{trait}</li>
            {/each}
          </ul>
        {/if}
        <CardDescription class="mt-3 text-sm leading-relaxed">{r.profileDesc ?? ''}</CardDescription>
      </CardHeader>
    </Card>
  {/if}

  <div class="grid gap-4 sm:grid-cols-2">
    <Card>
      <CardHeader>
        <p class="text-muted-foreground text-xs">Kepribadian Saat di Publik</p>
        <CardTitle class="text-base">{r?.mostProfileTitle ?? '-'}</CardTitle>
      </CardHeader>
      <CardContent>
        {#if mostTraits.length > 0}
          <ul class="flex flex-wrap gap-1.5">
            {#each mostTraits as trait}
              <li class="bg-muted text-muted-foreground rounded-full px-2.5 py-0.5 text-xs">{trait}</li>
            {/each}
          </ul>
        {/if}
      </CardContent>
    </Card>

    <Card>
      <CardHeader>
        <p class="text-muted-foreground text-xs">Kepribadian Saat Mendapat Tekanan</p>
        <CardTitle class="text-base">{r?.leastProfileTitle ?? '-'}</CardTitle>
      </CardHeader>
      <CardContent>
        {#if leastTraits.length > 0}
          <ul class="flex flex-wrap gap-1.5">
            {#each leastTraits as trait}
              <li class="bg-muted text-muted-foreground rounded-full px-2.5 py-0.5 text-xs">{trait}</li>
            {/each}
          </ul>
        {/if}
      </CardContent>
    </Card>
  </div>

  {#if r?.jobRecommendations}
    <Card>
      <CardHeader><CardTitle class="text-sm">Job Match</CardTitle></CardHeader>
      <CardContent>
        <p class="text-muted-foreground text-sm leading-relaxed">{r.jobRecommendations}</p>
      </CardContent>
    </Card>
  {/if}

  <Card>
    <CardHeader><CardTitle class="text-sm">Grafik DISC</CardTitle></CardHeader>
    <CardContent>
      <div class="grid grid-cols-3 gap-2">
        <DiscLineChart
          title="GRAPH 1 MOST"
          subtitle="Mask Public Self"
          values={{ d: r?.mostDConv ?? 0, i: r?.mostIConv ?? 0, s: r?.mostSConv ?? 0, c: r?.mostCConv ?? 0 }}
        />
        <DiscLineChart
          title="GRAPH 2 LEAST"
          subtitle="Core Private Self"
          values={{ d: r?.leastDConv ?? 0, i: r?.leastIConv ?? 0, s: r?.leastSConv ?? 0, c: r?.leastCConv ?? 0 }}
        />
        <DiscLineChart
          title="GRAPH 3 CHANGE"
          subtitle="Mirror Perceived Self"
          values={{ d: r?.difDConv ?? 0, i: r?.difIConv ?? 0, s: r?.difSConv ?? 0, c: r?.difCConv ?? 0 }}
        />
      </div>
    </CardContent>
  </Card>

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
