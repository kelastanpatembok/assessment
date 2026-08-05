<script lang="ts">
  /* Warm shared chrome for the free-test flow. */
  import SiteHeader from '$lib/components/site/SiteHeader.svelte';
  import SiteFooter from '$lib/components/site/SiteFooter.svelte';

  let { children } = $props();
</script>

<svelte:head>
  <title>Tes Gratis — Asesmen</title>
  <meta
    name="description"
    content="Ikuti tes kepribadian singkat secara gratis — kenali potensi dirimu dalam 3 menit."
  />
</svelte:head>

<div class="free">
  <SiteHeader />
  <main class="free-body">
    {@render children()}
  </main>
  <SiteFooter />
</div>

<style>
  .free {
    background: var(--lp-paper);
    color: var(--lp-ink);
    font-family: Figtree, ui-sans-serif, system-ui, sans-serif;
    font-size: 1rem;
    line-height: 1.6;
    min-height: 100dvh;
    display: flex;
    flex-direction: column;
    -webkit-font-smoothing: antialiased;
  }

  .free-body {
    flex: 1;
    width: 100%;
  }

  .free :global(a):focus-visible,
  .free :global(button):focus-visible {
    outline: 2px solid var(--lp-focus);
    outline-offset: 3px;
  }
</style>
