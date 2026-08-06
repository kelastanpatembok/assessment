<script lang="ts">
  import CertificateCard from '$lib/components/certificate/CertificateCard.svelte';

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

<div class="lp-wrap flex flex-col gap-6">
  <nav aria-label="Breadcrumb" class="lp-crumbs">
    <a href="/student-dashboard">Dashboard</a>
    <span aria-hidden="true">/</span>
    <span>Hasil Tes IQ CFIT</span>
  </nav>

  <header class="flex flex-col gap-1">
    <p class="lp-kicker">Hasil Kecerdasan IQ CFIT</p>
    <h2 class="lp-display text-3xl sm:text-4xl">Hasil Tes IQ CFIT</h2>
    <p class="lp-lead text-sm">{r?.studentName} · {r?.schoolName ?? '-'}</p>
  </header>

  <div class="lp-grid lp-grid-3">
    <div class="lp-card lp-card-pad flex flex-col gap-1">
      <p class="lp-muted text-sm font-medium">Skor Total (RS)</p>
      <p class="lp-display text-3xl">{r?.totalScore ?? '-'}</p>
    </div>
    <div class="lp-card lp-card-pad flex flex-col gap-2">
      <p class="lp-muted text-sm font-medium">Kategori</p>
      <div>
        <span class="lp-chip lp-chip-strong text-sm">{r?.category ?? '-'}</span>
      </div>
    </div>
  </div>

  <div class="lp-card lp-card-pad flex flex-col gap-3">
    <h3 class="text-base font-semibold">Skor Per Subtes</h3>
    <table class="lp-table">
      <thead>
        <tr>
          <th>Subtes</th>
          <th class="num">Skor</th>
        </tr>
      </thead>
      <tbody>
        {#each subtestScores as s}
          <tr>
            <td>{s.label}</td>
            <td class="num">{s.value}</td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>

  {#if r?.description}
    <div class="lp-card lp-card-pad flex flex-col gap-2">
      <h3 class="text-base font-semibold">Deskripsi</h3>
      <p class="lp-lead text-sm leading-relaxed">{r.description}</p>
    </div>
  {/if}

  <CertificateCard
    testKey="cfit"
    testName="Tes Kecerdasan IQ CFIT"
    testDescription="Culture Fair Intelligence Test — empat subtes untuk mengukur kecerdasan umum."
    resultLabel="Skor IQ"
    resultLines={[
      r?.totalScore != null ? `Skor total (RS): ${r.totalScore}` : '',
      r?.category ? `Kategori: ${r.category}` : ''
    ].filter(Boolean)}
    studentId={data.user?.userId}
    studentName={data.profile?.name ?? 'Peserta'}
    avatarUrl={data.profile?.avatarUrl ?? null}
  />
</div>
