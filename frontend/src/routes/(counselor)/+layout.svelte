<script lang="ts">
  import DashboardShell from '$lib/components/dashboard/DashboardShell.svelte';

  let { children, data } = $props();

  const navLinks = [
    { href: '/counselor-dashboard', label: 'Dashboard' },
    { href: '/counselor-students', label: 'Siswa' },
    { href: '/counselor-results', label: 'Hasil Tes' },
  ];
</script>

<svelte:head><title>Panel Guru BK — Asesmen</title></svelte:head>

<DashboardShell roleLabel="Guru BK" navLinks={navLinks} user={data.user} profile={data.profile}>
  {@render children()}
</DashboardShell>
