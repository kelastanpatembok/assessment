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
  let editTarget = $state<{ id: number; name: string; address: string; email: string } | null>(null);
  let picSchool = $state<any | null>(null);
  let loading = $state(false);

  const columns: TableColumn[] = [
    { key: 'id', label: 'ID', sortable: true, hideBelow: 'sm' },
    { key: 'name', label: 'Nama Sekolah', sortable: true },
    { key: 'address', label: 'Alamat', hideBelow: 'sm' },
    { key: 'email', label: 'Email resmi', hideBelow: 'md' },
    { key: 'pic', label: 'PIC utama', hideBelow: 'md' },
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
          {:else if column.key === 'email'}
            <span class="text-muted-foreground">{school.email ?? 'Belum diisi'}</span>
          {:else if column.key === 'pic'}
            {@const primaryPic = (data.picsBySchool[school.id] ?? []).find((pic: any) => pic.isPrimary)}
            <span class="text-muted-foreground">{primaryPic?.name ?? 'Belum dipilih'}</span>
          {:else if column.key === 'actions'}
            <div class="flex items-center justify-end gap-3 sm:justify-start">
              <button
                type="button"
                class="text-primary text-xs hover:underline"
                onclick={() => (editTarget = { id: school.id, name: school.name, address: school.address ?? '', email: school.email ?? '' })}
              >Edit</button>
              <button type="button" class="text-primary text-xs hover:underline" onclick={() => (picSchool = school)}>Atur PIC</button>
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
          <div class="flex flex-col gap-2">
            <Label for="email">Email resmi sekolah</Label>
            <Input id="email" name="email" type="email" placeholder="sekolah@sch.id" required />
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
          <div class="flex flex-col gap-2">
            <Label for="editEmail">Email resmi sekolah</Label>
            <Input id="editEmail" name="email" type="email" value={editTarget.email} required />
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

{#if picSchool}
  <div class="bg-background/80 fixed inset-0 z-50 flex items-center justify-center p-4 backdrop-blur-sm">
    <Card class="w-full max-w-xl">
      <CardHeader><CardTitle>PIC {picSchool.name}</CardTitle></CardHeader>
      <CardContent class="space-y-5">
        <p class="text-muted-foreground text-sm">PIC wajib merupakan akun staf yang terhubung ke sekolah ini. Seluruh PIC menerima salinan laporan; PIC utama menandai kontak penanggung jawab.</p>
        {@const schoolPics = data.picsBySchool[picSchool.id] ?? []}
        {#if schoolPics.length}
          <div class="space-y-2">
            {#each schoolPics as pic}
              <div class="border-border flex items-center justify-between gap-3 rounded-lg border p-3">
                <div>
                  <p class="font-medium">{pic.name} {pic.isPrimary ? '(utama)' : ''}</p>
                  <p class="text-muted-foreground text-xs">{pic.email} · {pic.role}</p>
                </div>
                <div class="flex gap-2">
                  {#if !pic.isPrimary}
                    <form method="POST" action="?/setPrimaryPic" use:enhance>
                      <input type="hidden" name="schoolId" value={picSchool.id} />
                      <input type="hidden" name="authUserId" value={pic.authUserId} />
                      <button class="text-primary text-xs hover:underline" type="submit">Jadikan utama</button>
                    </form>
                  {/if}
                  <form method="POST" action="?/removePic" use:enhance>
                    <input type="hidden" name="schoolId" value={picSchool.id} />
                    <input type="hidden" name="authUserId" value={pic.authUserId} />
                    <button class="text-destructive text-xs hover:underline" type="submit">Hapus</button>
                  </form>
                </div>
              </div>
            {/each}
          </div>
        {/if}
        <form method="POST" action="?/addPic" use:enhance class="space-y-3">
          <input type="hidden" name="schoolId" value={picSchool.id} />
          <div class="flex flex-col gap-2">
            <Label for="authUserId">Akun staf sekolah</Label>
            <select id="authUserId" name="authUserId" class="border-input bg-background h-10 rounded-lg border px-3 text-sm" required>
              <option value="">Pilih akun...</option>
              {#each data.users.filter((user: any) => user.school?.id === picSchool.id && user.role !== 'siswa' && !schoolPics.some((pic: any) => pic.authUserId === user.authUserId)) as user}
                <option value={user.authUserId}>{user.name} · {user.email} ({user.role})</option>
              {/each}
            </select>
          </div>
          <label class="flex items-center gap-2 text-sm"><input type="checkbox" name="isPrimary" /> Jadikan PIC utama</label>
          <div class="flex justify-end gap-2">
            <Button type="button" variant="outline" onclick={() => (picSchool = null)}>Tutup</Button>
            <Button type="submit">Tambahkan PIC</Button>
          </div>
        </form>
      </CardContent>
    </Card>
  </div>
{/if}
