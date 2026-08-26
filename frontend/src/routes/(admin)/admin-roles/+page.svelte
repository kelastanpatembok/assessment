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

  let editRole = $state<any>(null);

  const availablePermissions = [
    'CreateUser', 'ReadUser', 'UpdateUser', 'DeleteUser',
    'CreateSchool', 'ReadSchool', 'UpdateSchool', 'DeleteSchool',
    'CreateAssessment', 'ReadAssessment', 'UpdateAssessment', 'DeleteAssessment',
    'TakeTest', 'SubmitTest',
    'ReadOwnResults', 'ReadStudentResults', 'ReadAllResults',
    'GenerateReports', 'ExportReports',
    'ReadFees', 'UpdateFees',
    'AccessAdminPanel', 'ManageSystemSettings'
  ];

  let selectedPermissions = $state<string[]>([]);

  function togglePermission(perm: string) {
    if (selectedPermissions.includes(perm)) {
      selectedPermissions = selectedPermissions.filter(p => p !== perm);
    } else {
      selectedPermissions = [...selectedPermissions, perm];
    }
  }

  function openEdit(role: any) {
    editRole = { ...role };
    selectedPermissions = role.permissions.map((p: any) => p.permission);
  }

  function openCreate() {
    editRole = null;
    selectedPermissions = [];
    showModal = true;
  }
</script>

<svelte:head><title>Manajemen Role & Akses</title></svelte:head>

<div class="flex flex-col gap-6">
  <div class="flex items-center justify-between">
    <h2 class="text-2xl font-bold">Manajemen Role & Akses</h2>
    <Button onclick={openCreate}>+ Tambah Role</Button>
  </div>

  {#if form?.error}
    <div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">{form.error}</div>
  {/if}

  <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
    {#each data.roles as role}
      <Card>
        <CardHeader class="pb-3">
          <div class="flex justify-between items-start">
            <div>
              <CardTitle>{role.displayName}</CardTitle>
              <p class="text-sm text-muted-foreground">{role.role}</p>
            </div>
            <div class="flex gap-2">
              <button class="text-primary text-xs hover:underline" onclick={() => openEdit(role)}>Edit</button>
              {#if role.role !== 'SUPERADMIN'}
                <form method="POST" action="?/delete" use:enhance>
                  <input type="hidden" name="id" value={role.role} />
                  <button type="submit" class="text-destructive text-xs hover:underline">Hapus</button>
                </form>
              {/if}
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <p class="text-sm mb-4">{role.description || 'Tidak ada deskripsi'}</p>
          <div class="flex flex-wrap gap-1">
            {#each role.permissions.slice(0, 5) as p}
              <Badge variant="secondary" class="text-xs">{p.permission}</Badge>
            {/each}
            {#if role.permissions.length > 5}
              <Badge variant="outline" class="text-xs">+{role.permissions.length - 5} lainnya</Badge>
            {/if}
          </div>
        </CardContent>
      </Card>
    {/each}
  </div>
</div>

{#if showModal || editRole}
  <div class="bg-background/80 fixed inset-0 z-50 flex items-center justify-center p-4 backdrop-blur-sm overflow-y-auto">
    <Card class="w-full max-w-2xl my-auto">
      <CardHeader>
        <CardTitle>{editRole ? 'Edit Role' : 'Tambah Role Baru'}</CardTitle>
      </CardHeader>
      <CardContent>
        <form
          method="POST"
          action={editRole ? "?/update" : "?/create"}
          use:enhance={() => {
            loading = true;
            return async ({ update }) => { 
              loading = false; 
              showModal = false; 
              editRole = null; 
              await update(); 
            };
          }}
          class="flex flex-col gap-4"
        >
          {#if editRole}
            <input type="hidden" name="id" value={editRole.role} />
          {/if}
          <input type="hidden" name="permissions" value={JSON.stringify(selectedPermissions)} />
          
          <div class="grid gap-4 md:grid-cols-2">
            {#if !editRole}
              <div class="flex flex-col gap-2">
                <Label for="id">ID Role (KAPITAL, tanpa spasi)</Label>
                <Input id="id" name="id" placeholder="Contoh: ASISTEN_PSIKOLOG" required />
              </div>
            {/if}
            
            <div class="flex flex-col gap-2">
              <Label for="displayName">Nama Tampilan</Label>
              <Input id="displayName" name="displayName" value={editRole?.displayName ?? ''} placeholder="Asisten Psikolog" required />
            </div>
          </div>
          
          <div class="flex flex-col gap-2">
            <Label for="description">Deskripsi</Label>
            <Input id="description" name="description" value={editRole?.description ?? ''} placeholder="Deskripsi role..." />
          </div>

          <div class="mt-4">
            <Label class="mb-2 block">Hak Akses (Permissions)</Label>
            <div class="grid grid-cols-2 md:grid-cols-3 gap-2 max-h-60 overflow-y-auto p-2 border rounded-md">
              {#each availablePermissions as perm}
                <label class="flex items-center gap-2 text-sm cursor-pointer hover:bg-muted/50 p-1 rounded">
                  <input 
                    type="checkbox" 
                    checked={selectedPermissions.includes(perm)}
                    onchange={() => togglePermission(perm)}
                    class="rounded border-input"
                  />
                  {perm}
                </label>
              {/each}
            </div>
          </div>

          <div class="flex justify-end gap-2 mt-4">
            <Button type="button" variant="outline" onclick={() => { showModal = false; editRole = null; }}>Batal</Button>
            <Button type="submit" disabled={loading}>{loading ? 'Menyimpan...' : 'Simpan'}</Button>
          </div>
        </form>
      </CardContent>
    </Card>
  </div>
{/if}
