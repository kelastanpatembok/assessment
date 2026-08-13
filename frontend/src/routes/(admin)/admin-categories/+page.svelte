<script lang="ts">
  import { enhance } from '$app/forms';
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import DataTable from '$lib/components/table/DataTable.svelte';
  import type { TableColumn } from '$lib/table/types';

  const TEST_OPTIONS = ['disc', 'holland', 'papi', 'cfit', 'ist', 'epps'];

  let { data, form } = $props();
  let showModal = $state(false);
  let editTarget = $state<{ id: number; name: string; slug: string; price: number; tests: string[] } | null>(null);
  let loading = $state(false);

  const columns: TableColumn[] = [
    { key: 'id', label: 'ID', sortable: true, hideBelow: 'sm' },
    { key: 'name', label: 'Nama', sortable: true },
    { key: 'slug', label: 'Slug', hideBelow: 'sm' },
    { key: 'price', label: 'Harga', sortable: true, align: 'right' },
    { key: 'actions', label: 'Aksi' },
  ];
</script>

<svelte:head><title>Kategori Tes</title></svelte:head>

<div class="flex flex-col gap-6">
  <div class="flex items-center justify-between">
    <h2 class="text-2xl font-bold">Kategori Tes</h2>
    <Button onclick={() => (showModal = true)}>+ Tambah Kategori</Button>
  </div>

  {#if form?.error}
    <div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">{form.error}</div>
  {/if}

  <Card>
    <CardContent class="pt-6">
      <DataTable
        {columns}
        table={data.table}
        searchPlaceholder="Cari nama atau slug kategori..."
        rowKey={(c: any) => c.id}
      >
        {#snippet cell(column, cat)}
          {#if column.key === 'id'}
            <span class="text-muted-foreground">{cat.id}</span>
          {:else if column.key === 'name'}
            <span class="font-medium">{cat.name}</span>
          {:else if column.key === 'slug'}
            <span class="text-muted-foreground">{cat.slug ?? '-'}</span>
          {:else if column.key === 'price'}
            <span>Rp {(cat.price ?? 0).toLocaleString('id-ID')}</span>
          {:else if column.key === 'actions'}
            <div class="flex items-center justify-end gap-3 sm:justify-start">
              <button
                type="button"
                class="text-primary text-xs hover:underline"
                onclick={() => (editTarget = { id: cat.id, name: cat.name, slug: cat.slug ?? '', price: cat.price ?? 0, tests: cat.tests ?? [] })}
              >Edit</button>
              <form method="POST" action="?/delete" use:enhance>
                <input type="hidden" name="id" value={cat.id} />
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
      <CardHeader><CardTitle>Tambah Kategori</CardTitle></CardHeader>
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
            <Label for="name">Nama Kategori</Label>
            <Input id="name" name="name" placeholder="cth: DISC + Holland" required />
          </div>
          <div class="flex flex-col gap-2">
            <Label for="slug">Slug</Label>
            <Input id="slug" name="slug" placeholder="cth: disc-holland" />
          </div>
          <div class="flex flex-col gap-2">
            <Label for="price">Harga (Rp)</Label>
            <Input id="price" name="price" type="number" placeholder="0" min="0" />
          </div>
          <div class="flex flex-col gap-2">
            <Label>Tes yang Termasuk</Label>
            <div class="flex flex-wrap gap-3">
              {#each TEST_OPTIONS as t}
                <label class="flex items-center gap-1.5 text-sm capitalize">
                  <input type="checkbox" name="tests" value={t} class="size-4" />
                  {t.toUpperCase()}
                </label>
              {/each}
            </div>
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
      <CardHeader><CardTitle>Edit Kategori</CardTitle></CardHeader>
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
          <div class="flex flex-col gap-2">
            <Label for="editName">Nama Kategori</Label>
            <Input id="editName" name="name" value={editTarget.name} required />
          </div>
          <div class="flex flex-col gap-2">
            <Label for="editSlug">Slug</Label>
            <Input id="editSlug" name="slug" value={editTarget.slug} />
          </div>
          <div class="flex flex-col gap-2">
            <Label for="editPrice">Harga (Rp)</Label>
            <Input id="editPrice" name="price" type="number" value={editTarget.price} min="0" />
          </div>
          <div class="flex flex-col gap-2">
            <Label>Tes yang Termasuk</Label>
            <div class="flex flex-wrap gap-3">
              {#each TEST_OPTIONS as t}
                <label class="flex items-center gap-1.5 text-sm capitalize">
                  <input type="checkbox" name="tests" value={t} checked={editTarget.tests.includes(t)} class="size-4" />
                  {t.toUpperCase()}
                </label>
              {/each}
            </div>
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
