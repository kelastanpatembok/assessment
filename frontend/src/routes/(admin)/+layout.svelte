<script lang="ts">
  import { page } from '$app/stores';

  let { children, data } = $props();

  const navLinks = [
    { href: '/admin-dashboard', label: 'Dashboard' },
    { href: '/admin-schools', label: 'Sekolah' },
    { href: '/admin-users', label: 'Pengguna' },
    { href: '/admin-students', label: 'Siswa' },
    { href: '/admin-categories', label: 'Kategori Tes' },
    { href: '/admin-assignments', label: 'Penugasan' },
    { href: '/admin-fees', label: 'Biaya' },
  ];
</script>

<div class="bg-background flex min-h-screen">
  <aside class="bg-card border-border flex w-60 flex-col border-r">
    <div class="border-border border-b px-6 py-5">
      <div class="flex items-center gap-2">
        <div class="bg-primary text-primary-foreground flex size-8 items-center justify-center rounded-lg text-sm font-bold">
          A
        </div>
        <span class="font-semibold">Assessment</span>
      </div>
      <p class="text-muted-foreground mt-1 text-xs">Superadmin</p>
    </div>

    <nav class="flex-1 px-3 py-4">
      <ul class="flex flex-col gap-1">
        {#each navLinks as link}
          <li>
            <a
              href={link.href}
              class="hover:bg-accent hover:text-accent-foreground flex items-center rounded-lg px-3 py-2 text-sm transition-colors
                {$page.url.pathname === link.href ? 'bg-accent text-accent-foreground font-medium' : 'text-muted-foreground'}"
            >
              {link.label}
            </a>
          </li>
        {/each}
      </ul>
    </nav>

    <div class="border-border border-t px-4 py-4">
      <p class="text-muted-foreground truncate text-xs">{data.user?.username}</p>
      <a href="/logout" class="text-destructive mt-1 block text-xs hover:underline">Keluar</a>
    </div>
  </aside>

  <div class="flex flex-1 flex-col">
    <header class="bg-card border-border border-b px-6 py-4">
      <div class="flex items-center justify-between">
        <h1 class="font-semibold">Panel Admin</h1>
        <span class="text-muted-foreground text-sm">{data.user?.username}</span>
      </div>
    </header>
    <main class="flex-1 p-6">
      {@render children()}
    </main>
  </div>
</div>
