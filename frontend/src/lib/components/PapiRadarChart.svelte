<script lang="ts">
  import { onMount } from 'svelte';
  import { Chart, registerables } from 'chart.js';

  type TraitDetail = {
    traitCode: string;
    traitName: string;
    score: number;
    band: 'TINGGI' | 'RENDAH';
  };

  type Props = {
    traitDetails: TraitDetail[];
  };

  let { traitDetails }: Props = $props();

  let canvas: HTMLCanvasElement;
  let chart: Chart | null = null;

  // The 20 PAPI traits in their canonical order (following the category groupings)
  const TRAIT_ORDER = [
    // Arah Kerja
    'N',
    'G',
    'A',
    // Kepemimpinan
    'L',
    'P',
    'I',
    // Aktivitas
    'T',
    'V',
    // Sifat Sosial
    'X',
    'S',
    'B',
    'O',
    // Gaya Kerja
    'R',
    'D',
    'C',
    // Temperamen
    'Z',
    'E',
    'K',
    // Kepengikutan
    'F',
    'W',
  ];

  const MAX_SCORE = 9;

  onMount(() => {
    // Register Chart.js components
    Chart.register(...registerables);

    // Map traits by code for quick lookup
    const traitMap = new Map(traitDetails.map((t) => [t.traitCode, t]));

    // Build data arrays in the canonical order
    const labels = TRAIT_ORDER.map((code) => {
      const trait = traitMap.get(code);
      return trait ? `${code} (${trait.traitName})` : code;
    });

    const scores = TRAIT_ORDER.map((code) => {
      const trait = traitMap.get(code);
      return trait?.score ?? 0;
    });

    // Create the radar chart
    chart = new Chart(canvas, {
      type: 'radar',
      data: {
        labels,
        datasets: [
          {
            label: 'Skor PAPI',
            data: scores,
            fill: true,
            backgroundColor: 'rgba(99, 102, 241, 0.2)', // Indigo with transparency
            borderColor: 'rgb(99, 102, 241)', // Indigo
            pointBackgroundColor: 'rgb(99, 102, 241)',
            pointBorderColor: '#fff',
            pointHoverBackgroundColor: '#fff',
            pointHoverBorderColor: 'rgb(99, 102, 241)',
            borderWidth: 2,
            pointRadius: 4,
            pointHoverRadius: 6,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: true,
        scales: {
          r: {
            beginAtZero: true,
            max: MAX_SCORE,
            min: 0,
            ticks: {
              stepSize: 1,
              font: {
                size: 10,
              },
              backdropColor: 'transparent',
            },
            pointLabels: {
              font: {
                size: 11,
              },
              color: 'hsl(var(--foreground))',
            },
            grid: {
              color: 'hsl(var(--border))',
            },
            angleLines: {
              color: 'hsl(var(--border))',
            },
          },
        },
        plugins: {
          legend: {
            display: false,
          },
          tooltip: {
            backgroundColor: 'hsl(var(--popover))',
            titleColor: 'hsl(var(--popover-foreground))',
            bodyColor: 'hsl(var(--popover-foreground))',
            borderColor: 'hsl(var(--border))',
            borderWidth: 1,
            padding: 12,
            displayColors: false,
            callbacks: {
              label: (context) => {
                const index = context.dataIndex;
                const code = TRAIT_ORDER[index];
                const trait = traitMap.get(code);
                return trait
                  ? `${code}: ${trait.score}/${MAX_SCORE} (${trait.band === 'TINGGI' ? 'Tinggi' : 'Rendah'})`
                  : `${code}: ${context.parsed.r}`;
              },
            },
          },
        },
      },
    });

    return () => {
      if (chart) {
        chart.destroy();
        chart = null;
      }
    };
  });
</script>

<div class="w-full">
  <canvas bind:this={canvas}></canvas>
</div>
