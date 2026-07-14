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

  function handleDevKeydown(e: KeyboardEvent) {
    if (!dev) return;
    if (e.key.toLowerCase() !== 'x') return;
    e.preventDefault();
    devFillRandomAndAdvance();
  }
</script>

<svelte:head><title>Tes PAPI Kostick</title></svelte:head>
<svelte:window onkeydown={handleDevKeydown} />

<div class="flex max-w-2xl flex-col gap-6">
  <div>
    <h2 class="text-2xl font-bold">Tes PAPI Kostick</h2>
    {#if dev}
      <p class="mt-1 text-xs text-amber-600">
        Dev mode: tekan <kbd class="rounded border px-1">X</kbd> untuk memilih jawaban acak dan lanjut otomatis.
      </p>
    {/if}
  </div>

  {#if data.unavailable}
    <Card>
      <CardContent class="pt-6">
        <p class="text-muted-foreground">Tes PAPI belum tersedia atau sudah Anda selesaikan.</p>
        <a href="/student-dashboard" class="text-primary mt-4 block text-sm hover:underline">Kembali ke Dashboard</a>
      </CardContent>
    </Card>
  {:else if form?.error}
    <div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">{form.error}</div>
  {:else if allPairs.length === 0}
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
                <CardTitle class="text-lg">Petunjuk Pengerjaan</CardTitle>
              </CardHeader>
              <CardContent class="flex flex-col gap-3 text-sm">
                <p>
                  Tes ini terdiri dari {totalQuestions} nomor. Setiap nomor berisi dua pernyataan (A dan B)
                  mengenai keadaan diri Anda.
                </p>
                <p>
                  Pilihlah satu pernyataan yang paling sesuai dengan keadaan diri Anda. Jika kedua
                  pernyataan sama-sama terasa sesuai, tetap pilih satu yang paling menggambarkan diri
                  Anda — tidak ada jawaban benar atau salah.
                </p>
                <p class="font-medium">Selamat mengerjakan!</p>
                <p class="text-muted-foreground mt-2 text-xs">
                  Kerjakan dengan teliti, jangan sampai ada nomor yang terlewati.
                </p>
              </CardContent>
            </Card>
          {:else if step.kind === 'form'}
            {@const pair = step.pair}
            <Card>
              <CardHeader>
                <CardTitle class="text-base">Pertanyaan {pair.pairNo} dari {totalQuestions}</CardTitle>
              </CardHeader>
              <CardContent>
                <p class="text-muted-foreground mb-4 text-sm">Pilih satu pernyataan yang lebih tepat menggambarkan Anda:</p>
                <div class="flex flex-col gap-3">
                  <label class="hover:bg-accent flex cursor-pointer items-start gap-3 rounded-lg border p-4 transition-colors">
                    <input
                      type="radio"
                      name="pair_{pair.pairNo}"
                      value="A"
                      checked={selections[pair.pairNo] === 'A'}
                      onchange={() => selectChoice(pair.pairNo, 'A')}
                      class="mt-0.5 size-4 shrink-0"
                      required
                    />
                    <span class="text-sm">{pair.stmtA}</span>
                  </label>
                  <label class="hover:bg-accent flex cursor-pointer items-start gap-3 rounded-lg border p-4 transition-colors">
                    <input
                      type="radio"
                      name="pair_{pair.pairNo}"
                      value="B"
                      checked={selections[pair.pairNo] === 'B'}
                      onchange={() => selectChoice(pair.pairNo, 'B')}
                      class="mt-0.5 size-4 shrink-0"
                      required
                    />
                    <span class="text-sm">{pair.stmtB}</span>
                  </label>
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
