<script lang="ts">
  import { Card, CardContent, CardHeader, CardTitle } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';

  let { data } = $props();
  let activeTab = $state('disc');
  $effect(() => { if (data.tab) activeTab = data.tab; });

  const tabs = [
    { key: 'disc', label: 'DISC' },
    { key: 'holland', label: 'Holland' },
    { key: 'papi', label: 'PAPI Kostick' },
    { key: 'cfit', label: 'IQ CFIT' },
    { key: 'ist', label: 'IQ IST' },
  ];

  let currentResults = $derived(
    activeTab === 'disc' ? data.disc :
    activeTab === 'holland' ? data.holland :
    activeTab === 'papi' ? data.papi :
    activeTab === 'cfit' ? data.cfit :
    data.ist
  );
</script>

<svelte:head><title>Hasil Tes</title></svelte:head>

<div class="flex flex-col gap-6">
  <h2 class="text-2xl font-bold">Hasil Tes</h2>

  <div class="flex gap-2 flex-wrap">
    {#each tabs as t}
      <Button
        variant={activeTab === t.key ? 'default' : 'outline'}
        size="sm"
        onclick={() => (activeTab = t.key)}
      >{t.label}</Button>
    {/each}
  </div>

  <Card>
    <CardHeader><CardTitle>{tabs.find(t => t.key === activeTab)?.label}</CardTitle></CardHeader>
    <CardContent>
      <table class="w-full text-sm">
        <thead>
          <tr class="border-border border-b text-left">
            <th class="pb-3 font-medium">Nama Siswa</th>
            <th class="pb-3 font-medium">Sekolah</th>
            <th class="pb-3 font-medium">Tanggal</th>
            <th class="pb-3 font-medium">Hasil</th>
          </tr>
        </thead>
        <tbody>
          {#each currentResults as r}
            <tr class="border-border border-b last:border-0">
              <td class="py-3 font-medium">{r.studentName}</td>
              <td class="text-muted-foreground py-3">{r.schoolName ?? '-'}</td>
              <td class="text-muted-foreground py-3">{r.createdAt ? new Date(r.createdAt).toLocaleDateString('id-ID') : '-'}</td>
              <td class="py-3">
                {#if activeTab === 'disc'}
                  D:{r.dMost ?? 0} I:{r.iMost ?? 0} S:{r.sMost ?? 0} C:{r.cMost ?? 0}
                {:else if activeTab === 'holland'}
                  R:{r.totalR ?? 0} I:{r.totalI ?? 0} A:{r.totalA ?? 0}
                {:else if activeTab === 'cfit'}
                  RS: {r.rawScore ?? '-'}
                {:else if activeTab === 'ist'}
                  IQ: {r.iqScore ?? '-'}
                {:else}
                  Selesai
                {/if}
              </td>
            </tr>
          {:else}
            <tr><td colspan="4" class="text-muted-foreground py-6 text-center">Belum ada hasil</td></tr>
          {/each}
        </tbody>
      </table>
    </CardContent>
  </Card>
</div>
