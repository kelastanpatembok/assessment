<script lang="ts">
  import { enhance } from '$app/forms';
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';

  let { data, form } = $props();
  let loading = $state(false);
  let activeSubtest = $state(0);

  type CfitQuestion = {
    id: number;
    subtestNo: number;
    itemNo: number;
    subtest: string;
    questionText?: string;
    question?: string;
    options?: Record<string, string> | null;
  };

  type Subtest = { key: string; label: string; subtestNo: number; questions: CfitQuestion[] };
  let subtests: Subtest[] = $derived(data.subtests ?? []);
  let total = $derived(subtests.length);

  function optionEntries(q: CfitQuestion): [string, string][] {
    if (!q.options) return [];
    return Object.entries(q.options);
  }
</script>

<svelte:head><title>Tes IQ CFIT</title></svelte:head>

<div class="flex max-w-3xl flex-col gap-6">
  <div>
    <h2 class="text-2xl font-bold">Tes IQ CFIT</h2>
    <p class="text-muted-foreground mt-1 text-sm">
      Jawab setiap soal dengan memilih jawaban yang paling tepat.
    </p>
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
      use:enhance={() => {
        loading = true;
        return async ({ update }) => { loading = false; await update(); };
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
                </CardTitle>
              </CardHeader>
              <CardContent>
                <p class="mb-4 text-sm">{q.questionText ?? q.question ?? ''}</p>
                {#if optionEntries(q).length > 0}
                  <div class="grid grid-cols-2 gap-2 sm:grid-cols-4">
                    {#each optionEntries(q) as [optKey, optVal]}
                      <label class="hover:bg-accent flex cursor-pointer items-center gap-2 rounded-lg border p-3 text-sm">
                        <input
                          type="radio"
                          name="st{q.subtestNo}_q{q.itemNo}"
                          value={optKey}
                          class="size-4 shrink-0"
                          required
                        />
                        <span>{optKey}. {optVal}</span>
                      </label>
                    {/each}
                  </div>
                {:else}
                  <input
                    type="text"
                    name="st{q.subtestNo}_q{q.itemNo}"
                    placeholder="Jawaban..."
                    class="border-input bg-background flex h-10 w-full max-w-xs rounded-lg border px-3 text-sm"
                    required
                  />
                {/if}
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
          <Button type="submit" disabled={loading}>
            {loading ? 'Mengirim...' : 'Kirim Semua Jawaban'}
          </Button>
        {/if}
      </div>
    </form>
  {/if}
</div>
