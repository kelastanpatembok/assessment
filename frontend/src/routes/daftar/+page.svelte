<script lang="ts">
  import SiteHeader from '$lib/components/site/SiteHeader.svelte';
  import SiteFooter from '$lib/components/site/SiteFooter.svelte';

  let { data, form } = $props();

  let step = $state<'form' | 'success'>('form');
  let loading = $state(false);

  let name = $state('');
  let email = $state('');
  let phone = $state('');
  let schoolName = $state('');
  let schoolAddress = $state('');
  let errorMsg = $state('');

  const canSubmit = $derived(
    name.trim() !== '' && email.trim().includes('@')
  );

  async function handleSubmit(e: SubmitEvent) {
    e.preventDefault();
    loading = true;
    errorMsg = '';
    try {
      const res = await fetch('/api/registrations', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          name: name.trim(),
          email: email.trim().toLowerCase(),
          phone: phone.trim() || null,
          schoolName: schoolName.trim() || null,
          schoolAddress: schoolAddress.trim() || null,
        }),
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        errorMsg = err.message || 'Terjadi kesalahan, coba lagi.';
      } else {
        step = 'success';
      }
    } catch {
      errorMsg = 'Koneksi gagal, periksa internet Anda.';
    } finally {
      loading = false;
    }
  }
</script>

<svelte:head>
  <title>Daftar Akun — Asesmen</title>
  <meta name="description" content="Daftarkan akun Anda untuk menggunakan layanan asesmen psikometri kami." />
</svelte:head>

