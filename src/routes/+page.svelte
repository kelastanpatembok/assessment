<script lang="ts">
	import { HugeiconsIcon } from '@hugeicons/svelte';
	import {
		SparklesIcon,
		AiMagicIcon,
		PaintBoardIcon,
		FlashIcon,
		ComponentIcon,
		TailwindcssIcon,
		Rocket01Icon,
		CheckmarkBadge01Icon,
		ArrowRight01Icon,
		GithubIcon,
		Moon02Icon,
		Sun03Icon
	} from '@hugeicons/core-free-icons';

	import { Button } from '$lib/components/ui/button/index.js';
	import {
		Card,
		CardContent,
		CardDescription,
		CardHeader,
		CardTitle
	} from '$lib/components/ui/card/index.js';
	import { Badge } from '$lib/components/ui/badge/index.js';
	import { Input } from '$lib/components/ui/input/index.js';
	import { Label } from '$lib/components/ui/label/index.js';
	import { Separator } from '$lib/components/ui/separator/index.js';

	let dark = $state(false);

	$effect(() => {
		document.documentElement.classList.toggle('dark', dark);
	});

	const features = [
		{
			icon: ComponentIcon,
			title: 'shadcn-svelte',
			description: 'Accessible, composable components you own and can fully customize.'
		},
		{
			icon: TailwindcssIcon,
			title: 'Tailwind CSS v4',
			description: 'Utility-first styling with the new zero-config engine.'
		},
		{
			icon: FlashIcon,
			title: 'SvelteKit + Vite',
			description: 'Instant HMR in dev and a fast, adapter-node build for production.'
		},
		{
			icon: PaintBoardIcon,
			title: 'Maia theme',
			description: 'Soft, rounded design system with Hugeicons and the Figtree typeface.'
		}
	];
</script>

<svelte:head>
	<title>Assessment — SvelteKit + shadcn</title>
</svelte:head>

<div class="bg-background text-foreground min-h-screen">
	<!-- Top bar -->
	<header class="border-border/60 border-b">
		<div class="mx-auto flex max-w-5xl items-center justify-between px-6 py-4">
			<div class="flex items-center gap-2 font-semibold">
				<span
					class="bg-primary text-primary-foreground flex size-8 items-center justify-center rounded-lg"
				>
					<HugeiconsIcon icon={SparklesIcon} size={18} />
				</span>
				assessment
			</div>
			<div class="flex items-center gap-2">
				<Button href="https://www.shadcn-svelte.com" target="_blank" variant="ghost" size="sm">
					Docs
				</Button>
				<Button onclick={() => (dark = !dark)} variant="outline" size="icon" aria-label="Toggle theme">
					<HugeiconsIcon icon={dark ? Sun03Icon : Moon02Icon} size={18} />
				</Button>
			</div>
		</div>
	</header>

	<!-- Hero -->
	<main class="mx-auto max-w-5xl px-6">
		<section class="flex flex-col items-center py-20 text-center">
			<Badge variant="secondary" class="mb-6 gap-1.5">
				<HugeiconsIcon icon={AiMagicIcon} size={14} />
				Powered by SvelteKit
			</Badge>

			<h1 class="max-w-2xl text-4xl font-bold tracking-tight text-balance sm:text-5xl">
				Your assessment app is
				<span class="text-primary">ready to build</span>.
			</h1>

			<p class="text-muted-foreground mt-5 max-w-xl text-lg text-pretty">
				Scaffolded with the latest SvelteKit, styled with Tailwind v4 and shadcn-svelte, and serving
				on the port from your <code class="bg-muted rounded px-1.5 py-0.5 text-sm">.env</code>.
			</p>

			<div class="mt-8 flex flex-wrap items-center justify-center gap-3">
				<Button size="lg" class="gap-2">
					<HugeiconsIcon icon={Rocket01Icon} size={18} />
					Get started
					<HugeiconsIcon icon={ArrowRight01Icon} size={18} />
				</Button>
				<Button size="lg" variant="outline" class="gap-2" href="https://github.com" target="_blank">
					<HugeiconsIcon icon={GithubIcon} size={18} />
					View source
				</Button>
			</div>
		</section>

		<!-- Feature cards -->
		<section class="grid gap-4 pb-16 sm:grid-cols-2">
			{#each features as feature (feature.title)}
				<Card class="transition-shadow hover:shadow-md">
					<CardHeader>
						<div
							class="bg-primary/10 text-primary mb-2 flex size-10 items-center justify-center rounded-lg"
						>
							<HugeiconsIcon icon={feature.icon} size={20} />
						</div>
						<CardTitle>{feature.title}</CardTitle>
						<CardDescription>{feature.description}</CardDescription>
					</CardHeader>
				</Card>
			{/each}
		</section>

		<!-- Newsletter / form demo -->
		<section class="pb-24">
			<Card class="mx-auto max-w-xl">
				<CardHeader>
					<CardTitle class="flex items-center gap-2">
						<HugeiconsIcon icon={CheckmarkBadge01Icon} size={20} class="text-primary" />
						Everything wired up
					</CardTitle>
					<CardDescription>
						A quick demo of form components. Drop in a real action when you're ready.
					</CardDescription>
				</CardHeader>
				<CardContent>
					<form
						class="flex flex-col gap-4 sm:flex-row sm:items-end"
						onsubmit={(e) => e.preventDefault()}
					>
						<div class="flex-1 space-y-2">
							<Label for="email">Email</Label>
							<Input id="email" type="email" placeholder="you@example.com" />
						</div>
						<Button type="submit">Notify me</Button>
					</form>
					<Separator class="my-6" />
					<div class="text-muted-foreground flex flex-wrap gap-2 text-sm">
						<Badge variant="outline">SvelteKit</Badge>
						<Badge variant="outline">Tailwind v4</Badge>
						<Badge variant="outline">shadcn-svelte</Badge>
						<Badge variant="outline">adapter-node</Badge>
					</div>
				</CardContent>
			</Card>
		</section>
	</main>

	<footer class="border-border/60 text-muted-foreground border-t">
		<div class="mx-auto max-w-5xl px-6 py-6 text-center text-sm">
			Built with SvelteKit · Tailwind · shadcn-svelte
		</div>
	</footer>
</div>
