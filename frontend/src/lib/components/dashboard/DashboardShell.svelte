<script lang="ts">
  import { page } from '$app/stores';
  import SiteHeader from '$lib/components/site/SiteHeader.svelte';
  import SiteFooter from '$lib/components/site/SiteFooter.svelte';

  let { roleLabel, navLinks, user, profile, children } = $props<{
    roleLabel: string;
    navLinks: { href: string; label: string }[];
    user?: { userId: string; username: string; role: string } | null;
    profile?: { name: string; avatarUrl: string | null } | null;
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
  <SiteHeader {user} {profile} />

  <div class="dash-body">
    <aside class="dash-side">
      <p class="dash-role">{roleLabel}</p>
      <nav class="dash-nav" aria-label="Navigasi panel">
        {#each navLinks as link}
          <a href={link.href} class="dash-link" class:active={isActive(link.href)}>{link.label}</a>
        {/each}
      </nav>
    </aside>

    <main class="dash-content">
      {@render children()}
    </main>
  </div>

  <SiteFooter />
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

    display: flex;
    flex-direction: column;
    min-height: 100dvh;
    background: var(--lp-paper);
    color: var(--lp-ink);
    font-family: Figtree, ui-sans-serif, system-ui, sans-serif;
    font-size: 1rem;
    line-height: 1.6;
    -webkit-font-smoothing: antialiased;
  }

  .dash-body {
    flex: 1;
    display: grid;
    grid-template-columns: 15rem minmax(0, 1fr);
    width: 100%;
  }

  .dash-side {
    background: var(--lp-paper-2);
    border-right: 1px solid var(--lp-rule);
    padding: 1.5rem 1rem;
    display: flex;
    flex-direction: column;
    gap: 1rem;
  }

  .dash-role {
    margin: 0;
    padding: 0 0.85rem;
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.14em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-muted);
  }

  .dash-nav {
    display: flex;
    flex-direction: column;
    gap: 0.35rem;
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

  .dash-content {
    min-width: 0;
    padding: clamp(1.5rem, 3vw, 2.5rem);
  }

  .dash :global(a):focus-visible {
    outline: 2px solid var(--lp-focus);
    outline-offset: 2px;
  }

  @media (max-width: 48rem) {
    .dash-body {
      grid-template-columns: minmax(0, 1fr);
    }

    .dash-side {
      border-right: 0;
      border-bottom: 1px solid var(--lp-rule);
      padding: 1rem 1rem 0.75rem;
      gap: 0.6rem;
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
  }
</style>
