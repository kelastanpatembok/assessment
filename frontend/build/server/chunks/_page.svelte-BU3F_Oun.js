import { ab as head, ad as escape_html, ae as ensure_array_like, ac as attr } from './dev-DBdtSqNh.js';
import './client-BH3cxpaA.js';
import { C as Card, a as Card_content, b as Card_header, c as Card_title } from './card-D-P3c-kH.js';
import { B as Button } from './button-axqvSO5n.js';
import { L as Label, I as Input } from './label-D2KfWwLz.js';
import { B as Badge } from './badge-DkcqB8h9.js';
import './internal2-BaeAYGUQ.js';
import './index-DBqjc0Yf.js';
import './index-jeR0PSLo.js';

//#region src/routes/(admin)/admin-assignments/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data, form } = $$props;
		let showModal = false;
		let loading = false;
		head("1f4xmuq", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Penugasan Tes</title>`);
			});
		});
		$$renderer.push(`<div class="flex flex-col gap-6"><div class="flex items-center justify-between"><h2 class="text-2xl font-bold">Penugasan Tes</h2> `);
		Button($$renderer, {
			onclick: () => showModal = true,
			children: ($$renderer) => {
				$$renderer.push(`<!---->+ Tambah Penugasan`);
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
						$$renderer.push(`<table class="w-full text-sm"><thead><tr class="border-border border-b text-left"><th class="pb-3 font-medium">Sekolah</th><th class="pb-3 font-medium">Kategori</th><th class="pb-3 font-medium">Mulai</th><th class="pb-3 font-medium">Selesai</th><th class="pb-3 font-medium">Status</th><th class="pb-3 font-medium">Aksi</th></tr></thead><tbody>`);
						const each_array = ensure_array_like(data.assignments);
						if (each_array.length !== 0) {
							$$renderer.push("<!--[-->");
							for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
								let a = each_array[$$index];
								$$renderer.push(`<tr class="border-border border-b last:border-0"><td class="py-3 font-medium">${escape_html(a.schoolName)}</td><td class="py-3">${escape_html(a.categoryName)}</td><td class="text-muted-foreground py-3">${escape_html(a.startDate)}</td><td class="text-muted-foreground py-3">${escape_html(a.endDate)}</td><td class="py-3">`);
								Badge($$renderer, {
									variant: a.status === "aktif" ? "default" : "secondary",
									children: ($$renderer) => {
										$$renderer.push(`<!---->${escape_html(a.status)}`);
									},
									$$slots: { default: true }
								});
								$$renderer.push(`<!----></td><td class="py-3"><form method="POST" action="?/delete"><input type="hidden" name="id"${attr("value", a.id)}/> <button type="submit" class="text-destructive text-xs hover:underline">Hapus</button></form></td></tr>`);
							}
						} else {
							$$renderer.push("<!--[!-->");
							$$renderer.push(`<tr><td colspan="6" class="text-muted-foreground py-6 text-center">Belum ada penugasan</td></tr>`);
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
									$$renderer.push(`<!---->Tambah Penugasan`);
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
								for: "schoolId",
								children: ($$renderer) => {
									$$renderer.push(`<!---->Sekolah`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> <select id="schoolId" name="schoolId" class="border-input bg-background flex h-10 w-full rounded-lg border px-3 text-sm" required="">`);
							$$renderer.option({ value: "" }, ($$renderer) => {
								$$renderer.push(`Pilih sekolah...`);
							});
							$$renderer.push(`<!--[-->`);
							const each_array_1 = ensure_array_like(data.schools);
							for (let $$index_1 = 0, $$length = each_array_1.length; $$index_1 < $$length; $$index_1++) {
								let s = each_array_1[$$index_1];
								$$renderer.option({ value: s.id }, ($$renderer) => {
									$$renderer.push(`${escape_html(s.schoolName)}`);
								});
							}
							$$renderer.push(`<!--]--></select></div> <div class="flex flex-col gap-2">`);
							Label($$renderer, {
								for: "categoryId",
								children: ($$renderer) => {
									$$renderer.push(`<!---->Kategori Tes`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> <select id="categoryId" name="categoryId" class="border-input bg-background flex h-10 w-full rounded-lg border px-3 text-sm" required="">`);
							$$renderer.option({ value: "" }, ($$renderer) => {
								$$renderer.push(`Pilih kategori...`);
							});
							$$renderer.push(`<!--[-->`);
							const each_array_2 = ensure_array_like(data.categories);
							for (let $$index_2 = 0, $$length = each_array_2.length; $$index_2 < $$length; $$index_2++) {
								let c = each_array_2[$$index_2];
								$$renderer.option({ value: c.id }, ($$renderer) => {
									$$renderer.push(`${escape_html(c.name)}`);
								});
							}
							$$renderer.push(`<!--]--></select></div> <div class="grid grid-cols-2 gap-4"><div class="flex flex-col gap-2">`);
							Label($$renderer, {
								for: "startDate",
								children: ($$renderer) => {
									$$renderer.push(`<!---->Tanggal Mulai`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> `);
							Input($$renderer, {
								id: "startDate",
								name: "startDate",
								type: "date",
								required: true
							});
							$$renderer.push(`<!----></div> <div class="flex flex-col gap-2">`);
							Label($$renderer, {
								for: "endDate",
								children: ($$renderer) => {
									$$renderer.push(`<!---->Tanggal Selesai`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> `);
							Input($$renderer, {
								id: "endDate",
								name: "endDate",
								type: "date",
								required: true
							});
							$$renderer.push(`<!----></div></div> <div class="flex items-center gap-2"><input type="checkbox" id="certificateEnabled" name="certificateEnabled" class="size-4"/> `);
							Label($$renderer, {
								for: "certificateEnabled",
								children: ($$renderer) => {
									$$renderer.push(`<!---->Aktifkan sertifikat`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----></div> <div class="flex justify-end gap-2">`);
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
		$$renderer.push(`<!--]-->`);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-BU3F_Oun.js.map
