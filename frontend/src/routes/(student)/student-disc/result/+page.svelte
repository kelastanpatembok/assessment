<script lang="ts">
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

  function dimColor(label: string): string {
    return {
      D: 'var(--lp-dim-d)',
      I: 'var(--lp-dim-i)',
      S: 'var(--lp-dim-s)',
      C: 'var(--lp-dim-c)',
    }[label] ?? 'var(--lp-accent)';
  }
</script>

<svelte:head><title>Hasil DISC</title></svelte:head>

<div class="lp-wrap flex flex-col gap-6">
  <nav aria-label="Breadcrumb" class="lp-crumbs">
    <a href="/student-dashboard">Dashboard</a>
    <span aria-hidden="true">/</span>
    <span>Hasil Tes DISC</span>
  </nav>

  <header class="flex flex-col gap-1">
    <p class="lp-kicker">Profil Kepribadian DISC</p>
    <h2 class="lp-display text-3xl sm:text-4xl">Hasil Tes DISC</h2>
    <p class="lp-lead text-sm">{r?.studentName} · {r?.schoolName ?? '-'}</p>
  </header>

  <div class="lp-card lp-card-pad flex flex-col gap-4">
    <h3 class="font-semibold">Grafik DISC</h3>
    <div class="lp-grid lp-grid-3">
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
  </div>

  <div class="lp-grid lp-grid-3">
    <div class="lp-card lp-card-pad flex flex-col gap-3">
      <h3 class="text-sm font-semibold">MOST (Paling Tepat)</h3>
      {#each mostScores as s}
        <div>
          <div class="mb-1 flex items-baseline justify-between text-xs">
            <span class="font-semibold">{s.label}</span>
            <span class="lp-muted">{s.value}</span>
          </div>
          <div class="lp-bar"><div style="width: {barWidth(s.value, maxMost)}%; background: {dimColor(s.label)}"></div></div>
        </div>
      {/each}
    </div>

    <div class="lp-card lp-card-pad flex flex-col gap-3">
      <h3 class="text-sm font-semibold">LEAST (Paling Tidak Tepat)</h3>
      {#each leastScores as s}
        <div>
          <div class="mb-1 flex items-baseline justify-between text-xs">
            <span class="font-semibold">{s.label}</span>
            <span class="lp-muted">{s.value}</span>
          </div>
          <div class="lp-bar"><div style="width: {barWidth(s.value, maxLeast)}%; background: {dimColor(s.label)}"></div></div>
        </div>
      {/each}
    </div>

    <div class="lp-card lp-card-pad flex flex-col gap-3">
      <h3 class="text-sm font-semibold">DIF (Selisih)</h3>
      {#each difScores as s}
        <div>
          <div class="mb-1 flex items-baseline justify-between text-xs">
            <span class="font-semibold">{s.label}</span>
            <span class="lp-muted">{s.value}</span>
          </div>
          <div class="lp-bar">
            <div
              style="width: {barWidth(Math.abs(s.value), maxDif)}%; background: {s.value >= 0 ? dimColor(s.label) : 'var(--lp-least)'}"
            ></div>
          </div>
        </div>
      {/each}
    </div>
  </div>

  {#if r?.profileTitle}
    <div class="lp-card lp-card-pad flex flex-col gap-3">
      <div class="flex flex-wrap items-start justify-between gap-3">
        <div class="flex flex-col gap-0.5">
          <p class="lp-kicker">Kepribadian Asli / Sesungguhnya</p>
          <h3 class="lp-display text-2xl">{r.profileTitle}</h3>
        </div>
        <span class="lp-chip lp-chip-strong">DISC</span>
      </div>
      {#if difTraits.length > 0}
        <div class="flex flex-wrap gap-1.5">
          {#each difTraits as trait}
            <span class="lp-chip">{trait}</span>
          {/each}
        </div>
      {/if}
      <p class="lp-lead text-sm leading-relaxed">{r.profileDesc ?? ''}</p>
    </div>
  {/if}

  <div class="lp-grid lp-grid-2">
    <div class="lp-card lp-card-pad flex flex-col gap-2">
      <p class="lp-kicker">Kepribadian Saat di Publik</p>
      <h3 class="text-base font-semibold">{r?.mostProfileTitle ?? '-'}</h3>
      {#if mostTraits.length > 0}
        <div class="flex flex-wrap gap-1.5">
          {#each mostTraits as trait}
            <span class="lp-chip">{trait}</span>
          {/each}
        </div>
      {/if}
    </div>

    <div class="lp-card lp-card-pad flex flex-col gap-2">
      <p class="lp-kicker">Kepribadian Saat Mendapat Tekanan</p>
      <h3 class="text-base font-semibold">{r?.leastProfileTitle ?? '-'}</h3>
      {#if leastTraits.length > 0}
        <div class="flex flex-wrap gap-1.5">
          {#each leastTraits as trait}
            <span class="lp-chip">{trait}</span>
          {/each}
        </div>
      {/if}
    </div>
  </div>

  {#if r?.jobRecommendations}
    <div class="lp-card lp-card-pad flex flex-col gap-2">
      <h3 class="text-sm font-semibold">Job Match</h3>
      <p class="lp-lead text-sm leading-relaxed">{r.jobRecommendations}</p>
    </div>
  {/if}

</div>
