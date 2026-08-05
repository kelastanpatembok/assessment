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

<DashboardShell title="Panel Guru BK" roleLabel="Guru BK" navLinks={navLinks} user={data.user}>
  {@render children()}
</DashboardShell>
