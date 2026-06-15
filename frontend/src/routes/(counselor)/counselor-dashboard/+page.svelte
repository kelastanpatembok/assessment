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
  import * as Card from '$lib/components/ui/card';

  ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, ArcElement);

  let { data } = $props();
  const { summary } = data;

  // Chart options
  const barOptions = {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        display: false
      }
    }
  };

  const doughnutOptions = {
    responsive: true,
    maintainAspectRatio: false,
  };

  // DISC Data
  const discLabels = Object.keys(summary.discProfileDistribution);
  const discDataValues = Object.values(summary.discProfileDistribution);
  
  const discData = {
    labels: discLabels,
    datasets: [
      {
        label: 'Jumlah Siswa',
        data: discDataValues,
        backgroundColor: 'rgba(59, 130, 246, 0.8)',
        borderColor: 'rgba(59, 130, 246, 1)',
        borderWidth: 1,
        borderRadius: 4,
      }
    ]
  };

  // Holland Data
  const hollandLabels = Object.keys(summary.hollandTypeDistribution).map(k => {
    const names: Record<string, string> = {
      'R': 'Realistic',
      'I': 'Investigative',
      'A': 'Artistic',
      'S': 'Social',
      'E': 'Enterprising',
      'C': 'Conventional'
    };
    return names[k] || k;
  });
  const hollandDataValues = Object.values(summary.hollandTypeDistribution);

  const hollandData = {
    labels: hollandLabels,
    datasets: [
      {
        data: hollandDataValues,
        backgroundColor: [
          'rgba(239, 68, 68, 0.8)',   // R - Red
          'rgba(245, 158, 11, 0.8)',  // I - Orange
          'rgba(16, 185, 129, 0.8)',  // A - Green
          'rgba(59, 130, 246, 0.8)',  // S - Blue
          'rgba(139, 92, 246, 0.8)',  // E - Purple
          'rgba(236, 72, 153, 0.8)'   // C - Pink
        ],
        borderWidth: 0,
      }
    ]
  };
</script>

<svelte:head>
  <title>Dashboard Guru BK - Assessment</title>
</svelte:head>

<div class="flex-1 space-y-6 p-8 pt-6">
  <div class="flex items-center justify-between space-y-2">
    <h2 class="text-3xl font-bold tracking-tight">Dashboard Hasil Evaluasi</h2>
  </div>

  <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
    <!-- Total Students KPI -->
    <Card.Root class="bg-gradient-to-br from-blue-50 to-white shadow-sm border-blue-100">
      <Card.Header class="flex flex-row items-center justify-between space-y-0 pb-2">
        <Card.Title class="text-sm font-medium">Total Siswa</Card.Title>
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-blue-500"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/></svg>
      </Card.Header>
      <Card.Content>
        <div class="text-3xl font-bold text-blue-700">{summary.totalStudents}</div>
        <p class="text-xs text-muted-foreground mt-1">
          Siswa terdaftar di sekolah ini
        </p>
      </Card.Content>
    </Card.Root>

    <!-- Completed Tests KPI -->
    <Card.Root class="bg-gradient-to-br from-green-50 to-white shadow-sm border-green-100">
      <Card.Header class="flex flex-row items-center justify-between space-y-0 pb-2">
        <Card.Title class="text-sm font-medium">Tes Selesai</Card.Title>
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-green-500"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/><polyline points="22 4 12 14.01 9 11.01"/></svg>
      </Card.Header>
      <Card.Content>
        <div class="text-3xl font-bold text-green-700">{summary.completedTests}</div>
        <p class="text-xs text-muted-foreground mt-1">
          Modul asesmen diselesaikan
        </p>
      </Card.Content>
    </Card.Root>

    <!-- Average IQ KPI -->
    <Card.Root class="bg-gradient-to-br from-purple-50 to-white shadow-sm border-purple-100">
      <Card.Header class="flex flex-row items-center justify-between space-y-0 pb-2">
        <Card.Title class="text-sm font-medium">Rata-rata IQ (Estimasi)</Card.Title>
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-purple-500"><path d="M2 12h4l3-9 5 18 3-9h5"/></svg>
      </Card.Header>
      <Card.Content>
        <div class="text-3xl font-bold text-purple-700">{summary.averageIq}</div>
        <p class="text-xs text-muted-foreground mt-1">
          Berdasarkan hasil IST / CFIT
        </p>
      </Card.Content>
    </Card.Root>
  </div>

  <div class="grid gap-6 md:grid-cols-2">
    <!-- DISC Chart -->
    <Card.Root class="shadow-md">
      <Card.Header>
        <Card.Title>Distribusi Profil Kepribadian (DISC)</Card.Title>
        <Card.Description>
          Mayoritas gaya kerja dan komunikasi siswa.
        </Card.Description>
      </Card.Header>
      <Card.Content class="h-[350px]">
        <Bar data={discData} options={barOptions} />
      </Card.Content>
    </Card.Root>

    <!-- Holland Chart -->
    <Card.Root class="shadow-md">
      <Card.Header>
        <Card.Title>Distribusi Minat Karier (Holland RIASEC)</Card.Title>
        <Card.Description>
          Kecenderungan bidang vokasional dominan siswa.
        </Card.Description>
      </Card.Header>
      <Card.Content class="h-[350px] flex items-center justify-center">
        <div class="w-full max-w-[300px] h-full">
          <Doughnut data={hollandData} options={doughnutOptions} />
        </div>
      </Card.Content>
    </Card.Root>
  </div>
</div>
