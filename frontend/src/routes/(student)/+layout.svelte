<script lang="ts">
  import DashboardShell from '$lib/components/dashboard/DashboardShell.svelte';

  let { children, data } = $props();

  const navLinks = [
    { href: '/student-dashboard', label: 'Dashboard' },
    { href: '/student-disc', label: 'Tes DISC' },
    { href: '/student-holland', label: 'Tes Holland' },
    { href: '/student-papi', label: 'Tes PAPI Kostick' },
    { href: '/student-cfit', label: 'Tes IQ CFIT' },
    { href: '/student-ist', label: 'Tes IQ IST' },
  ];
</script>

<svelte:head><title>Panel Siswa — Asesmen</title></svelte:head>

<DashboardShell title="Panel Siswa" roleLabel="Siswa" navLinks={navLinks} user={data.user}>
  {@render children()}
</DashboardShell>
