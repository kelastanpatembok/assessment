<script lang="ts">
  import { browser } from '$app/environment';
  import { enhance } from '$app/forms';
  import { getContext, onMount } from 'svelte';

  let { data, form } = $props();
  const examGuard = getContext<{ disarm: () => void }>('exam-guard');
  let draftKey = $derived(`epps-draft-${data.assignmentId ?? 'na'}`);
  const pageRanges = [
    [1, 8, '/epps/2.jpg'], [9, 24, '/epps/3.jpg'], [25, 41, '/epps/4.jpg'], [42, 57, '/epps/5.jpg'],
    [58, 75, '/epps/6.jpg'], [76, 93, '/epps/7.jpg'], [94, 111, '/epps/8.jpg'], [112, 127, '/epps/9.jpg'],
    [128, 144, '/epps/10.jpg'], [145, 161, '/epps/11.jpg'], [162, 178, '/epps/12.jpg'], [179, 194, '/epps/13.jpg'],
    [195, 212, '/epps/14.jpg'], [213, 225, '/epps/15.jpg']
  ] as const;
  let step = $state(0);
  let gender = $state('');
  let answers = $state<Record<number, 'A' | 'B'>>({});
  let ready = $state(false);
  let loading = $state(false);
  const current = $derived(pageRanges[step]);
  const numbers = $derived(Array.from({ length: current[1] - current[0] + 1 }, (_, i) => current[0] + i));
  const answered = $derived(Object.keys(answers).length);

  onMount(() => {
    try { const saved = JSON.parse(localStorage.getItem(draftKey) ?? 'null'); if (saved) { answers = saved.answers ?? {}; gender = saved.gender ?? ''; step = saved.step ?? 0; } } catch { /* start fresh */ }
    ready = true;
  });
  $effect(() => { if (browser && ready) localStorage.setItem(draftKey, JSON.stringify({ answers, gender, step })); });
  function choose(no: number, choice: 'A' | 'B') { answers = { ...answers, [no]: choice }; }
  function done() { localStorage.removeItem(draftKey); examGuard?.disarm(); }
</script>

<svelte:head><title>Tes EPPS</title></svelte:head>
<div class="lp-wrap flex flex-col gap-6">
  <header><p class="lp-kicker">Edwards Personal Preference Schedule</p><h2 class="lp-display text-3xl sm:text-4xl">Tes EPPS</h2></header>
  {#if data.unavailable}
    <div class="lp-card lp-card-pad"><p>Tes EPPS belum tersedia atau sudah diselesaikan.</p><a class="lp-btn lp-btn-outline mt-3" href="/student-dashboard">Kembali</a></div>
  {:else}
    <form method="POST" use:enhance={() => { loading = true; return async ({ result, update }) => { loading = false; if (result.type === 'redirect') done(); await update(); }; }}>
      <input type="hidden" name="assignmentId" value={data.assignmentId ?? 0} />
      <input type="hidden" name="gender" value={gender} />
      {#each Object.entries(answers) as [no, choice]}<input type="hidden" name="answer_{no}" value={choice} />{/each}
      {#if step === 0}
        <section class="lp-card lp-card-pad flex flex-col gap-4"><h3 class="lp-display text-xl">Petunjuk</h3><p class="lp-lead">Tes ini berisi 225 pasangan pernyataan. Pada setiap nomor, baca pilihan A dan B pada lembar soal, lalu pilih satu pernyataan yang paling menggambarkan diri Anda. Tidak ada jawaban benar atau salah.</p><label class="flex flex-col gap-2 max-w-sm"><span class="font-medium">Jenis kelamin</span><select class="lp-input" bind:value={gender} required><option value="">Pilih</option><option value="LAKI-LAKI">Laki-Laki</option><option value="PEREMPUAN">Perempuan</option></select></label></section>
      {:else}
        <section class="lp-card lp-card-pad flex flex-col gap-4"><div class="flex justify-between gap-3"><h3 class="font-semibold">Nomor {current[0]}–{current[1]}</h3><span class="lp-muted text-xs">{answered}/225 terjawab</span></div><p class="lp-muted text-sm">Baca pasangan pernyataan pada lembar berikut, lalu pilih A atau B untuk setiap nomor.</p><img class="epps-sheet" src={current[2]} alt="Lembar soal EPPS nomor {current[0]} sampai {current[1]}" /><div class="grid gap-2 sm:grid-cols-2">{#each numbers as no}<fieldset class="epps-answer"><legend>{no}</legend><label><input type="radio" checked={answers[no] === 'A'} onchange={() => choose(no, 'A')} /> A</label><label><input type="radio" checked={answers[no] === 'B'} onchange={() => choose(no, 'B')} /> B</label></fieldset>{/each}</div></section>
      {/if}
      {#if form?.error}<p class="lp-error">{form.error}</p>{/if}
      <div class="flex justify-between gap-3"><button class="lp-btn lp-btn-outline" type="button" disabled={step === 0} onclick={() => step--}>Sebelumnya</button>{#if step < pageRanges.length}<button class="lp-btn lp-btn-primary" type="button" disabled={step === 0 && !gender} onclick={() => step++}>Selanjutnya</button>{:else}<button class="lp-btn lp-btn-primary" type="submit" disabled={loading || answered !== 225}>{loading ? 'Mengirim...' : 'Kirim Jawaban'}</button>{/if}</div>
    </form>
  {/if}
</div>
<style>.epps-sheet { width: 100%; border: 1px solid var(--lp-rule); border-radius: .75rem; } .epps-answer { display:flex; align-items:center; gap:1rem; border:1px solid var(--lp-rule); border-radius:.5rem; padding:.5rem .75rem; } .epps-answer legend { font-weight:600; padding-right:.4rem; } .epps-answer label { display:flex; gap:.3rem; align-items:center; }</style>
