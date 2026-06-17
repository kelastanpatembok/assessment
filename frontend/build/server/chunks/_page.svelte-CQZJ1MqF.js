import { $ as head, a1 as escape_html, _ as derived, ae as ensure_array_like, af as attr_class, aq as stringify, ar as attr_style } from './dev-Ye9HvMQi.js';
import { C as Card, b as Card_header, c as Card_title, d as Card_description, a as Card_content } from './card-D43ruB05.js';
import { B as Badge } from './badge-DyWNom1p.js';
import './utils2-BzHbLXAp.js';
import './index-DpfMhswA.js';

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
				value: r()?.dmost ?? 0
			},
			{
				label: "I",
				value: r()?.imost ?? 0
			},
			{
				label: "S",
				value: r()?.smost ?? 0
			},
			{
				label: "C",
				value: r()?.cmost ?? 0
			}
		]);
		let leastScores = derived(() => [
			{
				label: "D",
				value: r()?.dleast ?? 0
			},
			{
				label: "I",
				value: r()?.ileast ?? 0
			},
			{
				label: "S",
				value: r()?.sleast ?? 0
			},
			{
				label: "C",
				value: r()?.cleast ?? 0
			}
		]);
		let difScores = derived(() => [
			{
				label: "D",
				value: r()?.ddif ?? 0
			},
			{
				label: "I",
				value: r()?.idif ?? 0
			},
			{
				label: "S",
				value: r()?.sdif ?? 0
			},
			{
				label: "C",
				value: r()?.cdif ?? 0
			}
		]);
		let maxMost = derived(() => Math.max(...mostScores().map((s) => s.value), 1));
		let maxLeast = derived(() => Math.max(...leastScores().map((s) => s.value), 1));
		let maxDif = derived(() => Math.max(...difScores().map((s) => Math.abs(s.value)), 1));
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
		if (r()?.profileTitle) {
			$$renderer.push("<!--[0-->");
			Card($$renderer, {
				children: ($$renderer) => {
					Card_header($$renderer, {
						children: ($$renderer) => {
							$$renderer.push(`<div class="flex items-start justify-between gap-2">`);
							Card_title($$renderer, {
								children: ($$renderer) => {
									$$renderer.push(`<!---->${escape_html(r().profileTitle)}`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> `);
							Badge($$renderer, {
								variant: "outline",
								children: ($$renderer) => {
									$$renderer.push(`<!---->DISC`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----></div> `);
							Card_description($$renderer, {
								class: "mt-2 text-sm leading-relaxed",
								children: ($$renderer) => {
									$$renderer.push(`<!---->${escape_html(r().profileDesc ?? "")}`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!---->`);
						},
						$$slots: { default: true }
					});
				},
				$$slots: { default: true }
			});
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> <div class="grid gap-4 sm:grid-cols-3">`);
		Card($$renderer, {
			children: ($$renderer) => {
				Card_header($$renderer, {
					children: ($$renderer) => {
						Card_title($$renderer, {
							class: "text-sm",
							children: ($$renderer) => {
								$$renderer.push(`<!---->MOST (Paling Tepat)`);
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
							$$renderer.push(`<div><div class="mb-1 flex justify-between text-xs"><span class="font-medium">${escape_html(s.label)}</span> <span class="text-muted-foreground">${escape_html(s.value)}</span></div> <div class="bg-muted h-2 w-full overflow-hidden rounded-full"><div${attr_class(`h-full rounded-full ${stringify(dimColors[s.label] ?? "bg-primary")}`)}${attr_style(`width: ${stringify(barWidth(s.value, maxMost()))}%`)}></div></div></div>`);
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
							class: "text-sm",
							children: ($$renderer) => {
								$$renderer.push(`<!---->LEAST (Paling Tidak Tepat)`);
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
							$$renderer.push(`<div><div class="mb-1 flex justify-between text-xs"><span class="font-medium">${escape_html(s.label)}</span> <span class="text-muted-foreground">${escape_html(s.value)}</span></div> <div class="bg-muted h-2 w-full overflow-hidden rounded-full"><div${attr_class(`h-full rounded-full ${stringify(dimColors[s.label] ?? "bg-primary")}`)}${attr_style(`width: ${stringify(barWidth(s.value, maxLeast()))}%`)}></div></div></div>`);
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
							class: "text-sm",
							children: ($$renderer) => {
								$$renderer.push(`<!---->DIF (Selisih)`);
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
						const each_array_2 = ensure_array_like(difScores());
						for (let $$index_2 = 0, $$length = each_array_2.length; $$index_2 < $$length; $$index_2++) {
							let s = each_array_2[$$index_2];
							$$renderer.push(`<div><div class="mb-1 flex justify-between text-xs"><span class="font-medium">${escape_html(s.label)}</span> <span class="text-muted-foreground">${escape_html(s.value)}</span></div> <div class="bg-muted h-2 w-full overflow-hidden rounded-full"><div${attr_class(`h-full rounded-full ${stringify(s.value >= 0 ? dimColors[s.label] ?? "bg-primary" : "bg-gray-400")}`)}${attr_style(`width: ${stringify(barWidth(Math.abs(s.value), maxDif()))}%`)}></div></div></div>`);
						}
						$$renderer.push(`<!--]--></div>`);
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!---->`);
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----></div> <div class="flex gap-3"><a href="/student-dashboard" class="text-primary text-sm hover:underline">← Kembali ke Dashboard</a></div></div>`);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-CQZJ1MqF.js.map
