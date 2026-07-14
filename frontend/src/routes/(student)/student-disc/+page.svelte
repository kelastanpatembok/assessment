<script lang="ts">
  import { enhance } from '$app/forms';
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';

  let { data, form } = $props();
  let loading = $state(false);
  let currentBlock = $state(0);

  type Statement = { id: number; blockNo: number; itemNo: number; category: string; statement: string };

  // Group questions by blockNo
  let allQuestions: Statement[] = $derived(data.questions ?? []);
  let blocks = $derived(
    Object.values(
      allQuestions.reduce((acc: Record<number, Statement[]>, q: Statement) => {
        (acc[q.blockNo] ??= []).push(q);
        return acc;
      }, {})
    ).sort((a: Statement[], b: Statement[]) => a[0].blockNo - b[0].blockNo)
  );
  let totalBlocks = $derived(blocks.length);

  // Track selections: blockNo → { mostItemNo, leastItemNo }
  let selections = $state<Record<number, { most?: number; least?: number }>>({});

  function selectMost(blockNo: number, itemNo: number) {
    selections = { ...selections, [blockNo]: { ...selections[blockNo], most: itemNo } };
  }

  function selectLeast(blockNo: number, itemNo: number) {
    selections = { ...selections, [blockNo]: { ...selections[blockNo], least: itemNo } };
  }

  let currentBlockNo = $derived(blocks[currentBlock]?.[0]?.blockNo);
  let currentBlockAnswered = $derived(
    selections[currentBlockNo]?.most !== undefined && selections[currentBlockNo]?.least !== undefined
  );
</script>

<svelte:head><title>Tes DISC</title></svelte:head>

<div class="flex max-w-2xl flex-col gap-6">
  <div>
    <h2 class="text-2xl font-bold">Tes DISC</h2>
    <p class="text-muted-foreground mt-1 text-sm">
      INSTRUKSI : Terdapat 24 soal, Setiap nomor di bawah ini memuat 4 (empat) kalimat. Tugas anda adalah :
    </p>
    <ol class="text-muted-foreground mt-1 list-decimal space-y-1 pl-5 text-sm">
      <li>Beri tanda [x] pada kolom di bawah huruf [P] di samping kalimat yang PALING menggambarkan diri anda</li>
      <li>Beri tanda [x] pada kolom di bawah huruf [K] di samping kalimat yang PALING TIDAK menggambarkan diri anda</li>
    </ol>
    <p class="text-muted-foreground mt-1 text-sm">
      PERHATIKAN : Setiap nomor hanya ada 1 (satu) tanda [x] di bawah masing-masing kolom P dan K.
    </p>
  </div>

  {#if data.unavailable}
    <Card>
      <CardContent class="pt-6">
        <p class="text-muted-foreground">Tes DISC belum tersedia atau sudah Anda selesaikan.</p>
        <a href="/student-dashboard" class="text-primary mt-4 block text-sm hover:underline">Kembali ke Dashboard</a>
      </CardContent>
    </Card>
  {:else if form?.error}
    <div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">{form.error}</div>
  {:else if blocks.length === 0}
    <Card><CardContent class="pt-6"><p class="text-muted-foreground">Tidak ada soal tersedia.</p></CardContent></Card>
  {:else}
    <form
      method="POST"
      use:enhance={() => {
        loading = true;
        return async ({ update }) => { loading = false; await update(); };
      }}
    >
      <input type="hidden" name="assignmentId" value={data.assignmentId ?? 0} />

      {#each blocks as stmts, bi}
        {@const blockNo = stmts[0].blockNo}
        <div class={bi === currentBlock ? 'block' : 'hidden'}>
          <Card>
            <CardHeader>
              <CardTitle class="text-base">Kelompok {bi + 1} dari {totalBlocks}</CardTitle>
            </CardHeader>
            <CardContent>
              <div class="mb-2 grid grid-cols-[1fr_auto_auto] gap-x-4 text-xs font-semibold text-center">
                <span>Pernyataan</span>
                <span class="text-primary w-24">Paling Tepat</span>
                <span class="text-muted-foreground w-28">Paling Tidak Tepat</span>
              </div>
              {#each stmts as q}
                <div class="grid grid-cols-[1fr_auto_auto] items-center gap-x-4 border-b py-3 last:border-0">
                  <span class="text-sm">{q.statement}</span>
                  <div class="flex w-24 justify-center">
                    <input
                      type="radio"
                      name="b{blockNo}_most"
                      value={q.itemNo}
                      checked={selections[blockNo]?.most === q.itemNo}
                      disabled={selections[blockNo]?.least === q.itemNo}
                      onchange={() => selectMost(blockNo, q.itemNo)}
                      class="size-4 cursor-pointer accent-green-600 disabled:cursor-not-allowed disabled:opacity-30"
                    />
                  </div>
                  <div class="flex w-28 justify-center">
                    <input
                      type="radio"
                      name="b{blockNo}_least"
                      value={q.itemNo}
                      checked={selections[blockNo]?.least === q.itemNo}
                      disabled={selections[blockNo]?.most === q.itemNo}
                      onchange={() => selectLeast(blockNo, q.itemNo)}
                      class="size-4 cursor-pointer accent-red-500 disabled:cursor-not-allowed disabled:opacity-30"
                    />
                  </div>
                </div>
              {/each}
            </CardContent>
          </Card>
        </div>
      {/each}

      <div class="mt-4 flex items-center justify-between">
        <Button
          type="button"
          variant="outline"
          disabled={currentBlock === 0}
          onclick={() => (currentBlock = Math.max(0, currentBlock - 1))}
        >Sebelumnya</Button>

        <span class="text-muted-foreground text-sm">{currentBlock + 1} / {totalBlocks}</span>

        {#if currentBlock < totalBlocks - 1}
          <Button
            type="button"
            disabled={!currentBlockAnswered}
            onclick={() => (currentBlock = Math.min(totalBlocks - 1, currentBlock + 1))}
          >Selanjutnya</Button>
        {:else}
          <Button type="submit" disabled={loading || !currentBlockAnswered}>
            {loading ? 'Mengirim...' : 'Kirim Jawaban'}
          </Button>
        {/if}
      </div>
    </form>
  {/if}
</div>
