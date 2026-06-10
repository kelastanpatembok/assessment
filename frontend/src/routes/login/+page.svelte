<script lang="ts">
  import { enhance } from '$app/forms';
  import { Card, CardContent, CardHeader, CardTitle, CardDescription } from '$lib/components/ui/card/index.js';
  import { Button } from '$lib/components/ui/button/index.js';
  import { Input } from '$lib/components/ui/input/index.js';
  import { Label } from '$lib/components/ui/label/index.js';

  let { form } = $props();
  let loading = $state(false);
</script>

<svelte:head><title>Masuk — Assessment</title></svelte:head>

<div class="bg-background flex min-h-screen items-center justify-center px-4">
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
            <Input
              id="password"
              name="password"
              type="password"
              placeholder="Masukkan password"
              autocomplete="current-password"
              required
            />
          </div>

          <Button type="submit" class="w-full" disabled={loading}>
            {loading ? 'Memproses...' : 'Masuk'}
          </Button>
        </form>
      </CardContent>
    </Card>
  </div>
</div>
