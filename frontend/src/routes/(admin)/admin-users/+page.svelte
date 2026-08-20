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
  let loading = $state(false);

  let editUser = $state<{ authUserId: string; name: string; email: string; schoolId: string } | null>(null);

  const roleLabel: Record<string, string> = {
    superadmin: 'Superadmin',
    gurubk: 'Guru BK',
    afiliator: 'Afiliator',
    psikolog: 'Psikolog',
    pic: 'PIC Sekolah',
    siswa: 'Siswa',
  };

  const roleFilters = [
    { value: '', label: 'Semua' },
    { value: 'gurubk', label: 'Guru BK' },
    { value: 'afiliator', label: 'Afiliator' },
    { value: 'psikolog', label: 'Psikolog' },
    { value: 'pic', label: 'PIC Sekolah' },
    { value: 'superadmin', label: 'Superadmin' },
  ];

  const columns: TableColumn[] = [
    { key: 'name', label: 'Nama', sortable: true },
    { key: 'username', label: 'Username', sortable: true },
    { key: 'email', label: 'Email', sortable: true, hideBelow: 'sm' },
    { key: 'role', label: 'Peran', sortable: true, hideBelow: 'sm' },
    { key: 'school', label: 'Sekolah', sortable: true, sortKey: 'school.name', hideBelow: 'md' },
    { key: 'actions', label: 'Aksi' },
  ];

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

  <div class="flex flex-wrap gap-2">
    {#each roleFilters as rf}
      <a
        href={rf.value ? `?role=${rf.value}` : '?'}
        class={"inline-flex h-9 items-center rounded-lg px-4 text-sm font-medium transition-colors " +
          (data.role === rf.value
            ? 'bg-primary text-primary-foreground'
            : 'border-input bg-background hover:bg-accent border')}
      >
        {rf.label}
      </a>
    {/each}
  </div>

  <Card>
    <CardContent class="pt-6">
      <DataTable
        {columns}
        table={data.table}
        searchPlaceholder="Cari nama, username, atau email..."
        rowKey={(u: any) => u.authUserId}
      >
        {#snippet cell(column, user)}
          {#if column.key === 'name'}
            <span class="font-medium">{user.name}</span>
          {:else if column.key === 'username'}
            <span>{user.username}</span>
          {:else if column.key === 'email'}
            <span class="text-muted-foreground">{user.email ?? '-'}</span>
          {:else if column.key === 'role'}
            <Badge variant="secondary">{roleLabel[user.role] ?? user.role}</Badge>
          {:else if column.key === 'school'}
            <span class="text-muted-foreground">{user.school?.name ?? '-'}</span>
          {:else if column.key === 'actions'}
            <div class="flex items-center justify-end gap-3 sm:justify-start">
              <button class="text-primary text-xs hover:underline" onclick={() => openEdit(user)}>Edit</button>
              <form method="POST" action="?/delete" use:enhance>
                <input type="hidden" name="id" value={user.authUserId} />
                <button type="submit" class="text-destructive text-xs hover:underline">Hapus</button>
              </form>
            </div>
          {/if}
        {/snippet}
      </DataTable>
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
            <SchoolSearchSelect token={data.token} name="schoolId" value={editUser.schoolId ? Number(editUser.schoolId) : null} placeholder="Cari sekolah (opsional)..." />
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
              <option value="pic">PIC Sekolah</option>
              <option value="superadmin">Superadmin</option>
            </select>
          </div>
          <div class="flex flex-col gap-2">
            <Label for="schoolId">Sekolah (wajib untuk Guru BK/PIC)</Label>
            <SchoolSearchSelect token={data.token} name="schoolId" placeholder="Cari sekolah (opsional)..." />
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
