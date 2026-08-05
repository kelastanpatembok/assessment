<script lang="ts">
  import { HugeiconsIcon } from '@hugeicons/svelte';
  import { ViewIcon, ViewOffIcon } from '@hugeicons/core-free-icons';
  import SiteHeader from '$lib/components/site/SiteHeader.svelte';
  import SiteFooter from '$lib/components/site/SiteFooter.svelte';

  let { form } = $props();

  let showPassword = $state(false);
  let name = $state('');
  let email = $state('');
  let password = $state('');
  let agree = $state(false);

  const canSubmit = $derived(
    name.trim() !== '' && email.trim().includes('@') && password.length >= 6 && agree
  );
</script>

<svelte:head>
  <title>Buat Akun — Asesmen</title>
</svelte:head>

<div class="signup">
  <SiteHeader />

  <main class="signup-main">
    <div class="signup-card">
      <p class="signup-kicker">Akun pengguna</p>
      <h1>Buat akun untuk mulai menggunakan Asesmen.</h1>
      <p class="signup-lede">
        Daftar dengan email — akun berlaku untuk semua layanan, termasuk tes kepribadian gratis.
      </p>

      {#if form?.error}
        <p class="signup-fail">{form.error}</p>
      {/if}

      <form method="POST" class="signup-form">
        <input
          type="email"
          name="email"
          placeholder="Email"
          autocomplete="email"
          aria-label="Email"
          bind:value={email}
          required
        />
        <input
          type="text"
          name="name"
          placeholder="Nama Lengkap"
          autocomplete="name"
          aria-label="Nama Lengkap"
          bind:value={name}
          required
        />
        <div class="signup-password">
          <input
            type={showPassword ? 'text' : 'password'}
            name="password"
            placeholder="Kata Sandi"
            autocomplete="new-password"
            aria-label="Kata Sandi"
            bind:value={password}
            required
          />
          <button
            type="button"
            class="signup-eye"
            onclick={() => (showPassword = !showPassword)}
            aria-label={showPassword ? 'Sembunyikan kata sandi' : 'Tampilkan kata sandi'}
            tabindex="-1"
          >
            <HugeiconsIcon icon={showPassword ? ViewOffIcon : ViewIcon} size={18} />
          </button>
        </div>

        <label class="signup-agree">
          <input type="checkbox" name="agree" value="yes" aria-label="Menyetujui Syarat dan Ketentuan" bind:checked={agree} />
          <span>
            Saya menyetujui
            <a href="/syarat-ketentuan" target="_blank" rel="noopener">Syarat &amp; Ketentuan</a>
          </span>
        </label>

        <button type="submit" class="signup-cta" disabled={!canSubmit}>Buat Akun</button>
      </form>

      <p class="signup-alt">
        Sudah punya akun? <a href="/login">Masuk</a>
      </p>
      <p class="signup-note">
        Dengan mendaftar, kamu menyetujui penggunaan data untuk keperluan platform asesmen.
      </p>
    </div>
  </main>

  <SiteFooter />
</div>

<style>
  .signup {
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

  .signup-main {
    flex: 1;
    display: flex;
    align-items: flex-start;
    justify-content: center;
    padding: clamp(2rem, 6vw, 3.5rem) clamp(1.25rem, 4vw, 2rem) 3rem;
  }

  .signup-card {
    max-width: 26rem;
    width: 100%;
  }

  .signup-kicker {
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-accent-deep);
    margin: 0 0 0.75rem;
  }

  .signup-card h1 {
    font-family: var(--lp-font-display);
    font-size: clamp(1.9rem, 6vw, 2.4rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1.12;
    margin: 0 0 0.75rem;
    overflow-wrap: anywhere;
  }

  .signup-lede {
    color: var(--lp-ink-2);
    margin: 0 0 1.75rem;
  }

  .signup-form {
    display: grid;
    gap: 0.85rem;
  }

  .signup-form > input,
  .signup-password input {
    width: 100%;
    min-height: 3.25rem;
    padding: 0.7rem 1rem;
    border-radius: 0.75rem;
    border: 1px solid var(--lp-rule-2);
    background: var(--lp-paper);
    font-size: 1rem;
    color: var(--lp-ink);
  }

  .signup-form > input:focus-visible,
  .signup-password input:focus-visible {
    outline: 2px solid var(--lp-focus);
    outline-offset: 2px;
  }

  .signup-form ::placeholder {
    color: var(--lp-muted);
  }

  .signup-password {
    position: relative;
  }

  .signup-password input {
    padding-inline-end: 3rem;
  }

  .signup-eye {
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

  .signup-eye:hover {
    color: var(--lp-ink);
  }

  .signup-agree {
    display: flex;
    align-items: flex-start;
    gap: 0.6rem;
    cursor: pointer;
    font-size: 0.88rem;
    color: var(--lp-ink-2);
    line-height: 1.5;
  }

  .signup-agree input {
    width: 1.1rem;
    height: 1.1rem;
    margin-top: 0.15rem;
    accent-color: var(--lp-accent-deep);
    flex: none;
  }

  .signup-agree a {
    color: var(--lp-accent-deep);
    font-weight: 600;
    text-decoration: underline;
  }

  .signup-cta {
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

  .signup-cta:hover:not(:disabled) {
    background: var(--lp-accent);
    transform: translateY(-1px);
  }

  .signup-cta:disabled {
    opacity: 0.45;
    cursor: not-allowed;
  }

  .signup-fail {
    color: oklch(0.55 0.18 25);
    background: oklch(0.96 0.03 25);
    border: 1px solid oklch(0.85 0.06 25);
    border-radius: 0.75rem;
    padding: 0.8rem 1rem;
    font-size: 0.9rem;
    margin: 0 0 1.25rem;
  }

  .signup-alt {
    text-align: center;
    margin: 1.25rem 0 0;
    font-size: 0.9rem;
    color: var(--lp-ink-2);
  }

  .signup-alt a {
    color: var(--lp-accent-deep);
    font-weight: 600;
    text-decoration: underline;
  }

  .signup-note {
    text-align: center;
    color: var(--lp-muted);
    font-size: 0.78rem;
    margin: 1rem 0 0;
  }

  .signup :global(a):focus-visible,
  .signup :global(button):focus-visible,
  .signup :global(input):focus-visible {
    outline: 2px solid var(--lp-focus);
    outline-offset: 3px;
  }
</style>
