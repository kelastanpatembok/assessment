import { ab as head, ad as escape_html, ae as ensure_array_like, af as attr_class, aj as clsx$1, a5 as derived, ac as attr } from './dev-DBdtSqNh.js';
import './client-BH3cxpaA.js';
import { C as Card, a as Card_content, b as Card_header, c as Card_title } from './card-D-P3c-kH.js';
import { B as Button } from './button-axqvSO5n.js';
import './internal2-BaeAYGUQ.js';
import './index-DBqjc0Yf.js';
import './index-jeR0PSLo.js';

//#region src/routes/(student)/student-papi/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data, form } = $$props;
		let loading = false;
		let currentPair = 0;
		let pairs = derived(() => data.pairs ?? []);
		let total = derived(() => pairs().length);
		head("1c4dmfe", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Tes PAPI Kostick</title>`);
			});
		});
		$$renderer.push(`<div class="flex max-w-2xl flex-col gap-6"><div><h2 class="text-2xl font-bold">Tes PAPI Kostick</h2> <p class="text-muted-foreground mt-1 text-sm">Untuk setiap pasang pernyataan, pilih satu yang LEBIH menggambarkan Anda.</p></div> `);
		if (data.unavailable) {
			$$renderer.push("<!--[0-->");
			Card($$renderer, {
				children: ($$renderer) => {
					Card_content($$renderer, {
						class: "pt-6",
						children: ($$renderer) => {
							$$renderer.push(`<p class="text-muted-foreground">Tes PAPI belum tersedia atau sudah Anda selesaikan.</p> <a href="/student-dashboard" class="text-primary mt-4 block text-sm hover:underline">Kembali ke Dashboard</a>`);
						},
						$$slots: { default: true }
					});
				},
				$$slots: { default: true }
			});
		} else if (form?.error) {
			$$renderer.push("<!--[1-->");
			$$renderer.push(`<div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">${escape_html(form.error)}</div>`);
		} else if (pairs().length === 0) {
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
			const each_array = ensure_array_like(pairs());
			for (let i = 0, $$length = each_array.length; i < $$length; i++) {
				let pair = each_array[i];
				$$renderer.push(`<div${attr_class(clsx$1(i === currentPair ? "block" : "hidden"))}>`);
				Card($$renderer, {
					children: ($$renderer) => {
						Card_header($$renderer, {
							children: ($$renderer) => {
								Card_title($$renderer, {
									class: "text-base",
									children: ($$renderer) => {
										$$renderer.push(`<!---->Pertanyaan ${escape_html(i + 1)} dari ${escape_html(total())}`);
									},
									$$slots: { default: true }
								});
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Card_content($$renderer, {
							children: ($$renderer) => {
								$$renderer.push(`<p class="text-muted-foreground mb-4 text-sm">Pilih satu pernyataan yang lebih tepat menggambarkan Anda:</p> <div class="flex flex-col gap-3"><label class="hover:bg-accent flex cursor-pointer items-start gap-3 rounded-lg border p-4 transition-colors"><input type="radio"${attr("name", pair.id)}${attr("value", pair.traitA)} class="mt-0.5 size-4 shrink-0" required=""/> <span class="text-sm">${escape_html(pair.stmtA)}</span></label> <label class="hover:bg-accent flex cursor-pointer items-start gap-3 rounded-lg border p-4 transition-colors"><input type="radio"${attr("name", pair.id)}${attr("value", pair.traitB)} class="mt-0.5 size-4 shrink-0" required=""/> <span class="text-sm">${escape_html(pair.stmtB)}</span></label></div>`);
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
				disabled: currentPair === 0,
				onclick: () => currentPair = Math.max(0, currentPair - 1),
				children: ($$renderer) => {
					$$renderer.push(`<!---->Sebelumnya`);
				},
				$$slots: { default: true }
			});
			$$renderer.push(`<!----> <span class="text-muted-foreground text-sm">${escape_html(currentPair + 1)} / ${escape_html(total())}</span> `);
			if (currentPair < total() - 1) {
				$$renderer.push("<!--[0-->");
				Button($$renderer, {
					type: "button",
					onclick: () => currentPair = Math.min(total() - 1, currentPair + 1),
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
//# sourceMappingURL=_page.svelte-DQg7hOOO.js.map
