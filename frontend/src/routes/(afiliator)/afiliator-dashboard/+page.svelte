<script lang="ts">
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';

  let { data } = $props();

  let total = $derived(
    data.fees?.reduce((sum: number, f: any) => sum + (f.affiliatorFee ?? 0), 0) ?? 0
  );
</script>

<svelte:head><title>Dashboard Afiliator</title></svelte:head>

<div class="flex flex-col gap-6">
  <h2 class="text-2xl font-bold">Dashboard</h2>

  <div class="grid gap-4 sm:grid-cols-2">
    <Card>
      <CardHeader>
        <CardTitle class="text-sm font-medium text-muted-foreground">Total Komisi</CardTitle>
      </CardHeader>
      <CardContent>
        <p class="text-3xl font-bold">Rp {total.toLocaleString('id-ID')}</p>
      </CardContent>
    </Card>
  </div>

  <Card>
    <CardHeader><CardTitle>Akses Cepat</CardTitle></CardHeader>
    <CardContent>
      <a href="/afiliator-fees" class="bg-primary text-primary-foreground rounded-lg px-4 py-2 text-sm hover:opacity-90">Lihat Komisi</a>
    </CardContent>
  </Card>
</div>
