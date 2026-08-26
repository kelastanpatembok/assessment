<script lang="ts">
  import type { Snippet } from 'svelte';

  let { user, profile, children } = $props<{
    user?: { userId: string; username: string; role: string } | null;
    profile?: { name: string; avatarUrl: string | null } | null;
    children?: Snippet;
  }>();

  let open = $state(false);

  const name = $derived(String(profile?.name?.trim() || user?.username || ''));
  const avatar = $derived(profile?.avatarUrl || null);
  const initial = $derived(name ? name.charAt(0).toUpperCase() : '?');

  const dash = $derived(
    (() => {
      switch (user?.role?.toLowerCase()) {
        case 'superadmin':
          return '/admin-dashboard';
        case 'gurubk':
          return '/counselor-dashboard';
        case 'afiliator':
          return '/afiliator-dashboard';
        case 'psikolog':
          return '/psikolog-dashboard';
        case 'siswa':
          return '/student-dashboard';
        case 'pic':
          return '/profil';
        default:
          return null;
      }
    })()
  );
</script>

{#if user}
  <div class="um">
    <button
      type="button"
      class="um-btn"
      onclick={() => (open = !open)}
      aria-haspopup="menu"
      aria-expanded={open}
      aria-label="Menu akun"
    >
      {#if avatar}
        <img class="um-avatar" src={avatar} alt="" />
      {:else}
        <span class="um-avatar um-fallback">{initial}</span>
      {/if}
      <span class="um-name">{name}</span>
      <svg class="um-caret" width="10" height="6" viewBox="0 0 10 6" aria-hidden="true">
        <path d="M1 1l4 4 4-4" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" />
      </svg>
    </button>

    {#if open}
      <button type="button" class="um-backdrop" aria-hidden="true" tabindex="-1" onclick={() => (open = false)}></button>
      <div class="um-menu" role="menu">
        <p class="um-menu-head">{user.username}</p>
        <a href="/profil" role="menuitem" onclick={() => (open = false)}>Profil &amp; Pengaturan</a>
        {#if dash}
          <a href={dash} role="menuitem" onclick={() => (open = false)}>Panel Saya</a>
        {/if}
        <a href="/logout" class="um-menu-logout" role="menuitem" onclick={() => (open = false)}>Keluar</a>
      </div>
    {/if}
  </div>
{:else}
  {@render children()}
{/if}

<style>
  .um {
    position: relative;
  }

  .um-btn {
    display: inline-flex;
    align-items: center;
    gap: 0.55rem;
    min-height: 2.75rem;
    padding: 0.3rem 0.4rem 0.3rem 0.3rem;
    border: 1px solid var(--lp-rule);
    border-radius: 999px;
    background: var(--lp-paper);
    cursor: pointer;
    transition: border-color 200ms var(--lp-ease-out), background-color 200ms var(--lp-ease-out);
    white-space: nowrap;
  }

  .um-btn:hover {
    border-color: var(--lp-rule-2);
    background: var(--lp-paper-2);
  }

  .um-btn:focus-visible {
    outline: 2px solid var(--lp-focus);
    outline-offset: 2px;
  }

  .um-avatar {
    width: 2rem;
    height: 2rem;
    border-radius: 999px;
    object-fit: cover;
    flex: none;
    background: var(--lp-accent-bg);
  }

  .um-fallback {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    font-size: 0.9rem;
    color: var(--lp-ink);
  }

  .um-name {
    font-weight: 650;
    font-size: 0.92rem;
    max-width: 12ch;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .um-caret {
    color: var(--lp-muted);
    flex: none;
  }

  .um-backdrop {
    position: fixed;
    inset: 0;
    z-index: 60;
    border: 0;
    background: transparent;
    cursor: default;
  }

  .um-menu {
    position: absolute;
    right: 0;
    top: calc(100% + 0.5rem);
    z-index: 61;
    min-width: 13rem;
    padding: 0.4rem;
    border: 1px solid var(--lp-rule-2);
    border-radius: 0.9rem;
    background: var(--lp-paper);
    box-shadow: 0 8px 28px oklch(0.3 0.03 40 / 0.14);
    display: grid;
  }

  .um-menu-head {
    margin: 0;
    padding: 0.4rem 0.7rem 0.6rem;
    font-size: 0.78rem;
    color: var(--lp-muted);
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .um-menu a {
    padding: 0.6rem 0.7rem;
    border-radius: 0.55rem;
    font-weight: 600;
    font-size: 0.92rem;
    color: var(--lp-ink);
    white-space: nowrap;
  }

  .um-menu a:hover {
    background: var(--lp-paper-2);
  }

  .um-menu a:focus-visible {
    outline: 2px solid var(--lp-focus);
    outline-offset: -1px;
  }

  .um-menu-logout {
    color: oklch(0.55 0.18 25) !important;
  }
</style>
