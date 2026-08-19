<script lang="ts">
  import { enhance } from '$app/forms';
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import { Badge } from '$lib/components/ui/badge/index.js';
  import SchoolSearchSelect from '$lib/components/SchoolSearchSelect.svelte';
  import DataTable from '$lib/components/table/DataTable.svelte';
  import type { TableColumn } from '$lib/table/types';

  let { data, form } = $props();
  let showModal = $state(false);
  let editTarget = $state<{ id: number; startDate: string; endDate: string; active: boolean; certificateEnabled: boolean } | null>(null);
  let loading = $state(false);

  const columns: TableColumn[] = [
    { key: 'school', label: 'Sekolah', sortable: true, sortKey: 'school.name' },
    { key: 'category', label: 'Kategori', sortable: true, sortKey: 'category.name', hideBelow: 'sm' },
    { key: 'windowStart', label: 'Mulai', sortable: true, hideBelow: 'sm' },
    { key: 'windowEnd', label: 'Selesai', sortable: true, hideBelow: 'sm' },
    { key: 'active', label: 'Status', sortable: true, hideBelow: 'sm' },
    { key: 'actions', label: 'Aksi' },
  ];
</script>

<svelte:head><title>Penugasan Tes</title></svelte:head>

<div class="flex flex-col gap-6">
  <div class="flex items-center justify-between">
    <h2 class="text-2xl font-bold">Penugasan Tes</h2>
    <Button onclick={() => (showModal = true)}>+ Tambah Penugasan</Button>
  </div>

  {#if form?.error}
    <div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">{form.error}</div>
  {/if}

  <Card>
    <CardContent class="pt-6">
      <DataTable
        {columns}
        table={data.table}
        searchPlaceholder="Cari sekolah atau kategori..."
        rowKey={(a: any) => a.id}
      >
        {#snippet cell(column, a)}
          {#if column.key === 'school'}
            <span class="font-medium">{a.school?.name ?? '-'}</span>
          {:else if column.key === 'category'}
            <span>{a.category?.name ?? '-'}</span>
          {:else if column.key === 'windowStart'}
            <span class="text-muted-foreground">{a.windowStart?.split('T')[0] ?? '-'}</span>
          {:else if column.key === 'windowEnd'}
            <span class="text-muted-foreground">{a.windowEnd?.split('T')[0] ?? '-'}</span>
          {:else if column.key === 'active'}
            <Badge variant={a.active ? 'default' : 'secondary'}>{a.active ? 'aktif' : 'pasif'}</Badge>
          {:else if column.key === 'actions'}
            <div class="flex items-center justify-end gap-3 sm:justify-start">
              <button
                type="button"
                class="text-primary text-xs hover:underline"
                onclick={() => (editTarget = {
                  id: a.id,
                  startDate: a.windowStart?.split('T')[0] ?? '',
                  endDate: a.windowEnd?.split('T')[0] ?? '',
                  active: a.active,
                  certificateEnabled: a.certificateEnabled ?? false,
                })}
              >Edit</button>
              <form method="POST" action="?/delete" use:enhance>
                <input type="hidden" name="id" value={a.id} />
                <button type="submit" class="text-destructive text-xs hover:underline">Hapus</button>
              </form>
            </div>
          {/if}
        {/snippet}
      </DataTable>
    </CardContent>
  </Card>
</div>

{#if showModal}
  <div class="bg-background/80 fixed inset-0 z-50 flex items-center justify-center backdrop-blur-sm">
    <Card class="w-full max-w-md">
      <CardHeader><CardTitle>Tambah Penugasan</CardTitle></CardHeader>
      <CardContent>
        <form
          method="POST"
          action="?/create"
          use:enhance={() => {
            loading = true;
            return async ({ update }) => { loading = false; showModal = false; await update(); };
          }}
          class="flex flex-col gap-4"
        >
          <div class="flex flex-col gap-2">
            <Label for="schoolId">Sekolah</Label>
            <SchoolSearchSelect token={data.token} name="schoolId" placeholder="Cari sekolah..." required />
          </div>
          <div class="flex flex-col gap-2">
            <Label for="categoryId">Kategori Tes</Label>
            <select id="categoryId" name="categoryId" class="border-input bg-background flex h-10 w-full rounded-lg border px-3 text-sm" required>
              <option value="">Pilih kategori...</option>
              {#each data.categories as c}
                <option value={c.id}>{c.name}</option>
              {/each}
            </select>
          </div>
          <div class="grid grid-cols-2 gap-4">
            <div class="flex flex-col gap-2">
              <Label for="startDate">Tanggal Mulai</Label>
              <Input id="startDate" name="startDate" type="date" required />
            </div>
            <div class="flex flex-col gap-2">
              <Label for="endDate">Tanggal Selesai</Label>
              <Input id="endDate" name="endDate" type="date" required />
            </div>
          </div>
          <div class="flex items-center gap-2">
            <input type="checkbox" id="certificateEnabled" name="certificateEnabled" class="size-4" />
            <Label for="certificateEnabled">Aktifkan sertifikat</Label>
          </div>
          <div class="flex justify-end gap-2">
            <Button type="button" variant="outline" onclick={() => (showModal = false)}>Batal</Button>
            <Button type="submit" disabled={loading}>{loading ? 'Menyimpan...' : 'Simpan'}</Button>
          </div>
        </form>
      </CardContent>
    </Card>
  </div>
{/if}

{#if editTarget}
  <div class="bg-background/80 fixed inset-0 z-50 flex items-center justify-center backdrop-blur-sm">
    <Card class="w-full max-w-md">
      <CardHeader><CardTitle>Edit Penugasan</CardTitle></CardHeader>
      <CardContent>
        <form
          method="POST"
          action="?/update"
          use:enhance={() => {
            loading = true;
            return async ({ update }) => { loading = false; editTarget = null; await update(); };
          }}
          class="flex flex-col gap-4"
        >
          <input type="hidden" name="id" value={editTarget.id} />
          <div class="grid grid-cols-2 gap-4">
            <div class="flex flex-col gap-2">
              <Label for="editStartDate">Tanggal Mulai</Label>
              <Input id="editStartDate" name="startDate" type="date" value={editTarget.startDate} required />
            </div>
            <div class="flex flex-col gap-2">
              <Label for="editEndDate">Tanggal Selesai</Label>
              <Input id="editEndDate" name="endDate" type="date" value={editTarget.endDate} required />
            </div>
          </div>
          <div class="flex items-center gap-2">
            <input type="checkbox" id="editActive" name="active" checked={editTarget.active} class="size-4" />
            <Label for="editActive">Aktif</Label>
          </div>
          <div class="flex items-center gap-2">
            <input type="checkbox" id="editCertEnabled" name="certificateEnabled" checked={editTarget.certificateEnabled} class="size-4" />
            <Label for="editCertEnabled">Aktifkan sertifikat</Label>
          </div>
          <div class="flex justify-end gap-2">
            <Button type="button" variant="outline" onclick={() => (editTarget = null)}>Batal</Button>
            <Button type="submit" disabled={loading}>{loading ? 'Menyimpan...' : 'Simpan'}</Button>
          </div>
        </form>
      </CardContent>
    </Card>
  </div>
{/if}
