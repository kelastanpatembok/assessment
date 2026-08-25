<script lang="ts">
  import { enhance } from '$app/forms';
  import SiteHeader from '$lib/components/site/SiteHeader.svelte';
  import SiteFooter from '$lib/components/site/SiteFooter.svelte';
  let { form } = $props();
  let email = $state('');
</script>

<svelte:head><title>Pulihkan kata sandi — Asesmen</title></svelte:head>
<div class="recovery"><SiteHeader /><main><section>
  <h1>Pulihkan kata sandi</h1>
  {#if form?.sent}
    <p>Jika email ini terdaftar, kami telah mengirimkan tautan untuk mengatur ulang kata sandi.</p>
  {:else}
    <p>Masukkan email akun Anda. Kami akan mengirimkan tautan pemulihan yang berlaku sekali.</p>
    {#if form?.error}<p class="error">{form.error}</p>{/if}
    <form method="POST" use:enhance><input type="email" name="email" bind:value={email} autocomplete="email" required /><button>Kirimi tautan pemulihan</button></form>
  {/if}
  <p><a href="/signin">Kembali ke masuk</a></p>
</section></main><SiteFooter /></div>
<style> .recovery{min-height:100dvh;display:flex;flex-direction:column;background:var(--lp-paper);color:var(--lp-ink)}main{flex:1;display:grid;place-items:center;padding:2rem}section{width:min(100%,30rem)}h1{font-family:var(--lp-font-display);font-size:2rem}form{display:grid;gap:.75rem;margin:1.5rem 0}input,button{min-height:3rem;border-radius:.65rem;padding:.65rem 1rem;font:inherit}input{border:1px solid var(--lp-rule-2)}button{border:0;background:var(--lp-accent-deep);color:white;font-weight:700}.error{color:#b42318}</style>
