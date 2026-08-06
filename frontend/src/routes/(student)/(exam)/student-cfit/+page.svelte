<script lang="ts">
  import { enhance } from '$app/forms';
  import { dev } from '$app/environment';
  import { getContext, onMount, tick } from 'svelte';

  let { data, form } = $props();
  let loading = $state(false);
  let formEl: HTMLFormElement | undefined = $state();
  const examGuard = getContext<{ disarm: () => void }>('exam-guard');
  let activeSubtest = $state(0);

  // Waktu Tes CFIT: Subtes 1 = 3 menit, 2 = 4 menit, 3 = 3 menit, 4 = 2,5 menit.
  // Per-subtest countdown: moving on (manually or on timeout) is one-way — once a
  // subtest is left, it can't be revisited, so there's no "Sebelumnya" button.
  const SUBTEST_DURATIONS_SEC = [180, 240, 180, 150];

  // Each subtest is preceded by an untimed instruction screen (the tester's
  // spoken instructions + worked examples, read from the physical test manual).
  // The countdown only starts once the student leaves that screen — it must
  // never run while they're still reading instructions.
  let subtestPhase: 'instruction' | 'testing' = $state('instruction');
  let remainingSeconds = $state(SUBTEST_DURATIONS_SEC[0]);
  let autoAdvancing = $state(false);

  // The opening speech isn't part of any subtest — it gets its own untimed
  // "Intro" tab ahead of Subtes 1, matching the physical test's opening script.
  let introDone = $state(false);

  function timeGreeting(): string {
    const hour = new Date().getHours();
    if (hour < 11) return 'pagi';
    if (hour < 15) return 'siang';
    if (hour < 19) return 'sore';
    return 'malam';
  }

  function introParagraphs(): string[] {
    return [
      `Selamat ${timeGreeting()}… Terima kasih atas kehadiran Anda pada hari ini.`,
      'Hari ini kita akan menjalani salah satu pemeriksaan psikologis. Tes ini berjudul CFIT skala 3 bentuk B dan terdiri dari 4 subtes yang masing-masing memiliki durasi waktu tersendiri, jadi harap Anda mengerjakan secepat mungkin namun bukan berarti asal-asalan.',
      'Anda tidak diperkenankan untuk membuka subtes selanjutnya sebelum ada instruksi. Setiap subtes dimulai dan diakhiri bersama-sama sesuai waktu yang ditentukan. Selama pemeriksaan berlangsung, Anda tidak diperkenankan untuk mencorat-coret buku tes.',
    ];
  }

  const SUBTEST_INSTRUCTIONS: Record<
    number,
    { title: string; paragraphs: string[]; exampleImages?: string[] }
  > = {
    1: {
      title: 'Instruksi Subtes 1',
      paragraphs: [
        'Silahkan anda membuka halaman satu. Instruksinya sederhana, anda diminta untuk melengkapi kotak keempat pada tiap soal. Kita lihat bersama, pada kotak pertama, terdapat gambar lingkaran yang besar, kotak kedua lingkaran mengecil, pada kotak yang ketiga lingkaran semakin mengecil. Maka pada kotak keempat, gambar yang paling tepat adalah....C. Kotak keempat adalah jawaban yang paling tepat sesuai dengan pola pada gambar kotak-kotak sebelumnya.',
        'Contoh ke 2, pada kotak pertama terlihat ada 1 garis, kotak kedua ada dua garis, kotak ketiga terdapat tiga garis, maka jawaban yang paling tepat adalah....E.',
        'Pada contoh soal ke tiga, terlihat kotak yang paling kanan ada gambar titik di atas X, kotak kedua, X dan titiknya bergerak berputar searah jarum jam sebanyak 45 derajat, kotak ketiga pun kembali berputar 45 derajat, maka pada kotak yang keempat, jawaban yang tepat adalah...E.',
      ],
      exampleImages: ['/cfit/examples/1.webp'],
    },
    2: {
      title: 'Instruksi Subtes 2',
      paragraphs: [
        'Pada subtes ini, cara menjawab persoalannya berbeda dengan subtes 1. Ada 5 kotak yang pada masing-masing kotak memiliki gambarnya tersendiri. Apabila anda lihat maka akan ada 2 gambar yang berbeda dari 3 gambar lainnya. Tugas anda adalah menentukan mana 2 gambar yang berbeda dari 3 gambar lainnya.',
        'Contoh: Pada contoh pertama, dapatkah anda melihat 2 gambar yang berbeda dari 3 gambar lainnya? Terlihat gambar pada kotak B dan D berbeda dari 3 gambar di kotak lainnya. Maka jawabannya adalah B dan D.',
        'Pada contoh ke 2, mana 2 gambar yang berbeda dari 3 gambar yang lainnya. Terlihat pada kotak C dan E gambarnya berbeda dengan 3 kotak lainnya. Segi empat pada kotak ini memiliki isi/buram/ada titik-titiknya, sedangkan pada 3 kotak lainnya, lingkarannya tidak berisi apa-apa.',
      ],
      exampleImages: ['/cfit/examples/3.webp'],
    },
    3: {
      title: 'Instruksi Subtes 3',
      paragraphs: [
        'Pada subtes ini, anda diminta untuk mencari pola gambar yang tepat untuk mengisi kotak yang kosong.',
        'Pada contoh pertama, anda melihat kotak di atas yaitu kotak pertama, kotak dengan dua garis hitam yang berdekatan satu garis menjauh. Pada kotak kedua, tiga garis saling berjauhan. Kotak ketiga polanya sama dengan pola kotak di atasnya, sehingga jawaban yang paling tepat untuk kotak keempat adalah....B.',
        'Contoh no 2, ada gambar tangan saling bertolak belakang di 2 kotak atas, di kotak kiri bawah, ada gambar tangan dengan titik-titik hitam di badannya. Maka jawaban untuk kotak yang kosong yang paling tepat adalah...C.',
        'Contoh ke 3, ada 1 segiempat pada kotak atas dengan warna gelap, dan bawah sebelah kiri tanpa warna dan 2 segiempat pada kotak kanan atas berwarna gelap. Maka gambar kotak kanan bawah yang paling tepat adalah...A.',
      ],
      exampleImages: [
        '/cfit/revisi/examples/t3-1.jpg',
        '/cfit/revisi/examples/t3-2.jpg',
        '/cfit/revisi/examples/t3-3.jpg',
      ],
    },
    4: {
      title: 'Instruksi Subtes 4',
      paragraphs: [
        'Pada subtes 4 ini agak berbeda dengan 3 subtes sebelumnya. Jika anda lihat, ada kotak di sebelah kiri dan kotak pilihan jawaban di sebelah kanannya. Ada 3 unsur bentuk dalam kotak sebelah kiri: titik, dan 2 bentuk lainnya. Tugas anda adalah memilih gambar dimana anda dapat meletakkan posisi titik yang tidak berbeda komposisinya dengan gambar contoh.',
        'Contoh: Misalnya pada gambar pertama, posisi titik berada dalam perpotongan bentuk persegi dan lingkaran. Maka jawaban yang benar adalah C, karena posisi titik masih berada dalam perpotongan persegi dan lingkaran.',
        'Contoh kedua, posisi titik berada dalam area dua buah segitiga yang saling berpotongan. Maka jawaban yang benar adalah D, karena posisi titik masih bisa ditempatkan dalam dua buah segitiga.',
        'Contoh ketiga, posisi titik berada di atas garis lengkung dan berada di dalam segiempat. Maka jawaban yang benar adalah B, karena titik masih dapat ditempatkan di atas garis lengkung dan di dalam segiempat.',
      ],
      exampleImages: ['/cfit/examples/6.webp'],
    },
  };

  function formatTime(sec: number): string {
    const m = Math.floor(sec / 60);
    const s = sec % 60;
    return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
  }

  function goToSubtest(index: number) {
    activeSubtest = index;
    subtestPhase = 'instruction';
    remainingSeconds = SUBTEST_DURATIONS_SEC[index] ?? 0;
  }

  function startSubtestTesting() {
    subtestPhase = 'testing';
  }

  function advanceOrSubmit() {
    if (activeSubtest < total - 1) {
      goToSubtest(activeSubtest + 1);
    } else if (!autoAdvancing) {
      autoAdvancing = true;
      tick().then(() => formEl?.requestSubmit());
    }
  }

  onMount(() => {
    const id = setInterval(() => {
      if (loading || autoAdvancing || subtests.length === 0 || subtestPhase !== 'testing') return;
      if (remainingSeconds <= 1) {
        remainingSeconds = 0;
        advanceOrSubmit();
      } else {
        remainingSeconds -= 1;
      }
    }, 1000);
    return () => clearInterval(id);
  });

  type CfitQuestion = {
    id: number;
    subtestNo: number;
    itemNo: number;
    stemImageUrl?: string | null;
    optionImages: string[];
  };

  type Subtest = { key: string; label: string; subtestNo: number; questions: CfitQuestion[] };
  let subtests: Subtest[] = $derived(data.subtests ?? []);
  let total = $derived(subtests.length);

  function fieldKey(q: CfitQuestion): string {
    return `st${q.subtestNo}_q${q.itemNo}`;
  }

  function optionLetter(index: number): string {
    return String.fromCharCode(97 + index);
  }

  // Subtest 2 (Classification) has no stem image and requires picking exactly 2 options
  // that match each other — every other subtest is a single-pick radio group.
  let checkedOptions: Record<string, string[]> = $state({});

  function isChecked(key: string, letter: string): boolean {
    return (checkedOptions[key] ?? []).includes(letter);
  }

  function isDisabled(key: string, letter: string): boolean {
    const current = checkedOptions[key] ?? [];
    return current.length >= 2 && !current.includes(letter);
  }

  function toggleOption(key: string, letter: string, checked: boolean) {
    const current = checkedOptions[key] ?? [];
    if (checked) {
      if (current.length < 2) checkedOptions[key] = [...current, letter];
    } else {
      checkedOptions[key] = current.filter((l) => l !== letter);
    }
  }

  // Tracks the radio pick per question (every subtest except 2) so "Selanjutnya"/submit
  // can be disabled until the active subtest's every item has an answer.
  let selectedAnswers: Record<string, string> = $state({});

  // Whether every item in the currently-active subtest has been answered — gates both
  // "Selanjutnya" and the final "Kirim Semua Jawaban" button, since students must not be
  // able to skip past unanswered items in any of the 4 subtests.
  let currentSubtestComplete = $derived.by(() => {
    const st = subtests[activeSubtest];
    if (!st) return false;
    if (st.subtestNo === 2) {
      return st.questions.every((q) => (checkedOptions[fieldKey(q)] ?? []).length === 2);
    }
    return st.questions.every((q) => !!selectedAnswers[fieldKey(q)]);
  });

  // Dev-only answer key, hardcoded from V19__cfit_real_answers.sql. Never sent by the
  // API (CfitController.CfitQuestionView deliberately omits correctAnswer/correctAnswer2
  // — see docs/todo-cfit-test.md), so the "always right" QA hotkey below embeds it
  // directly. Safe: `dev` is inlined to `false` in production builds and this whole
  // branch (including this map) is dead-code-eliminated from the shipped bundle, same
  // as the rest of the X/Y dev tooling in this file.
  const CFIT_CORRECT_ANSWERS: Record<string, string> = {
    st1_q1: 'b', st1_q2: 'c', st1_q3: 'b', st1_q4: 'd', st1_q5: 'e', st1_q6: 'b',
    st1_q7: 'd', st1_q8: 'b', st1_q9: 'f', st1_q10: 'c', st1_q11: 'b', st1_q12: 'b', st1_q13: 'b',
    st2_q1: 'be', st2_q2: 'ae', st2_q3: 'ad', st2_q4: 'ce', st2_q5: 'be', st2_q6: 'ad',
    st2_q7: 'be', st2_q8: 'be', st2_q9: 'ad', st2_q10: 'bd', st2_q11: 'ae', st2_q12: 'cd', st2_q13: 'bc',
    st3_q1: 'e', st3_q2: 'e', st3_q3: 'e', st3_q4: 'b', st3_q5: 'c', st3_q6: 'd',
    st3_q7: 'e', st3_q8: 'e', st3_q9: 'a', st3_q10: 'a', st3_q11: 'f', st3_q12: 'c', st3_q13: 'c',
    st4_q1: 'b', st4_q2: 'a', st4_q3: 'd', st4_q4: 'd', st4_q5: 'a',
    st4_q6: 'b', st4_q7: 'c', st4_q8: 'd', st4_q9: 'a', st4_q10: 'd',
  };

  // Shared tail for both dev-fill hotkeys: skip the intro/instruction screens, fill
  // every question in the active subtest via `pickAnswer`, then advance/submit.
  function devFillAndAdvance(pickAnswer: (q: CfitQuestion, key: string) => string) {
    if (loading) return;
    if (!introDone) {
      introDone = true;
      return;
    }
    if (subtestPhase === 'instruction') {
      startSubtestTesting();
      return;
    }
    const st = subtests[activeSubtest];
    if (st) {
      for (const q of st.questions) {
        const key = fieldKey(q);
        if (q.optionImages.length === 0) continue;
        const answer = pickAnswer(q, key);
        if (q.subtestNo === 2) {
          checkedOptions[key] = answer.split('');
        } else {
          selectedAnswers[key] = answer;
        }
      }
    }
    if (activeSubtest < total - 1) {
      goToSubtest(activeSubtest + 1);
    } else {
      tick().then(() => formEl?.requestSubmit());
    }
  }

  // "x": fills every question in the current subtest tab with a random option and
  // advances, so manual QA can blast through all 4 subtests without clicking through
  // every image.
  function devFillRandomAndAdvance() {
    devFillAndAdvance((q) => {
      if (q.subtestNo === 2) {
        const indices = [...Array(q.optionImages.length).keys()];
        for (let i = indices.length - 1; i > 0; i--) {
          const j = Math.floor(Math.random() * (i + 1));
          [indices[i], indices[j]] = [indices[j], indices[i]];
        }
        return indices.slice(0, Math.min(2, q.optionImages.length)).map(optionLetter).join('');
      }
      return optionLetter(Math.floor(Math.random() * q.optionImages.length));
    });
  }

  // "y": fills every question in the current subtest tab with the REAL correct answer
  // and advances, so a full run produces the maximum possible score — the only way to
  // manually QA the high end of the IQ conversion table (V20__cfit_real_iq_norms.sql)
  // without a real 49/49 test-taker, since "x" is random and averages a low score.
  function devFillCorrectAndAdvance() {
    devFillAndAdvance((q, key) => CFIT_CORRECT_ANSWERS[key] ?? optionLetter(0));
  }

  function handleDevKeydown(e: KeyboardEvent) {
    if (!dev) return;
    const key = e.key.toLowerCase();
    if (key === 'x') {
      e.preventDefault();
      devFillRandomAndAdvance();
    } else if (key === 'y') {
      e.preventDefault();
      devFillCorrectAndAdvance();
    }
  }
