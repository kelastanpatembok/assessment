<script lang="ts">
  import { enhance } from '$app/forms';
  import { dev, browser } from '$app/environment';
  import { getContext, onMount, tick } from 'svelte';

  let { data, form } = $props();
  let loading = $state(false);
  let currentStep = $state(0);
  let formEl: HTMLFormElement | undefined = $state();

  const examGuard = getContext<{ disarm: () => void }>('exam-guard');
  let draftKey = $derived(`papi-draft-${data.assignmentId ?? 'na'}`);

  type Pair = { pairNo: number; stmtA: string; stmtB: string; traitA: string; traitB: string };

  type Step = { kind: 'intro' } | { kind: 'form'; pair: Pair };

  let allPairs: Pair[] = $derived(data.pairs ?? []);

  let steps: Step[] = $derived.by(() => {
    const s: Step[] = [{ kind: 'intro' }];
    for (const pair of allPairs) s.push({ kind: 'form', pair });
    return s;
  });
  let totalSteps = $derived(steps.length);
  let totalQuestions = $derived(allPairs.length);

  // Track selections: pairNo → 'A' | 'B'
  let selections = $state<Record<number, 'A' | 'B'>>({});

  function selectChoice(pairNo: number, choice: 'A' | 'B') {
    selections = { ...selections, [pairNo]: choice };
  }

  let currentStepAnswered = $derived.by(() => {
    const step = steps[currentStep];
    if (!step || step.kind !== 'form') return true;
    return selections[step.pair.pairNo] !== undefined;
  });

  let answeredCount = $derived(Object.keys(selections).length);

  // Draft autosave: answers only reach the server on final submit, so an
  // accidental refresh/close would otherwise lose all progress. Restore on
  // mount, persist on every change, clear once the test is actually submitted.
  let draftHydrated = $state(false);

  onMount(() => {
    if (!browser) return;
    try {
      const raw = localStorage.getItem(draftKey);
      if (raw) {
        const parsed = JSON.parse(raw);
        if (parsed?.selections) selections = parsed.selections;
        if (typeof parsed?.currentStep === 'number') currentStep = parsed.currentStep;
      }
    } catch {
      // corrupt/unavailable draft — ignore and start fresh
    }
    draftHydrated = true;
  });

  $effect(() => {
    if (!browser || !draftHydrated) return;
    const snapshot = JSON.stringify({ selections, currentStep });
    localStorage.setItem(draftKey, snapshot);
  });

  function clearDraft() {
    if (!browser) return;
    localStorage.removeItem(draftKey);
  }

  function goNext() {
    if (currentStep < totalSteps - 1) currentStep += 1;
  }
  function goPrev() {
    if (currentStep > 0) currentStep -= 1;
  }

  // Dev-only helper: pressing "x" fills the current step with a random
  // choice and advances, so manual QA can blast through all 90 pairs.
  async function devFillRandomAndAdvance() {
    if (loading) return;
    const step = steps[currentStep];
    if (step?.kind === 'form') {
      selectChoice(step.pair.pairNo, Math.random() < 0.5 ? 'A' : 'B');
    }
    if (currentStep < totalSteps - 1) {
      currentStep += 1;
    } else {
      await tick();
      formEl?.requestSubmit();
    }
  }

  // Dev-only helper: pressing "y" always picks statement A and advances — a
  // deterministic run (PAPI is ipsative/forced-choice, so there's no single
  // "correct" or "maximum" answer; always-A instead gives a reproducible,
  // maximally one-sided trait profile) useful for QA'ing the result page
  // instead of X's random (roughly balanced) profile.
  async function devFillHighAndAdvance() {
    if (loading) return;
    const step = steps[currentStep];
    if (step?.kind === 'form') {
      selectChoice(step.pair.pairNo, 'A');
    }
    if (currentStep < totalSteps - 1) {
      currentStep += 1;
    } else {
      await tick();
      formEl?.requestSubmit();
    }
  }

  function handleDevKeydown(e: KeyboardEvent) {
    if (!dev) return;
    const key = e.key.toLowerCase();
    if (key === 'x') {
      e.preventDefault();
      devFillRandomAndAdvance();
    } else if (key === 'y') {
      e.preventDefault();
      devFillHighAndAdvance();
    }
  }
</script>

<svelte:head><title>Tes PAPI Kostick</title></svelte:head>
<svelte:window onkeydown={handleDevKeydown} />

