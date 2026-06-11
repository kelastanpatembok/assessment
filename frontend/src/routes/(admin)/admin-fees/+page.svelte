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
          <Label for="studentFee">Harga Per Siswa (Rp)</Label>
          <Input id="studentFee" name="studentFee" type="number" value={data.config?.studentFee ?? 0} min="0" />
        </div>
        <div class="flex flex-col gap-2">
          <Label for="platformSharePct">Persentase Platform (%)</Label>
          <Input id="platformSharePct" name="platformSharePct" type="number" value={data.config?.platformSharePct ?? 0} min="0" max="100" step="0.01" />
        </div>
        <div class="flex flex-col gap-2">
          <Label for="afiliatorSharePct">Persentase Afiliator (%)</Label>
          <Input id="afiliatorSharePct" name="afiliatorSharePct" type="number" value={data.config?.afiliatorSharePct ?? 0} min="0" max="100" step="0.01" />
        </div>
        <div class="flex flex-col gap-2">
          <Label for="gurubkSharePct">Persentase Guru BK (%)</Label>
          <Input id="gurubkSharePct" name="gurubkSharePct" type="number" value={data.config?.gurubkSharePct ?? 0} min="0" max="100" step="0.01" />
        </div>
        <Button type="submit" disabled={loading}>{loading ? 'Menyimpan...' : 'Simpan Konfigurasi'}</Button>
      </form>
    </CardContent>
  </Card>
</div>