</script>

<svelte:head><title>Tes IQ CFIT</title></svelte:head>
<svelte:window onkeydown={handleDevKeydown} />

<div class="lp-wrap flex flex-col gap-6">
  <header class="flex flex-col gap-1.5">
    <p class="lp-kicker">Tes Kecerdasan IQ CFIT</p>
    <h2 class="lp-display text-3xl sm:text-4xl">Tes IQ CFIT</h2>
    <p class="lp-lead text-sm">Jawab setiap soal dengan memilih jawaban yang paling tepat.</p>
    {#if dev}
      <p class="mt-1 text-xs" style="color: var(--lp-ink-2)">
        Mode pengembangan: tekan <kbd class="lp-kbd">X</kbd> untuk mengisi subtes ini secara acak dan lanjut otomatis,
        atau <kbd class="lp-kbd">Y</kbd> untuk mengisi dengan jawaban benar (skor maksimal).
      </p>
    {/if}
  </header>

  {#if data.unavailable}
    <div class="lp-card lp-card-pad flex flex-col gap-3">
      <p class="lp-lead text-sm">Tes CFIT belum tersedia atau sudah Anda selesaikan.</p>
      <a href="/student-dashboard" class="lp-btn lp-btn-outline lp-btn-sm self-start">Kembali ke Dashboard</a>
    </div>
  {:else if form?.error}
    <div class="lp-error">{form.error}</div>
  {:else if subtests.length === 0}
    <div class="lp-card lp-card-pad"><p class="lp-lead text-sm">Tidak ada soal tersedia.</p></div>
  {:else}
    <!-- Progress — navigation is forward-only (timer-driven or manual Next),
         so these are indicators, not clickable tabs; going back isn't possible. -->
    <div class="flex flex-wrap items-center justify-between gap-2">
      <div class="flex flex-wrap gap-2">
        <span
          class="lp-tab {!introDone ? 'active' : 'done'}"
        >Intro</span>
        {#each subtests as st, i}
          <span
            class="lp-tab {introDone && activeSubtest === i
              ? 'active'
              : introDone && i < activeSubtest
                ? 'done'
                : 'next'}"
          >{st.label}</span>
        {/each}
      </div>
      {#if introDone && subtestPhase === 'testing'}
        <div class="lp-timer {remainingSeconds <= 30 ? 'danger' : ''}">{formatTime(remainingSeconds)}</div>
      {:else}
        <div class="lp-muted text-sm">Waktu belum dimulai</div>
      {/if}
    </div>

    {#if !introDone}
      <!-- Untimed opening speech, read from the tester's opening script. Not part
           of any subtest — its own tab, shown once before Subtes 1's instructions. -->
      <div class="lp-card lp-card-pad flex flex-col gap-4">
        <div class="flex flex-col gap-2">
          {#each introParagraphs() as p}
            <p class="lp-lead text-sm leading-relaxed">{p}</p>
          {/each}
        </div>
        <div class="flex justify-end">
          <button type="button" class="lp-btn lp-btn-primary" onclick={() => (introDone = true)}>Lanjut</button>
        </div>
      </div>
    {:else if subtestPhase === 'instruction'}
      <!-- Untimed instruction screen for the active subtest, read from the tester's
           spoken script + worked examples in the physical CFIT manual. The countdown
           for this subtest only starts once "Mulai Subtes" is clicked below. -->
      <div class="lp-card lp-card-pad flex flex-col gap-4">
        {#if SUBTEST_INSTRUCTIONS[activeSubtest + 1] !== undefined}
          {@const instr = SUBTEST_INSTRUCTIONS[activeSubtest + 1]!}
          <h3 class="font-semibold">{instr.title}</h3>

          {#if instr.exampleImages?.length}
            <div class="lp-card-tint overflow-hidden">
              {#each instr.exampleImages as exampleImage, index}
                <img
                  src={exampleImage}
                  alt="Contoh {index + 1} {instr.title}"
                  class="h-auto w-full object-contain {index > 0 ? 'lp-hairline-top' : ''}"
                  loading="lazy"
                />
              {/each}
            </div>
          {/if}

          <div class="flex flex-col gap-2">
            {#each instr.paragraphs as p}
              <p class="lp-lead text-sm leading-relaxed">{p}</p>
            {/each}
          </div>
        {/if}
        <div class="flex justify-end">
          <button type="button" class="lp-btn lp-btn-primary" onclick={startSubtestTesting}>
            Mulai {subtests[activeSubtest]?.label ?? 'Subtes'}
          </button>
        </div>
      </div>
    {/if}

    <form
      method="POST"
      bind:this={formEl}
      use:enhance={() => {
        loading = true;
        return async ({ result, update }) => {
          loading = false;
          if (result.type === 'redirect') examGuard?.disarm();
          await update();
        };
      }}
      class={!introDone || subtestPhase === 'instruction' ? 'hidden' : 'flex flex-col gap-4'}
    >
      <input type="hidden" name="assignmentId" value={data.assignmentId ?? 0} />

      {#each subtests as st, si}
        <div class={si === activeSubtest ? 'flex flex-col gap-4' : 'hidden'}>
          {#each st.questions as q, qi}
            {@const key = fieldKey(q)}
            <div class="lp-card lp-card-pad flex flex-col gap-3">
              <div class="flex flex-wrap items-baseline justify-between gap-2">
                <h3 class="text-sm font-semibold">
                  {st.label} — Soal {qi + 1}
                  {#if q.subtestNo === 2}
                    <span class="lp-muted ml-2 font-normal">(pilih tepat 2 gambar yang berpasangan)</span>
                  {/if}
                </h3>
                <span class="lp-muted text-xs">{qi + 1}/{st.questions.length}</span>
              </div>
              {#if q.stemImageUrl}
                <div>
                  <img src={q.stemImageUrl} alt="Soal {qi + 1}" class="cfit-stem-img" />
                </div>
              {/if}
              <div class="cfit-options">
                {#each q.optionImages as optImg, oi}
                  {@const letter = optionLetter(oi)}
                  <label
                    class="cfit-opt"
                    class:sel={q.subtestNo === 2 ? isChecked(key, letter) : selectedAnswers[key] === letter}
                    class:disabled={isDisabled(key, letter)}
                  >
                    {#if q.subtestNo === 2}
                      <input
                        type="checkbox"
                        name="{key}[]"
                        value={letter}
                        class="sr-only"
                        checked={isChecked(key, letter)}
                        disabled={isDisabled(key, letter)}
                        onchange={(e) => toggleOption(key, letter, e.currentTarget.checked)}
                      />
                    {:else}
                      <input
                        type="radio"
                        name={key}
                        value={letter}
                        class="sr-only"
                        checked={selectedAnswers[key] === letter}
                        onchange={() => (selectedAnswers[key] = letter)}
                      />
                    {/if}
                    <img src={optImg} alt="Opsi {letter}" class="cfit-opt-img" />
                    <span class="cfit-opt-letter">{letter}</span>
                  </label>
                {/each}
              </div>
            </div>
          {/each}
        </div>
      {/each}

      <div class="flex items-center justify-end">
        {#if activeSubtest < total - 1}
          <div class="flex flex-col items-end gap-1">
            <button
              type="button"
              class="lp-btn lp-btn-primary"
              onclick={() => goToSubtest(activeSubtest + 1)}
              disabled={!currentSubtestComplete}
            >
              Selanjutnya
            </button>
            {#if !currentSubtestComplete}
              <span class="lp-muted text-xs">Jawab semua soal di subtes ini terlebih dahulu.</span>
            {/if}
          </div>
        {:else}
          <div class="flex flex-col items-end gap-1">
            <button type="submit" class="lp-btn lp-btn-primary" disabled={loading || !currentSubtestComplete}>
              {loading ? 'Mengirim...' : 'Kirim Semua Jawaban'}
            </button>
            {#if !currentSubtestComplete}
              <span class="lp-muted text-xs">Jawab semua soal di subtes ini terlebih dahulu.</span>
            {/if}
          </div>
        {/if}
      </div>
    </form>
  {/if}
</div>

<style>
  .cfit-stem-img {
    width: 100%;
    max-width: 18rem;
    height: auto;
    border-radius: 0.75rem;
    border: 1px solid var(--lp-rule);
  }

  .cfit-options {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 0.6rem;
  }

  .cfit-opt {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.35rem;
    padding: 0.55rem 0.4rem;
    border: 1px solid var(--lp-rule-2);
    border-radius: 0.9rem;
    cursor: pointer;
    transition:
      background-color 200ms var(--lp-ease-out),
      border-color 200ms var(--lp-ease-out),
      opacity 200ms var(--lp-ease-out);
  }

  .cfit-opt:hover {
    border-color: var(--lp-accent);
  }

  .cfit-opt.sel {
    background: var(--lp-accent-bg);
    border-color: var(--lp-accent);
  }

  .cfit-opt.disabled {
    opacity: 0.4;
    cursor: not-allowed;
  }

  .cfit-opt-img {
    height: 4rem;
    width: auto;
    border-radius: 0.4rem;
  }

  .cfit-opt-letter {
    font-size: 0.78rem;
    font-weight: 650;
    color: var(--lp-muted);
    text-transform: uppercase;
  }

  .cfit-opt.sel .cfit-opt-letter {
    color: var(--lp-accent-deep);
  }

  .lp-hairline-top {
    border-top: 1px solid var(--lp-rule);
  }

  @media (min-width: 40rem) {
    .cfit-options {
      grid-template-columns: repeat(6, minmax(0, 1fr));
    }
  }
</style>
