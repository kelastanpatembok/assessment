<script lang="ts">
  import { enhance } from '$app/forms';
  import { dev } from '$app/environment';
  import { getContext, tick } from 'svelte';
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';

  let { data, form } = $props();
  let loading = $state(false);
  let formEl: HTMLFormElement | undefined = $state();
  const examGuard = getContext<{ disarm: () => void }>('exam-guard');
  let activeSubtest = $state(0);

  type CfitQuestion = {
    id: number;
    subtestNo: number;
    itemNo: number;
    stemImageUrl?: string | null;
    optionImages: string[];
  };

  type Subtest = { key: string; label: string; subtestNo: number; questions: CfitQuestion[] };
  let subtests: Subtest[] = $derived(data.subtests ?? []);
  let total = $derived(subtests.length);

  function fieldKey(q: CfitQuestion): string {
    return `st${q.subtestNo}_q${q.itemNo}`;
  }

  function optionLetter(index: number): string {
    return String.fromCharCode(97 + index);
  }

  // Subtest 2 (Classification) has no stem image and requires picking exactly 2 options
  // that match each other — every other subtest is a single-pick radio group.
  let checkedOptions: Record<string, string[]> = $state({});

  function isChecked(key: string, letter: string): boolean {
    return (checkedOptions[key] ?? []).includes(letter);
  }

  function isDisabled(key: string, letter: string): boolean {
    const current = checkedOptions[key] ?? [];
    return current.length >= 2 && !current.includes(letter);
  }

  function toggleOption(key: string, letter: string, checked: boolean) {
    const current = checkedOptions[key] ?? [];
    if (checked) {
      if (current.length < 2) checkedOptions[key] = [...current, letter];
    } else {
      checkedOptions[key] = current.filter((l) => l !== letter);
    }
  }

  let subtest2Complete = $derived(
    subtests
      .flatMap((st) => st.questions)
      .filter((q) => q.subtestNo === 2)
      .every((q) => (checkedOptions[fieldKey(q)] ?? []).length === 2)
  );

  // Dev-only helper: pressing "x" fills every question in the current subtest
  // tab with a random option and advances, so manual QA can blast through
  // all 4 subtests without clicking through every image.
  function devFillRandomAndAdvance() {
    if (loading) return;
    const st = subtests[activeSubtest];
    if (st) {
      for (const q of st.questions) {
        const key = fieldKey(q);
        const n = q.optionImages.length;
        if (n === 0) continue;
        if (q.subtestNo === 2) {
          const indices = [...Array(n).keys()];
          for (let i = indices.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [indices[i], indices[j]] = [indices[j], indices[i]];
          }
          checkedOptions[key] = indices.slice(0, Math.min(2, n)).map(optionLetter);
        } else {
          const letter = optionLetter(Math.floor(Math.random() * n));
          const radio = formEl?.querySelector<HTMLInputElement>(
            `input[type="radio"][name="${key}"][value="${letter}"]`
          );
          if (radio) radio.checked = true;
        }
      }
    }
    if (activeSubtest < total - 1) {
      activeSubtest += 1;
    } else {
      tick().then(() => formEl?.requestSubmit());
    }
  }

  function handleDevKeydown(e: KeyboardEvent) {
    if (!dev) return;
    if (e.key.toLowerCase() !== 'x') return;
    e.preventDefault();
    devFillRandomAndAdvance();
  }
</script>

<svelte:head><title>Tes IQ CFIT</title></svelte:head>
<svelte:window onkeydown={handleDevKeydown} />