<div class="reg">
  <SiteHeader user={data?.user} profile={data?.profile} />

  <main class="reg-main">
    {#if step === 'success'}
      <!-- ── Success State ──────────────────────────────── -->
      <div class="reg-card success-card">
        <div class="success-icon" aria-hidden="true">✓</div>
        <h1 class="success-title">Pendaftaran Berhasil!</h1>
        <p class="success-lede">
          Terima kasih, <strong>{name}</strong>! Kami telah menerima data Anda.
          Tim kami akan segera menghubungi Anda melalui email <strong>{email}</strong>
          atau nomor telepon yang Anda cantumkan.
        </p>
        <a href="/" class="reg-btn-primary">Kembali ke Beranda</a>
        <p class="success-note">Pertanyaan? Hubungi kami di <a href="mailto:hello@asesmen.id">hello@asesmen.id</a></p>
      </div>
    {:else}
      <!-- ── Form ──────────────────────────────────────── -->
      <div class="reg-card">
        <p class="reg-kicker">Mulai sekarang</p>
        <h1 class="reg-title">Daftarkan Akun Anda</h1>
        <p class="reg-lede">
          Isi formulir berikut. Tim kami akan menghubungi Anda untuk konfirmasi
          dan pengaturan akses layanan asesmen psikometri.
        </p>

        {#if errorMsg}
          <p class="reg-error" role="alert">{errorMsg}</p>
        {/if}

        <form class="reg-form" onsubmit={handleSubmit} novalidate>
          <!-- Nama -->
          <div class="field">
            <label for="reg-name" class="field-label">Nama Lengkap <span class="req">*</span></label>
            <input
              id="reg-name"
              type="text"
              name="name"
              placeholder="Nama lengkap Anda"
              autocomplete="name"
              required
              bind:value={name}
            />
          </div>

          <!-- Email -->
          <div class="field">
            <label for="reg-email" class="field-label">Email <span class="req">*</span></label>
            <input
              id="reg-email"
              type="email"
              name="email"
              placeholder="email@contoh.com"
              autocomplete="email"
              required
              bind:value={email}
            />
          </div>

          <!-- Telepon -->
          <div class="field">
            <label for="reg-phone" class="field-label">No. Telepon / HP</label>
            <input
              id="reg-phone"
              type="tel"
              name="phone"
              placeholder="08xx-xxxx-xxxx"
              autocomplete="tel"
              bind:value={phone}
            />
          </div>

          <div class="field-divider">
            <span class="field-divider-label">Informasi Sekolah / Institusi</span>
          </div>

          <!-- Nama Sekolah -->
          <div class="field">
            <label for="reg-school" class="field-label">Nama Sekolah / Institusi</label>
            <input
              id="reg-school"
              type="text"
              name="schoolName"
              placeholder="Contoh: SMA Negeri 1 Yogyakarta"
              bind:value={schoolName}
            />
          </div>

          <!-- Alamat Sekolah -->
          <div class="field">
            <label for="reg-address" class="field-label">Alamat Sekolah / Institusi</label>
            <textarea
              id="reg-address"
              name="schoolAddress"
              placeholder="Jalan, Kecamatan, Kota / Kabupaten, Provinsi"
              rows="3"
              bind:value={schoolAddress}
            ></textarea>
          </div>

          <button type="submit" class="reg-btn-primary" disabled={!canSubmit || loading}>
            {#if loading}
              <span class="spinner" aria-hidden="true"></span>
              Memproses…
            {:else}
              Kirim Pendaftaran
            {/if}
          </button>
        </form>

        <p class="reg-note">
          Sudah punya akun? <a href="/signin">Masuk di sini</a>
        </p>
      </div>
    {/if}
  </main>

  <SiteFooter />
</div>

<style>
  .reg {
    background: var(--lp-paper);
    color: var(--lp-ink);
    font-family: Figtree, ui-sans-serif, system-ui, sans-serif;
    min-height: 100dvh;
    display: flex;
    flex-direction: column;
    -webkit-font-smoothing: antialiased;
  }

  .reg-main {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: clamp(2rem, 6vw, 3.5rem) clamp(1.25rem, 4vw, 2rem) 3rem;
  }

  .reg-card {
    max-width: 30rem;
    width: 100%;
  }

  .reg-kicker {
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    color: var(--lp-accent-deep);
    margin: 0 0 0.75rem;
  }

  .reg-title {
    font-family: var(--lp-font-display);
    font-size: clamp(1.9rem, 6vw, 2.4rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1.12;
    margin: 0 0 0.75rem;
  }

  .reg-lede {
    color: var(--lp-ink-2);
    margin: 0 0 1.75rem;
  }

  .reg-form {
    display: grid;
    gap: 1rem;
  }

  .field {
    display: grid;
    gap: 0.4rem;
  }

  .field-label {
    font-size: 0.85rem;
    font-weight: 600;
    color: var(--lp-ink-2);
  }

  .req {
    color: oklch(0.55 0.18 25);
    margin-left: 0.1em;
  }

  .field input,
  .field textarea {
    width: 100%;
    min-height: 3rem;
    padding: 0.7rem 1rem;
    border-radius: 0.75rem;
    border: 1.5px solid var(--lp-rule-2);
    background: var(--lp-paper);
    font-size: 1rem;
    color: var(--lp-ink);
    font-family: inherit;
    transition: border-color 150ms;
    box-sizing: border-box;
  }

  .field textarea {
    min-height: 5rem;
    resize: vertical;
  }

  .field input:focus-visible,
  .field textarea:focus-visible {
    outline: none;
    border-color: var(--lp-focus);
    box-shadow: 0 0 0 3px oklch(from var(--lp-focus) l c h / 0.15);
  }

  .field input::placeholder,
  .field textarea::placeholder {
    color: var(--lp-muted);
  }

  .field-divider {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin: 0.5rem 0 0;
  }

  .field-divider-label {
    font-size: 0.78rem;
    font-weight: 600;
    letter-spacing: 0.08em;
    text-transform: uppercase;
    color: var(--lp-muted);
    white-space: nowrap;
  }

  .field-divider::before,
  .field-divider::after {
    content: '';
    flex: 1;
    height: 1px;
    background: var(--lp-rule);
  }

  .reg-btn-primary {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 0.5rem;
    min-height: 3.25rem;
    padding: 0.8rem 1.5rem;
    border-radius: 999px;
    background: var(--lp-ink);
    color: var(--lp-paper);
    border: none;
    font-weight: 650;
    font-size: 1rem;
    font-family: inherit;
    cursor: pointer;
    text-decoration: none;
    transition: background-color 200ms, transform 200ms;
    margin-top: 0.5rem;
  }

  .reg-btn-primary:hover:not(:disabled) {
    background: var(--lp-ink-2);
    transform: translateY(-1px);
  }

  .reg-btn-primary:disabled {
    opacity: 0.45;
    cursor: not-allowed;
  }

  .reg-error {
    color: oklch(0.55 0.18 25);
    background: oklch(0.96 0.03 25);
    border: 1px solid oklch(0.85 0.06 25);
    border-radius: 0.75rem;
    padding: 0.8rem 1rem;
    font-size: 0.9rem;
    margin: 0 0 1rem;
  }

  .reg-note {
    text-align: center;
    color: var(--lp-muted);
    font-size: 0.85rem;
    margin: 1.25rem 0 0;
  }

  .reg-note a {
    color: var(--lp-accent-deep);
    font-weight: 600;
    text-decoration: underline;
  }

  /* Success */
  .success-card {
    text-align: center;
    padding: 1rem 0;
  }

  .success-icon {
    width: 4rem;
    height: 4rem;
    border-radius: 999px;
    background: oklch(0.9 0.1 145);
    color: oklch(0.4 0.15 145);
    font-size: 2rem;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    margin-bottom: 1.25rem;
  }

  .success-title {
    font-family: var(--lp-font-display);
    font-size: clamp(1.8rem, 5vw, 2.2rem);
    font-weight: 560;
    margin: 0 0 1rem;
  }

  .success-lede {
    color: var(--lp-ink-2);
    margin: 0 0 2rem;
    line-height: 1.7;
  }

  .success-note {
    color: var(--lp-muted);
    font-size: 0.85rem;
    margin: 1.25rem 0 0;
  }

  .success-note a {
    color: var(--lp-accent-deep);
    text-decoration: underline;
  }

  .spinner {
    width: 1rem;
    height: 1rem;
    border: 2px solid transparent;
    border-top-color: currentColor;
    border-radius: 50%;
    animation: spin 0.7s linear infinite;
    display: inline-block;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }
</style>
