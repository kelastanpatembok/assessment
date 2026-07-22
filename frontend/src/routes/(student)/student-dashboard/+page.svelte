<script lang="ts">
  import { enhance } from '$app/forms';
  import { dev } from '$app/environment';
  import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '$lib/components/ui/card/index.js';
  import { Badge } from '$lib/components/ui/badge/index.js';
  import { Button } from '$lib/components/ui/button/index.js';

  let { data } = $props();

  const dateFmt = new Intl.DateTimeFormat('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });

  function formatWindow(windowStart: string | null, windowEnd: string | null): string | null {
    if (!windowStart && !windowEnd) return null;
    const start = windowStart ? dateFmt.format(new Date(windowStart)) : '?';
    const end = windowEnd ? dateFmt.format(new Date(windowEnd)) : '?';
    return `${start} – ${end}`;
  }
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
          {#if !test.completed}
            {@const window = formatWindow(test.windowStart, test.windowEnd)}
            {#if window}
              <p class="text-muted-foreground text-xs">Periode pengerjaan: {window}</p>
            {/if}
          {/if}
        </CardHeader>
        <CardContent class="mt-auto flex flex-col gap-2">
          {#if test.completed}
            <Button href="{test.href}/result" variant="outline" class="w-full">Lihat Hasil</Button>
            {#if dev}
              <form
                method="POST"
                action="?/clear"
                use:enhance={() => async ({ update }) => { await update(); }}
              >
                <input type="hidden" name="testKey" value={test.key} />
                <Button type="submit" variant="ghost" size="sm" class="text-destructive w-full">
                  Clear (dev)
                </Button>
              </form>
            {/if}
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
