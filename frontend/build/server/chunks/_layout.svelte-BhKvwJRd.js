import { ae as ensure_array_like, ac as attr, af as attr_class, ag as store_get, ad as escape_html, ah as unsubscribe_stores } from './dev-DBdtSqNh.js';
import { p as page } from './stores-Dm9KMtgs.js';
import './client-BH3cxpaA.js';
import './internal2-BaeAYGUQ.js';
import './index-DBqjc0Yf.js';

//#region src/routes/(counselor)/+layout.svelte
function _layout($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		var $$store_subs;
		let { children, data } = $$props;
		const navLinks = [
			{
				href: "/counselor-dashboard",
				label: "Dashboard"
			},
			{
				href: "/counselor-students",
				label: "Siswa"
			},
			{
				href: "/counselor-results",
				label: "Hasil Tes"
			}
		];
		$$renderer.push(`<div class="bg-background flex min-h-screen"><aside class="bg-card border-border flex w-60 flex-col border-r"><div class="border-border border-b px-6 py-5"><div class="flex items-center gap-2"><div class="bg-primary text-primary-foreground flex size-8 items-center justify-center rounded-lg text-sm font-bold">A</div> <span class="font-semibold">Assessment</span></div> <p class="text-muted-foreground mt-1 text-xs">Guru BK</p></div> <nav class="flex-1 px-3 py-4"><ul class="flex flex-col gap-1"><!--[-->`);
		const each_array = ensure_array_like(navLinks);
		for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
			let link = each_array[$$index];
			$$renderer.push(`<li><a${attr("href", link.href)}${attr_class(`hover:bg-accent hover:text-accent-foreground flex items-center rounded-lg px-3 py-2 text-sm transition-colors ${store_get($$store_subs ??= {}, "$page", page).url.pathname === link.href ? "bg-accent text-accent-foreground font-medium" : "text-muted-foreground"}`)}>${escape_html(link.label)}</a></li>`);
		}
		$$renderer.push(`<!--]--></ul></nav> <div class="border-border border-t px-4 py-4"><p class="text-muted-foreground truncate text-xs">${escape_html(data.user?.username)}</p> <a href="/logout" class="text-destructive mt-1 block text-xs hover:underline">Keluar</a></div></aside> <div class="flex flex-1 flex-col"><header class="bg-card border-border border-b px-6 py-4"><div class="flex items-center justify-between"><h1 class="font-semibold">Panel Guru BK</h1> <span class="text-muted-foreground text-sm">${escape_html(data.user?.username)}</span></div></header> <main class="flex-1 p-6">`);
		children($$renderer);
		$$renderer.push(`<!----></main></div></div>`);
		if ($$store_subs) unsubscribe_stores($$store_subs);
	});
}

export { _layout as default };
//# sourceMappingURL=_layout.svelte-BhKvwJRd.js.map
