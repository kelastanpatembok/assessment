<script lang="ts">
  import { createApiClient } from '$lib/api/index';
  import { browser } from '$app/environment';
  let { data } = $props();
  let downloading = $state(false);
  async function download() {
    downloading = true;
    try {
      const api = createApiClient(data.token);
      const blob = await api.getBlob(`/psychological-reports/${data.assignment}/${data.studentId}/download`);
      const href = URL.createObjectURL(blob); const a = document.createElement('a'); a.href = href; a.download = 'laporan-psikologis.pdf'; a.click(); URL.revokeObjectURL(href);
    } finally { downloading = false; }
  }
</script>
<svelte:head><title>Hasil Laporan Psikologis</title></svelte:head>
<section class="report">
  <a href="/student-dashboard">← Kembali ke dashboard</a>
  <h1>Hasil Laporan Psikologis</h1><p>{data.report.studentName} · {data.report.schoolName}</p>
  {#each data.report.aspects as aspect}<article><h2>{aspect.label}</h2><p>{aspect.definition}</p><p><strong>{aspect.result}</strong></p></article>{/each}
  <article><h2>Minat karier (Holland RIASEC)</h2><p>{data.report.holland}</p></article>
  {#if browser}<button onclick={download} disabled={downloading}>{downloading ? 'Menyiapkan PDF…' : 'Unduh PDF resmi'}</button>{/if}
</section>
<style>.report{max-width:48rem;margin:auto;display:grid;gap:1rem}.report article{border:1px solid var(--lp-rule);border-radius:1rem;padding:1rem;background:white}.report h1,.report h2{font-family:var(--lp-font-display);margin:0}.report h2{font-size:1.15rem}.report p{margin:.45rem 0;color:var(--lp-ink-2)}button{justify-self:start;background:var(--lp-accent-deep);color:white;border:0;border-radius:.6rem;padding:.7rem 1rem;font:inherit}</style>