<div class="flex max-w-3xl flex-col gap-6">
  <div>
    <h2 class="text-2xl font-bold">Tes IQ CFIT</h2>
    <p class="text-muted-foreground mt-1 text-sm">
      Jawab setiap soal dengan memilih jawaban yang paling tepat.
    </p>
    {#if dev}
      <p class="mt-1 text-xs text-amber-600">
        Dev mode: tekan <kbd class="rounded border px-1">X</kbd> untuk mengisi subtes ini secara acak dan lanjut otomatis.
      </p>
    {/if}
  </div>

  {#if data.unavailable}
    <Card>
      <CardContent class="pt-6">
        <p class="text-muted-foreground">Tes CFIT belum tersedia atau sudah Anda selesaikan.</p>
        <a href="/student-dashboard" class="text-primary mt-4 block text-sm hover:underline">Kembali ke Dashboard</a>
      </CardContent>
    </Card>
  {:else if form?.error}
    <div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">{form.error}</div>
  {:else if subtests.length === 0}
    <Card><CardContent class="pt-6"><p class="text-muted-foreground">Tidak ada soal tersedia.</p></CardContent></Card>
  {:else}
    <!-- Subtest tabs -->
    <div class="flex gap-2">
      {#each subtests as st, i}
        <button
          type="button"
          class="rounded-lg px-4 py-2 text-sm transition-colors {activeSubtest === i ? 'bg-primary text-primary-foreground' : 'bg-secondary text-secondary-foreground hover:bg-secondary/80'}"
          onclick={() => (activeSubtest = i)}
        >{st.label}</button>
      {/each}
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
          {#each st.questions as q, qi}
            <Card>
              <CardHeader>
                <CardTitle class="text-sm font-medium">
                  {st.label} — Soal {qi + 1}
                  {#if q.subtestNo === 2}
                    <span class="text-muted-foreground ml-2 font-normal">(pilih tepat 2 gambar yang berpasangan)</span>
                  {/if}
                </CardTitle>
              </CardHeader>
              <CardContent>
                {#if q.stemImageUrl}
                  <div class="mb-4">
                    <img src={q.stemImageUrl} alt="Soal {qi + 1}" class="h-auto max-w-xs rounded-lg border" />
                  </div>
                {/if}
                <div class="grid grid-cols-3 gap-2 sm:grid-cols-6">
                  {#each q.optionImages as optImg, oi}
                    {@const letter = optionLetter(oi)}
                    {@const key = fieldKey(q)}
                    <label
                      class="hover:bg-accent flex cursor-pointer flex-col items-center gap-1 rounded-lg border p-2 text-xs {isDisabled(key, letter) ? 'opacity-40' : ''}"
                    >
                      {#if q.subtestNo === 2}
                        <input
                          type="checkbox"
                          name="{key}[]"
                          value={letter}
                          class="size-4 shrink-0"
                          checked={isChecked(key, letter)}
                          disabled={isDisabled(key, letter)}
                          onchange={(e) => toggleOption(key, letter, e.currentTarget.checked)}
                        />
                      {:else}
                        <input type="radio" name={key} value={letter} class="size-4 shrink-0" required />
                      {/if}
                      <img src={optImg} alt="Opsi {letter}" class="h-16 w-auto rounded border" />
                      <span>{letter}</span>
                    </label>
                  {/each}
                </div>
              </CardContent>
            </Card>
          {/each}
        </div>
      {/each}

      <div class="flex items-center justify-between">
        <Button
          type="button"
          variant="outline"
          disabled={activeSubtest === 0}
          onclick={() => (activeSubtest = Math.max(0, activeSubtest - 1))}
        >Sebelumnya</Button>

        {#if activeSubtest < total - 1}
          <Button type="button" onclick={() => (activeSubtest = Math.min(total - 1, activeSubtest + 1))}>
            Selanjutnya
          </Button>
        {:else}
          <div class="flex flex-col items-end gap-1">
            <Button type="submit" disabled={loading || !subtest2Complete}>
              {loading ? 'Mengirim...' : 'Kirim Semua Jawaban'}
            </Button>
            {#if !subtest2Complete}
              <span class="text-destructive text-xs">Lengkapi Subtes 2: pilih tepat 2 gambar di setiap soal.</span>
            {/if}
          </div>
        {/if}
      </div>
    </form>
  {/if}
</div>
