import { $ as head, a1 as escape_html } from './dev-Ye9HvMQi.js';
import './client-59jucBkC.js';
import { C as Card, b as Card_header, c as Card_title, d as Card_description, a as Card_content } from './card-D43ruB05.js';
import { B as Button } from './button-Cw17vFE1.js';
import { L as Label, I as Input } from './label-CtBNDRHL.js';
import './index-server-DVlmzpyW.js';
import './internal2-DrRkwNAm.js';
import './index-DBqjc0Yf.js';
import './utils2-BzHbLXAp.js';
import './index-DpfMhswA.js';

//#region src/routes/(admin)/admin-fees/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data, form } = $$props;
		let loading = false;
		head("kbcpkt", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Konfigurasi Biaya</title>`);
			});
		});
		$$renderer.push(`<div class="flex flex-col gap-6"><h2 class="text-2xl font-bold">Konfigurasi Biaya</h2> `);
		Card($$renderer, {
			class: "max-w-lg",
			children: ($$renderer) => {
				Card_header($$renderer, {
					children: ($$renderer) => {
						Card_title($$renderer, {
							children: ($$renderer) => {
								$$renderer.push(`<!---->Pengaturan Biaya &amp; Persentase`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Card_description($$renderer, {
							children: ($$renderer) => {
								$$renderer.push(`<!---->Atur harga tes dan pembagian komisi`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!---->`);
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!----> `);
				Card_content($$renderer, {
					children: ($$renderer) => {
						$$renderer.push(`<form method="POST" action="?/update" class="flex flex-col gap-4"><div class="flex flex-col gap-2">`);
						Label($$renderer, {
							for: "studentFee",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Harga Per Siswa (Rp)`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Input($$renderer, {
							id: "studentFee",
							name: "studentFee",
							type: "number",
							value: data.config?.studentFee ?? 0,
							min: "0"
						});
						$$renderer.push(`<!----></div> <div class="flex flex-col gap-2">`);
						Label($$renderer, {
							for: "platformSharePct",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Persentase Platform (%)`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Input($$renderer, {
							id: "platformSharePct",
							name: "platformSharePct",
							type: "number",
							value: data.config?.platformSharePct ?? 0,
							min: "0",
							max: "100",
							step: "0.01"
						});
						$$renderer.push(`<!----></div> <div class="flex flex-col gap-2">`);
						Label($$renderer, {
							for: "afiliatorSharePct",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Persentase Afiliator (%)`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Input($$renderer, {
							id: "afiliatorSharePct",
							name: "afiliatorSharePct",
							type: "number",
							value: data.config?.afiliatorSharePct ?? 0,
							min: "0",
							max: "100",
							step: "0.01"
						});
						$$renderer.push(`<!----></div> <div class="flex flex-col gap-2">`);
						Label($$renderer, {
							for: "gurubkSharePct",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Persentase Guru BK (%)`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Input($$renderer, {
							id: "gurubkSharePct",
							name: "gurubkSharePct",
							type: "number",
							value: data.config?.gurubkSharePct ?? 0,
							min: "0",
							max: "100",
							step: "0.01"
						});
						$$renderer.push(`<!----></div> `);
						Button($$renderer, {
							type: "submit",
							disabled: loading,
							children: ($$renderer) => {
								$$renderer.push(`<!---->${escape_html("Simpan Konfigurasi")}`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----></form>`);
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!---->`);
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----></div>`);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-DTAC5cBV.js.map
