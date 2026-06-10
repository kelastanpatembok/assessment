<script lang="ts">
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';

  let { data } = $props();
</script>

<svelte:head><title>Dashboard Admin</title></svelte:head>

<div class="flex flex-col gap-6">
  <h2 class="text-2xl font-bold">Dashboard</h2>

  <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
    <Card>
      <CardHeader>
        <CardTitle class="text-sm font-medium text-muted-foreground">Total Sekolah</CardTitle>
      </CardHeader>
      <CardContent>
        <p class="text-3xl font-bold">{data.schoolCount}</p>
      </CardContent>
    </Card>
    <Card>
      <CardHeader>
        <CardTitle class="text-sm font-medium text-muted-foreground">Total Pengguna</CardTitle>
      </CardHeader>
      <CardContent>
        <p class="text-3xl font-bold">{data.userCount}</p>
      </CardContent>
    </Card>
  </div>

  <Card>
    <CardHeader>
      <CardTitle>Akses Cepat</CardTitle>
    </CardHeader>
    <CardContent>
      <div class="flex flex-wrap gap-2">
        <a href="/admin-schools" class="bg-primary text-primary-foreground rounded-lg px-4 py-2 text-sm hover:opacity-90">Kelola Sekolah</a>
        <a href="/admin-users" class="bg-secondary text-secondary-foreground rounded-lg px-4 py-2 text-sm hover:opacity-90">Kelola Pengguna</a>
        <a href="/admin-assignments" class="bg-secondary text-secondary-foreground rounded-lg px-4 py-2 text-sm hover:opacity-90">Kelola Penugasan</a>
      </div>
    </CardContent>
  </Card>
</div>
