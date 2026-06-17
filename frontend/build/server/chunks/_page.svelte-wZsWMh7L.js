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

//#region src/routes/(admin)/admin-schools/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data, form } = $$props;
		let showModal = false;
		let loading = false;
		head("1tuetjp", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Sekolah</title>`);
			});
		});
		$$renderer.push(`<div class="flex flex-col gap-6"><div class="flex items-center justify-between"><h2 class="text-2xl font-bold">Sekolah</h2> `);
		Button($$renderer, {
			onclick: () => showModal = true,
			children: ($$renderer) => {
				$$renderer.push(`<!---->+ Tambah Sekolah`);
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
						$$renderer.push(`<table class="w-full text-sm"><thead><tr class="border-border border-b text-left"><th class="pb-3 font-medium">No</th><th class="pb-3 font-medium">Nama Sekolah</th><th class="pb-3 font-medium">Alamat</th><th class="pb-3 font-medium">Aksi</th></tr></thead><tbody>`);
						const each_array = ensure_array_like(data.schools);
						if (each_array.length !== 0) {
							$$renderer.push("<!--[-->");
							for (let i = 0, $$length = each_array.length; i < $$length; i++) {
								let school = each_array[i];
								$$renderer.push(`<tr class="border-border border-b last:border-0"><td class="py-3">${escape_html(i + 1)}</td><td class="py-3 font-medium">${escape_html(school.name)}</td><td class="text-muted-foreground py-3">${escape_html(school.address ?? "-")}</td><td class="flex gap-3 py-3"><button type="button" class="text-xs text-blue-600 hover:underline">Edit</button> <form method="POST" action="?/delete"><input type="hidden" name="id"${attr("value", school.id)}/> <button type="submit" class="text-destructive text-xs hover:underline">Hapus</button></form></td></tr>`);
							}
						} else {
							$$renderer.push("<!--[!-->");
							$$renderer.push(`<tr><td colspan="4" class="text-muted-foreground py-6 text-center">Belum ada sekolah</td></tr>`);
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
									$$renderer.push(`<!---->Tambah Sekolah`);
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
								for: "schoolName",
								children: ($$renderer) => {
									$$renderer.push(`<!---->Nama Sekolah`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> `);
							Input($$renderer, {
								id: "schoolName",
								name: "schoolName",
								placeholder: "Contoh: SMA Negeri 1 Jakarta",
								required: true
							});
							$$renderer.push(`<!----></div> <div class="flex flex-col gap-2">`);
							Label($$renderer, {
								for: "address",
								children: ($$renderer) => {
									$$renderer.push(`<!---->Alamat`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> `);
							Input($$renderer, {
								id: "address",
								name: "address",
								placeholder: "Alamat lengkap"
							});
							$$renderer.push(`<!----></div> <div class="flex gap-2 justify-end">`);
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
//# sourceMappingURL=_page.svelte-wZsWMh7L.js.map
