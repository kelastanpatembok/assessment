<script lang="ts">
  import DashboardShell from '$lib/components/dashboard/DashboardShell.svelte';

  let { children, data } = $props();

  const navLinks = [
    { href: '/admin-dashboard', label: 'Dashboard' },
    { href: '/admin-schools', label: 'Sekolah' },
    { href: '/admin-users', label: 'Pengguna' },
    { href: '/admin-students', label: 'Siswa' },
    { href: '/assignment-modules', label: 'Modul Penugasan' },
    { href: '/admin-categories', label: 'Kategori Tes' },
    { href: '/admin-assignments', label: 'Penugasan' },
    { href: '/admin-fees', label: 'Biaya' },
    { href: '/admin-report-rules', label: 'Rubrik Laporan' },
  ];
</script>

<svelte:head><title>Panel Admin — Asesmen</title></svelte:head>

<DashboardShell roleLabel="Superadmin" navLinks={navLinks} user={data.user} profile={data.profile}>
  {@render children()}
</DashboardShell>
