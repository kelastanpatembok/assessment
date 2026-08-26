<script lang="ts">
  import DashboardShell from '$lib/components/dashboard/DashboardShell.svelte';
  import { enhance } from '$app/forms';
  import { invalidateAll } from '$app/navigation';
  import { page } from '$app/stores';

  let { data, form } = $props();

  const navLinks = [
    { href: '/admin-dashboard', label: 'Dashboard' },
    { href: '/admin-schools', label: 'Sekolah' },
    { href: '/admin-users', label: 'Pengguna' },
    { href: '/admin-registrations', label: 'Pendaftaran' },
    { href: '/admin-roles', label: 'Manajemen Role' },
    { href: '/admin-students', label: 'Siswa' },
    { href: '/assignment-modules', label: 'Modul Penugasan' },
    { href: '/admin-categories', label: 'Kategori Tes' },
    { href: '/admin-assignments', label: 'Penugasan' },
    { href: '/admin-fees', label: 'Biaya' },
  ];

  let search = $state(data.search || '');
  let statusFilter = $state(data.status || '');
  let selectedReg = $state<any>(null);
  let showDetail = $state(false);
  let editNotes = $state('');
  let editStatus = $state('');

  let showProvision = $state(false);
  let provUsername = $state('');
  let provPassword = $state('');
  let provRole = $state('siswa');
  let provSchoolId = $state('');

  function openDetail(reg: any) {
    selectedReg = reg;
    editNotes = reg.notes || '';
    editStatus = reg.status;
    showDetail = true;
  }

  function closeDetail() {
    showDetail = false;
    selectedReg = null;
  }

  function openProvision(reg: any) {
    selectedReg = reg;
    // Suggest username based on email
    provUsername = reg.email.split('@')[0];
    provPassword = Math.random().toString(36).slice(-8);
    provRole = reg.role.toLowerCase() || 'siswa';
    provSchoolId = '';
    showProvision = true;
  }

  function closeProvision() {
    showProvision = false;
    selectedReg = null;
  }

  const statusBadge: Record<string, { label: string; cls: string }> = {
    pending: { label: 'Menunggu', cls: 'badge-pending' },
    approved: { label: 'Disetujui', cls: 'badge-approved' },
    rejected: { label: 'Ditolak', cls: 'badge-rejected' },
  };

  function formatDate(d: string) {
    return new Date(d).toLocaleDateString('id-ID', { day: 'numeric', month: 'short', year: 'numeric' });
  }
</script>

<svelte:head>
  <title>Laporan Pendaftaran — Asesmen</title>
</svelte:head>

