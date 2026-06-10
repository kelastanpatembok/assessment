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

<svelte:head><title>Siswa</title></svelte:head>

<div class="flex flex-col gap-6">
  <div class="flex items-center justify-between">
    <h2 class="text-2xl font-bold">Siswa</h2>
    <Button onclick={() => (showModal = true)}>+ Tambah Siswa</Button>
  </div>

  {#if form?.error}
    <div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">{form.error}</div>
  {/if}

  <Card>
    <CardContent class="pt-6">
      <table class="w-full text-sm">
        <thead>
          <tr class="border-border border-b text-left">
            <th class="pb-3 font-medium">Nama</th>
            <th class="pb-3 font-medium">Username</th>
            <th class="pb-3 font-medium">Sekolah</th>
            <th class="pb-3 font-medium">Kategori</th>
            <th class="pb-3 font-medium">Aksi</th>
          </tr>
        </thead>
        <tbody>
          {#each data.students as s}
            <tr class="border-border border-b last:border-0">
              <td class="py-3 font-medium">{s.name}</td>
              <td class="py-3">{s.username}</td>
              <td class="text-muted-foreground py-3">{s.schoolName ?? '-'}</td>
              <td class="text-muted-foreground py-3">{s.categoryName ?? '-'}</td>
              <td class="py-3">
                <form method="POST" action="?/delete" use:enhance>
                  <input type="hidden" name="id" value={s.authUserId} />
                  <button type="submit" class="text-destructive text-xs hover:underline">Hapus</button>
                </form>
              </td>
            </tr>
          {:else}
            <tr><td colspan="5" class="text-muted-foreground py-6 text-center">Belum ada siswa</td></tr>
          {/each}
        </tbody>
      </table>
    </CardContent>
  </Card>
</div>

{#if showModal}
  <div class="bg-background/80 fixed inset-0 z-50 flex items-center justify-center backdrop-blur-sm">
    <Card class="w-full max-w-md">
      <CardHeader><CardTitle>Tambah Siswa</CardTitle></CardHeader>
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
            <Label for="name">Nama Lengkap</Label>
            <Input id="name" name="name" placeholder="Nama lengkap" required />
          </div>
          <div class="flex flex-col gap-2">
            <Label for="username">Username</Label>
            <Input id="username" name="username" placeholder="Username" required />
          </div>
          <div class="flex flex-col gap-2">
            <Label for="email">Email</Label>
            <Input id="email" name="email" type="email" placeholder="email@contoh.com" />
          </div>
          <div class="flex flex-col gap-2">
            <Label for="password">Password</Label>
            <Input id="password" name="password" type="password" placeholder="Password" required />
          </div>
          <div class="flex flex-col gap-2">
            <Label for="schoolId">Sekolah</Label>
            <select id="schoolId" name="schoolId" class="border-input bg-background flex h-10 w-full rounded-lg border px-3 text-sm" required>
              <option value="">Pilih sekolah...</option>
              {#each data.schools as s}
                <option value={s.id}>{s.schoolName}</option>
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
          <div class="flex justify-end gap-2">
            <Button type="button" variant="outline" onclick={() => (showModal = false)}>Batal</Button>
            <Button type="submit" disabled={loading}>{loading ? 'Menyimpan...' : 'Simpan'}</Button>
          </div>
        </form>
      </CardContent>
    </Card>
  </div>
{/if}
