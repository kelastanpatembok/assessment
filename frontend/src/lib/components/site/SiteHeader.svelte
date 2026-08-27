<script lang="ts">
  import UserMenu from './UserMenu.svelte';

  let { user, profile } = $props<{
    user?: { userId: string; username: string; role: string } | null;
    profile?: { name: string; avatarUrl: string | null } | null;
  }>();
</script>

<header class="site-head">
  <div class="site-head-inner">
    <a href="/" class="brand" aria-label="Beranda Asesmen">
      <span class="brand-mark" aria-hidden="true"></span>
      <span class="brand-name">Asesmen</span>
    </a>
    <nav class="site-nav" aria-label="Navigasi utama">
      <a href="/#layanan">Layanan</a>
      <a href="/#instrumen">Instrumen</a>
      <a href="/peta">Peta</a>
      <a href="/#alur">Alur</a>
      <a href="/#faq">FAQ</a>
    </nav>
    <UserMenu {user} {profile}>
      <a href="/signin" class="btn btn-primary btn-sm">Masuk</a>
    </UserMenu>
  </div>
</header>

<style>
  .site-head {
    position: sticky;
    top: 0;
    z-index: 50;
    background: color-mix(in oklab, var(--lp-paper) 88%, transparent);
    backdrop-filter: blur(10px);
    border-bottom: 1px solid var(--lp-rule);
  }

  .site-head-inner {
    max-width: 64rem;
    margin-inline: auto;
    padding: 0.9rem clamp(1.25rem, 4vw, 2.5rem);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1.5rem;
  }

  .brand {
    display: inline-flex;
    align-items: center;
    gap: 0.6rem;
    white-space: nowrap;
  }

  .brand-mark {
    width: 0.7rem;
    height: 0.7rem;
    background: var(--lp-accent);
    flex: none;
  }

  .brand-name {
    font-family: var(--lp-font-display);
    font-size: 1.35rem;
    font-weight: 620;
    letter-spacing: -0.02em;
    line-height: 1;
  }

  .site-nav {
    display: flex;
    align-items: center;
    gap: clamp(1rem, 2.5vw, 2rem);
  }

  .site-nav a {
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.12em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-ink-2);
    padding-block: 0.75rem;
    background-image: linear-gradient(var(--lp-accent-deep), var(--lp-accent-deep));
    background-size: 0 1px;
    background-repeat: no-repeat;
    background-position: 50% 100%;
    transition: color 150ms var(--lp-ease-out), background-size 200ms var(--lp-ease-out);
    white-space: nowrap;
  }

  .site-nav a:hover {
    color: var(--lp-ink);
    background-size: 100% 1px;
  }

  .btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    min-height: 3rem;
    padding: 0.7rem 1.6rem;
    border-radius: 0.625rem;
    font-weight: 600;
    letter-spacing: 0.01em;
    cursor: pointer;
    white-space: nowrap;
    transition: background-color 200ms var(--lp-ease-out), color 200ms var(--lp-ease-out),
      transform 200ms var(--lp-ease-out), border-color 200ms var(--lp-ease-out);
  }

  .btn-sm {
    min-height: 2.5rem;
    padding: 0.45rem 1.15rem;
    font-size: 0.9rem;
  }

  .btn-primary {
    background: var(--lp-accent-bg);
    color: var(--lp-ink);
    border: 1px solid var(--lp-accent-bg);
  }

  .btn-primary:hover {
    background: var(--lp-accent);
    border-color: var(--lp-accent);
    transform: translateY(-1px);
  }

  .btn-primary:active {
    transform: translateY(0);
  }

  @media (pointer: coarse) {
    .site-nav a {
      padding-block: 1rem;
    }
  }

  @media (max-width: 40rem) {
    .site-nav {
      display: none;
    }
  }
</style>
