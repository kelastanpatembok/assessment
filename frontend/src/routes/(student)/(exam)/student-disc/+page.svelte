<script lang="ts">
  import { enhance } from '$app/forms';
  import { dev, browser } from '$app/environment';
  import { getContext, onMount, tick } from 'svelte';

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

  // Dev-only helper: pressing "y" always picks D as "Paling Tepat" and C as
  // "Paling Tidak Tepat" (every block has exactly one statement per D/I/S/C
  // category) and advances — a deterministic run that maxes out the D score
  // and minimizes C, useful for QA'ing the high end of the DISC result page
  // instead of X's random (and thus roughly flat) profile.
  async function devFillHighAndAdvance() {
    if (loading || blocks.length === 0) return;
    const blockNo = currentBlockNo;
    const items = blocks[currentBlock] as Statement[];
    if (!blockNo || !items?.length) return;

    const most = items.find((q) => q.category === 'D') ?? items[0];
    const least =
      items.find((q) => q.category === 'C' && q.itemNo !== most.itemNo) ??
      items.find((q) => q.itemNo !== most.itemNo) ??
      items[0];

    selectMost(blockNo, most.itemNo);
    selectLeast(blockNo, least.itemNo);

    if (currentBlock < totalBlocks - 1) {
      currentBlock = Math.min(totalBlocks - 1, currentBlock + 1);
    } else {
      await tick();
      formEl?.requestSubmit();
    }
  }

  function handleDevKeydown(e: KeyboardEvent) {
    if (!dev) return;
    const key = e.key.toLowerCase();
    if (key === 'x') {
      e.preventDefault();
      devFillRandomAndAdvance();
    } else if (key === 'y') {
      e.preventDefault();
      devFillHighAndAdvance();
    }
  }
</script>

<svelte:head><title>Tes DISC</title></svelte:head>
<svelte:window onkeydown={handleDevKeydown} />

