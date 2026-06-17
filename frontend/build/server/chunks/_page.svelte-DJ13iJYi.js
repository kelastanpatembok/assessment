import { $ as head, a1 as escape_html, ae as ensure_array_like, a0 as attr } from './dev-Ye9HvMQi.js';
import './client-59jucBkC.js';
import { C as Card, a as Card_content, b as Card_header, c as Card_title } from './card-D43ruB05.js';
import { B as Button } from './button-Cw17vFE1.js';
import { L as Label, I as Input } from './label-CtBNDRHL.js';
import './index-server-DVlmzpyW.js';
import './internal2-DrRkwNAm.js';
import './index-DBqjc0Yf.js';
import './utils2-BzHbLXAp.js';
import './index-DpfMhswA.js';

//#region src/routes/(admin)/admin-categories/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		const TEST_OPTIONS = [
			"disc",
			"holland",
			"papi",
			"cfit",
			"ist"
		];
		let { data, form } = $$props;
		let showModal = false;
		let loading = false;
		head("t0qgai", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Kategori Tes</title>`);
			});
		});
		$$renderer.push(`<div class="flex flex-col gap-6"><div class="flex items-center justify-between"><h2 class="text-2xl font-bold">Kategori Tes</h2> `);
		Button($$renderer, {
			onclick: () => showModal = true,
			children: ($$renderer) => {
				$$renderer.push(`<!---->+ Tambah Kategori`);
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----></div> `);
		if (form?.error) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">${escape_html(form.error)}</div>`);
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> `);
		Card($$renderer, {
			children: ($$renderer) => {
				Card_content($$renderer, {
					class: "pt-6",
					children: ($$renderer) => {
						$$renderer.push(`<table class="w-full text-sm"><thead><tr class="border-border border-b text-left"><th class="pb-3 font-medium">ID</th><th class="pb-3 font-medium">Nama</th><th class="pb-3 font-medium">Slug</th><th class="pb-3 font-medium">Harga</th><th class="pb-3 font-medium">Aksi</th></tr></thead><tbody>`);
						const each_array = ensure_array_like(data.categories);
						if (each_array.length !== 0) {
							$$renderer.push("<!--[-->");
							for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
								let cat = each_array[$$index];
								$$renderer.push(`<tr class="border-border border-b last:border-0"><td class="text-muted-foreground py-3">${escape_html(cat.id)}</td><td class="py-3 font-medium">${escape_html(cat.name)}</td><td class="text-muted-foreground py-3">${escape_html(cat.slug ?? "-")}</td><td class="py-3">Rp ${escape_html((cat.price ?? 0).toLocaleString("id-ID"))}</td><td class="flex gap-3 py-3"><button type="button" class="text-xs text-blue-600 hover:underline">Edit</button> <form method="POST" action="?/delete"><input type="hidden" name="id"${attr("value", cat.id)}/> <button type="submit" class="text-destructive text-xs hover:underline">Hapus</button></form></td></tr>`);
							}
						} else {
							$$renderer.push("<!--[!-->");
							$$renderer.push(`<tr><td colspan="5" class="text-muted-foreground py-6 text-center">Belum ada kategori</td></tr>`);
						}
						$$renderer.push(`<!--]--></tbody></table>`);
					},
					$$slots: { default: true }
				});
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----></div> `);
		if (showModal) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<div class="bg-background/80 fixed inset-0 z-50 flex items-center justify-center backdrop-blur-sm">`);
			Card($$renderer, {
				class: "w-full max-w-md",
				children: ($$renderer) => {
					Card_header($$renderer, {
						children: ($$renderer) => {
							Card_title($$renderer, {
								children: ($$renderer) => {
									$$renderer.push(`<!---->Tambah Kategori`);
								},
								$$slots: { default: true }
							});
						},
						$$slots: { default: true }
					});
					$$renderer.push(`<!----> `);
					Card_content($$renderer, {
						children: ($$renderer) => {
							$$renderer.push(`<form method="POST" action="?/create" class="flex flex-col gap-4"><div class="flex flex-col gap-2">`);
							Label($$renderer, {
								for: "name",
								children: ($$renderer) => {
									$$renderer.push(`<!---->Nama Kategori`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> `);
							Input($$renderer, {
								id: "name",
								name: "name",
								placeholder: "cth: DISC + Holland",
								required: true
							});
							$$renderer.push(`<!----></div> <div class="flex flex-col gap-2">`);
							Label($$renderer, {
								for: "slug",
								children: ($$renderer) => {
									$$renderer.push(`<!---->Slug`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> `);
							Input($$renderer, {
								id: "slug",
								name: "slug",
								placeholder: "cth: disc-holland"
							});
							$$renderer.push(`<!----></div> <div class="flex flex-col gap-2">`);
							Label($$renderer, {
								for: "price",
								children: ($$renderer) => {
									$$renderer.push(`<!---->Harga (Rp)`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> `);
							Input($$renderer, {
								id: "price",
								name: "price",
								type: "number",
								placeholder: "0",
								min: "0"
							});
							$$renderer.push(`<!----></div> <div class="flex flex-col gap-2">`);
							Label($$renderer, {
								children: ($$renderer) => {
									$$renderer.push(`<!---->Tes yang Termasuk`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> <div class="flex flex-wrap gap-3"><!--[-->`);
							const each_array_1 = ensure_array_like(TEST_OPTIONS);
							for (let $$index_1 = 0, $$length = each_array_1.length; $$index_1 < $$length; $$index_1++) {
								let t = each_array_1[$$index_1];
								$$renderer.push(`<label class="flex items-center gap-1.5 text-sm capitalize"><input type="checkbox" name="tests"${attr("value", t)} class="size-4"/> ${escape_html(t.toUpperCase())}</label>`);
							}
							$$renderer.push(`<!--]--></div></div> <div class="flex justify-end gap-2">`);
							Button($$renderer, {
								type: "button",
								variant: "outline",
								onclick: () => showModal = false,
								children: ($$renderer) => {
									$$renderer.push(`<!---->Batal`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> `);
							Button($$renderer, {
								type: "submit",
								disabled: loading,
								children: ($$renderer) => {
									$$renderer.push(`<!---->${escape_html("Simpan")}`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----></div></form>`);
						},
						$$slots: { default: true }
					});
					$$renderer.push(`<!---->`);
				},
				$$slots: { default: true }
			});
			$$renderer.push(`<!----></div>`);
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> `);
		$$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]-->`);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-DJ13iJYi.js.map
