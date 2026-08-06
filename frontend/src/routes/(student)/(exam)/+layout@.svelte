<script lang="ts">
  import { setContext } from 'svelte';
  import { beforeNavigate, goto } from '$app/navigation';

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
  let cancelBtn: HTMLButtonElement | undefined = $state();

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

  function closeLeaveDialog() {
    showLeaveDialog = false;
    pendingUrl = null;
  }

  function confirmLeave() {
    guardArmed = false;
    const target = pendingUrl;
    pendingUrl = null;
    showLeaveDialog = false;
    if (target) goto(target);
  }

  function handleKeydown(e: KeyboardEvent) {
    if (e.key === 'Escape' && showLeaveDialog) closeLeaveDialog();
  }

  $effect(() => {
    if (showLeaveDialog) cancelBtn?.focus();
  });
</script>

<svelte:window onbeforeunload={handleBeforeUnload} onkeydown={handleKeydown} />

<div class="exam lp">
  <header class="exam-head">
    <div class="exam-head-inner">
      <a href="/student-dashboard" class="exam-brand" aria-label="Kembali ke Dashboard">
        <span class="exam-mark" aria-hidden="true"></span>
        <span class="exam-name">Asesmen</span>
      </a>
      <button type="button" class="lp-btn lp-btn-ghost lp-btn-sm" onclick={requestExit}>Keluar dari Tes</button>
    </div>
  </header>
  <main class="exam-body">
    {@render children()}
  </main>
</div>

{#if showLeaveDialog}
  <div
    class="lp-modal-backdrop"
    role="presentation"
    onclick={(e) => {
      if (e.target === e.currentTarget) closeLeaveDialog();
    }}
    onkeydown={(e) => {
      if (e.key === 'Escape') closeLeaveDialog();
    }}
  >
    <div
      class="lp-modal"
      role="alertdialog"
      aria-modal="true"
      aria-labelledby="leave-dialog-title"
      aria-describedby="leave-dialog-desc"
    >
      <h2 id="leave-dialog-title" class="lp-display text-2xl">Yakin ingin keluar dari tes?</h2>
      <p id="leave-dialog-desc" class="lp-muted text-sm">Jawaban yang belum dikirim akan hilang.</p>
      <div class="lp-modal-actions">
        <button type="button" class="lp-btn lp-btn-outline" bind:this={cancelBtn} onclick={closeLeaveDialog}>
          Batal
        </button>
        <button type="button" class="lp-btn lp-btn-primary" onclick={confirmLeave}>Keluar</button>
      </div>
    </div>
  </div>
{/if}

<style>
  .exam {
    min-height: 100dvh;
    display: flex;
    flex-direction: column;
    background: var(--lp-paper);
    color: var(--lp-ink);
    font-family: Figtree, ui-sans-serif, system-ui, sans-serif;
    font-size: 1rem;
    line-height: 1.6;
    -webkit-font-smoothing: antialiased;
  }

  .exam-head {
    position: sticky;
    top: 0;
    z-index: 40;
    background: color-mix(in oklab, var(--lp-paper) 88%, transparent);
    backdrop-filter: blur(10px);
    border-bottom: 1px solid var(--lp-rule);
  }

  .exam-head-inner {
    max-width: 44rem;
    margin-inline: auto;
    padding: 0.7rem clamp(1rem, 4vw, 1.5rem);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
  }

  .exam-brand {
    display: inline-flex;
    align-items: center;
    gap: 0.55rem;
    white-space: nowrap;
  }

  .exam-mark {
    width: 0.7rem;
    height: 0.7rem;
    background: var(--lp-accent);
    flex: none;
  }

  .exam-name {
    font-family: var(--lp-font-display);
    font-size: 1.2rem;
    font-weight: 620;
    letter-spacing: -0.02em;
    line-height: 1;
  }

  .exam-body {
    flex: 1;
    width: 100%;
    max-width: 44rem;
    margin-inline: auto;
    padding: clamp(1.25rem, 4vw, 2rem) clamp(1rem, 4vw, 1.5rem) 3rem;
  }
</style>
