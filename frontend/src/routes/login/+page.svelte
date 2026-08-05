<script lang="ts">
  import { enhance } from '$app/forms';
  import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';
  import { HugeiconsIcon } from '@hugeicons/svelte';
  import { ViewIcon, ViewOffIcon } from '@hugeicons/core-free-icons';
  import SiteHeader from '$lib/components/site/SiteHeader.svelte';
  import SiteFooter from '$lib/components/site/SiteFooter.svelte';

  let { form } = $props();
  let loading = $state(false);
  let showPassword = $state(false);
</script>

<svelte:head><title>Masuk — Assessment</title></svelte:head>

<div class="login-page">
  <SiteHeader />
  <main class="login-main">
    <div class="w-full max-w-sm">
      <div class="mb-8 text-center">
        <div class="bg-primary text-primary-foreground mx-auto mb-4 flex size-12 items-center justify-center rounded-xl text-xl font-bold">
          A
        </div>
        <h1 class="text-2xl font-bold">Selamat Datang</h1>
        <p class="text-muted-foreground mt-1 text-sm">Masuk ke platform asesmen psikometri</p>
      </div>

    <Card>
      <CardHeader>
        <CardTitle>Masuk</CardTitle>
        <CardDescription>Masukkan username dan password Anda</CardDescription>
      </CardHeader>
      <CardContent>
        <form
          method="POST"
          use:enhance={() => {
            loading = true;
            return async ({ update }) => {
              loading = false;
              await update();
            };
          }}
          class="flex flex-col gap-4"
        >
          {#if form?.error}
            <div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">
              {form.error}
            </div>
          {/if}

          <div class="flex flex-col gap-2">
            <Label for="username">Username</Label>
            <Input
              id="username"
              name="username"
              type="text"
              placeholder="Masukkan username"
              autocomplete="username"
              required
            />
          </div>

          <div class="flex flex-col gap-2">
            <Label for="password">Password</Label>
            <div class="relative">
              <Input
                id="password"
                name="password"
                type={showPassword ? 'text' : 'password'}
                placeholder="Masukkan password"
                autocomplete="current-password"
                required
                class="pr-10"
              />
              <button
                type="button"
                class="text-muted-foreground hover:text-foreground absolute inset-y-0 right-0 flex items-center px-3"
                onclick={() => (showPassword = !showPassword)}
                aria-label={showPassword ? 'Sembunyikan password' : 'Tampilkan password'}
                tabindex="-1"
              >
                <HugeiconsIcon icon={showPassword ? ViewOffIcon : ViewIcon} size={18} />
              </button>
            </div>
          </div>

          <Button type="submit" class="w-full" disabled={loading}>
            {loading ? 'Memproses...' : 'Masuk'}
          </Button>
        </form>
      </CardContent>
    </Card>
    </div>
  </main>
  <SiteFooter />
</div>

<style>
  .login-page {
    background: var(--lp-paper);
    color: var(--lp-ink);
    font-family: Figtree, ui-sans-serif, system-ui, sans-serif;
    min-height: 100dvh;
    display: flex;
    flex-direction: column;
    -webkit-font-smoothing: antialiased;
  }

  .login-main {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: clamp(2rem, 6vw, 3.5rem) 1rem;
  }
</style>
