<script lang="ts">
  import { setContext } from 'svelte';
  import { beforeNavigate, goto } from '$app/navigation';
  import { Button } from '$lib/components/ui/button/index.js';

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

  beforeNavigate((nav) => {
    if (!guardArmed) return;
    const ok = confirm('Jawaban Anda belum dikirim. Yakin ingin keluar dari tes?');
    if (!ok) nav.cancel();
  });

  function handleBeforeUnload(e: BeforeUnloadEvent) {
    if (!guardArmed) return;
    e.preventDefault();
    e.returnValue = '';
  }

  function exit() {
    if (!confirm('Yakin ingin keluar dari tes? Jawaban yang belum dikirim akan hilang.')) return;
    guardArmed = false;
    goto('/student-dashboard');
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
      <Button variant="ghost" size="sm" onclick={exit}>Keluar dari Tes</Button>
    </div>
  </header>
  <main class="mx-auto max-w-2xl p-6">
    {@render children()}
  </main>
</div>
