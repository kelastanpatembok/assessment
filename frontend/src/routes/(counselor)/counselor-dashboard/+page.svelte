<script lang="ts">
  import { Bar, Doughnut } from 'svelte-chartjs';
  import {
    Chart as ChartJS,
    Title,
    Tooltip,
    Legend,
    BarElement,
    CategoryScale,
    LinearScale,
    ArcElement,
  } from 'chart.js';

  ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, ArcElement);

  let { data } = $props();
  const summary = $derived(data.summary);

  const barOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: { legend: { display: false } }
  };

  const doughnutOptions = {
    responsive: true,
    maintainAspectRatio: false
  };

  const discData = $derived({
    labels: Object.keys(summary.discProfileDistribution),
    datasets: [
      {
        label: 'Jumlah Siswa',
        data: Object.values(summary.discProfileDistribution),
        backgroundColor: 'rgba(163, 84, 42, 0.82)',
        borderColor: 'rgba(163, 84, 42, 1)',
        borderWidth: 1,
        borderRadius: 6,
      }
    ]
  });

  const hollandNames: Record<string, string> = {
    R: 'Realistic',
    I: 'Investigative',
    A: 'Artistic',
    S: 'Social',
    E: 'Enterprising',
    C: 'Conventional'
  };

  const hollandData = $derived({
    labels: Object.keys(summary.hollandTypeDistribution).map((k) => hollandNames[k] || k),
    datasets: [
      {
        data: Object.values(summary.hollandTypeDistribution),
        backgroundColor: [
          'rgba(201, 123, 84, 0.85)',
          'rgba(217, 154, 61, 0.85)',
          'rgba(122, 158, 110, 0.85)',
          'rgba(94, 139, 155, 0.85)',
          'rgba(138, 107, 168, 0.85)',
          'rgba(192, 106, 126, 0.85)'
        ],
        borderWidth: 0,
      }
    ]
  });
</script>

<svelte:head><title>Dashboard Guru BK — Asesmen</title></svelte:head>

<div class="cdash">
  <section class="cdash-hero">
    <p class="cdash-kicker">Panel Guru BK</p>
    <h2 class="cdash-title">Hasil evaluasi.</h2>
    <p class="cdash-lede">Pantau perkembangan asesmen siswa di sekolah Anda.</p>
  </section>

  <div class="kpi-grid">
    <article class="kpi kpi-amber">
      <p class="kpi-label">Total Siswa</p>
      <p class="kpi-num">{summary.totalStudents}</p>
      <p class="kpi-sub">Siswa terdaftar di sekolah ini</p>
    </article>
    <article class="kpi kpi-sage">
      <p class="kpi-label">Tes Selesai</p>
      <p class="kpi-num">{summary.completedTests}</p>
      <p class="kpi-sub">Modul asesmen yang diselesaikan</p>
    </article>
    <article class="kpi kpi-clay">
      <p class="kpi-label">Rata-rata IQ (Estimasi)</p>
      <p class="kpi-num">{summary.averageIq}</p>
      <p class="kpi-sub">Berdasarkan hasil IST / CFIT</p>
    </article>
  </div>

  <div class="chart-grid">
    <section class="chart-card">
      <h3 class="chart-title">Distribusi Profil Kepribadian (DISC)</h3>
      <p class="chart-sub">Mayoritas gaya kerja dan komunikasi siswa.</p>
      <div class="chart-box">
        <Bar data={discData} options={barOptions} />
      </div>
    </section>

    <section class="chart-card">
      <h3 class="chart-title">Distribusi Minat Karier (Holland RIASEC)</h3>
      <p class="chart-sub">Kecenderungan bidang vokasional dominan siswa.</p>
      <div class="chart-box chart-box-doughnut">
        <div class="chart-doughnut">
          <Doughnut data={hollandData} options={doughnutOptions} />
        </div>
      </div>
    </section>
  </div>
</div>

<style>
  .cdash {
    display: grid;
    gap: clamp(1.5rem, 3vw, 2.25rem);
  }

  .cdash-hero {
    max-width: 40rem;
  }

  .cdash-kicker {
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-accent-deep);
    margin: 0 0 0.5rem;
  }

  .cdash-title {
    font-family: var(--lp-font-display);
    font-size: clamp(1.7rem, 3vw + 0.6rem, 2.3rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1.12;
    margin: 0 0 0.6rem;
  }

  .cdash-lede {
    color: var(--lp-ink-2);
    margin: 0;
  }

  .kpi-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(13rem, 1fr));
    gap: 1rem;
  }

  .kpi {
    border: 1px solid var(--lp-rule);
    border-radius: 1.25rem;
    padding: 1.4rem 1.5rem;
    display: grid;
    gap: 0.35rem;
  }

  .kpi-amber { background: var(--lp-tint-amber); }
  .kpi-sage { background: var(--lp-tint-sage); }
  .kpi-clay { background: var(--lp-tint-clay); }

  .kpi-label {
    font-size: 0.8rem;
    font-weight: 650;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    color: var(--lp-ink-2);
    margin: 0;
  }

  .kpi-num {
    font-family: var(--lp-font-display);
    font-size: clamp(2.2rem, 4vw, 3rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1;
    margin: 0;
    font-variant-numeric: tabular-nums;
  }

  .kpi-sub {
    color: var(--lp-muted);
    font-size: 0.85rem;
    margin: 0;
  }

  .chart-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(20rem, 1fr));
    gap: 1rem;
  }

  .chart-card {
    border: 1px solid var(--lp-rule);
    border-radius: 1.25rem;
    background: var(--lp-paper);
    padding: 1.4rem 1.5rem;
    display: grid;
    gap: 0.4rem;
  }

  .chart-title {
    font-family: var(--lp-font-display);
    font-size: 1.15rem;
    font-weight: 560;
    letter-spacing: -0.01em;
    margin: 0;
  }

  .chart-sub {
    color: var(--lp-muted);
    font-size: 0.85rem;
    margin: 0 0 0.75rem;
  }

  .chart-box {
    height: 20rem;
    min-width: 0;
  }

  .chart-box-doughnut {
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .chart-doughnut {
    width: 100%;
    max-width: 18rem;
    height: 100%;
  }
</style>
