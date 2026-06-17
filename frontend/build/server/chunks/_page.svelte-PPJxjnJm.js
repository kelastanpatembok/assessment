import { $ as head, a1 as escape_html, a0 as attr, ae as ensure_array_like, af as attr_class, aj as clsx$1, _ as derived, aq as stringify } from './dev-Ye9HvMQi.js';
import './client-59jucBkC.js';
import { C as Card, a as Card_content, b as Card_header, c as Card_title } from './card-D43ruB05.js';
import { B as Button } from './button-Cw17vFE1.js';
import './index-server-DVlmzpyW.js';
import './internal2-DrRkwNAm.js';
import './index-DBqjc0Yf.js';
import './utils2-BzHbLXAp.js';
import './index-DpfMhswA.js';

//#region src/routes/(student)/student-disc/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data, form } = $$props;
		let loading = false;
		let currentBlock = 0;
		let allQuestions = derived(() => data.questions ?? []);
		let blocks = derived(() => Object.values(allQuestions().reduce((acc, q) => {
			(acc[q.blockNo] ??= []).push(q);
			return acc;
		}, {})).sort((a, b) => a[0].blockNo - b[0].blockNo));
		let totalBlocks = derived(() => blocks().length);
		let selections = {};
		head("m82pld", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Tes DISC</title>`);
			});
		});
		$$renderer.push(`<div class="flex max-w-2xl flex-col gap-6"><div><h2 class="text-2xl font-bold">Tes DISC</h2> <p class="text-muted-foreground mt-1 text-sm">Pilih satu pernyataan yang PALING menggambarkan Anda (✓) dan satu yang PALING TIDAK menggambarkan Anda (✗).</p></div> `);
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
		} else if (blocks().length === 0) {
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
			$$renderer.push(`<form method="POST"><input type="hidden" name="assignmentId"${attr("value", data.assignmentId ?? 0)}/> <!--[-->`);
			const each_array = ensure_array_like(blocks());
			for (let bi = 0, $$length = each_array.length; bi < $$length; bi++) {
				let stmts = each_array[bi];
				const blockNo = stmts[0].blockNo;
				$$renderer.push(`<div${attr_class(clsx$1(bi === currentBlock ? "block" : "hidden"))}>`);
				Card($$renderer, {
					children: ($$renderer) => {
						Card_header($$renderer, {
							children: ($$renderer) => {
								Card_title($$renderer, {
									class: "text-base",
									children: ($$renderer) => {
										$$renderer.push(`<!---->Kelompok ${escape_html(bi + 1)} dari ${escape_html(totalBlocks())}`);
									},
									$$slots: { default: true }
								});
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Card_content($$renderer, {
							children: ($$renderer) => {
								$$renderer.push(`<div class="mb-2 grid grid-cols-[1fr_auto_auto] gap-x-4 text-xs font-semibold text-center"><span>Pernyataan</span> <span class="text-primary w-24">Paling Tepat</span> <span class="text-muted-foreground w-28">Paling Tidak Tepat</span></div> <!--[-->`);
								const each_array_1 = ensure_array_like(stmts);
								for (let $$index = 0, $$length = each_array_1.length; $$index < $$length; $$index++) {
									let q = each_array_1[$$index];
									$$renderer.push(`<div class="grid grid-cols-[1fr_auto_auto] items-center gap-x-4 border-b py-3 last:border-0"><span class="text-sm">${escape_html(q.statement)}</span> <div class="flex w-24 justify-center"><input type="radio"${attr("name", `b${stringify(blockNo)}_most`)}${attr("value", q.itemNo)}${attr("checked", selections[blockNo]?.most === q.itemNo, true)} class="size-4 cursor-pointer accent-green-600"/></div> <div class="flex w-28 justify-center"><input type="radio"${attr("name", `b${stringify(blockNo)}_least`)}${attr("value", q.itemNo)}${attr("checked", selections[blockNo]?.least === q.itemNo, true)} class="size-4 cursor-pointer accent-red-500"/></div></div>`);
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
//# sourceMappingURL=_page.svelte-PPJxjnJm.js.map