<div class="lp-wrap flex flex-col gap-6">
  <header class="flex flex-col gap-1.5">
    <p class="lp-kicker">Tes Kepribadian Kerja PAPI Kostick</p>
    <h2 class="lp-display text-3xl sm:text-4xl">Tes PAPI Kostick</h2>
    {#if dev}
      <p class="mt-1 text-xs" style="color: var(--lp-ink-2)">
        Mode pengembangan: tekan <kbd class="lp-kbd">X</kbd> untuk memilih jawaban acak dan lanjut otomatis, atau
        <kbd class="lp-kbd">Y</kbd> untuk selalu memilih pernyataan A dan lanjut otomatis (profil sepihak untuk QA).
      </p>
    {/if}
  </header>

  {#if data.unavailable}
    <div class="lp-card lp-card-pad flex flex-col gap-3">
      <p class="lp-lead text-sm">Tes PAPI belum tersedia atau sudah Anda selesaikan.</p>
      <a href="/student-dashboard" class="lp-btn lp-btn-outline lp-btn-sm self-start">Kembali ke Dashboard</a>
    </div>
  {:else if form?.error}
    <div class="lp-error">{form.error}</div>
  {:else if allPairs.length === 0}
    <div class="lp-card lp-card-pad"><p class="lp-lead text-sm">Tidak ada soal tersedia.</p></div>
  {:else}
    <form
      method="POST"
      bind:this={formEl}
      use:enhance={() => {
        loading = true;
        return async ({ result, update }) => {
          loading = false;
          if (result.type === 'redirect') {
            examGuard?.disarm();
            clearDraft();
          }
          await update();
        };
      }}
    >
      <input type="hidden" name="assignmentId" value={data.assignmentId ?? 0} />

      {#each steps as step, si}
        <div class={si === currentStep ? 'block' : 'hidden'}>
          {#if step.kind === 'intro'}
            <div class="lp-card lp-card-pad flex flex-col gap-3">
              <h3 class="lp-display text-xl">Petunjuk Pengerjaan</h3>
              <div class="flex flex-col gap-3 text-sm">
                <p class="lp-lead">
                  Tes ini terdiri dari {totalQuestions} nomor. Setiap nomor berisi dua pernyataan (A dan B) mengenai
                  keadaan diri Anda.
                </p>
                <p class="lp-lead">
                  Pilihlah satu pernyataan yang paling sesuai dengan keadaan diri Anda. Jika kedua pernyataan sama-sama
                  terasa sesuai, tetap pilih satu yang paling menggambarkan diri Anda — tidak ada jawaban benar atau
                  salah.
                </p>
                <p class="font-medium">Selamat mengerjakan!</p>
                <p class="lp-muted text-xs">Kerjakan dengan teliti, jangan sampai ada nomor yang terlewati.</p>
              </div>
            </div>
          {:else if step.kind === 'form'}
            {@const pair = step.pair}
            <div class="lp-card lp-card-pad flex flex-col gap-4">
              <div class="flex items-baseline justify-between gap-3">
                <h3 class="font-semibold">Pertanyaan {pair.pairNo} dari {totalQuestions}</h3>
                <span class="lp-muted text-xs">{answeredCount}/{totalQuestions} terjawab</span>
              </div>
              <p class="lp-muted text-sm">Pilih satu pernyataan yang lebih tepat menggambarkan Anda:</p>
              <div class="flex flex-col gap-3">
                <label class="lp-choice" class:selected={selections[pair.pairNo] === 'A'}>
                  <input
                    type="radio"
                    name="pair_{pair.pairNo}"
                    value="A"
                    checked={selections[pair.pairNo] === 'A'}
                    onchange={() => selectChoice(pair.pairNo, 'A')}
                    class="sr-only"
                    required
                  />
                  <span class="lp-choice-dot" aria-hidden="true"></span>
                  <span class="lp-choice-label">{pair.stmtA}</span>
                </label>
                <label class="lp-choice" class:selected={selections[pair.pairNo] === 'B'}>
                  <input
                    type="radio"
                    name="pair_{pair.pairNo}"
                    value="B"
                    checked={selections[pair.pairNo] === 'B'}
                    onchange={() => selectChoice(pair.pairNo, 'B')}
                    class="sr-only"
                    required
                  />
                  <span class="lp-choice-dot" aria-hidden="true"></span>
                  <span class="lp-choice-label">{pair.stmtB}</span>
                </label>
              </div>
            </div>
          {/if}
        </div>
      {/each}

      <div class="mt-4 flex flex-col gap-3">
        <div class="lp-muted flex items-center justify-between text-sm">
          <span>Langkah {currentStep + 1} dari {totalSteps} · {answeredCount}/{totalQuestions} pernyataan terjawab</span>
          <span>{Math.round(((currentStep + 1) / totalSteps) * 100)}%</span>
        </div>
        <div class="lp-progress"><div style="width: {((currentStep + 1) / totalSteps) * 100}%"></div></div>

        <div class="mt-1 flex items-center justify-between gap-3">
          <button type="button" class="lp-btn lp-btn-outline" disabled={currentStep === 0} onclick={goPrev}>
            Sebelumnya
          </button>

          {#if currentStep < totalSteps - 1}
            <button type="button" class="lp-btn lp-btn-primary" disabled={!currentStepAnswered} onclick={goNext}>
              Selanjutnya
            </button>
          {:else}
            <button
              type="submit"
              class="lp-btn lp-btn-primary"
              disabled={loading || !currentStepAnswered || answeredCount < totalQuestions}
            >
              {loading ? 'Mengirim...' : 'Kirim Jawaban'}
            </button>
          {/if}
        </div>
      </div>
    </form>
  {/if}
</div>
