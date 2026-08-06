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
  let filterRole = $state('');

  let editUser = $state<{ authUserId: string; name: string; email: string; schoolId: string } | null>(null);

  const roleLabel: Record<string, string> = {
    superadmin: 'Superadmin',
    gurubk: 'Guru BK',
    afiliator: 'Afiliator',
    psikolog: 'Psikolog',
    siswa: 'Siswa',
  };

  let filtered = $derived(
    filterRole ? data.users.filter((u: any) => u.role === filterRole) : data.users
  );

  function openEdit(user: any) {
    editUser = {
      authUserId: user.authUserId,
      name: user.name,
      email: user.email ?? '',
      schoolId: user.school?.id ? String(user.school.id) : '',
    };
  }
</script>

<svelte:head><title>Pengguna</title></svelte:head>

<div class="flex flex-col gap-6">
  <div class="flex items-center justify-between">
    <h2 class="text-2xl font-bold">Pengguna</h2>
    <Button onclick={() => (showModal = true)}>+ Tambah Pengguna</Button>
  </div>

  {#if form?.error}
    <div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">{form.error}</div>
  {/if}

  <div class="flex gap-2">
    <Button variant={filterRole === '' ? 'default' : 'outline'} size="sm" onclick={() => (filterRole = '')}>Semua</Button>
    <Button variant={filterRole === 'gurubk' ? 'default' : 'outline'} size="sm" onclick={() => (filterRole = 'gurubk')}>Guru BK</Button>
    <Button variant={filterRole === 'afiliator' ? 'default' : 'outline'} size="sm" onclick={() => (filterRole = 'afiliator')}>Afiliator</Button>
    <Button variant={filterRole === 'psikolog' ? 'default' : 'outline'} size="sm" onclick={() => (filterRole = 'psikolog')}>Psikolog</Button>
  </div>

  <Card>
    <CardContent class="pt-6">
      <table class="w-full text-sm">
        <thead>
          <tr class="border-border border-b text-left">
            <th class="pb-3 font-medium">Nama</th>
            <th class="pb-3 font-medium">Username</th>
            <th class="pb-3 font-medium">Email</th>
            <th class="pb-3 font-medium">Peran</th>
            <th class="pb-3 font-medium">Sekolah</th>
            <th class="pb-3 font-medium">Aksi</th>
          </tr>
        </thead>
        <tbody>
          {#each filtered as user}
            <tr class="border-border border-b last:border-0">
              <td class="py-3 font-medium">{user.name}</td>
              <td class="py-3">{user.username}</td>
              <td class="text-muted-foreground py-3">{user.email ?? '-'}</td>
              <td class="py-3"><Badge variant="secondary">{roleLabel[user.role] ?? user.role}</Badge></td>
              <td class="text-muted-foreground py-3">{user.school?.name ?? '-'}</td>
              <td class="py-3">
                <div class="flex items-center gap-3">
                  <button class="text-primary text-xs hover:underline" onclick={() => openEdit(user)}>Edit</button>
                  <form method="POST" action="?/delete" use:enhance>
                    <input type="hidden" name="id" value={user.authUserId} />
                    <button type="submit" class="text-destructive text-xs hover:underline">Hapus</button>
                  </form>
                </div>
              </td>
            </tr>
          {:else}
            <tr><td colspan="6" class="text-muted-foreground py-6 text-center">Belum ada pengguna</td></tr>
          {/each}
        </tbody>
      </table>
    </CardContent>
  </Card>
</div>

{#if editUser}
  <div class="bg-background/80 fixed inset-0 z-50 flex items-center justify-center backdrop-blur-sm">
    <Card class="w-full max-w-md">
      <CardHeader><CardTitle>Edit Pengguna</CardTitle></CardHeader>
      <CardContent>
        <form
          method="POST"
          action="?/update"
          use:enhance={() => {
            loading = true;
            return async ({ update }) => { loading = false; editUser = null; await update(); };
          }}
          class="flex flex-col gap-4"
        >
          <input type="hidden" name="id" value={editUser.authUserId} />
          <div class="flex flex-col gap-2">
            <Label for="edit-name">Nama Lengkap</Label>
            <Input id="edit-name" name="name" value={editUser.name} required />
          </div>
          <div class="flex flex-col gap-2">
            <Label for="edit-email">Email</Label>
            <Input id="edit-email" name="email" type="email" value={editUser.email} />
          </div>
          <div class="flex flex-col gap-2">
            <Label for="edit-school">Sekolah</Label>
            <select id="edit-school" name="schoolId" class="border-input bg-background flex h-10 w-full rounded-lg border px-3 text-sm">
              <option value="">Tanpa sekolah</option>
              {#each data.schools as s}
                <option value={s.id} selected={editUser.schoolId === String(s.id)}>{s.name}</option>
              {/each}
            </select>
          </div>
          <div class="flex flex-col gap-2">
            <Label for="edit-password">Password</Label>
            <Input id="edit-password" name="password" type="password" placeholder="Kosongkan untuk menggunakan password lama" />
          </div>
          <div class="flex justify-end gap-2">
            <Button type="button" variant="outline" onclick={() => (editUser = null)}>Batal</Button>
            <Button type="submit" disabled={loading}>{loading ? 'Menyimpan...' : 'Simpan'}</Button>
          </div>
        </form>
      </CardContent>
    </Card>
  </div>
{/if}

{#if showModal}
  <div class="bg-background/80 fixed inset-0 z-50 flex items-center justify-center backdrop-blur-sm">
    <Card class="w-full max-w-md">
      <CardHeader><CardTitle>Tambah Pengguna</CardTitle></CardHeader>
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
            <Label for="role">Peran</Label>
            <select id="role" name="role" class="border-input bg-background flex h-10 w-full rounded-lg border px-3 text-sm" required>
              <option value="">Pilih peran...</option>
              <option value="gurubk">Guru BK</option>
              <option value="afiliator">Afiliator</option>
              <option value="psikolog">Psikolog</option>
              <option value="superadmin">Superadmin</option>
            </select>
          </div>
          <div class="flex flex-col gap-2">
            <Label for="schoolId">Sekolah (opsional)</Label>
            <select id="schoolId" name="schoolId" class="border-input bg-background flex h-10 w-full rounded-lg border px-3 text-sm">
              <option value="">Tanpa sekolah</option>
              {#each data.schools as s}
                <option value={s.id}>{s.name}</option>
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
