<script lang="ts">
  import { enhance } from '$app/forms';
  import { getContext, onMount, tick } from 'svelte';
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';

  let { data, form } = $props();
  let loading = $state(false);
  let formEl: HTMLFormElement | undefined = $state();
  const examGuard = getContext<{ disarm: () => void }>('exam-guard');
  let activeSubtest = $state(0);

  // WAKTU PENYAJIAN TEST: SE 6m, WA 6m, AN 7m, GE 8m, RA 10m, ZR 10m, FA 7m, WU 9m.
  // ME has two phases: 3m to read/study, then 6m to answer.
  // Per-subtest countdown: moving on (manually or on timeout) is one-way — once a
  // subtest is left, it can't be revisited, so there's no "Sebelumnya" button.
  const SUBTEST_DURATIONS_SEC: Record<string, number> = {
    SE: 360, WA: 360, AN: 420, GE: 480, RA: 600, ZR: 600, FA: 420, WU: 540,
  };
  const ME_MENGHAFAL_SEC = 180;
  const ME_MENGERJAKAN_SEC = 360;

  let mePhase: 'menghafal' | 'mengerjakan' = $state('menghafal');
  let remainingSeconds = $state(SUBTEST_DURATIONS_SEC.SE);
  let autoAdvancing = $state(false);

  function formatTime(sec: number): string {
    const m = Math.floor(sec / 60);
    const s = sec % 60;
    return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
  }

  function durationFor(index: number): number {
    const key = subtests[index]?.key;
    if (key === 'ME') return ME_MENGHAFAL_SEC;
    return SUBTEST_DURATIONS_SEC[key ?? ''] ?? 0;
  }

  function goToSubtest(index: number) {
    activeSubtest = index;
    mePhase = 'menghafal';
    remainingSeconds = durationFor(index);
  }

  function startMeMengerjakan() {
    mePhase = 'mengerjakan';
    remainingSeconds = ME_MENGERJAKAN_SEC;
  }

  function advanceOrSubmit() {
    const key = subtests[activeSubtest]?.key;
    if (key === 'ME' && mePhase === 'menghafal') {
      startMeMengerjakan();
      return;
    }
    if (activeSubtest < total - 1) {
      goToSubtest(activeSubtest + 1);
    } else if (!autoAdvancing) {
      autoAdvancing = true;
      tick().then(() => formEl?.requestSubmit());
    }
  }

  onMount(() => {
    const id = setInterval(() => {
      if (loading || autoAdvancing || subtests.length === 0) return;
      if (remainingSeconds <= 1) {
        remainingSeconds = 0;
        advanceOrSubmit();
      } else {
        remainingSeconds -= 1;
      }
    }, 1000);
    return () => clearInterval(id);
  });

  type IstQuestion = {
    id: number;
    subtestCode?: string; // absent for ZR (its own table/endpoint) — fall back to the subtest key
    itemNo: number;
    questionText?: string | null;
    sequenceText?: string | null; // ZR only
    imageUrl?: string | null;
    options?: Record<string, string> | null;
    optionImages?: string[] | null;
  };

  type Subtest = { key: string; label: string; questions: IstQuestion[] };
  let subtests: Subtest[] = $derived(data.subtests ?? []);
  let total = $derived(subtests.length);

  // ZR: numeric text input. FA/WU: image MC. Everything else: text MC (or free-text
  // fallback when no options are seeded, e.g. SE/WA/AN/GE/RA placeholder content).
  function isZR(key: string) { return key === 'ZR'; }
  function isImageMC(q: IstQuestion) { return !!q.optionImages && q.optionImages.length > 0; }
  function optionLetter(index: number): string { return String.fromCharCode(97 + index); }
  function optionEntries(q: IstQuestion): [string, string][] {
    if (!q.options) return [];
    return Object.entries(q.options);
  }
</script>

<svelte:head><title>Tes IQ IST</title></svelte:head>

