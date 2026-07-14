<script lang="ts">
  import { enhance } from '$app/forms';
  import { getContext } from 'svelte';
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';

  let { data, form } = $props();
  let loading = $state(false);
  const examGuard = getContext<{ disarm: () => void }>('exam-guard');
  let activeSubtest = $state(0);

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
    <!-- Subtest nav -->
    <div class="flex flex-wrap gap-2">
      {#each subtests as st, i}
        <button
          type="button"
          class="rounded-lg px-3 py-1.5 text-sm transition-colors
            {activeSubtest === i ? 'bg-primary text-primary-foreground' : 'bg-secondary text-secondary-foreground hover:bg-secondary/80'}"
          onclick={() => (activeSubtest = i)}
        >{st.key}</button>
      {/each}
    </div>

    <form
      method="POST"
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
                            required
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
                      required
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
                            required
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
                      required
                    />
                  {/if}
                </div>
              {/each}
            </CardContent>
          </Card>
        </div>
      {/each}

      <div class="flex items-center justify-between">
        <Button
          type="button"
          variant="outline"
          disabled={activeSubtest === 0}
          onclick={() => (activeSubtest = Math.max(0, activeSubtest - 1))}
        >Sebelumnya</Button>

        <span class="text-muted-foreground text-sm">{activeSubtest + 1} / {total}</span>

        {#if activeSubtest < total - 1}
          <Button
            type="button"
            onclick={() => (activeSubtest = Math.min(total - 1, activeSubtest + 1))}
          >Selanjutnya</Button>
        {:else}
          <Button type="submit" disabled={loading}>
            {loading ? 'Mengirim...' : 'Kirim Semua Jawaban'}
          </Button>
        {/if}
      </div>
    </form>
  {/if}
</div>
