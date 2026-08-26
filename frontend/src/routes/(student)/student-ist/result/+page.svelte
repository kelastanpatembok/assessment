<script lang="ts">

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

<div class="lp-wrap flex flex-col gap-6">
  <nav aria-label="Breadcrumb" class="lp-crumbs">
    <a href="/student-dashboard">Dashboard</a>
    <span aria-hidden="true">/</span>
    <span>Hasil Tes IQ IST</span>
  </nav>

  <header class="flex flex-col gap-1">
    <p class="lp-kicker">Hasil Kecerdasan IQ IST</p>
    <h2 class="lp-display text-3xl sm:text-4xl">Hasil Tes IQ IST</h2>
    <p class="lp-lead text-sm">{r?.studentName} · {r?.schoolName ?? '-'}</p>
  </header>

  <div class="lp-grid lp-grid-3">
    <div class="lp-card lp-card-pad flex flex-col gap-1">
      <p class="lp-muted text-sm font-medium">Raw Score (RS)</p>
      <p class="lp-display text-3xl">{r?.totalWert ?? '-'}</p>
    </div>
    <div class="lp-card lp-card-pad flex flex-col gap-1">
      <p class="lp-muted text-sm font-medium">IQ Score</p>
      <p class="lp-display text-3xl">{r?.iqScore ?? '-'}</p>
    </div>
    <div class="lp-card lp-card-pad flex flex-col gap-2">
      <p class="lp-muted text-sm font-medium">Kategori</p>
      <div>
        <span class="lp-chip lp-chip-strong text-sm">{r?.iqCategory ?? '-'}</span>
      </div>
    </div>
  </div>

  <div class="lp-card lp-card-pad flex flex-col gap-3">
    <h3 class="text-base font-semibold">Skor Per Subtes</h3>
    <table class="lp-table">
      <thead>
        <tr>
          <th>Subtes</th>
          <th class="num">Raw Score</th>
          <th class="num">Wert Score</th>
        </tr>
      </thead>
      <tbody>
        {#each subtestScores as s}
          <tr>
            <td class="text-xs">{s.label}</td>
            <td class="num">{s.raw}</td>
            <td class="num">{s.wert}</td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>

</div>