<div class="flex max-w-3xl flex-col gap-6">
  <div>
    <h2 class="text-2xl font-bold">Tes IQ IST</h2>
    <p class="text-muted-foreground mt-1 text-sm">
      Tes kecerdasan 9 subtes. Kerjakan setiap subtes dengan cermat.
    </p>
  </div>

  {#if data.unavailable}
    <Card>
      <CardContent class="pt-6">
        <p class="text-muted-foreground">Tes IST belum tersedia atau sudah Anda selesaikan.</p>
        <a href="/student-dashboard" class="text-primary mt-4 block text-sm hover:underline">Kembali ke Dashboard</a>
      </CardContent>
    </Card>
  {:else if form?.error}
    <div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">{form.error}</div>
  {:else if subtests.length === 0}
    <Card><CardContent class="pt-6"><p class="text-muted-foreground">Tidak ada soal tersedia.</p></CardContent></Card>
  {:else}
    <!-- Subtest progress — navigation is forward-only (timer-driven or manual Next),
         so these are indicators, not clickable tabs; going back isn't possible. -->
    <div class="flex items-center justify-between gap-2">
      <div class="flex flex-wrap gap-2">
        {#each subtests as st, i}
          <span
            class="rounded-lg px-3 py-1.5 text-sm
              {activeSubtest === i ? 'bg-primary text-primary-foreground' : i < activeSubtest ? 'bg-muted text-muted-foreground' : 'bg-secondary text-secondary-foreground'}"
          >{st.key}</span>
        {/each}
      </div>
      <div class="font-mono text-lg font-semibold {remainingSeconds <= 30 ? 'text-destructive' : ''}">
        {formatTime(remainingSeconds)}
        {#if subtests[activeSubtest]?.key === 'ME'}
          <span class="text-muted-foreground text-xs font-normal">({mePhase === 'menghafal' ? 'menghafal' : 'mengerjakan'})</span>
        {/if}
      </div>
    </div>

    <form
      method="POST"
      bind:this={formEl}
      use:enhance={() => {
        loading = true;
        return async ({ result, update }) => {
          loading = false;
          if (result.type === 'redirect') examGuard?.disarm();
          await update();
        };
      }}
      class="flex flex-col gap-4"
    >
      <input type="hidden" name="assignmentId" value={data.assignmentId ?? 0} />
      {#each subtests as st, si}
        <div class={si === activeSubtest ? 'flex flex-col gap-4' : 'hidden'}>
          <Card>
            <CardHeader>
              <CardTitle class="text-base">Subtes {st.key}</CardTitle>
            </CardHeader>
            <CardContent>
              {#if st.key === 'ME' && mePhase === 'menghafal'}
                <!-- ME menghafal phase: read-only study view, no inputs yet.
                     Real ME content/pairs aren't sourced yet (see docs/todo-ist-test.md),
                     so this is a timed read-through of the placeholder items. -->
                <p class="text-muted-foreground mb-4 text-sm">
                  Bacalah dan ingat soal-soal berikut. Anda akan menjawabnya setelah waktu menghafal habis.
                </p>
                <div class="flex flex-col gap-2">
                  {#each st.questions as q, qi}
                    <p class="text-sm">{qi + 1}. {q.questionText ?? ''}</p>
                  {/each}
                </div>
              {:else}
              {#each st.questions as q, qi}
                <div class="border-border border-b pb-4 last:border-0 last:pb-0 {qi > 0 ? 'pt-4' : ''}">
                  {#if q.questionText || q.sequenceText}
                    <p class="mb-3 text-sm font-medium">{qi + 1}. {q.questionText ?? q.sequenceText}</p>
                  {:else}
                    <p class="mb-3 text-sm font-medium">{qi + 1}.</p>
                  {/if}

                  {#if isImageMC(q)}
                    <!-- FA/WU: image stem + image options -->
                    {#if q.imageUrl}
                      <div class="mb-3">
                        <img src={q.imageUrl} alt="Soal {qi + 1}" class="h-auto max-w-xs rounded-lg border" />
                      </div>
                    {/if}
                    <div class="grid grid-cols-3 gap-2 sm:grid-cols-5">
                      {#each q.optionImages ?? [] as optImg, oi}
                        {@const letter = optionLetter(oi)}
                        <label class="hover:bg-accent flex cursor-pointer flex-col items-center gap-1 rounded-lg border p-2 text-xs">
                          <input
                            type="radio"
                            name="ist_{q.subtestCode ?? st.key}_{q.itemNo}"
                            value={letter}
                            class="size-4 shrink-0"
                          />
                          <img src={optImg} alt="Opsi {letter}" class="h-16 w-auto rounded border" />
                          <span>{letter}</span>
                        </label>
                      {/each}
                    </div>
                  {:else if isZR(st.key)}
                    <!-- ZR: text input -->
                    <input
                      type="text"
                      name="ist_{q.subtestCode ?? st.key}_{q.itemNo}"
                      placeholder="Jawaban Anda..."
                      class="border-input bg-background flex h-10 w-full max-w-xs rounded-lg border px-3 text-sm"
                    />
                  {:else if optionEntries(q).length > 0}
                    <!-- MC options -->
                    <div class="grid grid-cols-2 gap-2 sm:grid-cols-5">
                      {#each optionEntries(q) as [optKey, optVal]}
                        <label class="hover:bg-accent flex cursor-pointer items-center gap-2 rounded-lg border p-2 text-sm">
                          <input
                            type="radio"
                            name="ist_{q.subtestCode ?? st.key}_{q.itemNo}"
                            value={optKey}
                            class="size-4 shrink-0"
                          />
                          <span>{optKey}. {optVal}</span>
                        </label>
                      {/each}
                    </div>
                  {:else}
                    <!-- Text answer -->
                    <input
                      type="text"
                      name="ist_{q.subtestCode ?? st.key}_{q.itemNo}"
                      placeholder="Jawaban Anda..."
                      class="border-input bg-background flex h-10 w-full max-w-xs rounded-lg border px-3 text-sm"
                    />
                  {/if}
                </div>
              {/each}
              {/if}
            </CardContent>
          </Card>
        </div>
      {/each}

      <div class="flex items-center justify-between">
        <span class="text-muted-foreground text-sm">{activeSubtest + 1} / {total}</span>

        {#if activeSubtest < total - 1}
          <Button type="button" onclick={() => goToSubtest(activeSubtest + 1)}>Selanjutnya</Button>
        {:else if subtests[activeSubtest]?.key === 'ME' && mePhase === 'menghafal'}
          <Button type="button" onclick={startMeMengerjakan}>Lanjut ke Pengerjaan</Button>
        {:else}
          <Button type="submit" disabled={loading}>
            {loading ? 'Mengirim...' : 'Kirim Semua Jawaban'}
          </Button>
        {/if}
      </div>
    </form>
  {/if}
</div>
