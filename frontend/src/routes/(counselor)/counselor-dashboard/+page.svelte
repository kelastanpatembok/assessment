<script lang="ts">
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';

  let { data } = $props();
</script>

<svelte:head><title>Dashboard Guru BK</title></svelte:head>

<div class="flex flex-col gap-6">
  <h2 class="text-2xl font-bold">Dashboard</h2>

  <div class="grid gap-4 sm:grid-cols-2">
    <Card>
      <CardHeader>
        <CardTitle class="text-sm font-medium text-muted-foreground">Total Siswa</CardTitle>
      </CardHeader>
      <CardContent>
        <p class="text-3xl font-bold">{data.studentCount}</p>
      </CardContent>
    </Card>
  </div>

  <Card>
    <CardHeader><CardTitle>Akses Cepat</CardTitle></CardHeader>
    <CardContent>
      <div class="flex flex-wrap gap-2">
        <a href="/counselor-students" class="bg-primary text-primary-foreground rounded-lg px-4 py-2 text-sm hover:opacity-90">Kelola Siswa</a>
        <a href="/counselor-results" class="bg-secondary text-secondary-foreground rounded-lg px-4 py-2 text-sm hover:opacity-90">Lihat Hasil Tes</a>
      </div>
    </CardContent>
  </Card>
</div>
