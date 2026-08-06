<script lang="ts">
  import { PUBLIC_API_URL } from '$env/static/public';
  import { goto } from '$app/navigation';
  import { parse } from 'devalue';
  import { trackedFetch } from '$lib/loading.js';

  const BASE = (PUBLIC_API_URL || 'http://127.0.0.1:1005/api').replace(/\/+$/, '');

  type Question = { no: number; statement: string };

  const OPTIONS = [
    { value: 1, label: 'Sangat Tidak Setuju' },
    { value: 2, label: 'Tidak Setuju' },
    { value: 3, label: 'Netral' },
    { value: 4, label: 'Setuju' },
    { value: 5, label: 'Sangat Setuju' }
  ];

  let questions = $state<Question[]>([]);
  let idx = $state(0);
  let answers = $state<Record<number, number>>({});
  let loading = $state(true);
  let error = $state<string | null>(null);
  let submitting = $state(false);
  let failMsg = $state<string | null>(null);

  // Only ever one pending auto-advance. Without this, fast taps stack
  // timers that each do `idx + 1`, skipping questions and leaving their
  // answers unrecorded (=> backend "answer all questions" error).
  let advanceTimer: ReturnType<typeof setTimeout> | undefined;

  async function load() {
    loading = true;
    error = null;
    try {
      const res = await trackedFetch(`${BASE}/big5/questions`);
      if (!res.ok) throw new Error('Gagal memuat pertanyaan');
      questions = await res.json();
    } catch (e) {
      error = e instanceof Error ? e.message : 'Terjadi kesalahan';
    } finally {
      loading = false;
    }
  }

  load();

  const current = $derived(questions[idx]);
  const progress = $derived(questions.length ? (idx / questions.length) * 100 : 0);

  function select(value: number) {
    if (!current) return;
    answers = { ...answers, [current.no]: value };
    if (idx < questions.length - 1) {
      const from = idx;
      clearTimeout(advanceTimer);
      advanceTimer = setTimeout(() => {
        if (idx === from) idx = from + 1;
      }, 220);
    } else {
      submitAll();
    }
  }

  function back() {
    if (idx > 0) idx = idx - 1;
  }

  async function submitAll() {
    if (submitting) return;
    const missing = questions.find((q) => answers[q.no] === undefined);
    if (missing) {
      idx = questions.findIndex((q) => q.no === missing.no);
      return;
    }
    submitting = true;
    failMsg = null;
    try {
      const res = await trackedFetch('/tes-gratis/soal?/save', {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: new URLSearchParams({ answers: JSON.stringify(answers) })
      });
      if (res.status === 401) {
        goto('/signup');
        return;
      }
      const body = await res.json().catch(() => null);
      const data = body && typeof body.data === 'string' ? parse(body.data) : body?.data;
      if (!res.ok || body?.type === 'failure') {
        const reason =
          typeof data?.error === 'string'
            ? data.error
            : typeof body?.error === 'string'
              ? body.error
              : 'Gagal menyimpan hasil';
        throw new Error(reason);
      }
      const result = data;
      sessionStorage.setItem('big5_result', JSON.stringify(result));
      sessionStorage.setItem('big5_answers', JSON.stringify(answers));
      goto('/tes-gratis/hasil?saved=1');
    } catch (e) {
      failMsg = e instanceof Error ? e.message : 'Terjadi kesalahan';
      idx = questions.length - 1;
    } finally {
      submitting = false;
    }
  }
</script>

<svelte:head>
  <title>Tes Gratis — Kenali Kepribadianmu</title>
</svelte:head>

<div class="quiz">
  {#if loading}
    <p class="lp-lead quiz-status">Menyiapkan pertanyaan…</p>
  {:else if error}
    <div class="quiz-err">
      <p>{error}</p>
      <button class="lp-btn lp-btn-primary" onclick={load}>Coba Lagi</button>
    </div>
  {:else if current}
    <div class="quiz-progress-wrap">
      <div class="lp-progress" role="progressbar" aria-valuemin={0} aria-valuemax={100} aria-valuenow={progress}>
        <div style:width="{progress}%"></div>
      </div>
      <p class="lp-muted quiz-count">Pertanyaan {idx + 1} dari {questions.length}</p>
    </div>

    <div class="quiz-q">
      <p class="lp-display quiz-statement">{current.statement}</p>

      <div class="quiz-options">
        {#each OPTIONS as opt}
          <button
            type="button"
            class="lp-choice"
            class:selected={answers[current.no] === opt.value}
            onclick={() => select(opt.value)}
          >
            <span class="lp-choice-dot" aria-hidden="true"></span>
            <span class="lp-choice-label">{opt.label}</span>
            <span class="lp-muted quiz-opt-val">{opt.value}</span>
          </button>
        {/each}
      </div>
    </div>

    {#if failMsg}
      <p class="lp-error">{failMsg}</p>
    {/if}

    <div class="quiz-nav">
      {#if idx > 0}
        <button type="button" class="lp-btn lp-btn-outline lp-btn-sm" onclick={back}>Kembali</button>
      {:else}
        <span class="quiz-back-spacer"></span>
      {/if}
      <span class="lp-muted quiz-hint">{answers[current.no] ? 'Jawaban tersimpan' : 'Pilih satu jawaban'}</span>
    </div>
  {/if}
</div>

<style>
  .quiz {
    max-width: 42rem;
    margin-inline: auto;
    padding: clamp(1.25rem, 4vw, 2rem) clamp(1.25rem, 4vw, 2rem) 2rem;
    min-height: 62dvh;
    display: flex;
    flex-direction: column;
  }

  .quiz-progress-wrap {
    margin-bottom: 2rem;
  }

  .quiz-count {
    margin: 0.6rem 0 0;
    font-size: 0.8rem;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
  }

  .quiz-q {
    flex: 1;
  }

  .quiz-statement {
    font-size: clamp(1.5rem, 5vw, 2rem);
    line-height: 1.3;
    margin: 0 0 2rem;
  }

  .quiz-options {
    display: grid;
    gap: 0.6rem;
  }

  .quiz-opt-val {
    font-size: 0.82rem;
    font-variant-numeric: tabular-nums;
  }

  .quiz-nav {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
    margin-top: 2rem;
  }

  .quiz-back-spacer {
    width: 1rem;
  }

  .quiz-hint {
    font-size: 0.85rem;
  }

  .quiz-status,
  .quiz-err {
    color: var(--lp-ink-2);
    padding: 2rem 0;
  }
</style>
