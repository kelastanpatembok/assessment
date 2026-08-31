<script lang="ts">
  import { enhance } from '$app/forms';
  import { HugeiconsIcon } from '@hugeicons/svelte';
  import { ViewIcon, ViewOffIcon } from '@hugeicons/core-free-icons';
  import SiteHeader from '$lib/components/site/SiteHeader.svelte';
  import SiteFooter from '$lib/components/site/SiteFooter.svelte';

  let { form } = $props();

  let showPassword = $state(false);
  let username = $state('');
  let password = $state('');
  let loading = $state(false);

  const canSubmit = $derived(username.trim() !== '' && password.length >= 6);

  let error = $state('');
  $effect(() => {
    error = form?.error ?? '';
  });
</script>

<svelte:head>
  <title>Masuk — Asesmen</title>
</svelte:head>

<div class="signin">
  <SiteHeader />

  <main class="signin-main">
    <div class="signin-card">
      <p class="signin-kicker">Akun pengguna</p>
      <h1>Selamat datang kembali.</h1>
      <p class="signin-lede">
        Masuk untuk mengakses tes dan hasil asesmenmu di platform Asesmen.
      </p>

      {#if error}
        <p class="signin-fail">{error}</p>
      {/if}

      {#if form?.lockedOut}
        <p class="signin-lockout">
          Kehilangan akses ke perangkat lama?
          <a href="/login-link">Kirimkan tautan masuk ke email saya</a> untuk memindahkan sesi ke
          perangkat ini.
        </p>
      {/if}

      <form
        method="POST"
        class="signin-form"
        use:enhance={() => {
          loading = true;
          return async ({ update }) => {
            loading = false;
            await update();
          };
        }}
      >
        <input
          type="text"
          name="username"
          placeholder="Email atau username"
          autocomplete="username"
          inputmode="email"
          aria-label="Email atau username"
          bind:value={username}
          required
        />
        <div class="signin-password">
          <input
            type={showPassword ? 'text' : 'password'}
            name="password"
            placeholder="Kata Sandi"
            autocomplete="current-password"
            aria-label="Kata Sandi"
            bind:value={password}
            required
          />
          <button
            type="button"
            class="signin-eye"
            onclick={() => (showPassword = !showPassword)}
            aria-label={showPassword ? 'Sembunyikan kata sandi' : 'Tampilkan kata sandi'}
            tabindex="-1"
          >
            <HugeiconsIcon icon={showPassword ? ViewOffIcon : ViewIcon} size={18} />
          </button>
        </div>

        <button type="submit" class="signin-cta" disabled={!canSubmit || loading}>
          {loading ? 'Memproses…' : 'Masuk'}
        </button>
      </form>

      <p class="signin-recovery"><a href="/forgot-password">Lupa kata sandi?</a></p>

      <p class="signin-alt">
        Belum punya akun? <a href="/signup">Daftar</a>
      </p>
    </div>
  </main>

  <SiteFooter />
</div>

<style>
  .signin {
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

  .signin-main {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: clamp(2rem, 6vw, 3.5rem) clamp(1.25rem, 4vw, 2rem) 3rem;
  }

  .signin-card {
    max-width: 26rem;
    width: 100%;
  }

  .signin-kicker {
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-accent-deep);
    margin: 0 0 0.75rem;
  }

  .signin-card h1 {
    font-family: var(--lp-font-display);
    font-size: clamp(1.9rem, 6vw, 2.4rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1.12;
    margin: 0 0 0.75rem;
    overflow-wrap: anywhere;
  }

  .signin-lede {
    color: var(--lp-ink-2);
    margin: 0 0 1.75rem;
  }

  .signin-form {
    display: grid;
    gap: 0.85rem;
  }

  .signin-form > input,
  .signin-password input {
    width: 100%;
    min-height: 3.25rem;
    padding: 0.7rem 1rem;
    border-radius: 0.75rem;
    border: 1px solid var(--lp-rule-2);
    background: var(--lp-paper);
    font-size: 1rem;
    color: var(--lp-ink);
  }

  .signin-form > input:focus-visible,
  .signin-password input:focus-visible {
    outline: 2px solid var(--lp-focus);
    outline-offset: 2px;
  }

  .signin-form ::placeholder {
    color: var(--lp-muted);
  }

  .signin-password {
    position: relative;
  }

  .signin-password input {
    padding-inline-end: 3rem;
  }

  .signin-eye {
    position: absolute;
    inset-inline-end: 0.5rem;
    top: 50%;
    transform: translateY(-50%);
    display: flex;
    align-items: center;
    justify-content: center;
    width: 2.5rem;
    height: 2.5rem;
    border: 0;
    background: transparent;
    color: var(--lp-muted);
    cursor: pointer;
    transition: color 150ms var(--lp-ease-out);
  }

  .signin-eye:hover {
    color: var(--lp-ink);
  }

  .signin-cta {
    min-height: 3.25rem;
    padding: 0.8rem 1.5rem;
    border-radius: 999px;
    background: var(--lp-accent-bg);
    color: var(--lp-ink);
    border: 1px solid var(--lp-accent-bg);
    font-weight: 650;
    cursor: pointer;
    white-space: nowrap;
    transition: background-color 200ms var(--lp-ease-out), transform 200ms var(--lp-ease-out);
  }

  .signin-cta:hover:not(:disabled) {
    background: var(--lp-accent);
    transform: translateY(-1px);
  }

  .signin-cta:disabled {
    opacity: 0.45;
    cursor: not-allowed;
  }

  .signin-fail {
    color: oklch(0.55 0.18 25);
    background: oklch(0.96 0.03 25);
    border: 1px solid oklch(0.85 0.06 25);
    border-radius: 0.75rem;
    padding: 0.8rem 1rem;
    font-size: 0.9rem;
    margin: 0 0 1.25rem;
  }

  .signin-lockout {
    color: var(--lp-ink-2);
    background: var(--lp-paper);
    border: 1px solid var(--lp-accent-bg);
    border-radius: 0.75rem;
    padding: 0.8rem 1rem;
    font-size: 0.9rem;
    margin: 0 0 1.25rem;
  }

  .signin-lockout a {
    color: var(--lp-accent-deep);
    font-weight: 600;
    text-decoration: underline;
  }

  .signin-alt {
    text-align: center;
    margin: 1.25rem 0 0;
    font-size: 0.9rem;
    color: var(--lp-ink-2);
  }

  .signin-alt a {
    color: var(--lp-accent-deep);
    font-weight: 600;
    text-decoration: underline;
  }

  .signin :global(a):focus-visible,
  .signin :global(button):focus-visible,
  .signin :global(input):focus-visible {
    outline: 2px solid var(--lp-focus);
    outline-offset: 3px;
  }
</style>
