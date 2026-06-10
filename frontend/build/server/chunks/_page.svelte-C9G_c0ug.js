import { ab as head, ad as escape_html, a5 as derived, ae as ensure_array_like, af as attr_class, aq as stringify, ar as attr_style } from './dev-DBdtSqNh.js';
import { C as Card, b as Card_header, c as Card_title, f as Card_description, a as Card_content } from './card-D-P3c-kH.js';
import { B as Badge } from './badge-DkcqB8h9.js';
import './index-jeR0PSLo.js';

//#region src/routes/(student)/student-disc/result/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data } = $$props;
		let r = derived(() => data.result);
		function barWidth(value, max) {
			return max > 0 ? Math.round(value / max * 100) : 0;
		}
		let mostScores = derived(() => [
			{
				label: "D",
				value: r()?.dMost ?? 0
			},
			{
				label: "I",
				value: r()?.iMost ?? 0
			},
			{
				label: "S",
				value: r()?.sMost ?? 0
			},
			{
				label: "C",
				value: r()?.cMost ?? 0
			}
		]);
		let leastScores = derived(() => [
			{
				label: "D",
				value: r()?.dLeast ?? 0
			},
			{
				label: "I",
				value: r()?.iLeast ?? 0
			},
			{
				label: "S",
				value: r()?.sLeast ?? 0
			},
			{
				label: "C",
				value: r()?.cLeast ?? 0
			}
		]);
		let maxMost = derived(() => Math.max(...mostScores().map((s) => s.value), 1));
		let maxLeast = derived(() => Math.max(...leastScores().map((s) => s.value), 1));
		const dimColors = {
			D: "bg-red-500",
			I: "bg-yellow-500",
			S: "bg-green-500",
			C: "bg-blue-500"
		};
		head("dxxuyn", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Hasil DISC</title>`);
			});
		});
		$$renderer.push(`<div class="flex max-w-2xl flex-col gap-6"><div><h2 class="text-2xl font-bold">Hasil Tes DISC</h2> <p class="text-muted-foreground mt-1 text-sm">${escape_html(r()?.studentName)} · ${escape_html(r()?.schoolName ?? "-")}</p></div> `);
		if (r()?.profile) {
			$$renderer.push("<!--[0-->");
			Card($$renderer, {
				children: ($$renderer) => {
					Card_header($$renderer, {
						children: ($$renderer) => {
							$$renderer.push(`<div class="flex items-start justify-between gap-2">`);
							Card_title($$renderer, {
								children: ($$renderer) => {
									$$renderer.push(`<!---->${escape_html(r().profile.typeKey)}`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> `);
							Badge($$renderer, {
								children: ($$renderer) => {
									$$renderer.push(`<!---->${escape_html(r().profile.traits ?? "")}`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----></div> `);
							Card_description($$renderer, {
								class: "mt-2 text-sm leading-relaxed",
								children: ($$renderer) => {
									$$renderer.push(`<!---->${escape_html(r().profile.description ?? "")}`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!---->`);
						},
						$$slots: { default: true }
					});
					$$renderer.push(`<!----> `);
					if (r().profile.jobRecommendations) {
						$$renderer.push("<!--[0-->");
						Card_content($$renderer, {
							children: ($$renderer) => {
								$$renderer.push(`<p class="text-sm font-medium">Rekomendasi Karier:</p> <p class="text-muted-foreground mt-1 text-sm">${escape_html(r().profile.jobRecommendations)}</p>`);
							},
							$$slots: { default: true }
						});
					} else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]-->`);
				},
				$$slots: { default: true }
			});
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> <div class="grid gap-4 sm:grid-cols-2">`);
		Card($$renderer, {
			children: ($$renderer) => {
				Card_header($$renderer, {
					children: ($$renderer) => {
						Card_title($$renderer, {
							class: "text-base",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Profil MOST (Paling Tepat)`);
							},
							$$slots: { default: true }
						});
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!----> `);
				Card_content($$renderer, {
					children: ($$renderer) => {
						$$renderer.push(`<div class="flex flex-col gap-3"><!--[-->`);
						const each_array = ensure_array_like(mostScores());
						for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
							let s = each_array[$$index];
							$$renderer.push(`<div><div class="mb-1 flex justify-between text-sm"><span class="font-medium">${escape_html(s.label)}</span> <span class="text-muted-foreground">${escape_html(s.value)}</span></div> <div class="bg-muted h-3 w-full overflow-hidden rounded-full"><div${attr_class(`h-full rounded-full transition-all ${stringify(dimColors[s.label] ?? "bg-primary")}`)}${attr_style(`width: ${stringify(barWidth(s.value, maxMost()))}%`)}></div></div></div>`);
						}
						$$renderer.push(`<!--]--></div>`);
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
							class: "text-base",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Profil LEAST (Paling Tidak Tepat)`);
							},
							$$slots: { default: true }
						});
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!----> `);
				Card_content($$renderer, {
					children: ($$renderer) => {
						$$renderer.push(`<div class="flex flex-col gap-3"><!--[-->`);
						const each_array_1 = ensure_array_like(leastScores());
						for (let $$index_1 = 0, $$length = each_array_1.length; $$index_1 < $$length; $$index_1++) {
							let s = each_array_1[$$index_1];
							$$renderer.push(`<div><div class="mb-1 flex justify-between text-sm"><span class="font-medium">${escape_html(s.label)}</span> <span class="text-muted-foreground">${escape_html(s.value)}</span></div> <div class="bg-muted h-3 w-full overflow-hidden rounded-full"><div${attr_class(`h-full rounded-full transition-all ${stringify(dimColors[s.label] ?? "bg-primary")}`)}${attr_style(`width: ${stringify(barWidth(s.value, maxLeast()))}%`)}></div></div></div>`);
						}
						$$renderer.push(`<!--]--></div>`);
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!---->`);
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----></div> <a href="/student-dashboard" class="text-primary text-sm hover:underline">← Kembali ke Dashboard</a></div>`);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-C9G_c0ug.js.map
