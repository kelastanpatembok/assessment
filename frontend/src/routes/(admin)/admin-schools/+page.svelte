<script lang="ts">
  import { enhance } from '$app/forms';
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import DataTable from '$lib/components/table/DataTable.svelte';
  import type { TableColumn } from '$lib/table/types';

  let { data, form } = $props();
  let showModal = $state(false);
  let editTarget = $state<{ id: number; name: string; address: string } | null>(null);
  let loading = $state(false);

  const columns: TableColumn[] = [
    { key: 'id', label: 'ID', sortable: true, hideBelow: 'sm' },
    { key: 'name', label: 'Nama Sekolah', sortable: true },
    { key: 'address', label: 'Alamat', hideBelow: 'sm' },
    { key: 'actions', label: 'Aksi' },
  ];
</script>

<svelte:head><title>Sekolah</title></svelte:head>

<div class="flex flex-col gap-6">
  <div class="flex items-center justify-between">
    <h2 class="text-2xl font-bold">Sekolah</h2>
    <Button onclick={() => (showModal = true)}>+ Tambah Sekolah</Button>
  </div>

  {#if form?.error}
    <div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">{form.error}</div>
  {/if}

  <Card>
    <CardContent class="pt-6">
      <DataTable
        {columns}
        table={data.table}
        searchPlaceholder="Cari nama sekolah, kota, atau provinsi..."
        rowKey={(s: any) => s.id}
      >
        {#snippet cell(column, school)}
          {#if column.key === 'id'}
            <span class="text-muted-foreground">{school.id}</span>
          {:else if column.key === 'name'}
            <span class="font-medium">{school.name}</span>
          {:else if column.key === 'address'}
            <span class="text-muted-foreground">{school.address ?? '-'}</span>
          {:else if column.key === 'actions'}
            <div class="flex items-center justify-end gap-3 sm:justify-start">
              <button
                type="button"
                class="text-primary text-xs hover:underline"
                onclick={() => (editTarget = { id: school.id, name: school.name, address: school.address ?? '' })}
              >Edit</button>
              <form method="POST" action="?/delete" use:enhance>
                <input type="hidden" name="id" value={school.id} />
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
      <CardHeader>
        <CardTitle>Tambah Sekolah</CardTitle>
      </CardHeader>
      <CardContent>
        <form
          method="POST"
          action="?/create"
          use:enhance={() => {
            loading = true;
            return async ({ update }) => {
              loading = false;
              showModal = false;
              await update();
            };
          }}
          class="flex flex-col gap-4"
        >
          <div class="flex flex-col gap-2">
            <Label for="schoolName">Nama Sekolah</Label>
            <Input id="schoolName" name="schoolName" placeholder="Contoh: SMA Negeri 1 Jakarta" required />
          </div>
          <div class="flex flex-col gap-2">
            <Label for="address">Alamat</Label>
            <Input id="address" name="address" placeholder="Alamat lengkap" />
          </div>
          <div class="flex gap-2 justify-end">
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
      <CardHeader>
        <CardTitle>Edit Sekolah</CardTitle>
      </CardHeader>
      <CardContent>
        <form
          method="POST"
          action="?/update"
          use:enhance={() => {
            loading = true;
            return async ({ update }) => {
              loading = false;
              editTarget = null;
              await update();
            };
          }}
          class="flex flex-col gap-4"
        >
          <input type="hidden" name="id" value={editTarget.id} />
          <div class="flex flex-col gap-2">
            <Label for="editName">Nama Sekolah</Label>
            <Input id="editName" name="schoolName" value={editTarget.name} required />
          </div>
          <div class="flex flex-col gap-2">
            <Label for="editAddress">Alamat</Label>
            <Input id="editAddress" name="address" value={editTarget.address} />
          </div>
          <div class="flex gap-2 justify-end">
            <Button type="button" variant="outline" onclick={() => (editTarget = null)}>Batal</Button>
            <Button type="submit" disabled={loading}>{loading ? 'Menyimpan...' : 'Simpan'}</Button>
          </div>
        </form>
      </CardContent>
    </Card>
  </div>
{/if}
