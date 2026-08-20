<script lang="ts">
  import { enhance } from '$app/forms';
  import { createApiClient } from '$lib/api/index';
  import { downloadBlob } from '$lib/utils';

  let { data, form } = $props();
  let sending = $state(false);
  let downloading = $state<number | null>(null);

  const statusLabel: Record<string, string> = {
    preparing: 'Menyiapkan', queued: 'Dalam antrean', sending: 'Mengirim', sent: 'Terkirim',
    delivered: 'Diterima', failed: 'Gagal', bounced: 'Terpental', suppressed: 'Diblokir'
  };

  function date(value: string | null) {
    if (!value) return '-';
    return new Date(value).toLocaleString('id-ID');
  }

  async function downloadReport(item: any) {
    downloading = item.id;
    try {
      const api = createApiClient(data.token);
      const blob = await api.getBlob(`/assessment-reports/${item.id}/download`);
      downloadBlob(blob, item.pdfFilename);
    } finally {
      downloading = null;
    }
  }
</script>

<svelte:head><title>Laporan Sekolah — Asesmen</title></svelte:head>

<div class="space-y-8">
  <div>
    <h2 class="text-2xl font-bold">Laporan Hasil untuk Sekolah</h2>
    <p class="text-muted-foreground mt-2 max-w-3xl text-sm">Tinjau penerima dan kelengkapan hasil sebelum membuat PDF berpassword dan mengirimkannya ke email resmi sekolah.</p>
  </div>

  {#if form?.error}<div class="bg-destructive/10 text-destructive rounded-xl px-4 py-3 text-sm">{form.error}</div>{/if}
  {#if form?.success}<div class="rounded-xl bg-green-50 px-4 py-3 text-sm text-green-800">Laporan masuk antrean email. Status pengiriman tersedia pada riwayat di bawah.</div>{/if}

  <section class="bg-card border-border rounded-2xl border p-5">
    <h3 class="text-lg font-semibold">Pilih paket sekolah</h3>
    <div class="mt-4 grid gap-3 md:grid-cols-2 xl:grid-cols-3">
      {#each data.assignments.items as assignment}
        <a href={`?assignmentId=${assignment.id}`} class="border-border hover:border-primary rounded-xl border p-4 transition-colors">
          <p class="font-semibold">{assignment.schoolName}</p>
          <p class="text-muted-foreground mt-1 text-sm">{assignment.categoryName}</p>
          <p class="text-muted-foreground mt-2 text-xs">{(assignment.tests ?? []).map((test: string) => test.toUpperCase()).join(' · ')}</p>
        </a>
      {/each}
    </div>
  </section>

  {#if data.previewError}
    <section class="border-destructive/30 bg-destructive/5 rounded-2xl border p-5"><p class="text-destructive text-sm">{data.previewError}</p></section>
  {:else if data.preview}
    <section class="bg-card border-border rounded-2xl border p-5">
      <div class="flex flex-wrap items-start justify-between gap-4">
        <div>
          <h3 class="text-xl font-semibold">{data.preview.schoolName}</h3>
          <p class="text-muted-foreground text-sm">{data.preview.packageName}</p>
        </div>
        <div class="text-sm">
          <p><strong>To:</strong> {data.preview.officialEmail}</p>
          <p><strong>CC semua PIC:</strong> {data.preview.picRecipients.map((pic: any) => `${pic.name} <${pic.email}>`).join(', ')}</p>
        </div>
      </div>

      <div class="mt-5 grid gap-3 sm:grid-cols-3">
        <div class="bg-muted rounded-xl p-4"><p class="text-muted-foreground text-xs">Siswa</p><p class="mt-1 text-2xl font-bold">{data.preview.studentCount}</p></div>
        <div class="bg-muted rounded-xl p-4"><p class="text-muted-foreground text-xs">Belum lengkap</p><p class="mt-1 text-2xl font-bold">{data.preview.incompleteStudentCount}</p></div>
        <div class="bg-muted rounded-xl p-4"><p class="text-muted-foreground text-xs">Metode paket</p><p class="mt-1 text-2xl font-bold">{data.preview.methods.length}</p></div>
      </div>

      <div class="mt-5 overflow-x-auto">
        <table class="w-full min-w-[720px] border-collapse text-sm">
          <thead><tr class="bg-primary text-primary-foreground"><th class="p-3 text-left">Siswa</th>{#each data.preview.methods as method}<th class="p-3 text-left">{method.label}</th>{/each}</tr></thead>
          <tbody>
            {#each data.preview.students as student, index}
              <tr class={index % 2 === 0 ? 'bg-muted/40' : ''}>
                <td class="border-border border p-3 font-medium">{student.name}</td>
                {#each data.preview.methods as method}
                  {@const result = student.results.find((item: any) => item.key === method.key)}
                  <td class="border-border border p-3"><span class={result?.completed ? '' : 'font-semibold text-amber-700'}>{result?.completed ? result.summary : 'BELUM'}</span></td>
                {/each}
              </tr>
            {/each}
          </tbody>
        </table>
      </div>

      <div class="mt-5 flex flex-wrap items-center justify-between gap-4">
        <p class="text-muted-foreground max-w-2xl text-xs">PDF selalu menyertakan halaman detail untuk setiap siswa. Hasil yang belum selesai ditandai sebagai BELUM, bukan nilai nol.</p>
        <form method="POST" action="?/send" use:enhance={() => { sending = true; return async ({ update }) => { sending = false; await update(); }; }}>
          <input type="hidden" name="assignmentId" value={data.preview.assignmentId} />
          <button type="submit" disabled={sending} class="bg-primary text-primary-foreground hover:bg-primary/90 disabled:opacity-50 h-11 rounded-xl px-5 text-sm font-semibold">
            {sending ? 'Menyiapkan dan mengirim…' : 'Kirim laporan berpassword'}
          </button>
        </form>
      </div>
    </section>
  {/if}

  <section class="bg-card border-border rounded-2xl border p-5">
    <div class="flex flex-wrap items-end justify-between gap-4">
      <div><h3 class="text-lg font-semibold">Riwayat Email Laporan</h3><p class="text-muted-foreground text-sm">Status, penerima, jumlah siswa, dan PDF yang pernah dikirim.</p></div>
      <form method="GET" class="flex gap-2">
        <input type="search" name="historySearch" value={data.historySearch} placeholder="Cari sekolah, email, nomor…" class="border-input bg-background h-10 rounded-lg border px-3 text-sm" />
        <button class="border-input bg-background hover:bg-accent h-10 rounded-lg border px-4 text-sm" type="submit">Cari</button>
      </form>
    </div>
    <div class="mt-4 overflow-x-auto">
      <table class="w-full min-w-[850px] border-collapse text-sm">
        <thead><tr class="border-border border-b"><th class="p-3 text-left">Dibuat</th><th class="p-3 text-left">Sekolah / laporan</th><th class="p-3 text-left">Penerima</th><th class="p-3 text-left">Siswa</th><th class="p-3 text-left">Status</th><th class="p-3 text-left">PDF</th></tr></thead>
        <tbody>
          {#each data.history.items as item}
            <tr class="border-border border-b align-top">
              <td class="p-3 text-xs">{date(item.createdAt)}</td>
              <td class="p-3"><p class="font-medium">{item.schoolName}</p><p class="text-muted-foreground text-xs">{item.reportNo}</p></td>
              <td class="p-3 text-xs"><p>{item.officialEmail}</p><p class="text-muted-foreground">CC: {item.picEmails.join(', ')}</p></td>
              <td class="p-3">{item.studentCount}<span class="text-muted-foreground text-xs"> ({item.incompleteStudentCount} belum lengkap)</span></td>
              <td class="p-3"><span class="bg-muted rounded-full px-2.5 py-1 text-xs font-medium">{statusLabel[item.status] ?? item.status}</span>{#if item.error}<p class="text-destructive mt-1 max-w-xs text-xs">{item.error}</p>{/if}</td>
              <td class="p-3"><button type="button" onclick={() => downloadReport(item)} disabled={downloading === item.id} class="text-primary text-xs font-semibold hover:underline">{downloading === item.id ? 'Mengunduh…' : 'Unduh'}</button></td>
            </tr>
          {/each}
        </tbody>
      </table>
      {#if data.history.items.length === 0}<p class="text-muted-foreground py-8 text-center text-sm">Belum ada riwayat laporan.</p>{/if}
    </div>
  </section>
</div>
