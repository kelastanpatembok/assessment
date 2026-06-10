<script lang="ts">
  import { enhance } from '$app/forms';
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';

  let { data, form } = $props();
  let loading = $state(false);

  type HollandQuestion = {
    id: number;
    groupCode: string; // R1, R2, ... C3
    itemNo: number;
    statement: string;
  };

  let questions: HollandQuestion[] = $derived(data.questions ?? []);

  // Group by groupCode
  let groups = $derived(
    Object.values(
      questions.reduce((acc: Record<string, HollandQuestion[]>, q: HollandQuestion) => {
        (acc[q.groupCode] ??= []).push(q);
        return acc;
      }, {})
    ).sort((a: HollandQuestion[], b: HollandQuestion[]) =>
      a[0].groupCode.localeCompare(b[0].groupCode)
    )
  );
</script>

<svelte:head><title>Tes Holland RIASEC</title></svelte:head>

<div class="flex max-w-3xl flex-col gap-6">
  <div>
    <h2 class="text-2xl font-bold">Tes Holland RIASEC</h2>
    <p class="text-muted-foreground mt-1 text-sm">
      Nilai setiap pernyataan dari 1 (Sangat Tidak Suka) hingga 5 (Sangat Suka).
    </p>
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
  {:else if questions.length === 0}
    <Card><CardContent class="pt-6"><p class="text-muted-foreground">Tidak ada soal tersedia.</p></CardContent></Card>
  {:else}
    <form
      method="POST"
      use:enhance={() => {
        loading = true;
        return async ({ update }) => { loading = false; await update(); };
      }}
      class="flex flex-col gap-6"
    >
      <input type="hidden" name="assignmentId" value={data.assignmentId ?? 0} />

      {#each groups as stmts}
        <Card>
          <CardHeader>
            <CardTitle class="text-base">Kelompok {stmts[0].groupCode}</CardTitle>
          </CardHeader>
          <CardContent>
            <div class="flex flex-col gap-4">
              {#each stmts as q}
                <div>
                  <p class="mb-2 text-sm">{q.statement}</p>
                  <div class="flex gap-4">
                    {#each [1,2,3,4,5] as val}
                      <label class="flex cursor-pointer flex-col items-center gap-1">
                        <input
                          type="radio"
                          name="q{q.id}_score"
                          value={val}
                          class="size-4"
                          required
                        />
                        <span class="text-muted-foreground text-xs">{val}</span>
                      </label>
                    {/each}
                  </div>
                </div>
              {/each}
            </div>
          </CardContent>
        </Card>
      {/each}

      <Button type="submit" class="self-end" disabled={loading}>
        {loading ? 'Mengirim...' : 'Kirim Jawaban'}
      </Button>
    </form>
  {/if}
</div>
