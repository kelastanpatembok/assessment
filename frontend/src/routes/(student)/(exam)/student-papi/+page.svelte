<script lang="ts">
  import { enhance } from '$app/forms';
  import { getContext } from 'svelte';
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';

  let { data, form } = $props();
  let loading = $state(false);
  const examGuard = getContext<{ disarm: () => void }>('exam-guard');
  let currentPair = $state(0);

  type Pair = { pairNo: number; stmtA: string; stmtB: string; traitA: string; traitB: string };
  let pairs: Pair[] = $derived(data.pairs ?? []);
  let total = $derived(pairs.length);
</script>

<svelte:head><title>Tes PAPI Kostick</title></svelte:head>

<div class="flex max-w-2xl flex-col gap-6">
  <div>
    <h2 class="text-2xl font-bold">Tes PAPI Kostick</h2>
    <p class="text-muted-foreground mt-1 text-sm">
      Untuk setiap pasang pernyataan, pilih satu yang LEBIH menggambarkan Anda.
    </p>
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
  {:else if pairs.length === 0}
    <Card><CardContent class="pt-6"><p class="text-muted-foreground">Tidak ada soal tersedia.</p></CardContent></Card>
  {:else}
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
    >
      <input type="hidden" name="assignmentId" value={data.assignmentId ?? 0} />

      {#each pairs as pair, i}
        <div class={i === currentPair ? 'block' : 'hidden'}>
          <Card>
            <CardHeader>
              <CardTitle class="text-base">Pertanyaan {i + 1} dari {total}</CardTitle>
            </CardHeader>
            <CardContent>
              <p class="text-muted-foreground mb-4 text-sm">Pilih satu pernyataan yang lebih tepat menggambarkan Anda:</p>
              <div class="flex flex-col gap-3">
                <label class="hover:bg-accent flex cursor-pointer items-start gap-3 rounded-lg border p-4 transition-colors">
                  <input type="radio" name="pair_{pair.pairNo}" value="A" class="mt-0.5 size-4 shrink-0" required />
                  <span class="text-sm">{pair.stmtA}</span>
                </label>
                <label class="hover:bg-accent flex cursor-pointer items-start gap-3 rounded-lg border p-4 transition-colors">
                  <input type="radio" name="pair_{pair.pairNo}" value="B" class="mt-0.5 size-4 shrink-0" required />
                  <span class="text-sm">{pair.stmtB}</span>
                </label>
              </div>
            </CardContent>
          </Card>
        </div>
      {/each}

      <div class="mt-4 flex items-center justify-between">
        <Button
          type="button"
          variant="outline"
          disabled={currentPair === 0}
          onclick={() => (currentPair = Math.max(0, currentPair - 1))}
        >Sebelumnya</Button>

        <span class="text-muted-foreground text-sm">{currentPair + 1} / {total}</span>

        {#if currentPair < total - 1}
          <Button type="button" onclick={() => (currentPair = Math.min(total - 1, currentPair + 1))}>
            Selanjutnya
          </Button>
        {:else}
          <Button type="submit" disabled={loading}>
            {loading ? 'Mengirim...' : 'Kirim Jawaban'}
          </Button>
        {/if}
      </div>
    </form>
  {/if}
</div>
