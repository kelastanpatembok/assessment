<script lang="ts">
  import { enhance } from '$app/forms';

  let { data, form } = $props();

  const roleLabel: Record<string, string> = {
    superadmin: 'Superadmin',
    gurubk: 'Guru BK',
    afiliator: 'Afiliator',
    psikolog: 'Psikolog',
    siswa: 'Siswa',
  };

  let students = $derived(form?.matches?.length ? form.matches : data.students);
  let searching = $derived(form?.matches !== undefined && form?.matches?.length === 0);
</script>

<svelte:head><title>Dashboard Psikolog — Asesmen</title></svelte:head>

<div class="pdash">
  <section class="pdash-hero">
    <p class="pdash-kicker">Panel Psikolog</p>
    <h2 class="pdash-title">Temukan peserta, bahas hasilnya.</h2>
    <p class="pdash-lede">
      Cari peserta berdasarkan username atau nama untuk meninjau hasil asesmen psikologi — siap
      didiskusikan bersama guru BK saat pertemuan.
    </p>
  </section>

  <form method="POST" action="?/search" use:enhance class="psearch">
    <label class="psearch-label" for="query">Cari peserta</label>
    <div class="psearch-row">
      <input
        id="query"
        name="query"
        type="search"
        class="psearch-input"
        placeholder="Username atau nama…"
        value={form?.query ?? ''}
        minlength="2"
        required
      />
      <button type="submit" class="psearch-btn">Cari</button>
    </div>
    <p class="psearch-hint">Minimal 2 karakter. Contoh: “adit”, “siti”, “Tes_PL”.</p>
  </form>

  <section class="plist">
    <div class="plist-head">
      <h3 class="plist-title">
        {form?.matches !== undefined ? 'Hasil pencarian' : 'Peserta terdaftar'}
      </h3>
      <span class="plist-count">{students.length}</span>
    </div>

    {#if searching}
      <p class="plist-empty">Tidak ada peserta yang cocok. Coba kata kunci lain.</p>
    {:else if students.length === 0}
      <p class="plist-empty">Belum ada peserta terdaftar.</p>
    {:else}
      <div class="plist-grid">
        {#each students as s}
          <a class="pcard" href={`/psikolog-siswa/${encodeURIComponent(s.authUserId)}`}>
            <span class="pcard-ava">{(s.name ?? s.username ?? '?').charAt(0).toUpperCase()}</span>
            <span class="pcard-body">
              <span class="pcard-name">{s.name}</span>
              <span class="pcard-username">@{s.username}</span>
            </span>
            <span class="pcard-meta">
              <span class="pcard-role">{roleLabel[s.role] ?? s.role}</span>
              <span class="pcard-school">{s.school?.name ?? '—'}</span>
            </span>
            <span class="pcard-arrow" aria-hidden="true">→</span>
          </a>
        {/each}
      </div>
    {/if}
  </section>
</div>

<style>
  .pdash {
    display: grid;
    gap: clamp(1.5rem, 3vw, 2.25rem);
  }

  .pdash-hero {
    max-width: 42rem;
  }

  .pdash-kicker {
    font-size: 0.72rem;
    font-weight: 600;
    letter-spacing: 0.16em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-accent-deep);
    margin: 0 0 0.5rem;
  }

  .pdash-title {
    font-family: var(--lp-font-display);
    font-size: clamp(1.7rem, 3vw + 0.6rem, 2.3rem);
    font-weight: 560;
    letter-spacing: -0.02em;
    line-height: 1.12;
    margin: 0 0 0.6rem;
  }

  .pdash-lede {
    color: var(--lp-ink-2);
    margin: 0;
  }

  .psearch {
    display: grid;
    gap: 0.5rem;
    max-width: 42rem;
  }

  .psearch-label {
    font-size: 0.8rem;
    font-weight: 650;
    letter-spacing: 0.06em;
    text-transform: uppercase;
    color: var(--lp-ink-2);
  }

  .psearch-row {
    display: grid;
    grid-template-columns: minmax(0, 1fr) auto;
    gap: 0.6rem;
  }

  .psearch-input {
    border: 1px solid var(--lp-rule-2);
    border-radius: 0.875rem;
    background: var(--lp-paper);
    padding: 0.75rem 1rem;
    font-size: 0.95rem;
    color: var(--lp-ink);
    font-family: inherit;
  }

  .psearch-input:focus-visible {
    outline: 2px solid var(--lp-focus);
    outline-offset: 2px;
  }

  .psearch-btn {
    border: 0;
    border-radius: 0.875rem;
    background: var(--lp-accent-deep);
    color: #fff;
    font-weight: 650;
    font-size: 0.95rem;
    padding: 0 1.4rem;
    cursor: pointer;
    transition: filter 160ms var(--lp-ease-out);
  }

  .psearch-btn:hover {
    filter: brightness(1.08);
  }

  .psearch-hint {
    margin: 0;
    font-size: 0.8rem;
    color: var(--lp-muted);
  }

  .plist {
    display: grid;
    gap: 1rem;
  }

  .plist-head {
    display: flex;
    align-items: baseline;
    gap: 0.6rem;
  }

  .plist-title {
    font-family: var(--lp-font-display);
    font-size: 1.4rem;
    font-weight: 560;
    letter-spacing: -0.01em;
    margin: 0;
  }

  .plist-count {
    font-size: 0.75rem;
    font-weight: 650;
    color: var(--lp-accent-deep);
  }

  .plist-empty {
    margin: 0;
    padding: 1.25rem;
    border: 1px dashed var(--lp-rule-2);
    border-radius: 1.25rem;
    color: var(--lp-muted);
    text-align: center;
  }

  .plist-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(18rem, 1fr));
    gap: 0.9rem;
  }

  .pcard {
    display: grid;
    grid-template-columns: auto 1fr auto;
    grid-template-rows: auto auto;
    gap: 0.2rem 0.85rem;
    align-items: center;
    border: 1px solid var(--lp-rule);
    border-radius: 1.1rem;
    background: var(--lp-paper);
    padding: 1rem 1.1rem;
    text-decoration: none;
    transition: transform 160ms var(--lp-ease-out), border-color 160ms var(--lp-ease-out);
  }

  .pcard:hover {
    transform: translateY(-2px);
    border-color: var(--lp-rule-2);
  }

  .pcard-ava {
    grid-row: 1 / span 2;
    width: 2.6rem;
    height: 2.6rem;
    border-radius: 999px;
    background: var(--lp-accent-bg);
    color: var(--lp-ink);
    display: inline-flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    font-size: 1rem;
  }

  .pcard-body {
    display: grid;
    min-width: 0;
  }

  .pcard-name {
    font-weight: 650;
    color: var(--lp-ink);
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }

  .pcard-username {
    font-size: 0.82rem;
    color: var(--lp-muted);
  }

  .pcard-meta {
    grid-column: 3;
    display: grid;
    justify-items: end;
    gap: 0.15rem;
  }

  .pcard-role {
    font-size: 0.72rem;
    font-weight: 650;
    letter-spacing: 0.05em;
    text-transform: uppercase;
    color: var(--lp-accent-deep);
  }

  .pcard-school {
    font-size: 0.78rem;
    color: var(--lp-muted);
  }

  .pcard-arrow {
    grid-column: 3;
    justify-self: end;
    color: var(--lp-muted);
    font-size: 1rem;
  }
</style>
