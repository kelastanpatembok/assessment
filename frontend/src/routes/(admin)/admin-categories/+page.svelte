<script lang="ts">
  import { enhance } from '$app/forms';
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';

  let { data, form } = $props();
  let showModal = $state(false);
  let loading = $state(false);
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
      <table class="w-full text-sm">
        <thead>
          <tr class="border-border border-b text-left">
            <th class="pb-3 font-medium">ID</th>
            <th class="pb-3 font-medium">Nama</th>
            <th class="pb-3 font-medium">Slug</th>
            <th class="pb-3 font-medium">Harga</th>
            <th class="pb-3 font-medium">Aksi</th>
          </tr>
        </thead>
        <tbody>
          {#each data.categories as cat}
            <tr class="border-border border-b last:border-0">
              <td class="text-muted-foreground py-3">{cat.id}</td>
              <td class="py-3 font-medium">{cat.name}</td>
              <td class="text-muted-foreground py-3">{cat.slug ?? '-'}</td>
              <td class="py-3">Rp {(cat.price ?? 0).toLocaleString('id-ID')}</td>
              <td class="py-3">
                <form method="POST" action="?/delete" use:enhance>
                  <input type="hidden" name="id" value={cat.id} />
                  <button type="submit" class="text-destructive text-xs hover:underline">Hapus</button>
                </form>
              </td>
            </tr>
          {:else}
            <tr><td colspan="5" class="text-muted-foreground py-6 text-center">Belum ada kategori</td></tr>
          {/each}
        </tbody>
      </table>
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
          <div class="flex justify-end gap-2">
            <Button type="button" variant="outline" onclick={() => (showModal = false)}>Batal</Button>
            <Button type="submit" disabled={loading}>{loading ? 'Menyimpan...' : 'Simpan'}</Button>
          </div>
        </form>
      </CardContent>
    </Card>
  </div>
{/if}
