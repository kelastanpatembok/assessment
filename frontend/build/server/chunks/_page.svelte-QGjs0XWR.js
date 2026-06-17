import { $ as head, a1 as escape_html, _ as derived, ae as ensure_array_like, ar as attr_style, aq as stringify } from './dev-Ye9HvMQi.js';
import { C as Card, b as Card_header, c as Card_title, a as Card_content } from './card-D43ruB05.js';
import './utils2-BzHbLXAp.js';

//#region src/routes/(student)/student-papi/result/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data } = $$props;
		let r = derived(() => data.result);
		const traitNames = {
			G: "Peran kepemimpinan (G)",
			N: "Kebutuhan diakui (N)",
			A: "Keaktifan di atas rata-rata (A)",
			P: "Kebutuhan berprestasi (P)",
			X: "Kebutuhan variasi (X)",
			B: "Kebutuhan memiliki kebebasan (B)",
			O: "Kebutuhan untuk aturan dan supervisi (O)",
			Z: "Kebutuhan perubahan (Z)",
			K: "Kepemimpinan dalam kelompok (K)",
			F: "Keperluan untuk disenangi (F)",
			L: "Keperluan untuk berafiliasi (L)",
			I: "Keperluan untuk bertahan (I)",
			T: "Keperluan untuk berpikir dan bertindak secara mandiri (T)",
			V: "Orientasi pada detail (V)",
			S: "Pengendalian diri (S)",
			R: "Keperluan untuk taat pada aturan (R)",
			D: "Keperluan akan keteraturan (D)",
			E: "Orientasi kerja keras (E)",
			C: "Keperluan untuk berempati (C)",
			W: "Orientasi terhadap kerja (W)"
		};
		const traitOrder = [
			"G",
			"N",
			"A",
			"P",
			"X",
			"B",
			"O",
			"Z",
			"K",
			"F",
			"L",
			"I",
			"T",
			"V",
			"S",
			"R",
			"D",
			"E",
			"C",
			"W"
		];
		let parsedTraits = derived(() => () => {
			if (!r()?.traitScores) return {};
			if (typeof r().traitScores === "object") return r().traitScores;
			try {
				return JSON.parse(r().traitScores);
			} catch {
				return {};
			}
		});
		let scores = derived(() => traitOrder.map((t) => ({
			key: t,
			name: traitNames[t] ?? t,
			value: parsedTraits()()[t] ?? 0
		})));
		let maxScore = derived(() => Math.max(...scores().map((s) => s.value), 1));
		head("o08tiw", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Hasil PAPI Kostick</title>`);
			});
		});
		$$renderer.push(`<div class="flex max-w-2xl flex-col gap-6"><div><h2 class="text-2xl font-bold">Hasil Tes PAPI Kostick</h2> <p class="text-muted-foreground mt-1 text-sm">${escape_html(r()?.studentName)} · ${escape_html(r()?.schoolName ?? "-")}</p></div> `);
		Card($$renderer, {
			children: ($$renderer) => {
				Card_header($$renderer, {
					children: ($$renderer) => {
						Card_title($$renderer, {
							class: "text-base",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Skor Per Trait (20 Dimensi)`);
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
						const each_array = ensure_array_like(scores());
						for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
							let s = each_array[$$index];
							$$renderer.push(`<div><div class="mb-1 flex items-center justify-between text-sm"><span class="font-medium">${escape_html(s.key)}</span> <span class="text-muted-foreground text-xs">${escape_html(s.name.split("(")[0].trim())}: ${escape_html(s.value)}</span></div> <div class="bg-muted h-2.5 w-full overflow-hidden rounded-full"><div class="bg-primary h-full rounded-full"${attr_style(`width: ${stringify(Math.round(s.value / maxScore() * 100))}%`)}></div></div></div>`);
						}
						$$renderer.push(`<!--]--></div>`);
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!---->`);
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----> <a href="/student-dashboard" class="text-primary text-sm hover:underline">← Kembali ke Dashboard</a></div>`);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-QGjs0XWR.js.map
