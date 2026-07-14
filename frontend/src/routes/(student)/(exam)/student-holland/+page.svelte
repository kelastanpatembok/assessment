<script lang="ts">
  import { enhance } from '$app/forms';
  import { dev, browser } from '$app/environment';
  import { getContext, onMount, tick } from 'svelte';
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Progress } from '$lib/components/ui/progress/index.js';

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

  function handleDevKeydown(e: KeyboardEvent) {
    if (!dev) return;
    if (e.key.toLowerCase() !== 'x') return;
    e.preventDefault();
    devFillRandomAndAdvance();
  }
</script>

<svelte:head><title>Tes Holland RIASEC</title></svelte:head>
<svelte:window onkeydown={handleDevKeydown} />

<div class="flex max-w-2xl flex-col gap-6">
  <div>
    <h2 class="text-2xl font-bold">Tes Holland RIASEC</h2>
    {#if dev}
      <p class="mt-1 text-xs text-amber-600">
        Dev mode: tekan <kbd class="rounded border px-1">X</kbd> untuk mengisi jawaban acak dan lanjut otomatis.
      </p>
    {/if}
  </div>

  {#if data.unavailable}
    <Card>
      <CardContent class="pt-6">
        <p class="text-muted-foreground">Tes Holland belum tersedia atau sudah Anda selesaikan.</p>
        <a href="/student-dashboard" class="text-primary mt-4 block text-sm hover:underline">Kembali ke Dashboard</a>
      </CardContent>
    </Card>
  {:else if form?.error}
    <div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">{form.error}</div>
  {:else if allQuestions.length === 0}
    <Card><CardContent class="pt-6"><p class="text-muted-foreground">Tidak ada soal tersedia.</p></CardContent></Card>
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
            <Card>
              <CardHeader>
                <CardTitle class="text-lg">Pengantar</CardTitle>
              </CardHeader>
              <CardContent class="flex flex-col gap-3 text-sm">
                <p>
                  Pada tiap-tiap bagian berikut ini terdapat berbagai pilihan pekerjaan dan situasi
                  pekerjaan yang mungkin akan bersesuaian dengan minat, kompetensi, dan pilihan karir Anda.
                </p>
                <p>
                  Bacalah petunjuk pengisian pada masing-masing bagian. Tidak ada jawaban yang salah.
                  Oleh karena itu isilah sesuai dengan keadaan diri Anda yang sesungguhnya, dan
                  lengkapilah jawaban Anda pada semua butir pernyataan.
                </p>
                <p class="font-medium">Selamat mengerjakan!</p>
                <p class="text-muted-foreground mt-2 text-xs">
                  Tes ini terdiri dari 3 bagian (Minat, Kemampuan, dan Pilihan Karir), masing-masing
                  mencakup 6 kelompok RIASEC (Realistic, Investigative, Artistic, Social, Enterprising,
                  Conventional) dengan 11 pernyataan per kelompok — total {totalQuestions} pernyataan.
                </p>
              </CardContent>
            </Card>
          {:else if step.kind === 'round-intro'}
            {@const meta = ROUND_META[step.round]}
            <Card>
              <CardHeader>
                <CardTitle class="text-lg">{meta.title}</CardTitle>
                <p class="text-muted-foreground text-sm">{meta.subtitle}</p>
              </CardHeader>
              <CardContent class="flex flex-col gap-4 text-sm">
                <p>Petunjuk Pengisian: {meta.instruction}</p>
                <div>
                  <p class="mb-2 text-xs font-semibold">Pilihan jawaban pada bagian ini:</p>
                  <ol class="list-decimal space-y-1 pl-5">
                    {#each meta.scale as label}
                      <li>{label}</li>
                    {/each}
                  </ol>
                </div>
                <p class="text-muted-foreground text-xs">
                  Bagian ini mencakup 6 kelompok pernyataan (R, I, A, S, E, C), masing-masing 11
                  pernyataan. Kerjakan satu per satu mengikuti tombol Selanjutnya.
                </p>
              </CardContent>
            </Card>
          {:else if step.kind === 'form'}
            {@const meta = ROUND_META[step.round]}
            <Card>
              <CardHeader>
                <div class="flex items-center justify-between">
                  <CardTitle class="text-base">
                    {step.type} — {TYPE_NAMES[step.type]}
                  </CardTitle>
                  <span class="text-muted-foreground text-xs">{meta.subtitle}</span>
                </div>
                <p class="text-muted-foreground mt-1 text-xs">Petunjuk: {meta.instruction}</p>
              </CardHeader>
              <CardContent>
                <div class="mb-2 grid grid-cols-[1fr_repeat(5,2.75rem)] items-end gap-x-1 border-b pb-2">
                  <span></span>
                  {#each meta.scale as label, li}
                    <span class="text-muted-foreground text-center text-[10px] leading-tight">{li + 1}</span>
                  {/each}
                </div>
                {#each step.questions as q}
                  <div class="grid grid-cols-[1fr_repeat(5,2.75rem)] items-center gap-x-1 border-b py-3 last:border-0">
                    <span class="pr-2 text-sm">{q.statement}</span>
                    {#each [1, 2, 3, 4, 5] as val}
                      <div class="flex justify-center">
                        <input
                          type="radio"
                          name="q{q.id}_score"
                          value={val}
                          checked={selections[q.id] === val}
                          onchange={() => selectScore(q.id, val)}
                          class="size-4 cursor-pointer accent-primary"
                          required
                        />
                      </div>
                    {/each}
                  </div>
                {/each}
                <div class="text-muted-foreground mt-3 flex justify-between text-[10px]">
                  <span>1 = {meta.scale[0]}</span>
                  <span>5 = {meta.scale[4]}</span>
                </div>
              </CardContent>
            </Card>
          {/if}
        </div>
      {/each}

      <div class="mt-4 flex flex-col gap-2">
        <div class="text-muted-foreground flex items-center justify-between text-sm">
          <span>Langkah {currentStep + 1} dari {totalSteps} · {answeredCount}/{totalQuestions} pernyataan terjawab</span>
          <span>{Math.round(((currentStep + 1) / totalSteps) * 100)}%</span>
        </div>
        <Progress value={currentStep + 1} max={totalSteps} />

        <div class="mt-2 flex items-center justify-between">
          <Button type="button" variant="outline" disabled={currentStep === 0} onclick={goPrev}>
            Sebelumnya
          </Button>

          {#if currentStep < totalSteps - 1}
            <Button type="button" disabled={!currentStepAnswered} onclick={goNext}>Selanjutnya</Button>
          {:else}
            <Button type="submit" disabled={loading || !currentStepAnswered || answeredCount < totalQuestions}>
              {loading ? 'Mengirim...' : 'Kirim Jawaban'}
            </Button>
          {/if}
        </div>
      </div>
    </form>
  {/if}
</div>
