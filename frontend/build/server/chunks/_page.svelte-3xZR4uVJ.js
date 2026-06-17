import { $ as head, a1 as escape_html, _ as derived, ae as ensure_array_like } from './dev-Ye9HvMQi.js';
import { C as Card, b as Card_header, c as Card_title, a as Card_content } from './card-D43ruB05.js';
import { B as Badge } from './badge-DyWNom1p.js';
import './utils2-BzHbLXAp.js';
import './index-DpfMhswA.js';

//#region src/routes/(student)/student-ist/result/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data } = $$props;
		let r = derived(() => data.result);
		const subtestDefs = [
			{
				key: "SE",
				label: "SE — Melengkapi Kalimat"
			},
			{
				key: "WA",
				label: "WA — Memilih Kata"
			},
			{
				key: "AN",
				label: "AN — Analogi"
			},
			{
				key: "GE",
				label: "GE — Kemampuan Umum"
			},
			{
				key: "RA",
				label: "RA — Aritmatika"
			},
			{
				key: "ZR",
				label: "ZR — Deret Angka"
			},
			{
				key: "FA",
				label: "FA — Pemilihan Bentuk"
			},
			{
				key: "WU",
				label: "WU — Pengetahuan Praktis"
			},
			{
				key: "ME",
				label: "ME — Memori"
			}
		];
		let parsedSubtests = derived(() => () => {
			if (!r()?.subtestScores) return {};
			if (typeof r().subtestScores === "object") return r().subtestScores;
			try {
				return JSON.parse(r().subtestScores);
			} catch {
				return {};
			}
		});
		let subtestScores = derived(() => subtestDefs.map((d) => ({
			label: d.label,
			raw: parsedSubtests()()[d.key]?.raw ?? "-",
			wert: parsedSubtests()()[d.key]?.wert ?? "-"
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
						$$renderer.push(`<p class="text-3xl font-bold">${escape_html(r()?.totalWert ?? "-")}</p>`);
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
								$$renderer.push(`<!---->${escape_html(r()?.iqCategory ?? "-")}`);
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
//# sourceMappingURL=_page.svelte-3xZR4uVJ.js.map
