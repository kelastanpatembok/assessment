<script lang="ts">
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';

  let { data } = $props();
  let r = $derived(data.result);

  const traitNames: Record<string, string> = {
    G: 'Peran kepemimpinan (G)', N: 'Kebutuhan diakui (N)', A: 'Keaktifan di atas rata-rata (A)',
    P: 'Kebutuhan berprestasi (P)', X: 'Kebutuhan variasi (X)', B: 'Kebutuhan memiliki kebebasan (B)',
    O: 'Kebutuhan untuk aturan dan supervisi (O)', Z: 'Kebutuhan perubahan (Z)', K: 'Kepemimpinan dalam kelompok (K)',
    F: 'Keperluan untuk disenangi (F)', L: 'Keperluan untuk berafiliasi (L)', I: 'Keperluan untuk bertahan (I)',
    T: 'Keperluan untuk berpikir dan bertindak secara mandiri (T)', V: 'Orientasi pada detail (V)',
    S: 'Pengendalian diri (S)', R: 'Keperluan untuk taat pada aturan (R)', D: 'Keperluan akan keteraturan (D)',
    E: 'Orientasi kerja keras (E)', C: 'Keperluan untuk berempati (C)', W: 'Orientasi terhadap kerja (W)',
  };

  const traitOrder = ['G','N','A','P','X','B','O','Z','K','F','L','I','T','V','S','R','D','E','C','W'];

  // traitScores is a JSON string from the backend: {"G":3,"N":2,...}
  let parsedTraits = $derived(() => {
    if (!r?.traitScores) return {};
    if (typeof r.traitScores === 'object') return r.traitScores as Record<string,number>;
    try { return JSON.parse(r.traitScores) as Record<string,number>; } catch { return {}; }
  });

  let scores = $derived(
    traitOrder.map(t => ({
      key: t,
      name: traitNames[t] ?? t,
      value: parsedTraits()[t] ?? 0,
    }))
  );
  let maxScore = $derived(Math.max(...scores.map(s => s.value), 1));
</script>

<svelte:head><title>Hasil PAPI Kostick</title></svelte:head>

<div class="flex max-w-2xl flex-col gap-6">
  <div>
    <h2 class="text-2xl font-bold">Hasil Tes PAPI Kostick</h2>
    <p class="text-muted-foreground mt-1 text-sm">
      {r?.studentName} · {r?.schoolName ?? '-'}
    </p>
  </div>

  <Card>
    <CardHeader><CardTitle class="text-base">Skor Per Trait (20 Dimensi)</CardTitle></CardHeader>
    <CardContent>
      <div class="flex flex-col gap-3">
        {#each scores as s}
          <div>
            <div class="mb-1 flex items-center justify-between text-sm">
              <span class="font-medium">{s.key}</span>
              <span class="text-muted-foreground text-xs">{s.name.split('(')[0].trim()}: {s.value}</span>
            </div>
            <div class="bg-muted h-2.5 w-full overflow-hidden rounded-full">
              <div
                class="bg-primary h-full rounded-full"
                style="width: {Math.round((s.value / maxScore) * 100)}%"
              ></div>
            </div>
          </div>
        {/each}
      </div>
    </CardContent>
  </Card>

  <a href="/student-dashboard" class="text-primary text-sm hover:underline">← Kembali ke Dashboard</a>
</div>
