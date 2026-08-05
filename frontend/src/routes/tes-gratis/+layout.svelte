<script lang="ts">
  /* Hallmark · genre: editorial-warm · macrostructure: single-column funnel
   * theme: warm (paper · terracotta · ink) · shared tokens for the free-test flow */
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
  <header class="free-head">
    <div class="free-head-inner">
      <a href="/" class="free-brand">
        <span class="free-mark" aria-hidden="true"></span>
        <span class="free-name">Asesmen</span>
      </a>
      <a href="/login" class="free-login">Masuk</a>
    </div>
  </header>
  <main class="free-body">
    {@render children()}
  </main>
  <footer class="free-foot">
    <p>Tes ini bersifat eksplorasi diri dan bukan diagnosis klinis.</p>
  </footer>
</div>

<style>
  .free {
    --lp-paper: oklch(0.972 0.012 75);
    --lp-paper-2: oklch(0.95 0.02 75);
    --lp-ink: oklch(0.24 0.025 55);
    --lp-ink-2: oklch(0.4 0.02 55);
    --lp-muted: oklch(0.43 0.02 55);
    --lp-rule: oklch(0.88 0.02 75);
    --lp-rule-2: oklch(0.79 0.025 75);
    --lp-accent: oklch(0.6 0.14 42);
    --lp-accent-deep: oklch(0.42 0.12 38);
    --lp-accent-bg: oklch(0.7 0.12 45);
    --lp-focus: oklch(0.55 0.15 40);
    --lp-font-display: 'Fraunces Variable', Georgia, serif;
    --lp-ease-out: cubic-bezier(0.16, 1, 0.3, 1);

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

  .free-head {
    border-bottom: 1px solid var(--lp-rule);
  }

  .free-head-inner {
    max-width: 48rem;
    margin-inline: auto;
    padding: 0.9rem clamp(1.25rem, 4vw, 2rem);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
  }

  .free-brand {
    display: inline-flex;
    align-items: center;
    gap: 0.55rem;
    white-space: nowrap;
  }

  .free-mark {
    width: 0.65rem;
    height: 0.65rem;
    background: var(--lp-accent);
    flex: none;
  }

  .free-name {
    font-family: var(--lp-font-display);
    font-size: 1.3rem;
    font-weight: 620;
    letter-spacing: -0.02em;
    line-height: 1;
  }

  .free-login {
    font-size: 0.78rem;
    font-weight: 600;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-accent-deep);
    padding: 0.6rem 0;
    background-image: linear-gradient(var(--lp-accent-deep), var(--lp-accent-deep));
    background-size: 0 1px;
    background-repeat: no-repeat;
    background-position: 50% 100%;
    transition: background-size 200ms var(--lp-ease-out);
    white-space: nowrap;
  }

  .free-login:hover {
    background-size: 100% 1px;
  }

  .free-body {
    flex: 1;
    width: 100%;
  }

  .free-foot {
    text-align: center;
    padding: 1.25rem clamp(1.25rem, 4vw, 2rem) 1.5rem;
    color: var(--lp-muted);
    font-size: 0.8rem;
  }

  .free :global(a):focus-visible,
  .free :global(button):focus-visible {
    outline: 2px solid var(--lp-focus);
    outline-offset: 3px;
  }
</style>
