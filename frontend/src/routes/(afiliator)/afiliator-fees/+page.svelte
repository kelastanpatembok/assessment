<script lang="ts">
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import DataTable from '$lib/components/table/DataTable.svelte';
  import type { TableColumn } from '$lib/table/types';

  let { data } = $props();

  const columns: TableColumn[] = [
    { key: 'studentName', label: 'Nama Siswa', sortable: true },
    { key: 'schoolName', label: 'Sekolah', sortable: true, hideBelow: 'sm' },
    { key: 'afiliatorShare', label: 'Komisi Afiliator', sortable: true, align: 'right' },
    { key: 'createdAt', label: 'Tanggal', sortable: true, hideBelow: 'sm' },
  ];

  function formatRp(value: number | null | undefined) {
    return `Rp ${(value ?? 0).toLocaleString('id-ID')}`;
  }

  function formatDate(value: string | null | undefined) {
    if (!value) return '-';
    try {
      return new Date(value).toLocaleDateString('id-ID');
    } catch {
      return value;
    }
  }
</script>

<svelte:head><title>Komisi Afiliator</title></svelte:head>

<div class="flex flex-col gap-6">
  <h2 class="text-2xl font-bold">Laporan Komisi</h2>

  <Card class="max-w-sm">
    <CardHeader>
      <CardTitle class="text-sm font-medium text-muted-foreground">Total Komisi</CardTitle>
    </CardHeader>
    <CardContent>
      <p class="text-3xl font-bold">{formatRp(Number(data.totalShare ?? 0))}</p>
    </CardContent>
  </Card>

  <Card>
    <CardContent class="pt-6">
      <DataTable
        {columns}
        table={data.table}
        searchPlaceholder="Cari nama siswa, sekolah, atau kategori..."
        rowKey={(f: any) => f.id}
      >
        {#snippet cell(column, f)}
          {#if column.key === 'studentName'}
            <span class="font-medium">{f.studentName ?? '-'}</span>
          {:else if column.key === 'schoolName'}
            <span class="text-muted-foreground">{f.schoolName ?? '-'}</span>
          {:else if column.key === 'afiliatorShare'}
            <span>{formatRp(Number(f.afiliatorShare ?? 0))}</span>
          {:else if column.key === 'createdAt'}
            <span class="text-muted-foreground">{formatDate(f.createdAt)}</span>
          {/if}
        {/snippet}
      </DataTable>
    </CardContent>
  </Card>
</div>
