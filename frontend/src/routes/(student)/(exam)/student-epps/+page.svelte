<script lang="ts">
  import { browser } from '$app/environment';
  import { enhance } from '$app/forms';
  import { getContext, onMount } from 'svelte';

  type EppsQuestion = {
    id: number;
    no: number;
    statementA: string;
    statementB: string;
  };

  let { data, form } = $props();
  const examGuard = getContext<{ disarm: () => void }>('exam-guard');
  let draftKey = $derived(`epps-draft-${data.assignmentId ?? 'na'}`);
  const questions: EppsQuestion[] = $derived(data.questions ?? []);
  const totalQuestions = $derived(questions.length);

  let step = $state(0);
  let gender = $state('');
  let answers = $state<Record<number, 'A' | 'B'>>({});
  let ready = $state(false);
  let loading = $state(false);

  const current = $derived(step > 0 ? questions[step - 1] : undefined);
  const answered = $derived(Object.keys(answers).length);
  const currentStepAnswered = $derived(step === 0 ? gender !== '' : current ? answers[current.no] !== undefined : false);

  onMount(() => {
    try {
      const saved = JSON.parse(localStorage.getItem(draftKey) ?? 'null');
      if (saved) {
        answers = saved.answers ?? {};
        gender = saved.gender ?? '';
        step = Math.min(Math.max(saved.step ?? 0, 0), questions.length);
      }
    } catch {
      // Ignore an invalid draft and start from the instructions.
    }
    ready = true;
  });

  $effect(() => {
    if (browser && ready) localStorage.setItem(draftKey, JSON.stringify({ answers, gender, step }));
  });

  function choose(no: number, choice: 'A' | 'B') {
    answers = { ...answers, [no]: choice };
  }

  function done() {
    localStorage.removeItem(draftKey);
    examGuard?.disarm();
  }
</script>

<svelte:head><title>Tes EPPS</title></svelte:head>

<div class="lp-wrap flex flex-col gap-6">
  <header class="flex flex-col gap-1.5">
    <p class="lp-kicker">Edwards Personal Preference Schedule</p>
    <h2 class="lp-display text-3xl sm:text-4xl">Tes EPPS</h2>
  </header>

  {#if data.unavailable}
    <div class="lp-card lp-card-pad">
      <p>Tes EPPS belum tersedia atau sudah diselesaikan.</p>
      <a class="lp-btn lp-btn-outline mt-3" href="/student-dashboard">Kembali</a>
    </div>
  {:else if totalQuestions !== 225}
    <div class="lp-card lp-card-pad">
      <p class="lp-error">Soal EPPS belum lengkap. Silakan hubungi administrator.</p>
    </div>
  {:else}
    <form
      method="POST"
      use:enhance={() => {
        loading = true;
        return async ({ result, update }) => {
          loading = false;
          if (result.type === 'redirect') done();
          await update();
        };
      }}
    >
      <input type="hidden" name="assignmentId" value={data.assignmentId ?? 0} />
      <input type="hidden" name="gender" value={gender} />
      {#each Object.entries(answers) as [no, choice]}
        <input type="hidden" name="answer_{no}" value={choice} />
      {/each}

      {#if step === 0}
        <section class="lp-card lp-card-pad flex flex-col gap-4">
          <h3 class="lp-display text-xl">Petunjuk Pengerjaan</h3>
          <p class="lp-lead text-sm">
            Tes ini berisi 225 pasangan pernyataan. Pada setiap nomor, pilih satu pernyataan—A atau B—yang paling
            menggambarkan diri Anda. Tidak ada jawaban benar atau salah.
          </p>
          <label class="flex max-w-sm flex-col gap-2">
            <span class="font-medium">Jenis kelamin</span>
            <select class="lp-input" bind:value={gender} required>
              <option value="">Pilih</option>
              <option value="LAKI-LAKI">Laki-Laki</option>
              <option value="PEREMPUAN">Perempuan</option>
            </select>
          </label>
        </section>
      {:else if current}
        <section class="lp-card lp-card-pad flex flex-col gap-4">
          <div class="flex items-baseline justify-between gap-3">
            <h3 class="font-semibold">Pertanyaan {current.no} dari {totalQuestions}</h3>
            <span class="lp-muted text-xs">{answered}/{totalQuestions} terjawab</span>
          </div>
          <p class="lp-muted text-sm">Pilih satu pernyataan yang lebih menggambarkan diri Anda:</p>
          <div class="flex flex-col gap-3">
            <label class="lp-choice" class:selected={answers[current.no] === 'A'}>
              <input
                type="radio"
                checked={answers[current.no] === 'A'}
                onchange={() => choose(current.no, 'A')}
                class="sr-only"
              />
              <span class="lp-choice-dot" aria-hidden="true"></span>
              <span class="lp-choice-label"><strong>A.</strong> {current.statementA}</span>
            </label>
            <label class="lp-choice" class:selected={answers[current.no] === 'B'}>
              <input
                type="radio"
                checked={answers[current.no] === 'B'}
                onchange={() => choose(current.no, 'B')}
                class="sr-only"
              />
              <span class="lp-choice-dot" aria-hidden="true"></span>
              <span class="lp-choice-label"><strong>B.</strong> {current.statementB}</span>
            </label>
          </div>
        </section>
      {/if}

      {#if form?.error}<p class="lp-error mt-4">{form.error}</p>{/if}

      <div class="mt-4 flex flex-col gap-3">
        <div class="lp-muted flex items-center justify-between text-sm">
          <span>Langkah {step + 1} dari {totalQuestions + 1} · {answered}/{totalQuestions} terjawab</span>
          <span>{Math.round(((step + 1) / (totalQuestions + 1)) * 100)}%</span>
        </div>
        <div class="lp-progress"><div style="width: {((step + 1) / (totalQuestions + 1)) * 100}%"></div></div>

        <div class="mt-1 flex items-center justify-between gap-3">
          <button class="lp-btn lp-btn-outline" type="button" disabled={step === 0} onclick={() => step--}>
            Sebelumnya
          </button>
          {#if step < totalQuestions}
            <button class="lp-btn lp-btn-primary" type="button" disabled={!currentStepAnswered} onclick={() => step++}>
              Selanjutnya
            </button>
          {:else}
            <button class="lp-btn lp-btn-primary" type="submit" disabled={loading || answered !== totalQuestions}>
              {loading ? 'Mengirim...' : 'Kirim Jawaban'}
            </button>
          {/if}
        </div>
      </div>
    </form>
  {/if}
</div>
