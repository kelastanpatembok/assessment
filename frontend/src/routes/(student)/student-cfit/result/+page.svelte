<script lang="ts">
  import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '$lib/components/ui/card/index.js';
  import { Badge } from '$lib/components/ui/badge/index.js';

  let { data } = $props();
  let r = $derived(data.result);

  let subtestScores = $derived([
    { label: 'Subtes 1', value: r?.sub1Score ?? 0 },
    { label: 'Subtes 2', value: r?.sub2Score ?? 0 },
    { label: 'Subtes 3', value: r?.sub3Score ?? 0 },
    { label: 'Subtes 4', value: r?.sub4Score ?? 0 },
  ]);
</script>

<svelte:head><title>Hasil IQ CFIT</title></svelte:head>

<div class="flex max-w-2xl flex-col gap-6">
  <div>
    <h2 class="text-2xl font-bold">Hasil Tes IQ CFIT</h2>
    <p class="text-muted-foreground mt-1 text-sm">
      {r?.studentName} · {r?.schoolName ?? '-'}
    </p>
  </div>

  <div class="grid gap-4 sm:grid-cols-3">
    <Card>
      <CardHeader>
        <CardTitle class="text-sm font-medium text-muted-foreground">Skor Total (RS)</CardTitle>
      </CardHeader>
      <CardContent>
        <p class="text-3xl font-bold">{r?.totalScore ?? '-'}</p>
      </CardContent>
    </Card>
    <Card>
      <CardHeader>
        <CardTitle class="text-sm font-medium text-muted-foreground">Kategori</CardTitle>
      </CardHeader>
      <CardContent>
        <Badge class="text-sm">{r?.category ?? '-'}</Badge>
      </CardContent>
    </Card>
  </div>

  <Card>
    <CardHeader><CardTitle class="text-base">Skor Per Subtes</CardTitle></CardHeader>
    <CardContent>
      <table class="w-full text-sm">
        <thead>
          <tr class="border-border border-b text-left">
            <th class="pb-3 font-medium">Subtes</th>
            <th class="pb-3 font-medium">Skor</th>
          </tr>
        </thead>
        <tbody>
          {#each subtestScores as s}
            <tr class="border-border border-b last:border-0">
              <td class="py-3">{s.label}</td>
              <td class="py-3 font-medium">{s.value}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    </CardContent>
  </Card>

  {#if r?.description}
    <Card>
      <CardHeader><CardTitle class="text-base">Deskripsi</CardTitle></CardHeader>
      <CardContent>
        <p class="text-muted-foreground text-sm leading-relaxed">{r.description}</p>
      </CardContent>
    </Card>
  {/if}

  <a href="/student-dashboard" class="text-primary text-sm hover:underline">← Kembali ke Dashboard</a>
</div>
