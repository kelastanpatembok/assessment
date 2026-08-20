<script lang="ts">
  import DashboardShell from '$lib/components/dashboard/DashboardShell.svelte';

  let { children, data } = $props();

  const navLinks = [
    { href: '/psikolog-dashboard', label: 'Dashboard' },
    { href: '/psikolog-dashboard', label: 'Cari Peserta' },
    { href: '/psikolog-laporan', label: 'Laporan Sekolah' },
  ];
</script>

<svelte:head><title>Panel Psikolog — Asesmen</title></svelte:head>

<DashboardShell roleLabel="Psikolog" navLinks={navLinks} user={data.user} profile={data.profile}>
  {@render children()}
</DashboardShell>
