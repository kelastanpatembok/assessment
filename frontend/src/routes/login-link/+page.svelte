<script lang="ts">
  import { enhance } from '$app/forms';
  import SiteHeader from '$lib/components/site/SiteHeader.svelte';
  import SiteFooter from '$lib/components/site/SiteFooter.svelte';
  let { data, form } = $props();
  let email = $state('');
</script>

<svelte:head><title>Masuk lewat email — Asesmen</title></svelte:head>
<div class="loginlink">
  <SiteHeader />
  <main>
    <section>
      <h1>Masuk lewat email</h1>

      {#if data.error}
        <p class="error">{data.error}</p>
        <p><a href="/login-link">Minta tautan baru</a></p>
      {:else if form?.sent}
        <p>
          Jika email ini terdaftar, kami telah mengirimkan tautan masuk. Tautan berlaku sekali
          dan kedaluwarsa dalam beberapa menit. Periksa inbox dan folder spam Anda.
        </p>
      {:else}
        <p>
          Tidak bisa masuk karena akun masih aktif di perangkat lain? Masukkan email akun Anda
          dan kami kirimkan tautan masuk sekali pakai. Menekan tautan itu akan memindahkan sesi ke
          perangkat ini.
        </p>
        {#if form?.error}<p class="error">{form.error}</p>{/if}
        <form method="POST" use:enhance>
          <input type="email" name="email" bind:value={email} autocomplete="email" required />
          <button>Kirimi tautan masuk</button>
        </form>
      {/if}

      <p class="back"><a href="/signin">Kembali ke masuk</a></p>
    </section>
  </main>
  <SiteFooter />
</div>

<style>
  .loginlink {
    min-height: 100dvh;
    display: flex;
    flex-direction: column;
    background: var(--lp-paper);
    color: var(--lp-ink);
  }
  main {
    flex: 1;
    display: grid;
    place-items: center;
    padding: 2rem;
  }
  section {
    width: min(100%, 30rem);
  }
  h1 {
    font-family: var(--lp-font-display);
    font-size: 2rem;
    margin: 0 0 0.75rem;
  }
  p {
    color: var(--lp-ink-2);
    line-height: 1.6;
    margin: 0 0 1rem;
  }
  form {
    display: grid;
    gap: 0.75rem;
    margin: 1.5rem 0;
  }
  input,
  button {
    min-height: 3rem;
    border-radius: 0.65rem;
    padding: 0.65rem 1rem;
    font: inherit;
  }
  input {
    border: 1px solid var(--lp-rule-2);
    background: var(--lp-paper);
  }
  button {
    border: 0;
    background: var(--lp-accent-deep);
    color: white;
    font-weight: 700;
    cursor: pointer;
  }
  .error {
    color: oklch(0.55 0.18 25);
    background: oklch(0.96 0.03 25);
    border: 1px solid oklch(0.85 0.06 25);
    border-radius: 0.75rem;
    padding: 0.8rem 1rem;
    font-size: 0.9rem;
  }
  .back a {
    color: var(--lp-accent-deep);
    text-decoration: underline;
  }
</style>
