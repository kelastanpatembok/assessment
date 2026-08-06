<script lang="ts">
  import { enhance } from '$app/forms';
  import { dev } from '$app/environment';
  import { getContext, onMount, tick } from 'svelte';

  let { data, form } = $props();
  let loading = $state(false);
  let formEl: HTMLFormElement | undefined = $state();
  const examGuard = getContext<{ disarm: () => void }>('exam-guard');
  let activeSubtest = $state(0);

  // WAKTU PENYAJIAN TEST: SE 6m, WA 6m, AN 7m, GE 8m, RA 10m, ZR 10m, FA 7m, WU 9m.
  // ME has two phases: 3m to read/study, then 6m to answer.
  // Per-subtest countdown: moving on (manually or on timeout) is one-way — once a
  // subtest is left, it can't be revisited, so there's no "Sebelumnya" button.
  const SUBTEST_DURATIONS_SEC: Record<string, number> = {
    SE: 360, WA: 360, AN: 420, GE: 480, RA: 600, ZR: 600, FA: 420, WU: 540,
  };
  const ME_MENGHAFAL_SEC = 180;
  const ME_MENGERJAKAN_SEC = 360;

  // Each subtest is preceded by an untimed instruction screen (the tester's spoken
  // instructions + worked examples, transcribed from the physical IST booklet). The
  // countdown only starts once the student leaves that screen — matching student-cfit's
  // pattern, since the timer must never run while they're still reading instructions.
  let subtestPhase: 'instruction' | 'testing' = $state('instruction');
  let mePhase: 'menghafal' | 'mengerjakan' = $state('menghafal');
  let remainingSeconds = $state(SUBTEST_DURATIONS_SEC.SE);
  let autoAdvancing = $state(false);

  // Real memorization word list for ME (Subtes 09), transcribed from the booklet's
  // "Halaman 17" — shown during the untimed instruction AND the timed 3-minute
  // menghafal phase. ME's actual 20 test items (157-176) ask which category a given
  // starting letter belongs to (see V21__ist_real_question_content.sql).
  const ME_WORD_LIST: { category: string; words: string }[] = [
    { category: 'BUNGA', words: 'Soka - Larat - Flamboyan - Yasmin - Dahlia' },
    { category: 'PERKAKAS', words: 'Wajan - Jarum - Kikir - Cangkul - Palu' },
    { category: 'BURUNG', words: 'Itik - Elang - Walet - Tekukur - Nuri' },
    { category: 'KESENIAN', words: 'Quintet - Arca - Opera - Gamelan - Ukiran' },
    { category: 'BINATANG', words: 'Musang - Rusa - Beruang - Zebra - Harimau' },
  ];

  const SUBTEST_INSTRUCTIONS: Record<string, { title: string; paragraphs: string[] }> = {
    SE: {
      title: 'Instruksi Subtes SE (Soal-soal No. 01-20)',
      paragraphs: [
        'Soal-soal 01-20 terdiri atas kalimat-kalimat. Pada setiap kalimat satu kata hilang dan disediakan 5 (lima) kata pilihan sebagai penggantinya. Pilihlah kata yang tepat yang dapat menyempurnakan kalimat itu!',
        'Contoh 01: "Seekor kuda mempunyai kesamaan terbanyak dengan seekor ......" — a) kucing b) bajing c) keledai d) lembu e) anjing. Jawaban yang benar ialah c) keledai.',
        'Contoh berikutnya: Lawannya "harapan" ialah ...... — a) duka b) putus asa c) sengsara d) cinta e) benci. Jawabannya ialah b) putus asa.',
      ],
    },
    WA: {
      title: 'Instruksi Subtes WA (Soal-soal No. 21-40)',
      paragraphs: [
        'Ditentukan 5 kata. Pada 4 dari 5 kata itu terdapat suatu kesamaan. Carilah kata yang kelima yang tidak memiliki kesamaan dengan keempat kata itu.',
        'Contoh 02: a) meja b) kursi c) burung d) lemari e) tempat tidur. a), b), d), dan e) ialah perabot rumah (meubel); c) burung bukan perabot rumah, sehingga tidak memiliki kesamaan dengan keempat kata itu. Jawaban yang benar ialah c) burung.',
        'Contoh berikutnya: a) duduk b) berbaring c) berdiri d) berjalan e) berjongkok. Pada a), b), c), dan e) orang berada dalam keadaan tidak bergerak, sedangkan d) orang dalam keadaan bergerak. Maka jawaban yang benar ialah d) berjalan.',
      ],
    },
    AN: {
      title: 'Instruksi Subtes AN (Soal-soal No. 41-60)',
      paragraphs: [
        'Ditentukan 3 (tiga) kata. Antara kata pertama dan kata kedua terdapat suatu hubungan tertentu. Carilah, di antara lima kata pilihan, kata yang mempunyai hubungan yang sama itu dengan kata ketiga.',
        'Contoh 03: Hutan : pohon = ? : tembok — a) batu bata b) rumah c) semen d) putih e) dinding. Hutan terdiri atas pohon-pohon, maka tembok terdiri atas batu-batu bata. Jawaban yang benar ialah a) batu bata.',
        'Contoh berikutnya: Gelap : terang = basah : ? — a) hujan b) hari c) lembab d) angin e) kering. Gelap ialah lawannya terang, maka lawannya basah ialah kering. Jawaban yang benar ialah e) kering.',
      ],
    },
    GE: {
      title: 'Instruksi Subtes GE (Soal-soal No. 61-76)',
      paragraphs: [
        'Ditentukan dua kata. Carilah satu perkataan yang meliputi pengertian kedua kata tadi, lalu tuliskan perkataan itu pada kotak jawaban yang sesuai.',
        'Contoh 04: "Ayam - itik" — jawabannya ialah "burung".',
        'Contoh berikutnya: "Gaun - celana" — jawabannya ialah "pakaian".',
      ],
    },
    RA: {
      title: 'Instruksi Subtes RA (Soal-soal No. 77-96)',
      paragraphs: [
        'Persoalan berikutnya ialah soal-soal hitungan. Kerjakan setiap soal dan tuliskan jawabannya berupa angka.',
        'Contoh 05: "Sebatang pensil harganya 25 rupiah. Berapakah harga 3 batang?" Jawabannya ialah 75.',
        'Contoh lain: "Dengan sepeda Husin dapat mencapai 15 km dalam waktu 1 jam. Berapa km-kah yang dapat ia capai dalam waktu 4 jam?" Jawabannya ialah 60.',
      ],
    },
    ZR: {
      title: 'Instruksi Subtes ZR (Soal-soal No. 97-116)',
      paragraphs: [
        'Pada persoalan berikut akan diberikan deret angka. Setiap deret tersusun menurut suatu aturan tertentu dan dapat dilanjutkan menurut aturan itu. Carilah untuk setiap deret, angka berikutnya yang sesuai.',
        'Contoh 06: 2 4 6 8 10 12 14 ? — jawabannya ialah 16 (deret ini selalu didapat jika angka didepannya ditambah dengan 2).',
        'Contoh berikutnya: 9 7 10 8 11 9 12 ? — jawabannya ialah 10 (deret ini selalu berganti-ganti dikurangi dengan 2 dan ditambah dengan 3).',
      ],
    },
    FA: {
      title: 'Instruksi Subtes FA (Soal-soal No. 117-136)',
      paragraphs: [
        'Setiap soal memperlihatkan sesuatu bentuk tertentu yang terpotong menjadi beberapa bagian. Carilah di antara bentuk-bentuk pilihan (a, b, c, d, e) bentuk yang dapat dibangun dengan menyusun potongan-potongan itu, sehingga tidak ada kelebihan sudut atau ruang di antaranya.',
        'Contoh 07: potongan-potongan pada contoh, jika disusun (digabungkan), menghasilkan bentuk a.',
        'Contoh berikutnya: potongan-potongan contoh kedua, jika disusun, menghasilkan bentuk e.',
      ],
    },
    WU: {
      title: 'Instruksi Subtes WU (Soal-soal No. 137-156)',
      paragraphs: [
        'Ditentukan 5 (lima) buah kubus a, b, c, d, e yang masing-masing berbeda susunan tandanya. Setiap soal memperlihatkan salah satu kubus itu dalam kedudukan yang berbeda (diputar dan/atau digulingkan dalam pikiran Anda). Carilah kubus yang dimaksudkan itu.',
        'Contoh 08: kubus kedua pada contoh adalah kubus e.',
        'Contoh berikutnya: kubus ketiga adalah kubus b, kubus keempat adalah kubus c, dan kubus kelima adalah kubus d.',
      ],
    },
    ME: {
      title: 'Instruksi Subtes ME (Soal-soal No. 157-176)',
      paragraphs: [
        'Pada subtes ini akan diajukan sejumlah pertanyaan mengenai kata-kata yang telah Anda hafalkan. Sebelum menjawab, Anda akan diberi waktu 3 menit untuk menghafalkan sekelompok kata yang dikelompokkan menjadi 5 jenis: BUNGA, PERKAKAS, BURUNG, KESENIAN, dan BINATANG.',
        'Contoh 09: "Kata yang mempunyai huruf permulaan Q adalah suatu ......" — a) bunga b) perkakas c) burung d) kesenian e) binatang. Quintet termasuk dalam jenis kesenian, sehingga jawaban yang benar ialah d) kesenian.',
        'Contoh berikutnya: "Kata yang mempunyai huruf permulaan Z adalah suatu ......" Jawabannya ialah e) binatang, karena Zebra termasuk dalam jenis binatang.',
      ],
    },
  };

  function formatTime(sec: number): string {
    const m = Math.floor(sec / 60);
    const s = sec % 60;
    return `${String(m).padStart(2, '0')}:${String(s).padStart(2, '0')}`;
  }

  function durationFor(index: number): number {
    const key = subtests[index]?.key;
    if (key === 'ME') return ME_MENGHAFAL_SEC;
    return SUBTEST_DURATIONS_SEC[key ?? ''] ?? 0;
  }

  function goToSubtest(index: number) {
    activeSubtest = index;
    subtestPhase = 'instruction';
    mePhase = 'menghafal';
    remainingSeconds = durationFor(index);
  }

  function startSubtestTesting() {
    subtestPhase = 'testing';
  }

  function startMeMengerjakan() {
    mePhase = 'mengerjakan';
    remainingSeconds = ME_MENGERJAKAN_SEC;
  }

  function advanceOrSubmit() {
    const key = subtests[activeSubtest]?.key;
    if (key === 'ME' && mePhase === 'menghafal') {
      startMeMengerjakan();
      return;
    }
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

  type IstQuestion = {
    id: number;
    subtestCode?: string; // absent for ZR (its own table/endpoint) — fall back to the subtest key
    itemNo: number;
    questionText?: string | null;
    sequenceText?: string | null; // ZR only
    imageUrl?: string | null;
    options?: Record<string, string> | null;
    optionImages?: string[] | null;
  };

  type Subtest = { key: string; label: string; questions: IstQuestion[] };
  let subtests: Subtest[] = $derived(data.subtests ?? []);
  let total = $derived(subtests.length);

  // ZR: numeric text input. FA/WU: image MC. Everything else: text MC (or free-text
  // fallback when no options are seeded, e.g. SE/WA/AN/GE/RA placeholder content).
  function isZR(key: string) { return key === 'ZR'; }
  function isImageMC(q: IstQuestion) { return !!q.optionImages && q.optionImages.length > 0; }
  function optionLetter(index: number): string { return String.fromCharCode(97 + index); }
  function optionEntries(q: IstQuestion): [string, string][] {
    if (!q.options) return [];
    return Object.entries(q.options);
  }

  // Dev-only helper: pressing "x" fills every question in the current subtest
  // with a random answer and advances, so manual QA can blast through all 9
  // subtests without answering each one by hand.
  function devFillRandomAndAdvance() {
    if (loading) return;
    if (subtestPhase === 'instruction') {
      startSubtestTesting();
      return;
    }
    const st = subtests[activeSubtest];
    if (st?.key === 'ME' && mePhase === 'menghafal') {
      startMeMengerjakan();
      return;
    }
    if (st) {
      for (const q of st.questions) {
        const name = `ist_${q.subtestCode ?? st.key}_${q.itemNo}`;
        if (isImageMC(q)) {
          const n = q.optionImages?.length ?? 0;
          if (n === 0) continue;
          const letter = optionLetter(Math.floor(Math.random() * n));
          const radio = formEl?.querySelector<HTMLInputElement>(
            `input[type="radio"][name="${name}"][value="${letter}"]`
          );
          if (radio) radio.checked = true;
        } else {
          const entries = optionEntries(q);
          if (entries.length > 0) {
            const [randKey] = entries[Math.floor(Math.random() * entries.length)];
            const radio = formEl?.querySelector<HTMLInputElement>(
              `input[type="radio"][name="${name}"][value="${randKey}"]`
            );
            if (radio) radio.checked = true;
          } else {
            const input = formEl?.querySelector<HTMLInputElement>(`input[type="text"][name="${name}"]`);
            if (input) input.value = String(Math.floor(Math.random() * 100));
          }
        }
      }
    }
    if (activeSubtest < total - 1) {
      goToSubtest(activeSubtest + 1);
    } else {
      tick().then(() => formEl?.requestSubmit());
    }
  }

  function handleDevKeydown(e: KeyboardEvent) {
    if (!dev) return;
    if (e.key.toLowerCase() !== 'x') return;
    e.preventDefault();
    devFillRandomAndAdvance();
  }
</script>

<svelte:head><title>Tes IQ IST</title></svelte:head>
<svelte:window onkeydown={handleDevKeydown} />

<div class="lp-wrap flex flex-col gap-6">
  <header class="flex flex-col gap-1.5">
    <p class="lp-kicker">Tes Kecerdasan IQ IST</p>
    <h2 class="lp-display text-3xl sm:text-4xl">Tes IQ IST</h2>
    <p class="lp-lead text-sm">Tes kecerdasan 9 subtes. Kerjakan setiap subtes dengan cermat.</p>
    {#if dev}
      <p class="mt-1 text-xs" style="color: var(--lp-ink-2)">
        Mode pengembangan: tekan <kbd class="lp-kbd">X</kbd> untuk melewati instruksi / mengisi subtes ini secara acak
        dan lanjut otomatis.
      </p>
    {/if}
  </header>

  {#if data.unavailable}
    <div class="lp-card lp-card-pad flex flex-col gap-3">
      <p class="lp-lead text-sm">Tes IST belum tersedia atau sudah Anda selesaikan.</p>
      <a href="/student-dashboard" class="lp-btn lp-btn-outline lp-btn-sm self-start">Kembali ke Dashboard</a>
    </div>
  {:else if form?.error}
    <div class="lp-error">{form.error}</div>
  {:else if subtests.length === 0}
    <div class="lp-card lp-card-pad"><p class="lp-lead text-sm">Tidak ada soal tersedia.</p></div>
  {:else}
    <!-- Subtest progress — navigation is forward-only (timer-driven or manual Next),
         so these are indicators, not clickable tabs; going back isn't possible. -->
    <div class="flex flex-wrap items-center justify-between gap-2">
      <div class="flex flex-wrap gap-2">
        {#each subtests as st, i}
          <span
            class="lp-tab {activeSubtest === i
              ? 'active'
              : i < activeSubtest
                ? 'done'
                : 'next'}"
          >{st.key}</span>
        {/each}
      </div>
      {#if subtestPhase === 'testing'}
        <div class="lp-timer {remainingSeconds <= 30 ? 'danger' : ''}">
          {formatTime(remainingSeconds)}
          {#if subtests[activeSubtest]?.key === 'ME'}
            <span class="lp-muted text-xs font-normal">({mePhase === 'menghafal' ? 'menghafal' : 'mengerjakan'})</span>
          {/if}
        </div>
      {:else}
        <div class="lp-muted text-sm">Waktu belum dimulai</div>
      {/if}
    </div>

    {#if subtestPhase === 'instruction'}
      <!-- Untimed instruction screen for the active subtest, transcribed from the
           physical IST booklet's own instruction+example page. The countdown for this
           subtest only starts once "Mulai Subtes" is clicked below. -->
      <div class="lp-card lp-card-pad flex flex-col gap-4">
        {#if SUBTEST_INSTRUCTIONS[subtests[activeSubtest]?.key ?? ''] !== undefined}
          {@const instr = SUBTEST_INSTRUCTIONS[subtests[activeSubtest]?.key ?? '']!}
          <h3 class="font-semibold">{instr.title}</h3>
          <div class="flex flex-col gap-2">
            {#each instr.paragraphs as p}
              <p class="lp-lead text-sm leading-relaxed">{p}</p>
            {/each}
          </div>
        {/if}
        {#if subtests[activeSubtest]?.key === 'ME'}
          <div class="lp-card-tint flex flex-col gap-1 rounded-xl p-3">
            <p class="text-xs font-semibold">Daftar kata yang akan dihafalkan (3 menit):</p>
            {#each ME_WORD_LIST as group}
              <p class="text-sm"><span class="font-medium">{group.category}</span>: {group.words}</p>
            {/each}
          </div>
        {/if}
        <div class="flex justify-end">
          <button type="button" class="lp-btn lp-btn-primary" onclick={startSubtestTesting}>
            Mulai Subtes {subtests[activeSubtest]?.key ?? ''}
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
      class={subtestPhase === 'instruction' ? 'hidden' : 'flex flex-col gap-4'}
    >
      <input type="hidden" name="assignmentId" value={data.assignmentId ?? 0} />
      {#each subtests as st, si}
        <div class={si === activeSubtest ? 'flex flex-col gap-4' : 'hidden'}>
          <div class="lp-card lp-card-pad flex flex-col gap-3">
            <div class="flex items-baseline justify-between gap-3">
              <h3 class="font-semibold">Subtes {st.key}</h3>
              <span class="lp-muted text-xs">{st.questions.length} soal</span>
            </div>

            {#if st.key === 'ME' && mePhase === 'menghafal'}
              <!-- ME menghafal phase: read-only study view of the real 5-category
                   word list (also shown on the instruction screen), no inputs yet. -->
              <p class="lp-muted text-sm">
                Bacalah dan hafalkan kata-kata berikut. Anda akan menjawab soal mengenainya setelah waktu menghafal habis.
              </p>
              <div class="flex flex-col gap-2">
                {#each ME_WORD_LIST as group}
                  <p class="text-sm"><span class="font-medium">{group.category}</span>: {group.words}</p>
                {/each}
              </div>
            {:else}
              {#each st.questions as q, qi}
                <div class="ist-item">
                  {#if q.questionText || q.sequenceText}
                    <p class="ist-q">{qi + 1}. {q.questionText ?? q.sequenceText}</p>
                  {:else}
                    <p class="ist-q">{qi + 1}.</p>
                  {/if}

                  {#if isImageMC(q)}
                    <!-- FA/WU: image stem + image options -->
                    {#if q.imageUrl}
                      <div>
                        <img src={q.imageUrl} alt="Soal {qi + 1}" class="ist-stem-img" />
                      </div>
                    {/if}
                    <div class="ist-img-options">
                      {#each q.optionImages ?? [] as optImg, oi}
                        {@const letter = optionLetter(oi)}
                        <label class="ist-img-opt">
                          <input
                            type="radio"
                            name="ist_{q.subtestCode ?? st.key}_{q.itemNo}"
                            value={letter}
                            class="sr-only"
                          />
                          <img src={optImg} alt="Opsi {letter}" class="ist-opt-img" />
                          <span class="ist-opt-letter">{letter}</span>
                        </label>
                      {/each}
                    </div>
                  {:else if isZR(st.key)}
                    <!-- ZR: text input -->
                    <input
                      type="text"
                      name="ist_{q.subtestCode ?? st.key}_{q.itemNo}"
                      placeholder="Jawaban Anda..."
                      class="lp-input"
                      inputmode="numeric"
                      autocomplete="off"
                    />
                  {:else if optionEntries(q).length > 0}
                    <!-- MC options -->
                    <div class="ist-mc">
                      {#each optionEntries(q) as [optKey, optVal]}
                        <label class="ist-mc-opt">
                          <input
                            type="radio"
                            name="ist_{q.subtestCode ?? st.key}_{q.itemNo}"
                            value={optKey}
                            class="sr-only"
                          />
                          <span class="ist-mc-key">{optKey}.</span>
                          <span class="ist-mc-label">{optVal}</span>
                        </label>
                      {/each}
                    </div>
                  {:else}
                    <!-- Text answer -->
                    <input
                      type="text"
                      name="ist_{q.subtestCode ?? st.key}_{q.itemNo}"
                      placeholder="Jawaban Anda..."
                      class="lp-input"
                      autocomplete="off"
                    />
                  {/if}
                </div>
              {/each}
            {/if}
          </div>
        </div>
      {/each}

      <div class="flex items-center justify-between gap-3">
        <span class="lp-muted text-sm">{activeSubtest + 1} / {total}</span>

        {#if activeSubtest < total - 1}
          <button type="button" class="lp-btn lp-btn-primary" onclick={() => goToSubtest(activeSubtest + 1)}>
            Selanjutnya
          </button>
        {:else if subtests[activeSubtest]?.key === 'ME' && mePhase === 'menghafal'}
          <button type="button" class="lp-btn lp-btn-primary" onclick={startMeMengerjakan}>
            Lanjut ke Pengerjaan
          </button>
        {:else}
          <button type="submit" class="lp-btn lp-btn-primary" disabled={loading}>
            {loading ? 'Mengirim...' : 'Kirim Semua Jawaban'}
          </button>
        {/if}
      </div>
    </form>
  {/if}
</div>

<style>
  .ist-item {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
    padding: 1rem 0;
    border-bottom: 1px solid var(--lp-rule);
  }

  .ist-item:first-child {
    padding-top: 0;
  }

  .ist-item:last-child {
    border-bottom: 0;
    padding-bottom: 0;
  }

  .ist-q {
    font-size: 0.95rem;
    font-weight: 600;
    line-height: 1.55;
    min-width: 0;
    overflow-wrap: anywhere;
  }

  .ist-stem-img {
    width: 100%;
    max-width: 18rem;
    height: auto;
    border-radius: 0.75rem;
    border: 1px solid var(--lp-rule);
  }

  .ist-img-options {
    display: grid;
    grid-template-columns: repeat(3, minmax(0, 1fr));
    gap: 0.5rem;
  }

  .ist-img-opt {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 0.3rem;
    padding: 0.5rem 0.4rem;
    border: 1px solid var(--lp-rule-2);
    border-radius: 0.9rem;
    cursor: pointer;
    transition: background-color 200ms var(--lp-ease-out), border-color 200ms var(--lp-ease-out);
  }

  .ist-img-opt:hover {
    border-color: var(--lp-accent);
  }

  .ist-img-opt:has(input:checked) {
    background: var(--lp-accent-bg);
    border-color: var(--lp-accent);
  }

  .ist-opt-img {
    height: 4rem;
    width: auto;
    border-radius: 0.4rem;
  }

  .ist-opt-letter {
    font-size: 0.78rem;
    font-weight: 650;
    color: var(--lp-muted);
    text-transform: uppercase;
  }

  .ist-mc {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(8.5rem, 1fr));
    gap: 0.5rem;
  }

  .ist-mc-opt {
    display: flex;
    align-items: flex-start;
    gap: 0.4rem;
    min-height: 2.75rem;
    padding: 0.6rem 0.8rem;
    border: 1px solid var(--lp-rule-2);
    border-radius: 0.9rem;
    cursor: pointer;
    transition: background-color 200ms var(--lp-ease-out), border-color 200ms var(--lp-ease-out);
  }

  .ist-mc-opt:hover {
    border-color: var(--lp-accent);
  }

  .ist-mc-opt:has(input:checked) {
    background: var(--lp-accent-bg);
    border-color: var(--lp-accent);
  }

  .ist-mc-key {
    flex: none;
    font-weight: 700;
    color: var(--lp-accent-deep);
  }

  .ist-mc-label {
    font-size: 0.9rem;
    line-height: 1.45;
  }

  @media (min-width: 40rem) {
    .ist-img-options {
      grid-template-columns: repeat(5, minmax(0, 1fr));
    }
  }
</style>
