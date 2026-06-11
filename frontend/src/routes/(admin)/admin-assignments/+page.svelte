<script lang="ts">
  import { enhance } from '$app/forms';
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import { Badge } from '$lib/components/ui/badge/index.js';

  let { data, form } = $props();
  let showModal = $state(false);
  let loading = $state(false);
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
      <table class="w-full text-sm">
        <thead>
          <tr class="border-border border-b text-left">
            <th class="pb-3 font-medium">Sekolah</th>
            <th class="pb-3 font-medium">Kategori</th>
            <th class="pb-3 font-medium">Mulai</th>
            <th class="pb-3 font-medium">Selesai</th>
            <th class="pb-3 font-medium">Status</th>
            <th class="pb-3 font-medium">Aksi</th>
          </tr>
        </thead>
        <tbody>
          {#each data.assignments as a}
            <tr class="border-border border-b last:border-0">
              <td class="py-3 font-medium">{a.school?.name ?? '-'}</td>
              <td class="py-3">{a.category?.name ?? '-'}</td>
              <td class="text-muted-foreground py-3">{a.windowStart?.split('T')[0] ?? '-'}</td>
              <td class="text-muted-foreground py-3">{a.windowEnd?.split('T')[0] ?? '-'}</td>
              <td class="py-3">
                <Badge variant={a.active ? 'default' : 'secondary'}>{a.active ? 'aktif' : 'pasif'}</Badge>
              </td>
              <td class="py-3">
                <form method="POST" action="?/delete" use:enhance>
                  <input type="hidden" name="id" value={a.id} />
                  <button type="submit" class="text-destructive text-xs hover:underline">Hapus</button>
                </form>
              </td>
            </tr>
          {:else}
            <tr><td colspan="6" class="text-muted-foreground py-6 text-center">Belum ada penugasan</td></tr>
          {/each}
        </tbody>
      </table>
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
            <select id="schoolId" name="schoolId" class="border-input bg-background flex h-10 w-full rounded-lg border px-3 text-sm" required>
              <option value="">Pilih sekolah...</option>
              {#each data.schools as s}
                <option value={s.id}>{s.name}</option>
              {/each}
            </select>
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
