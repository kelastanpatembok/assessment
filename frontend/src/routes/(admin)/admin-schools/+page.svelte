<script lang="ts">
  import { enhance } from '$app/forms';
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';

  let { data, form } = $props();
  let showModal = $state(false);
  let editTarget = $state<{ id: number; name: string; address: string } | null>(null);
  let loading = $state(false);
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
      <table class="w-full text-sm">
        <thead>
          <tr class="border-border border-b text-left">
            <th class="pb-3 font-medium">No</th>
            <th class="pb-3 font-medium">Nama Sekolah</th>
            <th class="pb-3 font-medium">Alamat</th>
            <th class="pb-3 font-medium">Aksi</th>
          </tr>
        </thead>
        <tbody>
          {#each data.schools as school, i}
            <tr class="border-border border-b last:border-0">
              <td class="py-3">{i + 1}</td>
              <td class="py-3 font-medium">{school.name}</td>
              <td class="text-muted-foreground py-3">{school.address ?? '-'}</td>
              <td class="flex gap-3 py-3">
                <button
                  type="button"
                  class="text-xs text-blue-600 hover:underline"
                  onclick={() => (editTarget = { id: school.id, name: school.name, address: school.address ?? '' })}
                >Edit</button>
                <form method="POST" action="?/delete" use:enhance>
                  <input type="hidden" name="id" value={school.id} />
                  <button type="submit" class="text-destructive text-xs hover:underline">Hapus</button>
                </form>
              </td>
            </tr>
          {:else}
            <tr><td colspan="4" class="text-muted-foreground py-6 text-center">Belum ada sekolah</td></tr>
          {/each}
        </tbody>
      </table>
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
