import { ab as head, ad as escape_html, ae as ensure_array_like, a5 as derived, af as attr_class, aq as stringify, ar as attr_style } from './dev-DBdtSqNh.js';
import { C as Card, b as Card_header, c as Card_title, a as Card_content } from './card-D-P3c-kH.js';
import { B as Badge } from './badge-DkcqB8h9.js';
import './index-jeR0PSLo.js';

//#region src/routes/(student)/student-holland/result/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data } = $$props;
		let r = derived(() => data.result);
		const dimColors = {
			R: "bg-orange-500",
			I: "bg-blue-500",
			A: "bg-purple-500",
			S: "bg-green-500",
			E: "bg-yellow-500",
			C: "bg-gray-500"
		};
		let dimensions = derived(() => [
			{
				key: "R",
				label: "Realistic",
				value: r()?.totalR ?? 0
			},
			{
				key: "I",
				label: "Investigative",
				value: r()?.totalI ?? 0
			},
			{
				key: "A",
				label: "Artistic",
				value: r()?.totalA ?? 0
			},
			{
				key: "S",
				label: "Social",
				value: r()?.totalS ?? 0
			},
			{
				key: "E",
				label: "Enterprising",
				value: r()?.totalE ?? 0
			},
			{
				key: "C",
				label: "Conventional",
				value: r()?.totalC ?? 0
			}
		].sort((a, b) => b.value - a.value));
		let hollandCode = derived(() => dimensions().slice(0, 3).map((d) => d.key).join(""));
		let maxVal = derived(() => Math.max(...dimensions().map((d) => d.value), 1));
		head("frbhbk", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Hasil Holland RIASEC</title>`);
			});
		});
		$$renderer.push(`<div class="flex max-w-2xl flex-col gap-6"><div><h2 class="text-2xl font-bold">Hasil Tes Holland RIASEC</h2> <p class="text-muted-foreground mt-1 text-sm">${escape_html(r()?.studentName)} · ${escape_html(r()?.schoolName ?? "-")}</p></div> `);
		Card($$renderer, {
			children: ($$renderer) => {
				Card_header($$renderer, {
					children: ($$renderer) => {
						$$renderer.push(`<div class="flex items-center gap-3">`);
						Card_title($$renderer, {
							children: ($$renderer) => {
								$$renderer.push(`<!---->Kode Holland`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Badge($$renderer, {
							class: "text-lg px-3",
							children: ($$renderer) => {
								$$renderer.push(`<!---->${escape_html(hollandCode())}`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----></div>`);
					},
					$$slots: { default: true }
				});
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
								$$renderer.push(`<!---->Skor Per Dimensi`);
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
						const each_array = ensure_array_like(dimensions());
						for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
							let d = each_array[$$index];
							$$renderer.push(`<div><div class="mb-1 flex justify-between text-sm"><span class="font-medium">${escape_html(d.key)} — ${escape_html(d.label)}</span> <span class="text-muted-foreground">${escape_html(d.value)}</span></div> <div class="bg-muted h-3 w-full overflow-hidden rounded-full"><div${attr_class(`h-full rounded-full ${stringify(dimColors[d.key] ?? "bg-primary")}`)}${attr_style(`width: ${stringify(Math.round(d.value / maxVal() * 100))}%`)}></div></div></div>`);
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
		if (r()?.descriptions?.length > 0) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<!--[-->`);
			const each_array_1 = ensure_array_like(r().descriptions);
			for (let $$index_1 = 0, $$length = each_array_1.length; $$index_1 < $$length; $$index_1++) {
				let desc = each_array_1[$$index_1];
				Card($$renderer, {
					children: ($$renderer) => {
						Card_header($$renderer, {
							children: ($$renderer) => {
								Card_title($$renderer, {
									class: "text-base",
									children: ($$renderer) => {
										$$renderer.push(`<!---->${escape_html(desc.type)} — ${escape_html(desc.description?.split(".")[0] ?? "")}`);
									},
									$$slots: { default: true }
								});
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						if (desc.jobMatch) {
							$$renderer.push("<!--[0-->");
							Card_content($$renderer, {
								children: ($$renderer) => {
									$$renderer.push(`<p class="text-sm font-medium">Pekerjaan yang Cocok:</p> <p class="text-muted-foreground mt-1 text-sm">${escape_html(desc.jobMatch)}</p>`);
								},
								$$slots: { default: true }
							});
						} else $$renderer.push("<!--[-1-->");
						$$renderer.push(`<!--]-->`);
					},
					$$slots: { default: true }
				});
			}
			$$renderer.push(`<!--]-->`);
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> <a href="/student-dashboard" class="text-primary text-sm hover:underline">← Kembali ke Dashboard</a></div>`);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-yWa6ieW4.js.map
