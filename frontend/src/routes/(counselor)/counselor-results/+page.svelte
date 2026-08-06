<script lang="ts">
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import DataTable from '$lib/components/table/DataTable.svelte';
  import type { TableColumn } from '$lib/table/types';
  import type { ResultTab } from './+page.server';

  let { data } = $props();

  const tabs: { key: ResultTab; label: string }[] = [
    { key: 'disc', label: 'DISC' },
    { key: 'holland', label: 'Holland' },
    { key: 'papi', label: 'PAPI Kostick' },
    { key: 'cfit', label: 'IQ CFIT' },
    { key: 'ist', label: 'IQ IST' },
  ];

  const columns: TableColumn[] = [
    { key: 'studentName', label: 'Nama Siswa', sortable: true },
    { key: 'schoolName', label: 'Sekolah', sortable: true, hideBelow: 'sm' },
    { key: 'completedAt', label: 'Tanggal', sortable: true, hideBelow: 'sm' },
    { key: 'result', label: 'Hasil' },
  ];

  function formatDate(value: string | null | undefined) {
    if (!value) return '-';
    try {
      return new Date(value).toLocaleDateString('id-ID');
    } catch {
      return value;
    }
  }

  function summary(tab: ResultTab, r: Record<string, any>): string {
    switch (tab) {
      case 'disc':
        return `D:${r.dMost ?? 0} I:${r.iMost ?? 0} S:${r.sMost ?? 0} C:${r.cMost ?? 0}`;
      case 'holland':
        return r.hollandCode ?? `R:${r.rScore ?? 0} I:${r.iScore ?? 0} A:${r.aScore ?? 0}`;
      case 'cfit':
        return `RS: ${r.totalScore ?? '-'} IQ: ${r.iqScore ?? '-'}`;
      case 'ist':
        return `IQ: ${r.iqScore ?? '-'} (${r.iqCategory ?? '-'})`;
      default:
        return 'Selesai';
    }
  }
</script>

<svelte:head><title>Hasil Tes</title></svelte:head>

<div class="flex flex-col gap-6">
  <h2 class="text-2xl font-bold">Hasil Tes</h2>

  <div class="flex flex-wrap gap-2">
    {#each tabs as t}
      <a
        href={t.key === 'disc' ? '?' : `?tab=${t.key}`}
        class={"inline-flex h-9 items-center rounded-lg px-4 text-sm font-medium transition-colors " +
          (data.tab === t.key
            ? 'bg-primary text-primary-foreground'
            : 'border-input bg-background hover:bg-accent border')}
      >
        {t.label}
      </a>
    {/each}
  </div>

  <Card>
    <CardHeader><CardTitle>{tabs.find((t) => t.key === data.tab)?.label}</CardTitle></CardHeader>
    <CardContent>
      <DataTable
        {columns}
        table={data.table}
        searchPlaceholder="Cari nama siswa atau sekolah..."
        rowKey={(r: any) => r.id}
      >
        {#snippet cell(column, r)}
          {#if column.key === 'studentName'}
            <span class="font-medium">{r.studentName}</span>
          {:else if column.key === 'schoolName'}
            <span class="text-muted-foreground">{r.schoolName ?? '-'}</span>
          {:else if column.key === 'completedAt'}
            <span class="text-muted-foreground">{formatDate(r.completedAt ?? r.createdAt)}</span>
          {:else if column.key === 'result'}
            <span>{summary(data.tab, r)}</span>
          {/if}
        {/snippet}
      </DataTable>
    </CardContent>
  </Card>
</div>
