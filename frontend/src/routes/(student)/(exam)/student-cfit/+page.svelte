<script lang="ts">
  import { enhance } from '$app/forms';
  import { dev } from '$app/environment';
  import { getContext, onMount, tick } from 'svelte';
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';

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

  const SUBTEST_INSTRUCTIONS: Record<number, { title: string; paragraphs: string[] }> = {
    1: {
      title: 'Instruksi Subtes 1',
      paragraphs: [
        'Silahkan anda membuka halaman satu. Instruksinya sederhana, anda diminta untuk melengkapi kotak keempat pada tiap soal. Kita lihat bersama, pada kotak pertama, terdapat gambar lingkaran yang besar, kotak kedua lingkaran mengecil, pada kotak yang ketiga lingkaran semakin mengecil. Maka pada kotak keempat, gambar yang paling tepat adalah....C. Kotak keempat adalah jawaban yang paling tepat sesuai dengan pola pada gambar kotak-kotak sebelumnya.',
        'Contoh ke 2, pada kotak pertama terlihat ada 1 garis, kotak kedua ada dua garis, kotak ketiga terdapat tiga garis, maka jawaban yang paling tepat adalah....E.',
        'Pada contoh soal ke tiga, terlihat kotak yang paling kanan ada gambar titik di atas X, kotak kedua, X dan titiknya bergerak berputar searah jarum jam sebanyak 45 derajat, kotak ketiga pun kembali berputar 45 derajat, maka pada kotak yang keempat, jawaban yang tepat adalah...E.',
      ],
    },
    2: {
      title: 'Instruksi Subtes 2',
      paragraphs: [
        'Pada subtes ini, cara menjawab persoalannya berbeda dengan subtes 1. Ada 5 kotak yang pada masing-masing kotak memiliki gambarnya tersendiri. Apabila anda lihat maka akan ada 2 gambar yang berbeda dari 3 gambar lainnya. Tugas anda adalah menentukan mana 2 gambar yang berbeda dari 3 gambar lainnya.',
        'Contoh: Pada contoh pertama, dapatkah anda melihat 2 gambar yang berbeda dari 3 gambar lainnya? Terlihat gambar pada kotak B dan D berbeda dari 3 gambar di kotak lainnya. Maka jawabannya adalah B dan D.',
        'Pada contoh ke 2, mana 2 gambar yang berbeda dari 3 gambar yang lainnya. Terlihat pada kotak C dan E gambarnya berbeda dengan 3 kotak lainnya. Segi empat pada kotak ini memiliki isi/buram/ada titik-titiknya, sedangkan pada 3 kotak lainnya, lingkarannya tidak berisi apa-apa.',
      ],
    },
    3: {
      title: 'Instruksi Subtes 3',
      paragraphs: [
        'Pada subtes ini, anda diminta untuk mencari pola gambar yang tepat untuk mengisi kotak yang kosong.',
        'Pada contoh pertama, anda melihat kotak di atas yaitu kotak pertama, kotak dengan dua garis hitam yang berdekatan satu garis menjauh. Pada kotak kedua, tiga garis saling berjauhan. Kotak ketiga polanya sama dengan pola kotak di atasnya, sehingga jawaban yang paling tepat untuk kotak keempat adalah....B.',
        'Contoh no 2, ada gambar tangan saling bertolak belakang di 2 kotak atas, di kotak kiri bawah, ada gambar tangan dengan titik-titik hitam di badannya. Maka jawaban untuk kotak yang kosong yang paling tepat adalah...C.',
        'Contoh ke 3, ada 1 segiempat pada kotak atas dengan warna gelap, dan bawah sebelah kiri tanpa warna dan 2 segiempat pada kotak kanan atas berwarna gelap. Maka gambar kotak kanan bawah yang paling tepat adalah...A.',
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

  let subtest2Complete = $derived(
    subtests
      .flatMap((st) => st.questions)
      .filter((q) => q.subtestNo === 2)
      .every((q) => (checkedOptions[fieldKey(q)] ?? []).length === 2)
  );

  // Dev-only helper: pressing "x" fills every question in the current subtest
  // tab with a random option and advances, so manual QA can blast through
  // all 4 subtests without clicking through every image. On the instruction
  // screen it just skips straight to the timed questions instead.
  function devFillRandomAndAdvance() {
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
        const n = q.optionImages.length;
        if (n === 0) continue;
        if (q.subtestNo === 2) {
          const indices = [...Array(n).keys()];
          for (let i = indices.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [indices[i], indices[j]] = [indices[j], indices[i]];
          }
          checkedOptions[key] = indices.slice(0, Math.min(2, n)).map(optionLetter);
        } else {
          const letter = optionLetter(Math.floor(Math.random() * n));
          const radio = formEl?.querySelector<HTMLInputElement>(
            `input[type="radio"][name="${key}"][value="${letter}"]`
          );
          if (radio) radio.checked = true;
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

<svelte:head><title>Tes IQ CFIT</title></svelte:head>
<svelte:window onkeydown={handleDevKeydown} />

<div class="flex max-w-3xl flex-col gap-6">
  <div>
    <h2 class="text-2xl font-bold">Tes IQ CFIT</h2>
    <p class="text-muted-foreground mt-1 text-sm">
      Jawab setiap soal dengan memilih jawaban yang paling tepat.
    </p>
    {#if dev}
      <p class="mt-1 text-xs text-amber-600">
        Dev mode: tekan <kbd class="rounded border px-1">X</kbd> untuk mengisi subtes ini secara acak dan lanjut otomatis.
      </p>
    {/if}
  </div>

  {#if data.unavailable}
    <Card>
      <CardContent class="pt-6">
        <p class="text-muted-foreground">Tes CFIT belum tersedia atau sudah Anda selesaikan.</p>
        <a href="/student-dashboard" class="text-primary mt-4 block text-sm hover:underline">Kembali ke Dashboard</a>
      </CardContent>
    </Card>
  {:else if form?.error}
    <div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">{form.error}</div>
  {:else if subtests.length === 0}
    <Card><CardContent class="pt-6"><p class="text-muted-foreground">Tidak ada soal tersedia.</p></CardContent></Card>
  {:else}
    <!-- Progress — navigation is forward-only (timer-driven or manual Next),
         so these are indicators, not clickable tabs; going back isn't possible. -->
    <div class="flex items-center justify-between gap-2">
      <div class="flex flex-wrap gap-2">
        <span
          class="rounded-lg px-4 py-2 text-sm {!introDone ? 'bg-primary text-primary-foreground' : 'bg-muted text-muted-foreground'}"
        >Intro</span>
        {#each subtests as st, i}
          <span
            class="rounded-lg px-4 py-2 text-sm {introDone && activeSubtest === i ? 'bg-primary text-primary-foreground' : introDone && i < activeSubtest ? 'bg-muted text-muted-foreground' : 'bg-secondary text-secondary-foreground'}"
          >{st.label}</span>
        {/each}
      </div>
      {#if introDone && subtestPhase === 'testing'}
        <div class="font-mono text-lg font-semibold {remainingSeconds <= 30 ? 'text-destructive' : ''}">
          {formatTime(remainingSeconds)}
        </div>
      {:else}
        <div class="text-muted-foreground text-sm">Waktu belum dimulai</div>
      {/if}
    </div>

    {#if !introDone}
      <!-- Untimed opening speech, read from the tester's opening script. Not part
           of any subtest — its own tab, shown once before Subtes 1's instructions. -->
      <Card>
        <CardContent class="flex flex-col gap-4 pt-6">
          <div class="flex flex-col gap-2">
            {#each introParagraphs() as p}
              <p class="text-sm leading-relaxed">{p}</p>
            {/each}
          </div>
          <div class="flex justify-end">
            <Button type="button" onclick={() => (introDone = true)}>Lanjut</Button>
          </div>
        </CardContent>
      </Card>
    {:else if subtestPhase === 'instruction'}
      <!-- Untimed instruction screen for the active subtest, read from the tester's
           spoken script + worked examples in the physical CFIT manual. The countdown
           for this subtest only starts once "Mulai Subtes" is clicked below. -->
      <Card>
        <CardContent class="flex flex-col gap-4 pt-6">
          {@const instr = SUBTEST_INSTRUCTIONS[activeSubtest + 1]}
          {#if instr}
            <h3 class="text-base font-semibold">{instr.title}</h3>
            <div class="flex flex-col gap-2">
              {#each instr.paragraphs as p}
                <p class="text-sm leading-relaxed">{p}</p>
              {/each}
            </div>
          {/if}
          <div class="flex justify-end">
            <Button type="button" onclick={startSubtestTesting}>
              Mulai {subtests[activeSubtest]?.label ?? 'Subtes'}
            </Button>
          </div>
        </CardContent>
      </Card>
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
            <Card>
              <CardHeader>
                <CardTitle class="text-sm font-medium">
                  {st.label} — Soal {qi + 1}
                  {#if q.subtestNo === 2}
                    <span class="text-muted-foreground ml-2 font-normal">(pilih tepat 2 gambar yang berpasangan)</span>
                  {/if}
                </CardTitle>
              </CardHeader>
              <CardContent>
                {#if q.stemImageUrl}
                  <div class="mb-4">
                    <img src={q.stemImageUrl} alt="Soal {qi + 1}" class="h-auto max-w-xs rounded-lg border" />
                  </div>
                {/if}
                <div class="grid grid-cols-3 gap-2 sm:grid-cols-6">
                  {#each q.optionImages as optImg, oi}
                    {@const letter = optionLetter(oi)}
                    {@const key = fieldKey(q)}
                    <label
                      class="hover:bg-accent flex cursor-pointer flex-col items-center gap-1 rounded-lg border p-2 text-xs {isDisabled(key, letter) ? 'opacity-40' : ''}"
                    >
                      {#if q.subtestNo === 2}
                        <input
                          type="checkbox"
                          name="{key}[]"
                          value={letter}
                          class="size-4 shrink-0"
                          checked={isChecked(key, letter)}
                          disabled={isDisabled(key, letter)}
                          onchange={(e) => toggleOption(key, letter, e.currentTarget.checked)}
                        />
                      {:else}
                        <input type="radio" name={key} value={letter} class="size-4 shrink-0" />
                      {/if}
                      <img src={optImg} alt="Opsi {letter}" class="h-16 w-auto rounded border" />
                      <span>{letter}</span>
                    </label>
                  {/each}
                </div>
              </CardContent>
            </Card>
          {/each}
        </div>
      {/each}

      <div class="flex items-center justify-end">
        {#if activeSubtest < total - 1}
          <Button type="button" onclick={() => goToSubtest(activeSubtest + 1)}>
            Selanjutnya
          </Button>
        {:else}
          <div class="flex flex-col items-end gap-1">
            <Button type="submit" disabled={loading}>
              {loading ? 'Mengirim...' : 'Kirim Semua Jawaban'}
            </Button>
            {#if !subtest2Complete}
              <span class="text-muted-foreground text-xs">Beberapa soal Subtes 2 belum lengkap (2 gambar per soal) — tetap bisa dikirim, soal yang belum lengkap dihitung salah.</span>
            {/if}
          </div>
        {/if}
      </div>
    </form>
  {/if}
</div>
