<script lang="ts">
  import { enhance } from '$app/forms';
  import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';

  let { data, form } = $props();
  let loading = $state(false);
</script>

<svelte:head><title>Konfigurasi Biaya</title></svelte:head>

<div class="flex flex-col gap-6">
  <h2 class="text-2xl font-bold">Konfigurasi Biaya</h2>

  <Card class="max-w-lg">
    <CardHeader>
      <CardTitle>Pengaturan Biaya & Persentase</CardTitle>
      <CardDescription>Atur harga tes dan pembagian komisi</CardDescription>
    </CardHeader>
    <CardContent>
      <form
        method="POST"
        action="?/update"
        use:enhance={() => {
          loading = true;
          return async ({ update }) => { loading = false; await update(); };
        }}
        class="flex flex-col gap-4"
      >
        <div class="flex flex-col gap-2">
          <Label for="price">Harga Per Siswa (Rp)</Label>
          <Input id="price" name="price" type="number" value={data.config?.price ?? 0} min="0" />
        </div>
        <div class="flex flex-col gap-2">
          <Label for="systemPct">Persentase Sistem (%)</Label>
          <Input id="systemPct" name="systemPct" type="number" value={data.config?.systemPct ?? 0} min="0" max="100" step="0.01" />
        </div>
        <div class="flex flex-col gap-2">
          <Label for="affiliatorPct">Persentase Afiliator (%)</Label>
          <Input id="affiliatorPct" name="affiliatorPct" type="number" value={data.config?.affiliatorPct ?? 0} min="0" max="100" step="0.01" />
        </div>
        <div class="flex flex-col gap-2">
          <Label for="counselorPct">Persentase Guru BK (%)</Label>
          <Input id="counselorPct" name="counselorPct" type="number" value={data.config?.counselorPct ?? 0} min="0" max="100" step="0.01" />
        </div>
        <Button type="submit" disabled={loading}>{loading ? 'Menyimpan...' : 'Simpan Konfigurasi'}</Button>
      </form>
    </CardContent>
  </Card>
</div>
