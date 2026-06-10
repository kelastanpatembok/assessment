import { ab as head, ad as escape_html, ae as ensure_array_like, af as attr_class, aj as clsx$1, a5 as derived, ac as attr, aq as stringify } from './dev-DBdtSqNh.js';
import './client-BH3cxpaA.js';
import { C as Card, a as Card_content, b as Card_header, c as Card_title } from './card-D-P3c-kH.js';
import { B as Button } from './button-axqvSO5n.js';
import './internal2-BaeAYGUQ.js';
import './index-DBqjc0Yf.js';
import './index-jeR0PSLo.js';

//#region src/routes/(student)/student-ist/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data, form } = $$props;
		let loading = false;
		let activeSubtest = 0;
		let meMemoryShown = false;
		let subtests = derived(() => data.subtests ?? []);
		let total = derived(() => subtests().length);
		function isWU(key) {
			return key === "WU";
		}
		function isZR(key) {
			return key === "ZR";
		}
		function isME(key) {
			return key === "ME";
		}
		function optionEntries(q) {
			if (!q.options) return [];
			return Object.entries(q.options);
		}
		head("1joanfo", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Tes IQ IST</title>`);
			});
		});
		$$renderer.push(`<div class="flex max-w-3xl flex-col gap-6"><div><h2 class="text-2xl font-bold">Tes IQ IST</h2> <p class="text-muted-foreground mt-1 text-sm">Tes kecerdasan 9 subtes. Kerjakan setiap subtes dengan cermat.</p></div> `);
		if (data.unavailable) {
			$$renderer.push("<!--[0-->");
			Card($$renderer, {
				children: ($$renderer) => {
					Card_content($$renderer, {
						class: "pt-6",
						children: ($$renderer) => {
							$$renderer.push(`<p class="text-muted-foreground">Tes IST belum tersedia atau sudah Anda selesaikan.</p> <a href="/student-dashboard" class="text-primary mt-4 block text-sm hover:underline">Kembali ke Dashboard</a>`);
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
			$$renderer.push(`<div class="flex flex-wrap gap-2"><!--[-->`);
			const each_array = ensure_array_like(subtests());
			for (let i = 0, $$length = each_array.length; i < $$length; i++) {
				let st = each_array[i];
				$$renderer.push(`<button type="button"${attr_class(`rounded-lg px-3 py-1.5 text-sm transition-colors ${activeSubtest === i ? "bg-primary text-primary-foreground" : "bg-secondary text-secondary-foreground hover:bg-secondary/80"}`)}>${escape_html(st.key)}</button>`);
			}
			$$renderer.push(`<!--]--></div> <form method="POST" class="flex flex-col gap-4"><!--[-->`);
			const each_array_1 = ensure_array_like(subtests());
			for (let si = 0, $$length = each_array_1.length; si < $$length; si++) {
				let st = each_array_1[si];
				$$renderer.push(`<div${attr_class(clsx$1(si === activeSubtest ? "flex flex-col gap-4" : "hidden"))}>`);
				Card($$renderer, {
					children: ($$renderer) => {
						Card_header($$renderer, {
							children: ($$renderer) => {
								Card_title($$renderer, {
									class: "text-base",
									children: ($$renderer) => {
										$$renderer.push(`<!---->Subtes ${escape_html(st.key)}`);
									},
									$$slots: { default: true }
								});
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Card_content($$renderer, {
							children: ($$renderer) => {
								if (isME(st.key) && !meMemoryShown) {
									$$renderer.push("<!--[0-->");
									$$renderer.push(`<p class="text-muted-foreground mb-4 text-sm font-medium">Hafalkan pasangan kata berikut. Anda akan diminta mengingat pasangannya.</p> <div class="grid grid-cols-2 gap-3"><!--[-->`);
									const each_array_2 = ensure_array_like(st.questions.filter((q) => !q.options));
									for (let $$index_1 = 0, $$length = each_array_2.length; $$index_1 < $$length; $$index_1++) {
										let q = each_array_2[$$index_1];
										$$renderer.push(`<div class="rounded-lg border p-3 text-center text-sm font-medium">${escape_html(q.question)}</div>`);
									}
									$$renderer.push(`<!--]--></div> `);
									Button($$renderer, {
										type: "button",
										class: "mt-4",
										onclick: () => meMemoryShown = true,
										children: ($$renderer) => {
											$$renderer.push(`<!---->Sudah Hafal — Lanjutkan`);
										},
										$$slots: { default: true }
									});
									$$renderer.push(`<!---->`);
								} else {
									$$renderer.push("<!--[-1-->");
									$$renderer.push(`<!--[-->`);
									const each_array_3 = ensure_array_like(st.questions);
									for (let qi = 0, $$length = each_array_3.length; qi < $$length; qi++) {
										let q = each_array_3[qi];
										if (!isME(st.key) || meMemoryShown || q.options) {
											$$renderer.push("<!--[0-->");
											$$renderer.push(`<div${attr_class(`border-border border-b pb-4 last:border-0 last:pb-0 ${qi > 0 ? "pt-4" : ""}`)}><p class="mb-3 text-sm font-medium">${escape_html(qi + 1)}. ${escape_html(q.question)}</p> `);
											if (isWU(st.key)) {
												$$renderer.push("<!--[0-->");
												$$renderer.push(`<div class="flex gap-4"><label class="flex cursor-pointer items-center gap-2 text-sm"><input type="radio"${attr("name", `ist_${stringify(q.id)}`)} value="BENAR" class="size-4" required=""/> Benar</label> <label class="flex cursor-pointer items-center gap-2 text-sm"><input type="radio"${attr("name", `ist_${stringify(q.id)}`)} value="SALAH" class="size-4" required=""/> Salah</label></div>`);
											} else if (isZR(st.key)) {
												$$renderer.push("<!--[1-->");
												$$renderer.push(`<input type="text"${attr("name", `ist_${stringify(q.id)}`)} placeholder="Jawaban Anda..." class="border-input bg-background flex h-10 w-full max-w-xs rounded-lg border px-3 text-sm" required=""/>`);
											} else if (optionEntries(q).length > 0) {
												$$renderer.push("<!--[2-->");
												$$renderer.push(`<div class="grid grid-cols-2 gap-2 sm:grid-cols-5"><!--[-->`);
												const each_array_4 = ensure_array_like(optionEntries(q));
												for (let $$index_2 = 0, $$length = each_array_4.length; $$index_2 < $$length; $$index_2++) {
													let [optKey, optVal] = each_array_4[$$index_2];
													$$renderer.push(`<label class="hover:bg-accent flex cursor-pointer items-center gap-2 rounded-lg border p-2 text-sm"><input type="radio"${attr("name", `ist_${stringify(q.id)}`)}${attr("value", optKey)} class="size-4 shrink-0" required=""/> <span>${escape_html(optKey)}. ${escape_html(optVal)}</span></label>`);
												}
												$$renderer.push(`<!--]--></div>`);
											} else {
												$$renderer.push("<!--[-1-->");
												$$renderer.push(`<input type="text"${attr("name", `ist_${stringify(q.id)}`)} placeholder="Jawaban Anda..." class="border-input bg-background flex h-10 w-full max-w-xs rounded-lg border px-3 text-sm" required=""/>`);
											}
											$$renderer.push(`<!--]--></div>`);
										} else $$renderer.push("<!--[-1-->");
										$$renderer.push(`<!--]-->`);
									}
									$$renderer.push(`<!--]-->`);
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
			$$renderer.push(`<!--]--> <div class="flex items-center justify-between">`);
			Button($$renderer, {
				type: "button",
				variant: "outline",
				disabled: activeSubtest === 0,
				onclick: () => {
					activeSubtest = Math.max(0, activeSubtest - 1);
					meMemoryShown = false;
				},
				children: ($$renderer) => {
					$$renderer.push(`<!---->Sebelumnya`);
				},
				$$slots: { default: true }
			});
			$$renderer.push(`<!----> <span class="text-muted-foreground text-sm">${escape_html(activeSubtest + 1)} / ${escape_html(total())}</span> `);
			if (activeSubtest < total() - 1) {
				$$renderer.push("<!--[0-->");
				Button($$renderer, {
					type: "button",
					onclick: () => {
						activeSubtest = Math.min(total() - 1, activeSubtest + 1);
						meMemoryShown = false;
					},
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
//# sourceMappingURL=_page.svelte-DGg5hWSc.js.map
