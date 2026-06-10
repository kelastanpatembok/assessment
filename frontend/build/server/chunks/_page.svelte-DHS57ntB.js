import { ab as head, ad as escape_html, a5 as derived, ae as ensure_array_like } from './dev-DBdtSqNh.js';
import { C as Card, b as Card_header, c as Card_title, a as Card_content } from './card-D-P3c-kH.js';
import { B as Badge } from './badge-DkcqB8h9.js';
import './index-jeR0PSLo.js';

//#region src/routes/(student)/student-ist/result/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data } = $$props;
		let r = derived(() => data.result);
		const subtestDefs = [
			{
				key: "SE",
				label: "SE — Melengkapi Kalimat",
				rawKey: "subtest1Raw",
				wertKey: "se"
			},
			{
				key: "WA",
				label: "WA — Memilih Kata",
				rawKey: "subtest2Raw",
				wertKey: "wa"
			},
			{
				key: "AN",
				label: "AN — Analogi",
				rawKey: "subtest3Raw",
				wertKey: "an"
			},
			{
				key: "GE",
				label: "GE — Kemampuan Umum",
				rawKey: "subtest4Raw",
				wertKey: "ge"
			},
			{
				key: "RA",
				label: "RA — Aritmatika",
				rawKey: "subtest5Raw",
				wertKey: "ra"
			},
			{
				key: "ZR",
				label: "ZR — Deret Angka",
				rawKey: "subtest6Raw",
				wertKey: "zr"
			},
			{
				key: "FA",
				label: "FA — Pemilihan Bentuk",
				rawKey: "subtest7Raw",
				wertKey: "fa"
			},
			{
				key: "WU",
				label: "WU — Pengetahuan Praktis",
				rawKey: "subtest8Raw",
				wertKey: "wu"
			},
			{
				key: "ME",
				label: "ME — Memori",
				rawKey: "subtest9Raw",
				wertKey: "me"
			}
		];
		let subtestScores = derived(() => subtestDefs.map((d) => ({
			label: d.label,
			raw: r()?.[d.rawKey] ?? "-",
			wert: r()?.[d.wertKey] ?? "-"
		})));
		head("jjrkju", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Hasil IQ IST</title>`);
			});
		});
		$$renderer.push(`<div class="flex max-w-2xl flex-col gap-6"><div><h2 class="text-2xl font-bold">Hasil Tes IQ IST</h2> <p class="text-muted-foreground mt-1 text-sm">${escape_html(r()?.studentName)} · ${escape_html(r()?.schoolName ?? "-")}</p></div> <div class="grid gap-4 sm:grid-cols-3">`);
		Card($$renderer, {
			children: ($$renderer) => {
				Card_header($$renderer, {
					children: ($$renderer) => {
						Card_title($$renderer, {
							class: "text-sm font-medium text-muted-foreground",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Raw Score (RS)`);
							},
							$$slots: { default: true }
						});
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!----> `);
				Card_content($$renderer, {
					children: ($$renderer) => {
						$$renderer.push(`<p class="text-3xl font-bold">${escape_html(r()?.rawScore ?? "-")}</p>`);
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
				Card_header($$renderer, {
					children: ($$renderer) => {
						Card_title($$renderer, {
							class: "text-sm font-medium text-muted-foreground",
							children: ($$renderer) => {
								$$renderer.push(`<!---->IQ Score`);
							},
							$$slots: { default: true }
						});
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!----> `);
				Card_content($$renderer, {
					children: ($$renderer) => {
						$$renderer.push(`<p class="text-3xl font-bold">${escape_html(r()?.iqScore ?? "-")}</p>`);
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
				Card_header($$renderer, {
					children: ($$renderer) => {
						Card_title($$renderer, {
							class: "text-sm font-medium text-muted-foreground",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Kategori`);
							},
							$$slots: { default: true }
						});
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!----> `);
				Card_content($$renderer, {
					children: ($$renderer) => {
						Badge($$renderer, {
							class: "text-sm",
							children: ($$renderer) => {
								$$renderer.push(`<!---->${escape_html(r()?.category ?? "-")}`);
							},
							$$slots: { default: true }
						});
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!---->`);
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----></div> `);
		Card($$renderer, {
			children: ($$renderer) => {
				Card_header($$renderer, {
					children: ($$renderer) => {
						Card_title($$renderer, {
							class: "text-base",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Skor Per Subtes`);
							},
							$$slots: { default: true }
						});
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!----> `);
				Card_content($$renderer, {
					children: ($$renderer) => {
						$$renderer.push(`<table class="w-full text-sm"><thead><tr class="border-border border-b text-left"><th class="pb-3 font-medium">Subtes</th><th class="pb-3 font-medium text-right">Raw Score</th><th class="pb-3 font-medium text-right">Wert Score</th></tr></thead><tbody><!--[-->`);
						const each_array = ensure_array_like(subtestScores());
						for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
							let s = each_array[$$index];
							$$renderer.push(`<tr class="border-border border-b last:border-0"><td class="py-3 text-xs">${escape_html(s.label)}</td><td class="py-3 text-right font-medium">${escape_html(s.raw)}</td><td class="py-3 text-right font-medium">${escape_html(s.wert)}</td></tr>`);
						}
						$$renderer.push(`<!--]--></tbody></table>`);
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!---->`);
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----> <a href="/student-dashboard" class="text-primary text-sm hover:underline">← Kembali ke Dashboard</a></div>`);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-DHS57ntB.js.map
