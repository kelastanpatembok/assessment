<script lang="ts">
  import { setContext } from 'svelte';
  import { beforeNavigate, goto } from '$app/navigation';
  import { Button } from '$lib/components/ui/button/index.js';
  import * as AlertDialog from '$lib/components/ui/alert-dialog/index.js';

  let { children } = $props();

  // Armed by default: any attempt to leave (browser back, typing a URL,
  // closing the tab) is confirmed first. Pages disarm this once their
  // submit action redirects, so the post-submit navigation to the result
  // page doesn't itself trigger the same confirmation.
  let guardArmed = $state(true);

  setContext('exam-guard', {
    disarm: () => {
      guardArmed = false;
    },
  });

  // SvelteKit can't pause an in-flight navigation for an async dialog, so we
  // always cancel first, then — if the student confirms — replay it
  // manually via goto(). Also doubles as the target for the explicit
  // "Keluar dari Tes" button.
  let showLeaveDialog = $state(false);
  let pendingUrl = $state<string | null>(null);

  beforeNavigate((nav) => {
    if (!guardArmed || showLeaveDialog) return;
    nav.cancel();
    pendingUrl = nav.to?.url.href ?? null;
    showLeaveDialog = true;
  });

  function handleBeforeUnload(e: BeforeUnloadEvent) {
    if (!guardArmed) return;
    e.preventDefault();
    e.returnValue = '';
  }

  function requestExit() {
    pendingUrl = '/student-dashboard';
    showLeaveDialog = true;
  }

  function confirmLeave() {
    guardArmed = false;
    if (pendingUrl) goto(pendingUrl);
    pendingUrl = null;
  }
</script>

<svelte:window onbeforeunload={handleBeforeUnload} />

<div class="bg-background min-h-screen">
  <header class="border-border bg-card border-b px-6 py-4">
    <div class="mx-auto flex max-w-2xl items-center justify-between">
      <div class="flex items-center gap-2">
        <div
          class="bg-primary text-primary-foreground flex size-8 items-center justify-center rounded-lg text-sm font-bold"
        >
          A
        </div>
        <span class="font-semibold">Assessment</span>
      </div>
      <Button variant="ghost" size="sm" onclick={requestExit}>Keluar dari Tes</Button>
    </div>
  </header>
  <main class="mx-auto max-w-2xl p-6">
    {@render children()}
  </main>
</div>

<AlertDialog.Root bind:open={showLeaveDialog}>
  <AlertDialog.Content>
    <AlertDialog.Header>
      <AlertDialog.Title>Yakin ingin keluar dari tes?</AlertDialog.Title>
      <AlertDialog.Description>
        Jawaban yang belum dikirim akan hilang.
      </AlertDialog.Description>
    </AlertDialog.Header>
    <AlertDialog.Footer>
      <AlertDialog.Cancel>Batal</AlertDialog.Cancel>
      <AlertDialog.Action onclick={confirmLeave}>Keluar</AlertDialog.Action>
    </AlertDialog.Footer>
  </AlertDialog.Content>
</AlertDialog.Root>
