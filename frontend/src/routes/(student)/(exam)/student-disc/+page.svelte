<script lang="ts">
  import { enhance } from '$app/forms';
  import { dev, browser } from '$app/environment';
  import { getContext, onMount, tick } from 'svelte';
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Progress } from '$lib/components/ui/progress/index.js';

  let { data, form } = $props();
  let loading = $state(false);
  let currentBlock = $state(0);
  let formEl: HTMLFormElement | undefined = $state();

  const examGuard = getContext<{ disarm: () => void }>('exam-guard');
  let draftKey = $derived(`disc-draft-${data.assignmentId ?? 'na'}`);

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

  // Draft autosave: since answers only reach the server on final submit,
  // an accidental refresh/close would otherwise lose all progress. Restore
  // on mount, persist on every change, and clear once the test is actually
  // submitted (see the form's use:enhance below).
  let draftHydrated = $state(false);

  onMount(() => {
    if (!browser) return;
    try {
      const raw = localStorage.getItem(draftKey);
      if (raw) {
        const parsed = JSON.parse(raw);
        if (parsed?.selections) selections = parsed.selections;
        if (typeof parsed?.currentBlock === 'number') currentBlock = parsed.currentBlock;
      }
    } catch {
      // corrupt/unavailable draft — ignore and start fresh
    }
    draftHydrated = true;
  });

  $effect(() => {
    if (!browser || !draftHydrated) return;
    const snapshot = JSON.stringify({ selections, currentBlock });
    localStorage.setItem(draftKey, snapshot);
  });

  function clearDraft() {
    if (!browser) return;
    localStorage.removeItem(draftKey);
  }

  // Dev-only helper: pressing "x" picks a random most/least pair on the
  // current block and advances, so manual QA (and later, browser-driven
  // integration tests) can blast through all 24 blocks without clicking
  // through every radio by hand. Gated on $app/environment's `dev` flag,
  // so it's compiled out of production builds entirely.
  async function devFillRandomAndAdvance() {
    if (loading || blocks.length === 0) return;
    const blockNo = currentBlockNo;
    const items = blocks[currentBlock] as Statement[];
    if (!blockNo || !items?.length) return;

    const mostIdx = Math.floor(Math.random() * items.length);
    let leastIdx = Math.floor(Math.random() * (items.length - 1));
    if (leastIdx >= mostIdx) leastIdx += 1;

    selectMost(blockNo, items[mostIdx].itemNo);
    selectLeast(blockNo, items[leastIdx].itemNo);

    if (currentBlock < totalBlocks - 1) {
      currentBlock = Math.min(totalBlocks - 1, currentBlock + 1);
    } else {
      // Radio `checked` state only reaches the DOM after Svelte flushes —
      // requestSubmit() right after setting state would serialize the form
      // BEFORE that flush and silently drop this last block's answer.
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

<svelte:head><title>Tes DISC</title></svelte:head>
<svelte:window onkeydown={handleDevKeydown} />

<div class="flex max-w-2xl flex-col gap-6">
  <div>
    <h2 class="text-2xl font-bold">Tes DISC</h2>
    {#if dev}
      <p class="mt-1 text-xs text-amber-600">
        Dev mode: tekan <kbd class="rounded border px-1">X</kbd> untuk mengisi jawaban acak dan lanjut otomatis.
      </p>
    {/if}
    <p class="text-muted-foreground mt-1 text-sm">
      INSTRUKSI : Terdapat 24 soal, Setiap nomor di bawah ini memuat 4 (empat) kalimat. Tugas anda adalah :
    </p>
    <ol class="text-muted-foreground mt-1 list-decimal space-y-1 pl-5 text-sm">
      <li>Pilih kolom "Paling Tepat" di samping kalimat yang PALING menggambarkan diri anda</li>
      <li>Pilih kolom "Paling Tidak Tepat" di samping kalimat yang PALING TIDAK menggambarkan diri anda</li>
    </ol>
    <p class="text-muted-foreground mt-1 text-sm">
      PERHATIKAN : Setiap nomor hanya ada 1 (satu) pilihan di bawah masing-masing kolom Paling Tepat dan Paling Tidak Tepat.
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

      <div class="mt-4 flex flex-col gap-2">
        <div class="text-muted-foreground flex items-center justify-between text-sm">
          <span>Soal {currentBlock + 1} dari {totalBlocks}</span>
          <span>{Math.round(((currentBlock + 1) / totalBlocks) * 100)}%</span>
        </div>
        <Progress value={currentBlock + 1} max={totalBlocks} />

        <div class="mt-2 flex items-center justify-between">
          <Button
            type="button"
            variant="outline"
            disabled={currentBlock === 0}
            onclick={() => (currentBlock = Math.max(0, currentBlock - 1))}
          >Sebelumnya</Button>

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
      </div>
    </form>
  {/if}
</div>
