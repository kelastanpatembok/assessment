<script lang="ts">
  import SiteHeader from '$lib/components/site/SiteHeader.svelte';
  import SiteFooter from '$lib/components/site/SiteFooter.svelte';

  let { form, data } = $props();
</script>

<svelte:head>
  <title>Profil — Asesmen</title>
</svelte:head>

<div class="profil">
  <SiteHeader user={data.user} profile={data.profile} />

  <main class="profil-main">
    <div class="profil-card">
      <p class="profil-kicker">Akun pengguna</p>
      <h1>Profil &amp; Pengaturan</h1>

      <section class="profil-sec">
        <h2>Foto profil</h2>
        {#if data.profile?.avatarUrl}
          <img class="profil-avatar" src={data.profile.avatarUrl} alt="Foto profil" />
        {:else}
          <span class="profil-avatar profil-fallback">
            {(data.profile?.name || data.user?.username || '?')[0]?.toUpperCase()}
          </span>
        {/if}
        {#if form?.error}
          <p class="profil-fail">{form.error}</p>
        {/if}
        <form method="POST" action="?/avatar" enctype="multipart/form-data" class="profil-avatar-form">
          <input type="file" name="file" accept="image/*" aria-label="Pilih foto profil" required />
          <button type="submit" class="profil-cta">Unggah Foto</button>
        </form>
      </section>

      <section class="profil-sec">
        <h2>Nama</h2>
        <form method="POST" action="?/name" class="profil-form">
          <input type="text" name="name" placeholder="Nama lengkap" value={data.profile?.name ?? ''} required />
          <button type="submit" class="profil-cta">Simpan Nama</button>
        </form>
      </section>

      <section class="profil-sec">
        <h2>Kata sandi</h2>
        {#if form?.ok}
          <p class="profil-ok">Kata sandi berhasil diubah.</p>
        {/if}
        <form method="POST" action="?/password" class="profil-form">
          <input type="password" name="newPassword" placeholder="Kata sandi baru (min. 6 karakter)" autocomplete="new-password" required />
          <input type="password" name="confirmPassword" placeholder="Ulangi kata sandi baru" autocomplete="new-password" required />
          <button type="submit" class="profil-cta">Ubah Kata Sandi</button>
        </form>
      </section>

      <section class="profil-sec">
        <h2>Informasi akun</h2>
        <dl class="profil-info">
          {#if data.profile?.email}
            <div><dt>Email</dt><dd>{data.profile.email}</dd></div>
          {/if}
        </dl>
      </section>
    </div>
  </main>

  <SiteFooter />
</div>

<style>
  .profil {
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

  .profil-main {
    flex: 1;
    display: flex;
    align-items: flex-start;
    justify-content: center;
    padding: clamp(2rem, 6vw, 3.5rem) clamp(1.25rem, 4vw, 2rem) 3rem;
  }

  .profil-card {
    max-width: 30rem;
    width: 100%;
  }

  .profil-kicker {
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-accent-deep);
    margin: 0 0 0.75rem;
  }

  .profil-card h1 {
    font-family: var(--lp-font-display);
    font-size: clamp(1.8rem, 6vw, 2.3rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1.12;
    margin: 0 0 2rem;
    overflow-wrap: anywhere;
  }

  .profil-sec {
    border-top: 1px solid var(--lp-rule);
    padding: 1.5rem 0;
    display: grid;
    gap: 0.9rem;
  }

  .profil-sec h2 {
    font-size: 1.05rem;
    font-weight: 650;
    margin: 0;
  }

  .profil-avatar {
    width: 4.5rem;
    height: 4.5rem;
    border-radius: 999px;
    object-fit: cover;
    background: var(--lp-accent-bg);
  }

  .profil-fallback {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    font-size: 1.6rem;
    color: var(--lp-ink);
  }

  .profil-avatar-form {
    display: flex;
    flex-wrap: wrap;
    gap: 0.75rem;
    align-items: center;
  }

  .profil-avatar-form input[type='file'] {
    font-size: 0.9rem;
    color: var(--lp-ink-2);
  }

  .profil-form {
    display: grid;
    gap: 0.75rem;
  }

  .profil-form input {
    min-height: 3rem;
    padding: 0.7rem 1rem;
    border-radius: 0.75rem;
    border: 1px solid var(--lp-rule-2);
    background: var(--lp-paper);
    font-size: 1rem;
    color: var(--lp-ink);
  }

  .profil-form input:focus-visible {
    outline: 2px solid var(--lp-focus);
    outline-offset: 2px;
  }

  .profil-form ::placeholder {
    color: var(--lp-muted);
  }

  .profil-cta {
    justify-self: start;
    min-height: 2.9rem;
    padding: 0.65rem 1.5rem;
    border-radius: 999px;
    background: var(--lp-accent-bg);
    color: var(--lp-ink);
    border: 1px solid var(--lp-accent-bg);
    font-weight: 650;
    cursor: pointer;
    white-space: nowrap;
    transition: background-color 200ms var(--lp-ease-out), transform 200ms var(--lp-ease-out);
  }

  .profil-cta:hover {
    background: var(--lp-accent);
    transform: translateY(-1px);
  }

  .profil-fail {
    color: oklch(0.55 0.18 25);
    background: oklch(0.96 0.03 25);
    border: 1px solid oklch(0.85 0.06 25);
    border-radius: 0.75rem;
    padding: 0.8rem 1rem;
    font-size: 0.9rem;
    margin: 0;
  }

  .profil-ok {
    color: oklch(0.5 0.12 150);
    background: oklch(0.96 0.04 150);
    border: 1px solid oklch(0.85 0.08 150);
    border-radius: 0.75rem;
    padding: 0.8rem 1rem;
    font-size: 0.9rem;
    margin: 0;
  }

  .profil-info {
    margin: 0;
  }

  .profil-info div {
    display: flex;
    justify-content: space-between;
    gap: 1rem;
    padding: 0.4rem 0;
    border-top: 1px solid var(--lp-rule);
  }

  .profil-info div:first-child {
    border-top: 0;
  }

  .profil-info dt {
    color: var(--lp-muted);
    font-size: 0.9rem;
  }

  .profil-info dd {
    margin: 0;
    font-weight: 600;
    overflow-wrap: anywhere;
  }

  .profil :global(a):focus-visible,
  .profil :global(button):focus-visible,
  .profil :global(input):focus-visible {
    outline: 2px solid var(--lp-focus);
    outline-offset: 3px;
  }
</style>
