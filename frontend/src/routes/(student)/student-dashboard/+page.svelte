<script lang="ts">
  import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '$lib/components/ui/card/index.js';
  import { Badge } from '$lib/components/ui/badge/index.js';
  import { Button } from '$lib/components/ui/button/index.js';

  let { data } = $props();
</script>

<svelte:head><title>Dashboard Siswa</title></svelte:head>

<div class="flex flex-col gap-6">
  <div>
    <h2 class="text-2xl font-bold">Halo, Selamat Datang!</h2>
    <p class="text-muted-foreground mt-1">Pilih tes yang tersedia di bawah ini untuk memulai.</p>
  </div>

  <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
    {#each data.tests as test}
      <Card class="flex flex-col">
        <CardHeader>
          <div class="flex items-start justify-between">
            <CardTitle>{test.label}</CardTitle>
            {#if test.completed}
              <Badge>Selesai</Badge>
            {:else if test.available}
              <Badge variant="secondary">Tersedia</Badge>
            {:else}
              <Badge variant="outline">Tidak Tersedia</Badge>
            {/if}
          </div>
          <CardDescription>
            {#if test.completed}
              Tes telah diselesaikan
            {:else if test.available}
              Tes tersedia, silakan kerjakan
            {:else}
              Tes belum tersedia untuk Anda
            {/if}
          </CardDescription>
        </CardHeader>
        <CardContent class="mt-auto">
          {#if test.completed}
            <Button href="{test.href}/result" variant="outline" class="w-full">Lihat Hasil</Button>
          {:else if test.available}
            <Button href={test.href} class="w-full">Mulai Tes</Button>
          {:else}
            <Button disabled class="w-full" variant="outline">Belum Tersedia</Button>
          {/if}
        </CardContent>
      </Card>
    {/each}
  </div>
</div>
