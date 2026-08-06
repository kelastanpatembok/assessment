<script lang="ts">
  import { enhance } from '$app/forms';
  import { dev, browser } from '$app/environment';
  import { getContext, onMount, tick } from 'svelte';

  let { data, form } = $props();
  let loading = $state(false);
  let currentStep = $state(0);
  let formEl: HTMLFormElement | undefined = $state();

  const examGuard = getContext<{ disarm: () => void }>('exam-guard');
  let draftKey = $derived(`holland-draft-${data.assignmentId ?? 'na'}`);

  type HollandQuestion = {
    id: number;
    round: number; // 1 = Minat, 2 = Kemampuan, 3 = Pilihan Karir
    riasecType: string; // R | I | A | S | E | C
    itemNo: number;
    statement: string;
  };

  const TYPE_ORDER = ['R', 'I', 'A', 'S', 'E', 'C'] as const;
  const TYPE_NAMES: Record<string, string> = {
    R: 'Realistic',
    I: 'Investigative',
    A: 'Artistic',
    S: 'Social',
    E: 'Enterprising',
    C: 'Conventional',
  };

  const ROUND_META: Record<number, { title: string; subtitle: string; instruction: string; scale: string[] }> = {
    1: {
      title: 'Bagian 1 — Minat',
      subtitle: 'Minat (Interest)',
      instruction:
        'Berilah tanda pada masing-masing kegiatan atau situasi pekerjaan, sesuai dengan tingkat keinginan (Minat) Anda untuk mengerjakannya. Pilihlah satu di antara lima pilihan yang tersedia.',
      scale: [
        'Tidak pernah menginginkan',
        'Pernah menginginkan',
        'Kadang menginginkan',
        'Sering menginginkan',
        'Selalu Menginginkan',
      ],
    },
    2: {
      title: 'Bagian 2 — Kemampuan',
      subtitle: 'Kemampuan (Ability)',
      instruction:
        'Berilah tanda pada pekerjaan atau situasi pekerjaan di bawah ini sesuai dengan tingkat kemampuan Anda. Pilihlah satu di antara lima pilihan yang tersedia.',
      scale: [
        'Tidak mampu (Belum pernah mencoba)',
        'Sedikit memiliki kemampuan',
        'Agak menguasai',
        'Menguasai',
        'Sangat menguasai (Ahli)',
      ],
    },
    3: {
      title: 'Bagian 3 — Pilihan Karir',
      subtitle: 'Pilihan Karir (Career Choice)',
      instruction:
        'Berilah tanda pada jenis pekerjaan di bawah ini sesuai dengan tingkat keinginan Anda untuk menekuninya sebagai pekerjaan utama/karir, dengan asumsi semua bidang ini memberikan penghasilan yang tinggi.',
      scale: [
        'Tidak ingin menekuni',
        'Pernah ingin menekuni',
        'Kadang ingin menekuni',
        'Sering ingin menekuni',
        'Sangat ingin menekuni',
      ],
    },
  };

  type Step =
    | { kind: 'intro' }
    | { kind: 'round-intro'; round: number }
    | { kind: 'form'; round: number; type: string; questions: HollandQuestion[] };

  let allQuestions: HollandQuestion[] = $derived(data.questions ?? []);

  let steps: Step[] = $derived.by(() => {
    const s: Step[] = [{ kind: 'intro' }];
    for (const round of [1, 2, 3]) {
      s.push({ kind: 'round-intro', round });
      for (const type of TYPE_ORDER) {
        const qs = allQuestions
          .filter((q) => q.round === round && q.riasecType === type)
          .sort((a, b) => a.itemNo - b.itemNo);
        if (qs.length > 0) s.push({ kind: 'form', round, type, questions: qs });
      }
    }
    return s;
  });
  let totalSteps = $derived(steps.length);

  // Track selections: questionId → score (1-5)
  let selections = $state<Record<number, number>>({});

  function selectScore(questionId: number, score: number) {
    selections = { ...selections, [questionId]: score };
  }

  let currentStepAnswered = $derived.by(() => {
    const step = steps[currentStep];
    if (!step || step.kind !== 'form') return true;
    return step.questions.every((q) => selections[q.id] !== undefined);
  });

  let answeredCount = $derived(Object.keys(selections).length);
  let totalQuestions = $derived(allQuestions.length);

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

  // Dev-only helper: pressing "x" fills the current form step with random
  // scores and advances, so manual QA can blast through all 22 steps.
  async function devFillRandomAndAdvance() {
    if (loading) return;
    const step = steps[currentStep];
    if (step?.kind === 'form') {
      for (const q of step.questions) {
        selectScore(q.id, 1 + Math.floor(Math.random() * 5));
      }
    }
    if (currentStep < totalSteps - 1) {
      currentStep += 1;
    } else {
      await tick();
      formEl?.requestSubmit();
    }
  }

  // Dev-only helper: pressing "y" fills the current form step with the
  // highest scale value (5) on every statement and advances — a deterministic
  // run that maxes out every RIASEC type simultaneously, useful for QA'ing
  // the high end of the result page instead of X's random (roughly flat)
  // profile.
  async function devFillHighAndAdvance() {
    if (loading) return;
    const step = steps[currentStep];
    if (step?.kind === 'form') {
      for (const q of step.questions) {
        selectScore(q.id, 5);
      }
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

<svelte:head><title>Tes Holland RIASEC</title></svelte:head>
<svelte:window onkeydown={handleDevKeydown} />

<div class="lp-wrap flex flex-col gap-6">
  <header class="flex flex-col gap-1.5">
    <p class="lp-kicker">Tes Minat Karir RIASEC</p>
    <h2 class="lp-display text-3xl sm:text-4xl">Tes Holland RIASEC</h2>
    {#if dev}
      <p class="mt-1 text-xs" style="color: var(--lp-ink-2)">
        Mode pengembangan: tekan <kbd class="lp-kbd">X</kbd> untuk mengisi jawaban acak dan lanjut otomatis, atau
        <kbd class="lp-kbd">Y</kbd> untuk mengisi nilai tertinggi (5) di semua pernyataan (skor RIASEC maksimal).
      </p>
    {/if}
  </header>

  {#if data.unavailable}
    <div class="lp-card lp-card-pad flex flex-col gap-3">
      <p class="lp-lead text-sm">Tes Holland belum tersedia atau sudah Anda selesaikan.</p>
      <a href="/student-dashboard" class="lp-btn lp-btn-outline lp-btn-sm self-start">Kembali ke Dashboard</a>
    </div>
  {:else if form?.error}
    <div class="lp-error">{form.error}</div>
  {:else if allQuestions.length === 0}
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
              <h3 class="lp-display text-xl">Pengantar</h3>
              <div class="flex flex-col gap-3 text-sm">
                <p class="lp-lead">
                  Pada tiap-tiap bagian berikut ini terdapat berbagai pilihan pekerjaan dan situasi pekerjaan yang
                  mungkin akan bersesuaian dengan minat, kompetensi, dan pilihan karir Anda.
                </p>
                <p class="lp-lead">
                  Bacalah petunjuk pengisian pada masing-masing bagian. Tidak ada jawaban yang salah. Oleh karena itu
                  isilah sesuai dengan keadaan diri Anda yang sesungguhnya, dan lengkapilah jawaban Anda pada semua butir
                  pernyataan.
                </p>
                <p class="font-medium">Selamat mengerjakan!</p>
                <p class="lp-muted text-xs">
                  Tes ini terdiri dari 3 bagian (Minat, Kemampuan, dan Pilihan Karir), masing-masing mencakup 6 kelompok
                  RIASEC (Realistic, Investigative, Artistic, Social, Enterprising, Conventional) dengan 11 pernyataan
                  per kelompok — total {totalQuestions} pernyataan.
                </p>
              </div>
            </div>
          {:else if step.kind === 'round-intro'}
            {@const meta = ROUND_META[step.round]}
            <div class="lp-card lp-card-pad flex flex-col gap-3">
              <div class="flex flex-col gap-0.5">
                <h3 class="lp-display text-xl">{meta.title}</h3>
                <p class="lp-muted text-sm">{meta.subtitle}</p>
              </div>
              <p class="text-sm">Petunjuk Pengisian: {meta.instruction}</p>
              <div>
                <p class="lp-muted mb-2 text-xs font-semibold">Pilihan jawaban pada bagian ini:</p>
                <ol class="lp-lead list-decimal space-y-1 pl-5 text-sm">
                  {#each meta.scale as label}
                    <li>{label}</li>
                  {/each}
                </ol>
              </div>
              <p class="lp-muted text-xs">
                Bagian ini mencakup 6 kelompok pernyataan (R, I, A, S, E, C), masing-masing 11 pernyataan. Kerjakan satu
                per satu mengikuti tombol Selanjutnya.
              </p>
            </div>
          {:else if step.kind === 'form'}
            {@const meta = ROUND_META[step.round]}
            <div class="lp-card lp-card-pad flex flex-col gap-4">
              <div class="flex flex-wrap items-baseline justify-between gap-2">
                <h3 class="font-semibold">{step.type} — {TYPE_NAMES[step.type]}</h3>
                <span class="lp-muted text-xs">{meta.subtitle}</span>
              </div>
              <p class="lp-muted text-xs">Petunjuk: {meta.instruction}</p>

              <div class="holland-grid holland-head" aria-hidden="true">
                <span></span>
                {#each meta.scale as _, li}
                  <span class="holland-num">{li + 1}</span>
                {/each}
              </div>

              {#each step.questions as q}
                <div class="holland-grid holland-row">
                  <p class="holland-statement">{q.statement}</p>
                  <div class="holland-radios">
                    {#each [1, 2, 3, 4, 5] as val}
                      <label class="holland-opt" class:sel={selections[q.id] === val}>
                        <input
                          type="radio"
                          name="q{q.id}_score"
                          value={val}
                          checked={selections[q.id] === val}
                          onchange={() => selectScore(q.id, val)}
                          class="sr-only"
                          required
                        />
                        <span class="holland-dot" aria-hidden="true"></span>
                      </label>
                    {/each}
                  </div>
                </div>
              {/each}

              <div class="lp-muted flex justify-between text-xs">
                <span>1 = {meta.scale[0]}</span>
                <span>5 = {meta.scale[4]}</span>
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

<style>
  .holland-grid {
    display: grid;
    grid-template-columns: minmax(0, 1fr) repeat(5, 2.75rem);
    gap: 0.25rem;
    align-items: center;
  }

  .holland-head {
    border-bottom: 1px solid var(--lp-rule-2);
    padding-bottom: 0.4rem;
  }

  .holland-num {
    text-align: center;
    font-size: 0.72rem;
    font-weight: 650;
    color: var(--lp-muted);
  }

  .holland-row {
    padding: 0.55rem 0;
    border-bottom: 1px solid var(--lp-rule);
  }

  .holland-row:last-child {
    border-bottom: 0;
  }

  .holland-statement {
    font-size: 0.92rem;
    line-height: 1.5;
    min-width: 0;
    padding-right: 0.5rem;
  }

  .holland-radios {
    display: contents;
  }

  .holland-opt {
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: pointer;
    min-height: 2.25rem;
  }

  .holland-dot {
    width: 1.05rem;
    height: 1.05rem;
    border-radius: 999px;
    border: 2px solid var(--lp-rule-2);
    transition:
      background-color 200ms var(--lp-ease-out),
      border-color 200ms var(--lp-ease-out);
  }

  .holland-opt.sel .holland-dot {
    background: var(--lp-accent-deep);
    border-color: var(--lp-accent-deep);
  }

  @media (max-width: 40rem) {
    .holland-grid {
      grid-template-columns: minmax(0, 1fr);
    }

    .holland-head {
      display: none;
    }

    .holland-radios {
      display: grid;
      grid-template-columns: repeat(5, minmax(0, 1fr));
      gap: 0.35rem;
      margin-top: 0.5rem;
    }
  }
</style>
