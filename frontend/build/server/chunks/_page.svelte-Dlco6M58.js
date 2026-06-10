import { ab as head, ad as escape_html, ae as ensure_array_like, a5 as derived, ac as attr } from './dev-DBdtSqNh.js';
import './client-BH3cxpaA.js';
import { C as Card, a as Card_content, b as Card_header, c as Card_title } from './card-D-P3c-kH.js';
import { B as Button } from './button-axqvSO5n.js';
import './internal2-BaeAYGUQ.js';
import './index-DBqjc0Yf.js';
import './index-jeR0PSLo.js';

//#region src/routes/(student)/student-holland/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data, form } = $$props;
		let loading = false;
		let questions = derived(() => data.questions ?? []);
		function statementsOf(q) {
			return [
				1,
				2,
				3,
				4,
				5,
				6,
				7,
				8,
				9,
				10,
				11
			].map((i) => {
				const text = q[`statement${i}`];
				return text ? {
					key: `${q.questionType.toLowerCase()}_${i}`,
					text
				} : null;
			}).filter(Boolean);
		}
		head("1b1lv1i", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Tes Holland RIASEC</title>`);
			});
		});
		$$renderer.push(`<div class="flex max-w-3xl flex-col gap-6"><div><h2 class="text-2xl font-bold">Tes Holland RIASEC</h2> <p class="text-muted-foreground mt-1 text-sm">Nilai setiap pernyataan dari 1 (Sangat Tidak Suka) hingga 5 (Sangat Suka).</p></div> `);
		if (data.unavailable) {
			$$renderer.push("<!--[0-->");
			Card($$renderer, {
				children: ($$renderer) => {
					Card_content($$renderer, {
						class: "pt-6",
						children: ($$renderer) => {
							$$renderer.push(`<p class="text-muted-foreground">Tes Holland belum tersedia atau sudah Anda selesaikan.</p> <a href="/student-dashboard" class="text-primary mt-4 block text-sm hover:underline">Kembali ke Dashboard</a>`);
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
			$$renderer.push(`<form method="POST" class="flex flex-col gap-6"><!--[-->`);
			const each_array = ensure_array_like(questions());
			for (let $$index_2 = 0, $$length = each_array.length; $$index_2 < $$length; $$index_2++) {
				let q = each_array[$$index_2];
				Card($$renderer, {
					children: ($$renderer) => {
						Card_header($$renderer, {
							children: ($$renderer) => {
								Card_title($$renderer, {
									class: "text-base",
									children: ($$renderer) => {
										$$renderer.push(`<!---->Kelompok ${escape_html(q.questionType)}`);
									},
									$$slots: { default: true }
								});
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Card_content($$renderer, {
							children: ($$renderer) => {
								$$renderer.push(`<div class="flex flex-col gap-4"><!--[-->`);
								const each_array_1 = ensure_array_like(statementsOf(q));
								for (let $$index_1 = 0, $$length = each_array_1.length; $$index_1 < $$length; $$index_1++) {
									let stmt = each_array_1[$$index_1];
									$$renderer.push(`<div><p class="mb-2 text-sm">${escape_html(stmt.text)}</p> <div class="flex gap-4"><!--[-->`);
									const each_array_2 = ensure_array_like([
										1,
										2,
										3,
										4,
										5
									]);
									for (let $$index = 0, $$length = each_array_2.length; $$index < $$length; $$index++) {
										let val = each_array_2[$$index];
										$$renderer.push(`<label class="flex cursor-pointer flex-col items-center gap-1"><input type="radio"${attr("name", stmt.key)}${attr("value", val)} class="size-4" required=""/> <span class="text-muted-foreground text-xs">${escape_html(val)}</span></label>`);
									}
									$$renderer.push(`<!--]--></div></div>`);
								}
								$$renderer.push(`<!--]--></div>`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!---->`);
					},
					$$slots: { default: true }
				});
			}
			$$renderer.push(`<!--]--> `);
			Button($$renderer, {
				type: "submit",
				class: "self-end",
				disabled: loading,
				children: ($$renderer) => {
					$$renderer.push(`<!---->${escape_html("Kirim Jawaban")}`);
				},
				$$slots: { default: true }
			});
			$$renderer.push(`<!----></form>`);
		}
		$$renderer.push(`<!--]--></div>`);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-Dlco6M58.js.map
