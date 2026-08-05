<script lang="ts">
  let { loginHref = '/signin', loginLabel = 'Masuk' } = $props();
</script>

<header class="site-head">
  <div class="site-head-inner">
    <a href="/" class="site-brand" aria-label="Beranda Asesmen">
      <span class="site-mark" aria-hidden="true"></span>
      <span class="site-name">Asesmen</span>
    </a>
    <a href={loginHref} class="site-login">{loginLabel}</a>
  </div>
</header>

<style>
  .site-head {
    border-bottom: 1px solid var(--lp-rule);
    background: var(--lp-paper);
  }

  .site-head-inner {
    max-width: 48rem;
    margin-inline: auto;
    padding: 0.9rem clamp(1.25rem, 4vw, 2rem);
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
  }

  .site-brand {
    display: inline-flex;
    align-items: center;
    gap: 0.55rem;
    white-space: nowrap;
  }

  .site-mark {
    width: 0.65rem;
    height: 0.65rem;
    background: var(--lp-accent);
    flex: none;
  }

  .site-name {
    font-family: var(--lp-font-display);
    font-size: 1.3rem;
    font-weight: 620;
    letter-spacing: -0.02em;
    line-height: 1;
  }

  .site-login {
    font-size: 0.78rem;
    font-weight: 600;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    font-variant-caps: all-small-caps;
    color: var(--lp-accent-deep);
    padding: 0.6rem 0;
    background-image: linear-gradient(var(--lp-accent-deep), var(--lp-accent-deep));
    background-size: 0 1px;
    background-repeat: no-repeat;
    background-position: 50% 100%;
    transition: background-size 200ms var(--lp-ease-out);
    white-space: nowrap;
  }

  .site-login:hover {
    background-size: 100% 1px;
  }
</style>
