<script lang="ts">
  import { PUBLIC_API_URL } from '$env/static/public';
  import { goto } from '$app/navigation';
  import { parse } from 'devalue';

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
      const res = await fetch(`${BASE}/big5/questions`);
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
      const res = await fetch('/tes-gratis/soal?/save', {
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
    <p class="quiz-status">Menyiapkan pertanyaan…</p>
  {:else if error}
    <div class="quiz-err">
      <p>{error}</p>
      <button class="quiz-retry" onclick={load}>Coba Lagi</button>
    </div>
  {:else if current}
    <div class="quiz-progress-wrap">
      <div class="quiz-progress" role="progressbar" aria-valuemin={0} aria-valuemax={100} aria-valuenow={progress}>
        <div class="quiz-progress-fill" style:width="{progress}%"></div>
      </div>
      <p class="quiz-count">Pertanyaan {idx + 1} dari {questions.length}</p>
    </div>

    <div class="quiz-q">
      <p class="quiz-statement">{current.statement}</p>

      <div class="quiz-options">
        {#each OPTIONS as opt}
          <button
            type="button"
            class="quiz-opt"
            class:selected={answers[current.no] === opt.value}
            onclick={() => select(opt.value)}
          >
            <span class="quiz-opt-dot" aria-hidden="true"></span>
            <span class="quiz-opt-label">{opt.label}</span>
            <span class="quiz-opt-val">{opt.value}</span>
          </button>
        {/each}
      </div>
    </div>

    {#if failMsg}
      <p class="quiz-fail">{failMsg}</p>
    {/if}

    <div class="quiz-nav">
      {#if idx > 0}
        <button type="button" class="quiz-back" onclick={back}>Kembali</button>
      {:else}
        <span class="quiz-back-spacer"></span>
      {/if}
      <span class="quiz-hint">{answers[current.no] ? 'Jawaban tersimpan' : 'Pilih satu jawaban'}</span>
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

  .quiz-progress {
    height: 6px;
    border-radius: 999px;
    background: var(--lp-paper-2);
    border: 1px solid var(--lp-rule);
    overflow: hidden;
  }

  .quiz-progress-fill {
    height: 100%;
    border-radius: 999px;
    background: var(--lp-accent);
    transition: width 300ms var(--lp-ease-out);
  }

  .quiz-count {
    color: var(--lp-muted);
    font-size: 0.8rem;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    margin: 0.6rem 0 0;
  }

  .quiz-q {
    flex: 1;
  }

  .quiz-statement {
    font-family: var(--lp-font-display);
    font-size: clamp(1.5rem, 5vw, 2rem);
    font-weight: 540;
    letter-spacing: -0.01em;
    line-height: 1.3;
    margin: 0 0 2rem;
    overflow-wrap: anywhere;
  }

  .quiz-options {
    display: grid;
    gap: 0.6rem;
  }

  .quiz-opt {
    display: flex;
    align-items: center;
    gap: 0.85rem;
    width: 100%;
    min-height: 3.4rem;
    padding: 0.7rem 1.1rem;
    border-radius: 999px;
    border: 1px solid var(--lp-rule-2);
    background: var(--lp-paper);
    cursor: pointer;
    text-align: left;
    transition: background-color 200ms var(--lp-ease-out), border-color 200ms var(--lp-ease-out),
      transform 100ms var(--lp-ease-out);
  }

  .quiz-opt:hover {
    border-color: var(--lp-accent);
  }

  .quiz-opt:active {
    transform: translateY(1px);
  }

  .quiz-opt.selected {
    background: var(--lp-accent-bg);
    border-color: var(--lp-accent);
  }

  .quiz-opt-dot {
    width: 1rem;
    height: 1rem;
    border-radius: 999px;
    border: 2px solid var(--lp-rule-2);
    flex: none;
    transition: background-color 200ms var(--lp-ease-out), border-color 200ms var(--lp-ease-out);
  }

  .quiz-opt.selected .quiz-opt-dot {
    background: var(--lp-accent-deep);
    border-color: var(--lp-accent-deep);
  }

  .quiz-opt-label {
    flex: 1;
    font-weight: 600;
    font-size: 0.98rem;
  }

  .quiz-opt-val {
    color: var(--lp-muted);
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

  .quiz-back {
    min-height: 3rem;
    padding: 0.6rem 1.4rem;
    border-radius: 999px;
    border: 1px solid var(--lp-rule-2);
    background: transparent;
    color: var(--lp-ink);
    font-weight: 600;
    cursor: pointer;
    transition: background-color 200ms var(--lp-ease-out), border-color 200ms var(--lp-ease-out);
  }

  .quiz-back:hover {
    border-color: var(--lp-ink-2);
    background: var(--lp-paper-2);
  }

  .quiz-back-spacer {
    width: 1rem;
  }

  .quiz-hint {
    color: var(--lp-muted);
    font-size: 0.85rem;
  }

  .quiz-status,
  .quiz-err {
    color: var(--lp-ink-2);
    padding: 2rem 0;
  }

  .quiz-fail {
    color: oklch(0.55 0.18 25);
    background: oklch(0.96 0.03 25);
    border: 1px solid oklch(0.85 0.06 25);
    border-radius: 0.75rem;
    padding: 0.8rem 1rem;
    font-size: 0.9rem;
    margin: 1.25rem 0 0;
  }

  .quiz-retry {
    margin-top: 1rem;
    min-height: 3rem;
    padding: 0.6rem 1.5rem;
    border-radius: 999px;
    background: var(--lp-accent-bg);
    border: 1px solid var(--lp-accent-bg);
    color: var(--lp-ink);
    font-weight: 650;
    cursor: pointer;
  }

  @media (pointer: coarse) {
    .quiz-opt {
      min-height: 3.75rem;
    }
  }
</style>