<DashboardShell roleLabel="Superadmin" {navLinks} user={data.user} profile={data.profile}>

  <!-- Header -->
  <div class="reg-header">
    <div>
      <h1 class="reg-title">Laporan Pendaftaran</h1>
      <p class="reg-sub">Total <strong>{data.total}</strong> pendaftaran masuk</p>
    </div>
    <a href="/daftar" target="_blank" class="btn-outline">Lihat Form Publik ↗</a>
  </div>

  {#if form?.error}
    <p class="flash-error">{form.error}</p>
  {/if}

  <!-- Filters -->
  <form method="GET" class="filters">
    <input
      type="text"
      name="search"
      placeholder="Cari nama, email, sekolah…"
      value={search}
      class="filter-input"
    />
    <select name="status" class="filter-select" bind:value={statusFilter}>
      <option value="">Semua Status</option>
      <option value="pending">Menunggu</option>
      <option value="approved">Disetujui</option>
      <option value="rejected">Ditolak</option>
    </select>
    <button type="submit" class="btn-primary">Filter</button>
  </form>

  <!-- Table -->
  <div class="table-wrap">
    <table class="reg-table">
      <thead>
        <tr>
          <th>Nama</th>
          <th>Email</th>
          <th>No. HP</th>
          <th>Sekolah</th>
          <th>Status</th>
          <th>Tanggal</th>
          <th>Aksi</th>
        </tr>
      </thead>
      <tbody>
        {#each data.registrations as reg (reg.id)}
          <tr>
            <td class="td-name">{reg.name}</td>
            <td class="td-email">{reg.email}</td>
            <td class="td-phone">{reg.phone ?? '—'}</td>
            <td class="td-school">{reg.schoolName ?? '—'}</td>
            <td>
              <span class="badge {statusBadge[reg.status]?.cls ?? ''}">
                {statusBadge[reg.status]?.label ?? reg.status}
              </span>
            </td>
            <td class="td-date">{formatDate(reg.createdAt)}</td>
            <td class="td-actions">
              <button type="button" class="link-btn" onclick={() => openDetail(reg)}>Detail</button>
              {#if !reg.authUserId && reg.status !== 'rejected'}
                <button type="button" class="link-btn success" onclick={() => openProvision(reg)}>Buat Akun</button>
              {/if}
              <form method="POST" action="?/delete" use:enhance class="inline">
                <input type="hidden" name="id" value={reg.id} />
                <button
                  type="submit"
                  class="link-btn danger"
                  onclick={(e) => { if (!confirm('Hapus pendaftaran ini?')) e.preventDefault(); }}
                >
                  Hapus
                </button>
              </form>
            </td>
          </tr>
        {:else}
          <tr>
            <td colspan="7" class="td-empty">Belum ada pendaftaran.</td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>

  <!-- Pagination -->
  {#if data.total > 25}
    <div class="pagination">
      {#if data.currentPage > 1}
        <a href="?page={data.currentPage - 1}&search={data.search}&status={data.status}" class="page-btn">← Sebelumnya</a>
      {/if}
      <span class="page-info">Halaman {data.currentPage}</span>
      {#if data.registrations.length === 25}
        <a href="?page={data.currentPage + 1}&search={data.search}&status={data.status}" class="page-btn">Berikutnya →</a>
      {/if}
    </div>
  {/if}

</DashboardShell>

<!-- Detail Modal -->
{#if showDetail && selectedReg}
  <div class="modal-backdrop" role="dialog" aria-modal="true" aria-label="Detail Pendaftaran">
    <div class="modal">
      <div class="modal-head">
        <h2>Detail Pendaftaran</h2>
        <button type="button" class="modal-close" onclick={closeDetail} aria-label="Tutup">✕</button>
      </div>

      <div class="detail-grid">
        <div class="detail-row">
          <span class="detail-label">Nama</span>
          <span class="detail-val">{selectedReg.name}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Email</span>
          <span class="detail-val">{selectedReg.email}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">No. HP</span>
          <span class="detail-val">{selectedReg.phone ?? '—'}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Sekolah</span>
          <span class="detail-val">{selectedReg.schoolName ?? '—'}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Alamat Sekolah</span>
          <span class="detail-val">{selectedReg.schoolAddress ?? '—'}</span>
        </div>
        <div class="detail-row">
          <span class="detail-label">Tanggal Daftar</span>
          <span class="detail-val">{formatDate(selectedReg.createdAt)}</span>
        </div>
      </div>

      <form
        method="POST"
        action="?/updateStatus"
        use:enhance={() => {
          return async ({ result, update }) => {
            await update();
            closeDetail();
          };
        }}
        class="modal-form"
      >
        <input type="hidden" name="id" value={selectedReg.id} />

        <label class="field-label">Status</label>
        <select name="status" class="modal-select" bind:value={editStatus}>
          <option value="pending">Menunggu</option>
          <option value="approved">Disetujui</option>
          <option value="rejected">Ditolak</option>
        </select>

        <label class="field-label" style="margin-top:0.75rem;">Catatan Admin</label>
        <textarea
          name="notes"
          rows="3"
          class="modal-textarea"
          placeholder="Catatan tambahan…"
          bind:value={editNotes}
        ></textarea>

        <div class="modal-actions">
          <button type="button" class="btn-outline" onclick={closeDetail}>Batal</button>
          <button type="submit" class="btn-primary">Simpan</button>
        </div>
      </form>
    </div>
  </div>
{/if}

<!-- Provision Modal -->
{#if showProvision && selectedReg}
  <div class="modal-backdrop" role="dialog" aria-modal="true" aria-label="Buat Akun">
    <div class="modal">
      <div class="modal-head">
        <h2>Buat Akun Baru</h2>
        <button type="button" class="modal-close" onclick={closeProvision} aria-label="Tutup">✕</button>
      </div>

      <div class="prov-info">
        <p>Anda akan membuat akun untuk <strong>{selectedReg.name}</strong> ({selectedReg.email}).</p>
        <p>Pendaftaran ini akan otomatis ditandai sebagai <strong>Disetujui</strong>.</p>
      </div>

      <form
        method="POST"
        action="?/provision"
        use:enhance={() => {
          return async ({ result, update }) => {
            if (result.type === 'success') {
              alert('Akun berhasil dibuat!');
            }
            await update();
            closeProvision();
          };
        }}
        class="modal-form"
      >
        <input type="hidden" name="id" value={selectedReg.id} />

        <div class="field">
          <label class="field-label">Username</label>
          <input type="text" name="username" class="modal-input" required bind:value={provUsername} />
        </div>

        <div class="field">
          <label class="field-label">Kata Sandi Sementara</label>
          <input type="text" name="password" class="modal-input" required bind:value={provPassword} />
        </div>

        <div class="field">
          <label class="field-label">Role Akses</label>
          <select name="role" class="modal-select" bind:value={provRole}>
            <option value="siswa">Siswa (Akses Terbatas)</option>
            <option value="gurubk">Guru BK (Akses Sekolah)</option>
            <option value="psikolog">Psikolog (Akses Semua Siswa)</option>
            <option value="afiliator">Afiliator (Akses Siswa Afiliasi)</option>
            <option value="superadmin">Superadmin (Akses Penuh)</option>
          </select>
        </div>

        {#if provRole === 'siswa' || provRole === 'gurubk'}
          <div class="field">
            <label class="field-label">Hubungkan ke Sekolah</label>
            <select name="schoolId" class="modal-select" bind:value={provSchoolId}>
              <option value="">-- Tanpa Sekolah --</option>
              {#each data.schools as s}
                <option value={s.id}>{s.name}</option>
              {/each}
            </select>
            <span class="field-hint">Kosongkan jika tidak terikat sekolah mana pun.</span>
          </div>
        {/if}

        <div class="modal-actions" style="margin-top: 1.5rem;">
          <button type="button" class="btn-outline" onclick={closeProvision}>Batal</button>
          <button type="submit" class="btn-primary">Buat Akun Sekarang</button>
        </div>
      </form>
    </div>
  </div>
{/if}

<style>
  .reg-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    flex-wrap: wrap;
    gap: 1rem;
    margin-bottom: 1.5rem;
  }

  .reg-title {
    font-size: 1.5rem;
    font-weight: 700;
    margin: 0 0 0.25rem;
  }

  .reg-sub {
    color: var(--lp-muted);
    font-size: 0.9rem;
    margin: 0;
  }

  .filters {
    display: flex;
    gap: 0.75rem;
    flex-wrap: wrap;
    margin-bottom: 1.5rem;
  }

  .filter-input {
    flex: 1;
    min-width: 14rem;
    padding: 0.6rem 1rem;
    border-radius: 0.6rem;
    border: 1.5px solid var(--lp-rule-2);
    background: var(--lp-paper);
    color: var(--lp-ink);
    font-size: 0.9rem;
  }

  .filter-select {
    padding: 0.6rem 1rem;
    border-radius: 0.6rem;
    border: 1.5px solid var(--lp-rule-2);
    background: var(--lp-paper);
    color: var(--lp-ink);
    font-size: 0.9rem;
  }

  .btn-primary {
    padding: 0.6rem 1.25rem;
    border-radius: 0.6rem;
    background: var(--lp-ink);
    color: var(--lp-paper);
    border: none;
    font-weight: 600;
    font-size: 0.9rem;
    cursor: pointer;
    transition: background 150ms;
  }

  .btn-primary:hover { background: var(--lp-ink-2); }

  .btn-outline {
    padding: 0.6rem 1.25rem;
    border-radius: 0.6rem;
    background: transparent;
    color: var(--lp-ink);
    border: 1.5px solid var(--lp-rule-2);
    font-weight: 600;
    font-size: 0.9rem;
    cursor: pointer;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    transition: border-color 150ms;
  }

  .btn-outline:hover { border-color: var(--lp-ink); }

  .table-wrap {
    overflow-x: auto;
    border: 1px solid var(--lp-rule);
    border-radius: 0.75rem;
  }

  .reg-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 0.88rem;
  }

  .reg-table th {
    text-align: left;
    padding: 0.75rem 1rem;
    background: var(--lp-paper-2);
    color: var(--lp-muted);
    font-weight: 600;
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    white-space: nowrap;
    border-bottom: 1px solid var(--lp-rule);
  }

  .reg-table td {
    padding: 0.8rem 1rem;
    border-bottom: 1px solid var(--lp-rule);
    vertical-align: top;
  }

  .reg-table tr:last-child td { border-bottom: none; }
  .reg-table tr:hover td { background: var(--lp-paper-2); }

  .td-name { font-weight: 600; }
  .td-email { color: var(--lp-muted); font-size: 0.85rem; }
  .td-phone { color: var(--lp-muted); font-size: 0.85rem; white-space: nowrap; }
  .td-school { max-width: 12rem; }
  .td-date { white-space: nowrap; color: var(--lp-muted); font-size: 0.82rem; }
  .td-empty { text-align: center; color: var(--lp-muted); padding: 2rem; }

  .td-actions {
    display: flex;
    gap: 0.75rem;
    align-items: center;
    white-space: nowrap;
  }

  .link-btn {
    background: none;
    border: none;
    padding: 0;
    font-size: 0.85rem;
    font-weight: 600;
    color: var(--lp-accent-deep);
    cursor: pointer;
    text-decoration: underline;
  }

  .link-btn.danger { color: oklch(0.55 0.18 25); }
  .link-btn.success { color: oklch(0.4 0.12 145); }
  .inline { display: inline; }

  .badge {
    display: inline-block;
    padding: 0.2em 0.65em;
    border-radius: 999px;
    font-size: 0.75rem;
    font-weight: 600;
    letter-spacing: 0.03em;
  }

  .badge-pending  { background: oklch(0.95 0.06 85);  color: oklch(0.5 0.1 85); }
  .badge-approved { background: oklch(0.92 0.08 145); color: oklch(0.4 0.12 145); }
  .badge-rejected { background: oklch(0.95 0.06 25);  color: oklch(0.5 0.14 25); }

  .flash-error {
    background: oklch(0.96 0.03 25);
    border: 1px solid oklch(0.85 0.06 25);
    color: oklch(0.5 0.14 25);
    border-radius: 0.65rem;
    padding: 0.7rem 1rem;
    font-size: 0.88rem;
    margin-bottom: 1rem;
  }

  .pagination {
    display: flex;
    align-items: center;
    gap: 1rem;
    justify-content: center;
    margin-top: 1.5rem;
  }

  .page-btn {
    padding: 0.5rem 1rem;
    border-radius: 0.5rem;
    border: 1.5px solid var(--lp-rule-2);
    color: var(--lp-ink);
    text-decoration: none;
    font-size: 0.88rem;
    font-weight: 600;
    transition: border-color 150ms;
  }

  .page-btn:hover { border-color: var(--lp-ink); }
  .page-info { color: var(--lp-muted); font-size: 0.85rem; }

  /* Modal */
  .modal-backdrop {
    position: fixed;
    inset: 0;
    background: oklch(0.1 0 0 / 0.45);
    backdrop-filter: blur(3px);
    z-index: 200;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 1rem;
  }

  .modal {
    background: var(--lp-paper);
    border-radius: 1rem;
    width: 100%;
    max-width: 28rem;
    padding: 1.75rem;
    box-shadow: 0 20px 60px oklch(0.1 0 0 / 0.25);
    max-height: 90dvh;
    overflow-y: auto;
  }

  .modal-head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.25rem;
  }

  .modal-head h2 {
    font-size: 1.1rem;
    font-weight: 700;
    margin: 0;
  }

  .modal-close {
    background: none;
    border: none;
    cursor: pointer;
    font-size: 1.1rem;
    color: var(--lp-muted);
    padding: 0.2rem;
    line-height: 1;
  }

  .detail-grid {
    display: grid;
    gap: 0.6rem;
    margin-bottom: 1.25rem;
    padding-bottom: 1.25rem;
    border-bottom: 1px solid var(--lp-rule);
  }

  .detail-row {
    display: grid;
    grid-template-columns: 7rem 1fr;
    gap: 0.5rem;
    font-size: 0.88rem;
  }

  .detail-label {
    color: var(--lp-muted);
    font-weight: 600;
    font-size: 0.8rem;
    padding-top: 0.1rem;
  }

  .detail-val { color: var(--lp-ink); word-break: break-word; }

  .modal-form { display: grid; gap: 0.85rem; }
  .field-label { font-size: 0.82rem; font-weight: 600; color: var(--lp-muted); display: block; margin-bottom: 0.25rem; }
  .field-hint { font-size: 0.75rem; color: var(--lp-muted); display: block; margin-top: 0.25rem; }

  .prov-info {
    font-size: 0.88rem;
    color: var(--lp-ink-2);
    margin-bottom: 1.25rem;
    padding: 0.75rem 1rem;
    background: var(--lp-paper-2);
    border-radius: 0.6rem;
  }
  .prov-info p { margin: 0 0 0.4rem; }
  .prov-info p:last-child { margin: 0; }

  .modal-select,
  .modal-input,
  .modal-textarea {
    width: 100%;
    padding: 0.65rem 0.9rem;
    border-radius: 0.6rem;
    border: 1.5px solid var(--lp-rule-2);
    background: var(--lp-paper);
    color: var(--lp-ink);
    font-size: 0.9rem;
    font-family: inherit;
    box-sizing: border-box;
  }

  .modal-textarea { resize: vertical; min-height: 4rem; }

  .modal-actions {
    display: flex;
    gap: 0.75rem;
    justify-content: flex-end;
    margin-top: 1rem;
  }
</style>
