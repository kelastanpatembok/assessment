<script lang="ts">
  import { page } from '$app/stores';

  let { title, roleLabel, navLinks, user, children } = $props<{
    title: string;
    roleLabel: string;
    navLinks: { href: string; label: string }[];
    user?: { username?: string } | null;
    children?: import('svelte').Snippet;
  }>();

  const pathname = $page.url.pathname;
  const dashHref = $derived(navLinks[0]?.href);

  function isActive(href: string): boolean {
    if (href === pathname) return true;
    if (href !== dashHref && pathname.startsWith(href + '/')) return true;
    return false;
  }
</script>

<div class="dash">
  <aside class="dash-side">
    <div class="dash-side-top">
      <a href="/" class="dash-brand" aria-label="Beranda Asesmen">
        <span class="dash-mark" aria-hidden="true"></span>
        <span class="dash-name">Asesmen</span>
      </a>
      <p class="dash-role">{roleLabel}</p>
    </div>

    <nav class="dash-nav" aria-label="Navigasi panel">
      {#each navLinks as link}
        <a href={link.href} class="dash-link" class:active={isActive(link.href)}>{link.label}</a>
      {/each}
    </nav>

    <div class="dash-foot">
      <p class="dash-username" title={user?.username}>{user?.username}</p>
      <a href="/logout" class="dash-logout">Keluar</a>
    </div>
  </aside>

  <div class="dash-main">
    <header class="dash-top">
      <h1 class="dash-title">{title}</h1>
      <span class="dash-top-user">{user?.username}</span>
    </header>
    <main class="dash-content">
      {@render children()}
    </main>
  </div>
</div>

<style>
  .dash {
    --lp-paper: oklch(0.972 0.012 75);
    --lp-paper-2: oklch(0.945 0.02 75);
    --lp-ink: oklch(0.24 0.025 55);
    --lp-ink-2: oklch(0.4 0.02 55);
    --lp-muted: oklch(0.43 0.02 55);
    --lp-rule: oklch(0.88 0.02 75);
    --lp-rule-2: oklch(0.79 0.025 75);
    --lp-accent: oklch(0.6 0.14 42);
    --lp-accent-deep: oklch(0.42 0.12 38);
    --lp-accent-bg: oklch(0.7 0.12 45);
    --lp-focus: oklch(0.55 0.15 40);
    --lp-tint-amber: oklch(0.965 0.035 78);
    --lp-tint-sage: oklch(0.958 0.028 145);
    --lp-tint-clay: oklch(0.962 0.03 55);
    --lp-tint-cold: oklch(0.96 0.018 220);
    --lp-tint-grey: oklch(0.952 0.014 70);
    --lp-font-display: 'Fraunces Variable', Georgia, serif;
    --lp-ease-out: cubic-bezier(0.16, 1, 0.3, 1);

    display: grid;
    grid-template-columns: 16rem minmax(0, 1fr);
    min-height: 100dvh;
    background: var(--lp-paper);
    color: var(--lp-ink);
    font-family: Figtree, ui-sans-serif, system-ui, sans-serif;
    font-size: 1rem;
    line-height: 1.6;
    -webkit-font-smoothing: antialiased;
  }

  .dash-side {
    display: flex;
    flex-direction: column;
    background: var(--lp-paper-2);
    border-right: 1px solid var(--lp-rule);
    padding: 1.5rem 1rem 1.25rem;
    position: sticky;
    top: 0;
    height: 100dvh;
  }

  .dash-side-top {
    padding: 0 0.5rem 1.25rem;
  }

  .dash-brand {
    display: inline-flex;
    align-items: center;
    gap: 0.6rem;
    white-space: nowrap;
  }

  .dash-mark {
    width: 0.7rem;
    height: 0.7rem;
    background: var(--lp-accent);
    flex: none;
  }

  .dash-name {
    font-family: var(--lp-font-display);
    font-size: 1.3rem;
    font-weight: 620;
    letter-spacing: -0.02em;
    line-height: 1;
  }

  .dash-role {
    margin: 0.5rem 0 0;
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.14em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-muted);
  }

  .dash-nav {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 0.35rem;
    overflow-y: auto;
  }

  .dash-link {
    display: block;
    padding: 0.6rem 0.85rem;
    border-radius: 0.625rem;
    color: var(--lp-ink-2);
    font-weight: 600;
    font-size: 0.95rem;
    white-space: nowrap;
    transition: background-color 160ms var(--lp-ease-out), color 160ms var(--lp-ease-out);
  }

  .dash-link:hover {
    background: color-mix(in oklab, var(--lp-paper) 60%, transparent);
    color: var(--lp-ink);
  }

  .dash-link.active {
    background: var(--lp-accent-bg);
    color: var(--lp-ink);
    font-weight: 650;
  }

  .dash-foot {
    border-top: 1px solid var(--lp-rule);
    padding: 1rem 0.5rem 0;
    margin-top: 1rem;
  }

  .dash-username {
    margin: 0 0 0.4rem;
    color: var(--lp-muted);
    font-size: 0.8rem;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .dash-logout {
    color: oklch(0.55 0.18 25);
    font-weight: 600;
    font-size: 0.85rem;
    text-decoration: underline;
  }

  .dash-main {
    min-width: 0;
  }

  .dash-top {
    position: sticky;
    top: 0;
    z-index: 40;
    background: color-mix(in oklab, var(--lp-paper) 88%, transparent);
    backdrop-filter: blur(10px);
    border-bottom: 1px solid var(--lp-rule);
    padding: 1rem clamp(1.25rem, 3vw, 2.25rem);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
  }

  .dash-title {
    font-family: var(--lp-font-display);
    font-size: clamp(1.3rem, 2vw + 0.6rem, 1.7rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    margin: 0;
  }

  .dash-top-user {
    color: var(--lp-muted);
    font-size: 0.85rem;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    max-width: 16ch;
  }

  .dash-content {
    padding: clamp(1.5rem, 3vw, 2.5rem);
  }

  .dash :global(a):focus-visible {
    outline: 2px solid var(--lp-focus);
    outline-offset: 2px;
  }

  @media (max-width: 48rem) {
    .dash {
      grid-template-columns: minmax(0, 1fr);
    }

    .dash-side {
      position: static;
      height: auto;
      border-right: 0;
      border-bottom: 1px solid var(--lp-rule);
      padding: 1rem 1rem 0.75rem;
    }

    .dash-nav {
      flex-direction: row;
      flex-wrap: nowrap;
      overflow-x: auto;
      gap: 0.4rem;
      padding-bottom: 0.25rem;
    }

    .dash-link {
      white-space: nowrap;
    }

    .dash-foot {
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 1rem;
      border-top: 0;
      padding: 0.5rem 0 0;
      margin-top: 0.5rem;
    }

    .dash-top-user {
      display: none;
    }
  }
</style>
