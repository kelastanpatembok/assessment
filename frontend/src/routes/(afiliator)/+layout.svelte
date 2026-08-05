<script lang="ts">
  import DashboardShell from '$lib/components/dashboard/DashboardShell.svelte';

  let { children, data } = $props();

  const navLinks = [
    { href: '/afiliator-dashboard', label: 'Dashboard' },
    { href: '/afiliator-fees', label: 'Komisi' },
  ];
</script>

<svelte:head><title>Panel Afiliator — Asesmen</title></svelte:head>

<DashboardShell roleLabel="Afiliator" navLinks={navLinks} user={data.user} profile={data.profile}>
  {@render children()}
</DashboardShell>
