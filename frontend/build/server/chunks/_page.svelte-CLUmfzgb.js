import { $ as head, a1 as escape_html, _ as derived, ae as ensure_array_like } from './dev-Ye9HvMQi.js';
import { C as Card, b as Card_header, c as Card_title, a as Card_content } from './card-D43ruB05.js';
import { B as Badge } from './badge-DyWNom1p.js';
import './utils2-BzHbLXAp.js';
import './index-DpfMhswA.js';

//#region src/routes/(student)/student-cfit/result/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data } = $$props;
		let r = derived(() => data.result);
		let subtestScores = derived(() => [
			{
				label: "Subtes 1",
				value: r()?.sub1Score ?? 0
			},
			{
				label: "Subtes 2",
				value: r()?.sub2Score ?? 0
			},
			{
				label: "Subtes 3",
				value: r()?.sub3Score ?? 0
			},
			{
				label: "Subtes 4",
				value: r()?.sub4Score ?? 0
			}
		]);
		head("aenkd0", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Hasil IQ CFIT</title>`);
			});
		});
		$$renderer.push(`<div class="flex max-w-2xl flex-col gap-6"><div><h2 class="text-2xl font-bold">Hasil Tes IQ CFIT</h2> <p class="text-muted-foreground mt-1 text-sm">${escape_html(r()?.studentName)} · ${escape_html(r()?.schoolName ?? "-")}</p></div> <div class="grid gap-4 sm:grid-cols-3">`);
		Card($$renderer, {
			children: ($$renderer) => {
				Card_header($$renderer, {
					children: ($$renderer) => {
						Card_title($$renderer, {
							class: "text-sm font-medium text-muted-foreground",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Skor Total (RS)`);
							},
							$$slots: { default: true }
						});
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!----> `);
				Card_content($$renderer, {
					children: ($$renderer) => {
						$$renderer.push(`<p class="text-3xl font-bold">${escape_html(r()?.totalScore ?? "-")}</p>`);
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
						$$renderer.push(`<table class="w-full text-sm"><thead><tr class="border-border border-b text-left"><th class="pb-3 font-medium">Subtes</th><th class="pb-3 font-medium">Skor</th></tr></thead><tbody><!--[-->`);
						const each_array = ensure_array_like(subtestScores());
						for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
							let s = each_array[$$index];
							$$renderer.push(`<tr class="border-border border-b last:border-0"><td class="py-3">${escape_html(s.label)}</td><td class="py-3 font-medium">${escape_html(s.value)}</td></tr>`);
						}
						$$renderer.push(`<!--]--></tbody></table>`);
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!---->`);
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----> `);
		if (r()?.description) {
			$$renderer.push("<!--[0-->");
			Card($$renderer, {
				children: ($$renderer) => {
					Card_header($$renderer, {
						children: ($$renderer) => {
							Card_title($$renderer, {
								class: "text-base",
								children: ($$renderer) => {
									$$renderer.push(`<!---->Deskripsi`);
								},
								$$slots: { default: true }
							});
						},
						$$slots: { default: true }
					});
					$$renderer.push(`<!----> `);
					Card_content($$renderer, {
						children: ($$renderer) => {
							$$renderer.push(`<p class="text-muted-foreground text-sm leading-relaxed">${escape_html(r().description)}</p>`);
						},
						$$slots: { default: true }
					});
					$$renderer.push(`<!---->`);
				},
				$$slots: { default: true }
			});
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> <a href="/student-dashboard" class="text-primary text-sm hover:underline">← Kembali ke Dashboard</a></div>`);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-CLUmfzgb.js.map