<div class="lp-wrap flex flex-col gap-6">
  <header class="flex flex-col gap-1.5">
    <p class="lp-kicker">Tes Kepribadian DISC</p>
    <h2 class="lp-display text-3xl sm:text-4xl">Tes DISC</h2>
    {#if dev}
      <p class="mt-1 text-xs" style="color: var(--lp-ink-2)">
        Mode pengembangan: tekan <kbd class="lp-kbd">X</kbd> untuk mengisi jawaban acak dan lanjut otomatis, atau
        <kbd class="lp-kbd">Y</kbd> untuk memilih D (Paling Tepat) &amp; C (Paling Tidak Tepat) di tiap kelompok (skor D maksimal).
      </p>
    {/if}
  </header>

  <div
    class="flex flex-col gap-2 rounded-xl border border-l-2 py-3 pl-4 pr-3 text-sm"
    style="border-color: var(--lp-rule); border-left-color: var(--lp-accent)"
  >
    <p class="font-semibold">INSTRUKSI</p>
    <p class="lp-lead">Terdapat 24 soal. Setiap nomor memuat 4 (empat) kalimat. Tugas Anda:</p>
    <ol class="lp-lead list-decimal space-y-1 pl-5">
      <li>Pilih "Paling Tepat" di samping kalimat yang PALING menggambarkan diri Anda.</li>
      <li>Pilih "Paling Tidak Tepat" di samping kalimat yang PALING TIDAK menggambarkan diri Anda.</li>
    </ol>
    <p class="lp-muted mt-1 text-xs">
      PERHATIKAN: setiap nomor hanya ada 1 (satu) pilihan di bawah masing-masing kolom Paling Tepat dan Paling Tidak Tepat.
    </p>
  </div>

  {#if data.unavailable}
    <div class="lp-card lp-card-pad flex flex-col gap-3">
      <p class="lp-lead text-sm">Tes DISC belum tersedia atau sudah Anda selesaikan.</p>
      <a href="/student-dashboard" class="lp-btn lp-btn-outline lp-btn-sm self-start">Kembali ke Dashboard</a>
    </div>
  {:else if form?.error}
    <div class="lp-error">{form.error}</div>
  {:else if blocks.length === 0}
    <div class="lp-card lp-card-pad"><p class="lp-lead text-sm">Tidak ada soal tersedia.</p></div>
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
          <div class="lp-card lp-card-pad flex flex-col gap-2">
            <div class="flex items-baseline justify-between gap-3">
              <h3 class="font-semibold">Kelompok {bi + 1} dari {totalBlocks}</h3>
              <span class="lp-muted text-xs">Pilih 1 "Paling Tepat" &amp; 1 "Paling Tidak Tepat"</span>
            </div>
            {#each stmts as q}
              <div class="disc-row">
                <p class="disc-statement">{q.statement}</p>
                <div class="disc-picks">
                  <label
                    class="disc-pick is-most"
                    class:sel={selections[blockNo]?.most === q.itemNo}
                    class:disabled={selections[blockNo]?.least === q.itemNo}
                  >
                    <input
                      type="radio"
                      name="b{blockNo}_most"
                      value={q.itemNo}
                      checked={selections[blockNo]?.most === q.itemNo}
                      disabled={selections[blockNo]?.least === q.itemNo}
                      onchange={() => selectMost(blockNo, q.itemNo)}
                      class="sr-only"
                    />
                    <span class="disc-dot" aria-hidden="true"></span>
                    <span>Paling Tepat</span>
                  </label>
                  <label
                    class="disc-pick is-least"
                    class:sel={selections[blockNo]?.least === q.itemNo}
                    class:disabled={selections[blockNo]?.most === q.itemNo}
                  >
                    <input
                      type="radio"
                      name="b{blockNo}_least"
                      value={q.itemNo}
                      checked={selections[blockNo]?.least === q.itemNo}
                      disabled={selections[blockNo]?.most === q.itemNo}
                      onchange={() => selectLeast(blockNo, q.itemNo)}
                      class="sr-only"
                    />
                    <span class="disc-dot" aria-hidden="true"></span>
                    <span>Paling Tidak Tepat</span>
                  </label>
                </div>
              </div>
            {/each}
          </div>
        </div>
      {/each}

      <div class="mt-4 flex flex-col gap-3">
        <div class="lp-muted flex items-center justify-between text-sm">
          <span>Soal {currentBlock + 1} dari {totalBlocks}</span>
          <span>{Math.round(((currentBlock + 1) / totalBlocks) * 100)}%</span>
        </div>
        <div class="lp-progress"><div style="width: {((currentBlock + 1) / totalBlocks) * 100}%"></div></div>

        <div class="mt-1 flex items-center justify-between gap-3">
          <button
            type="button"
            class="lp-btn lp-btn-outline"
            disabled={currentBlock === 0}
            onclick={() => (currentBlock = Math.max(0, currentBlock - 1))}
          >Sebelumnya</button>

          {#if currentBlock < totalBlocks - 1}
            <button
              type="button"
              class="lp-btn lp-btn-primary"
              disabled={!currentBlockAnswered}
              onclick={() => (currentBlock = Math.min(totalBlocks - 1, currentBlock + 1))}
            >Selanjutnya</button>
          {:else}
            <button type="submit" class="lp-btn lp-btn-primary" disabled={loading || !currentBlockAnswered}>
              {loading ? 'Mengirim...' : 'Kirim Jawaban'}
            </button>
          {/if}
        </div>
      </div>
    </form>
  {/if}
</div>

<style>
  .disc-row {
    display: grid;
    grid-template-columns: minmax(0, 1fr) auto auto;
    gap: 0.75rem 1.25rem;
    align-items: center;
    padding: 0.85rem 0;
    border-bottom: 1px solid var(--lp-rule);
  }

  .disc-row:last-child {
    border-bottom: 0;
    padding-bottom: 0;
  }

  .disc-statement {
    font-size: 0.95rem;
    line-height: 1.55;
    min-width: 0;
  }

  .disc-picks {
    display: contents;
  }

  .disc-pick {
    display: inline-flex;
    align-items: center;
    gap: 0.45rem;
    min-height: 2.5rem;
    padding: 0.4rem 0.9rem;
    border-radius: 999px;
    border: 1px solid var(--lp-rule-2);
    cursor: pointer;
    font-size: 0.82rem;
    font-weight: 600;
    white-space: nowrap;
    transition:
      background-color 200ms var(--lp-ease-out),
      border-color 200ms var(--lp-ease-out),
      opacity 200ms var(--lp-ease-out);
  }

  .disc-dot {
    width: 0.85rem;
    height: 0.85rem;
    border-radius: 999px;
    border: 2px solid var(--lp-rule-2);
    flex: none;
    transition:
      background-color 200ms var(--lp-ease-out),
      border-color 200ms var(--lp-ease-out);
  }

  .disc-pick.is-most.sel {
    background: var(--lp-accent-bg);
    border-color: var(--lp-accent);
  }

  .disc-pick.is-most.sel .disc-dot {
    background: var(--lp-most);
    border-color: var(--lp-most);
  }

  .disc-pick.is-least.sel {
    background: var(--lp-paper-2);
    border-color: var(--lp-least);
  }

  .disc-pick.is-least.sel .disc-dot {
    background: var(--lp-least);
    border-color: var(--lp-least);
  }

  .disc-pick.disabled {
    opacity: 0.35;
    cursor: not-allowed;
  }

  @media (max-width: 40rem) {
    .disc-row {
      grid-template-columns: minmax(0, 1fr);
      gap: 0.5rem;
      padding: 1rem 0;
    }

    .disc-picks {
      display: grid;
      grid-template-columns: repeat(2, minmax(0, 1fr));
      gap: 0.5rem;
    }

    .disc-pick {
      justify-content: center;
    }
  }
</style>
