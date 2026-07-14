<script lang="ts">
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Badge } from '$lib/components/ui/badge/index.js';

  let { data } = $props();
  let r = $derived(data.result);

  const subtestDefs = [
    { key: 'SE', label: 'SE — Melengkapi Kalimat' },
    { key: 'WA', label: 'WA — Memilih Kata' },
    { key: 'AN', label: 'AN — Analogi' },
    { key: 'GE', label: 'GE — Kemampuan Umum' },
    { key: 'RA', label: 'RA — Aritmatika' },
    { key: 'ZR', label: 'ZR — Deret Angka' },
    { key: 'FA', label: 'FA — Pemilihan Bentuk' },
    { key: 'WU', label: 'WU — Tugas Kubus' },
    { key: 'ME', label: 'ME — Memori' },
  ];

  // subtestScores is a JSON string: {"SE":{"raw":5,"wert":7},...}
  let parsedSubtests = $derived(() => {
    if (!r?.subtestScores) return {} as Record<string, { raw: number; wert: number }>;
    if (typeof r.subtestScores === 'object') return r.subtestScores as Record<string, { raw: number; wert: number }>;
    try { return JSON.parse(r.subtestScores) as Record<string, { raw: number; wert: number }>; } catch { return {}; }
  });

  let subtestScores = $derived(
    subtestDefs.map(d => ({
      label: d.label,
      raw: parsedSubtests()[d.key]?.raw ?? '-',
      wert: parsedSubtests()[d.key]?.wert ?? '-',
    }))
  );
</script>

<svelte:head><title>Hasil IQ IST</title></svelte:head>

<div class="flex max-w-2xl flex-col gap-6">
  <div>
    <h2 class="text-2xl font-bold">Hasil Tes IQ IST</h2>
    <p class="text-muted-foreground mt-1 text-sm">
      {r?.studentName} · {r?.schoolName ?? '-'}
    </p>
  </div>

  <div class="grid gap-4 sm:grid-cols-3">
    <Card>
      <CardHeader>
        <CardTitle class="text-sm font-medium text-muted-foreground">Raw Score (RS)</CardTitle>
      </CardHeader>
      <CardContent>
        <p class="text-3xl font-bold">{r?.totalWert ?? '-'}</p>
      </CardContent>
    </Card>
    <Card>
      <CardHeader>
        <CardTitle class="text-sm font-medium text-muted-foreground">IQ Score</CardTitle>
      </CardHeader>
      <CardContent>
        <p class="text-3xl font-bold">{r?.iqScore ?? '-'}</p>
      </CardContent>
    </Card>
    <Card>
      <CardHeader>
        <CardTitle class="text-sm font-medium text-muted-foreground">Kategori</CardTitle>
      </CardHeader>
      <CardContent>
        <Badge class="text-sm">{r?.iqCategory ?? '-'}</Badge>
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
            <th class="pb-3 font-medium text-right">Raw Score</th>
            <th class="pb-3 font-medium text-right">Wert Score</th>
          </tr>
        </thead>
        <tbody>
          {#each subtestScores as s}
            <tr class="border-border border-b last:border-0">
              <td class="py-3 text-xs">{s.label}</td>
              <td class="py-3 text-right font-medium">{s.raw}</td>
              <td class="py-3 text-right font-medium">{s.wert}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    </CardContent>
  </Card>

  <a href="/student-dashboard" class="text-primary text-sm hover:underline">← Kembali ke Dashboard</a>
</div>
