<script lang="ts">
  import { enhance } from '$app/forms';
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import SchoolSearchSelect from '$lib/components/SchoolSearchSelect.svelte';
  import DataTable from '$lib/components/table/DataTable.svelte';
  import type { TableColumn } from '$lib/table/types';

  let { data, form } = $props();
  let showModal = $state(false);
  let editTarget = $state<{ id: string; name: string; email: string; schoolId: string } | null>(null);
  let loading = $state(false);

  const columns: TableColumn[] = [
    { key: 'name', label: 'Nama', sortable: true },
    { key: 'username', label: 'Username', sortable: true },
    { key: 'school', label: 'Sekolah', sortable: true, sortKey: 'school.name', hideBelow: 'sm' },
    { key: 'email', label: 'Email', sortable: true, hideBelow: 'sm' },
    { key: 'actions', label: 'Aksi' },
  ];
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
      <DataTable
        {columns}
        table={data.table}
        searchPlaceholder="Cari nama, username, atau email..."
        rowKey={(s: any) => s.authUserId}
      >
        {#snippet cell(column, s)}
          {#if column.key === 'name'}
            <span class="font-medium">{s.name}</span>
          {:else if column.key === 'username'}
            <span>{s.username}</span>
          {:else if column.key === 'school'}
            <span class="text-muted-foreground">{s.school?.name ?? '-'}</span>
          {:else if column.key === 'email'}
            <span class="text-muted-foreground">{s.email ?? '-'}</span>
          {:else if column.key === 'actions'}
            <div class="flex items-center justify-end gap-3 sm:justify-start">
              <button
                type="button"
                class="text-primary text-xs hover:underline"
                onclick={() => (editTarget = { id: s.authUserId, name: s.name, email: s.email ?? '', schoolId: String(s.school?.id ?? '') })}
              >Edit</button>
              <form method="POST" action="?/delete" use:enhance>
                <input type="hidden" name="id" value={s.authUserId} />
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
      <CardHeader><CardTitle>Edit Siswa</CardTitle></CardHeader>
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
            <Label for="editName">Nama Lengkap</Label>
            <Input id="editName" name="name" value={editTarget.name} required />
          </div>
          <div class="flex flex-col gap-2">
            <Label for="editEmail">Email</Label>
            <Input id="editEmail" name="email" type="email" value={editTarget.email} />
          </div>
          <div class="flex flex-col gap-2">
            <Label for="editSchoolId">Sekolah</Label>
            <SchoolSearchSelect token={data.token} name="schoolId" value={editTarget.schoolId ? Number(editTarget.schoolId) : null} placeholder="Cari sekolah..." />
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
