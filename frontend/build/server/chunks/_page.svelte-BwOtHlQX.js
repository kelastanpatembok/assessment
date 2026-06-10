import { ab as head, ad as escape_html, ae as ensure_array_like, af as attr_class, aj as clsx$1, a5 as derived, ac as attr, aq as stringify } from './dev-DBdtSqNh.js';
import './client-BH3cxpaA.js';
import { C as Card, a as Card_content, b as Card_header, c as Card_title } from './card-D-P3c-kH.js';
import { B as Button } from './button-axqvSO5n.js';
import './internal2-BaeAYGUQ.js';
import './index-DBqjc0Yf.js';
import './index-jeR0PSLo.js';

//#region src/routes/(student)/student-disc/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data, form } = $$props;
		let loading = false;
		let currentBlock = 0;
		let questions = derived(() => data.questions ?? []);
		let totalBlocks = derived(() => questions().length);
		function optionsOf(q) {
			return [
				{
					label: q.optionA,
					mostKey: q.keyMostA,
					leastKey: q.keyLeastA,
					opt: "a"
				},
				{
					label: q.optionB,
					mostKey: q.keyMostB,
					leastKey: q.keyLeastB,
					opt: "b"
				},
				{
					label: q.optionC,
					mostKey: q.keyMostC,
					leastKey: q.keyLeastC,
					opt: "c"
				},
				{
					label: q.optionD,
					mostKey: q.keyMostD,
					leastKey: q.keyLeastD,
					opt: "d"
				}
			];
		}
		head("m82pld", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Tes DISC</title>`);
			});
		});
		$$renderer.push(`<div class="flex max-w-2xl flex-col gap-6"><div><h2 class="text-2xl font-bold">Tes DISC</h2> <p class="text-muted-foreground mt-1 text-sm">Pilih satu pernyataan yang PALING menggambarkan Anda dan satu yang PALING TIDAK menggambarkan Anda.</p></div> `);
		if (data.unavailable) {
			$$renderer.push("<!--[0-->");
			Card($$renderer, {
				children: ($$renderer) => {
					Card_content($$renderer, {
						class: "pt-6",
						children: ($$renderer) => {
							$$renderer.push(`<p class="text-muted-foreground">Tes DISC belum tersedia atau sudah Anda selesaikan.</p> <a href="/student-dashboard" class="text-primary mt-4 block text-sm hover:underline">Kembali ke Dashboard</a>`);
						},
						$$slots: { default: true }
					});
				},
				$$slots: { default: true }
			});
		} else if (form?.error) {
			$$renderer.push("<!--[1-->");
			$$renderer.push(`<div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">${escape_html(form.error)}</div>`);
		} else if (questions().length === 0) {
			$$renderer.push("<!--[2-->");
			Card($$renderer, {
				children: ($$renderer) => {
					Card_content($$renderer, {
						class: "pt-6",
						children: ($$renderer) => {
							$$renderer.push(`<p class="text-muted-foreground">Tidak ada soal tersedia.</p>`);
						},
						$$slots: { default: true }
					});
				},
				$$slots: { default: true }
			});
		} else {
			$$renderer.push("<!--[-1-->");
			$$renderer.push(`<form method="POST"><!--[-->`);
			const each_array = ensure_array_like(questions());
			for (let i = 0, $$length = each_array.length; i < $$length; i++) {
				let q = each_array[i];
				$$renderer.push(`<div${attr_class(clsx$1(i === currentBlock ? "block" : "hidden"))}>`);
				Card($$renderer, {
					children: ($$renderer) => {
						Card_header($$renderer, {
							children: ($$renderer) => {
								Card_title($$renderer, {
									class: "text-base",
									children: ($$renderer) => {
										$$renderer.push(`<!---->Kelompok ${escape_html(i + 1)} dari ${escape_html(totalBlocks())}`);
									},
									$$slots: { default: true }
								});
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Card_content($$renderer, {
							children: ($$renderer) => {
								$$renderer.push(`<div class="mb-3 grid grid-cols-[1fr_auto_auto] gap-x-6 text-xs font-medium text-center"><span></span> <span class="text-primary w-20">Paling Tepat</span> <span class="text-muted-foreground w-24">Paling Tidak Tepat</span></div> <!--[-->`);
								const each_array_1 = ensure_array_like(optionsOf(q));
								for (let $$index = 0, $$length = each_array_1.length; $$index < $$length; $$index++) {
									let row = each_array_1[$$index];
									$$renderer.push(`<div class="grid grid-cols-[1fr_auto_auto] items-center gap-x-6 border-b py-3 last:border-0"><span class="text-sm">${escape_html(row.label)}</span> <div class="flex w-20 justify-center"><input type="radio"${attr("name", `q${stringify(q.id)}M`)}${attr("value", row.mostKey)} class="size-4 cursor-pointer" required=""/></div> <div class="flex w-24 justify-center"><input type="radio"${attr("name", `q${stringify(q.id)}L`)}${attr("value", row.leastKey)} class="size-4 cursor-pointer" required=""/></div></div>`);
								}
								$$renderer.push(`<!--]-->`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!---->`);
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!----></div>`);
			}
			$$renderer.push(`<!--]--> <div class="mt-4 flex items-center justify-between">`);
			Button($$renderer, {
				type: "button",
				variant: "outline",
				disabled: currentBlock === 0,
				onclick: () => currentBlock = Math.max(0, currentBlock - 1),
				children: ($$renderer) => {
					$$renderer.push(`<!---->Sebelumnya`);
				},
				$$slots: { default: true }
			});
			$$renderer.push(`<!----> <span class="text-muted-foreground text-sm">${escape_html(currentBlock + 1)} / ${escape_html(totalBlocks())}</span> `);
			if (currentBlock < totalBlocks() - 1) {
				$$renderer.push("<!--[0-->");
				Button($$renderer, {
					type: "button",
					onclick: () => currentBlock = Math.min(totalBlocks() - 1, currentBlock + 1),
					children: ($$renderer) => {
						$$renderer.push(`<!---->Selanjutnya`);
					},
					$$slots: { default: true }
				});
			} else {
				$$renderer.push("<!--[-1-->");
				Button($$renderer, {
					type: "submit",
					disabled: loading,
					children: ($$renderer) => {
						$$renderer.push(`<!---->${escape_html("Kirim Jawaban")}`);
					},
					$$slots: { default: true }
				});
			}
			$$renderer.push(`<!--]--></div></form>`);
		}
		$$renderer.push(`<!--]--></div>`);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-BwOtHlQX.js.map
