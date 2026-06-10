import { ab as head, ae as ensure_array_like, ad as escape_html, a5 as derived } from './dev-DBdtSqNh.js';
import { C as Card, b as Card_header, c as Card_title, a as Card_content } from './card-D-P3c-kH.js';
import { B as Button } from './button-axqvSO5n.js';
import './index-jeR0PSLo.js';

//#region src/routes/(counselor)/counselor-results/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data } = $$props;
		let activeTab = "disc";
		const tabs = [
			{
				key: "disc",
				label: "DISC"
			},
			{
				key: "holland",
				label: "Holland"
			},
			{
				key: "papi",
				label: "PAPI Kostick"
			},
			{
				key: "cfit",
				label: "IQ CFIT"
			},
			{
				key: "ist",
				label: "IQ IST"
			}
		];
		let currentResults = derived(() => activeTab === "disc" ? data.disc : activeTab === "holland" ? data.holland : activeTab === "papi" ? data.papi : activeTab === "cfit" ? data.cfit : data.ist);
		head("40g4yo", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Hasil Tes</title>`);
			});
		});
		$$renderer.push(`<div class="flex flex-col gap-6"><h2 class="text-2xl font-bold">Hasil Tes</h2> <div class="flex gap-2 flex-wrap"><!--[-->`);
		const each_array = ensure_array_like(tabs);
		for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
			let t = each_array[$$index];
			Button($$renderer, {
				variant: activeTab === t.key ? "default" : "outline",
				size: "sm",
				onclick: () => activeTab = t.key,
				children: ($$renderer) => {
					$$renderer.push(`<!---->${escape_html(t.label)}`);
				},
				$$slots: { default: true }
			});
		}
		$$renderer.push(`<!--]--></div> `);
		Card($$renderer, {
			children: ($$renderer) => {
				Card_header($$renderer, {
					children: ($$renderer) => {
						Card_title($$renderer, {
							children: ($$renderer) => {
								$$renderer.push(`<!---->${escape_html(tabs.find((t) => t.key === activeTab)?.label)}`);
							},
							$$slots: { default: true }
						});
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!----> `);
				Card_content($$renderer, {
					children: ($$renderer) => {
						$$renderer.push(`<table class="w-full text-sm"><thead><tr class="border-border border-b text-left"><th class="pb-3 font-medium">Nama Siswa</th><th class="pb-3 font-medium">Sekolah</th><th class="pb-3 font-medium">Tanggal</th><th class="pb-3 font-medium">Hasil</th></tr></thead><tbody>`);
						const each_array_1 = ensure_array_like(currentResults());
						if (each_array_1.length !== 0) {
							$$renderer.push("<!--[-->");
							for (let $$index_1 = 0, $$length = each_array_1.length; $$index_1 < $$length; $$index_1++) {
								let r = each_array_1[$$index_1];
								$$renderer.push(`<tr class="border-border border-b last:border-0"><td class="py-3 font-medium">${escape_html(r.studentName)}</td><td class="text-muted-foreground py-3">${escape_html(r.schoolName ?? "-")}</td><td class="text-muted-foreground py-3">${escape_html(r.createdAt ? new Date(r.createdAt).toLocaleDateString("id-ID") : "-")}</td><td class="py-3">`);
								if (activeTab === "disc") {
									$$renderer.push("<!--[0-->");
									$$renderer.push(`D:${escape_html(r.dMost ?? 0)} I:${escape_html(r.iMost ?? 0)} S:${escape_html(r.sMost ?? 0)} C:${escape_html(r.cMost ?? 0)}`);
								} else if (activeTab === "holland") {
									$$renderer.push("<!--[1-->");
									$$renderer.push(`R:${escape_html(r.totalR ?? 0)} I:${escape_html(r.totalI ?? 0)} A:${escape_html(r.totalA ?? 0)}`);
								} else if (activeTab === "cfit") {
									$$renderer.push("<!--[2-->");
									$$renderer.push(`RS: ${escape_html(r.rawScore ?? "-")}`);
								} else if (activeTab === "ist") {
									$$renderer.push("<!--[3-->");
									$$renderer.push(`IQ: ${escape_html(r.iqScore ?? "-")}`);
								} else {
									$$renderer.push("<!--[-1-->");
									$$renderer.push(`Selesai`);
								}
								$$renderer.push(`<!--]--></td></tr>`);
							}
						} else {
							$$renderer.push("<!--[!-->");
							$$renderer.push(`<tr><td colspan="4" class="text-muted-foreground py-6 text-center">Belum ada hasil</td></tr>`);
						}
						$$renderer.push(`<!--]--></tbody></table>`);
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!---->`);
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----></div>`);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-DvHcNyAG.js.map
