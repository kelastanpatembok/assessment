import { $ as head, a1 as escape_html, ae as ensure_array_like, af as attr_class, a0 as attr, aj as clsx$1, _ as derived, aq as stringify } from './dev-Ye9HvMQi.js';
import './client-59jucBkC.js';
import { C as Card, a as Card_content, b as Card_header, c as Card_title } from './card-D43ruB05.js';
import { B as Button } from './button-Cw17vFE1.js';
import './index-server-DVlmzpyW.js';
import './internal2-DrRkwNAm.js';
import './index-DBqjc0Yf.js';
import './utils2-BzHbLXAp.js';
import './index-DpfMhswA.js';

//#region src/routes/(student)/student-cfit/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data, form } = $$props;
		let loading = false;
		let activeSubtest = 0;
		let subtests = derived(() => data.subtests ?? []);
		let total = derived(() => subtests().length);
		function optionEntries(q) {
			if (!q.options) return [];
			return Object.entries(q.options);
		}
		head("t81u8m", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Tes IQ CFIT</title>`);
			});
		});
		$$renderer.push(`<div class="flex max-w-3xl flex-col gap-6"><div><h2 class="text-2xl font-bold">Tes IQ CFIT</h2> <p class="text-muted-foreground mt-1 text-sm">Jawab setiap soal dengan memilih jawaban yang paling tepat.</p></div> `);
		if (data.unavailable) {
			$$renderer.push("<!--[0-->");
			Card($$renderer, {
				children: ($$renderer) => {
					Card_content($$renderer, {
						class: "pt-6",
						children: ($$renderer) => {
							$$renderer.push(`<p class="text-muted-foreground">Tes CFIT belum tersedia atau sudah Anda selesaikan.</p> <a href="/student-dashboard" class="text-primary mt-4 block text-sm hover:underline">Kembali ke Dashboard</a>`);
						},
						$$slots: { default: true }
					});
				},
				$$slots: { default: true }
			});
		} else if (form?.error) {
			$$renderer.push("<!--[1-->");
			$$renderer.push(`<div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">${escape_html(form.error)}</div>`);
		} else if (subtests().length === 0) {
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
			$$renderer.push(`<div class="flex gap-2"><!--[-->`);
			const each_array = ensure_array_like(subtests());
			for (let i = 0, $$length = each_array.length; i < $$length; i++) {
				let st = each_array[i];
				$$renderer.push(`<button type="button"${attr_class(`rounded-lg px-4 py-2 text-sm transition-colors ${activeSubtest === i ? "bg-primary text-primary-foreground" : "bg-secondary text-secondary-foreground hover:bg-secondary/80"}`)}>${escape_html(st.label)}</button>`);
			}
			$$renderer.push(`<!--]--></div> <form method="POST" class="flex flex-col gap-4"><input type="hidden" name="assignmentId"${attr("value", data.assignmentId ?? 0)}/> <!--[-->`);
			const each_array_1 = ensure_array_like(subtests());
			for (let si = 0, $$length = each_array_1.length; si < $$length; si++) {
				let st = each_array_1[si];
				$$renderer.push(`<div${attr_class(clsx$1(si === activeSubtest ? "flex flex-col gap-4" : "hidden"))}><!--[-->`);
				const each_array_2 = ensure_array_like(st.questions);
				for (let qi = 0, $$length = each_array_2.length; qi < $$length; qi++) {
					let q = each_array_2[qi];
					Card($$renderer, {
						children: ($$renderer) => {
							Card_header($$renderer, {
								children: ($$renderer) => {
									Card_title($$renderer, {
										class: "text-sm font-medium",
										children: ($$renderer) => {
											$$renderer.push(`<!---->${escape_html(st.label)} — Soal ${escape_html(qi + 1)}`);
										},
										$$slots: { default: true }
									});
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> `);
							Card_content($$renderer, {
								children: ($$renderer) => {
									$$renderer.push(`<p class="mb-4 text-sm">${escape_html(q.questionText ?? q.question ?? "")}</p> `);
									if (optionEntries(q).length > 0) {
										$$renderer.push("<!--[0-->");
										$$renderer.push(`<div class="grid grid-cols-2 gap-2 sm:grid-cols-4"><!--[-->`);
										const each_array_3 = ensure_array_like(optionEntries(q));
										for (let $$index_1 = 0, $$length = each_array_3.length; $$index_1 < $$length; $$index_1++) {
											let [optKey, optVal] = each_array_3[$$index_1];
											$$renderer.push(`<label class="hover:bg-accent flex cursor-pointer items-center gap-2 rounded-lg border p-3 text-sm"><input type="radio"${attr("name", `st${stringify(q.subtestNo)}_q${stringify(q.itemNo)}`)}${attr("value", optKey)} class="size-4 shrink-0" required=""/> <span>${escape_html(optKey)}. ${escape_html(optVal)}</span></label>`);
										}
										$$renderer.push(`<!--]--></div>`);
									} else {
										$$renderer.push("<!--[-1-->");
										$$renderer.push(`<input type="text"${attr("name", `st${stringify(q.subtestNo)}_q${stringify(q.itemNo)}`)} placeholder="Jawaban..." class="border-input bg-background flex h-10 w-full max-w-xs rounded-lg border px-3 text-sm" required=""/>`);
									}
									$$renderer.push(`<!--]-->`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!---->`);
						},
						$$slots: { default: true }
					});
				}
				$$renderer.push(`<!--]--></div>`);
			}
			$$renderer.push(`<!--]--> <div class="flex items-center justify-between">`);
			Button($$renderer, {
				type: "button",
				variant: "outline",
				disabled: activeSubtest === 0,
				onclick: () => activeSubtest = Math.max(0, activeSubtest - 1),
				children: ($$renderer) => {
					$$renderer.push(`<!---->Sebelumnya`);
				},
				$$slots: { default: true }
			});
			$$renderer.push(`<!----> `);
			if (activeSubtest < total() - 1) {
				$$renderer.push("<!--[0-->");
				Button($$renderer, {
					type: "button",
					onclick: () => activeSubtest = Math.min(total() - 1, activeSubtest + 1),
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
						$$renderer.push(`<!---->${escape_html("Kirim Semua Jawaban")}`);
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
//# sourceMappingURL=_page.svelte-pNfnF71P.js.map
