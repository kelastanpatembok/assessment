import { $ as head, a1 as escape_html, ae as ensure_array_like, _ as derived } from './dev-Ye9HvMQi.js';
import { C as Card, b as Card_header, c as Card_title, a as Card_content } from './card-D43ruB05.js';
import './utils2-BzHbLXAp.js';

//#region src/routes/(afiliator)/afiliator-fees/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data } = $$props;
		let total = derived(() => data.fees.reduce((sum, f) => sum + (f.affiliatorFee ?? 0), 0));
		head("un574h", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Komisi Afiliator</title>`);
			});
		});
		$$renderer.push(`<div class="flex flex-col gap-6"><h2 class="text-2xl font-bold">Laporan Komisi</h2> `);
		Card($$renderer, {
			class: "max-w-sm",
			children: ($$renderer) => {
				Card_header($$renderer, {
					children: ($$renderer) => {
						Card_title($$renderer, {
							class: "text-sm font-medium text-muted-foreground",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Total Komisi`);
							},
							$$slots: { default: true }
						});
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!----> `);
				Card_content($$renderer, {
					children: ($$renderer) => {
						$$renderer.push(`<p class="text-3xl font-bold">Rp ${escape_html(total().toLocaleString("id-ID"))}</p>`);
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!---->`);
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----> `);
		Card($$renderer, {
			children: ($$renderer) => {
				Card_content($$renderer, {
					class: "pt-6",
					children: ($$renderer) => {
						$$renderer.push(`<table class="w-full text-sm"><thead><tr class="border-border border-b text-left"><th class="pb-3 font-medium">Nama Siswa</th><th class="pb-3 font-medium">Sekolah</th><th class="pb-3 font-medium">Komisi Afiliator</th><th class="pb-3 font-medium">Tanggal</th></tr></thead><tbody>`);
						const each_array = ensure_array_like(data.fees);
						if (each_array.length !== 0) {
							$$renderer.push("<!--[-->");
							for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
								let f = each_array[$$index];
								$$renderer.push(`<tr class="border-border border-b last:border-0"><td class="py-3">${escape_html(f.studentName ?? "-")}</td><td class="text-muted-foreground py-3">${escape_html(f.schoolName ?? "-")}</td><td class="py-3 font-medium">Rp ${escape_html((f.affiliatorFee ?? 0).toLocaleString("id-ID"))}</td><td class="text-muted-foreground py-3">${escape_html(f.createdAt ? new Date(f.createdAt).toLocaleDateString("id-ID") : "-")}</td></tr>`);
							}
						} else {
							$$renderer.push("<!--[!-->");
							$$renderer.push(`<tr><td colspan="4" class="text-muted-foreground py-6 text-center">Belum ada data komisi</td></tr>`);
						}
						$$renderer.push(`<!--]--></tbody></table>`);
					},
					$$slots: { default: true }
				});
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----></div>`);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-FgpKg8gz.js.map
