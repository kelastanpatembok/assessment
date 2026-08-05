<script lang="ts">
  import DashboardShell from '$lib/components/dashboard/DashboardShell.svelte';

  let { children, data } = $props();

  const navLinks = [
    { href: '/afiliator-dashboard', label: 'Dashboard' },
    { href: '/afiliator-fees', label: 'Komisi' },
  ];
</script>

<svelte:head><title>Panel Afiliator — Asesmen</title></svelte:head>

<DashboardShell title="Panel Afiliator" roleLabel="Afiliator" navLinks={navLinks} user={data.user}>
  {@render children()}
</DashboardShell>
