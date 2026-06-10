<script lang="ts">
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';

  let { data } = $props();

  let total = $derived(
    data.fees.reduce((sum: number, f: any) => sum + (f.affiliatorFee ?? 0), 0)
  );
</script>

<svelte:head><title>Komisi Afiliator</title></svelte:head>

<div class="flex flex-col gap-6">
  <h2 class="text-2xl font-bold">Laporan Komisi</h2>

  <Card class="max-w-sm">
    <CardHeader>
      <CardTitle class="text-sm font-medium text-muted-foreground">Total Komisi</CardTitle>
    </CardHeader>
    <CardContent>
      <p class="text-3xl font-bold">Rp {total.toLocaleString('id-ID')}</p>
    </CardContent>
  </Card>

  <Card>
    <CardContent class="pt-6">
      <table class="w-full text-sm">
        <thead>
          <tr class="border-border border-b text-left">
            <th class="pb-3 font-medium">Nama Siswa</th>
            <th class="pb-3 font-medium">Sekolah</th>
            <th class="pb-3 font-medium">Komisi Afiliator</th>
            <th class="pb-3 font-medium">Tanggal</th>
          </tr>
        </thead>
        <tbody>
          {#each data.fees as f}
            <tr class="border-border border-b last:border-0">
              <td class="py-3">{f.studentName ?? '-'}</td>
              <td class="text-muted-foreground py-3">{f.schoolName ?? '-'}</td>
              <td class="py-3 font-medium">Rp {(f.affiliatorFee ?? 0).toLocaleString('id-ID')}</td>
              <td class="text-muted-foreground py-3">{f.createdAt ? new Date(f.createdAt).toLocaleDateString('id-ID') : '-'}</td>
            </tr>
          {:else}
            <tr><td colspan="4" class="text-muted-foreground py-6 text-center">Belum ada data komisi</td></tr>
          {/each}
        </tbody>
      </table>
    </CardContent>
  </Card>
</div>
