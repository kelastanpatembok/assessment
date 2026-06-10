import { ab as head, ad as escape_html } from './dev-DBdtSqNh.js';
import './client-BH3cxpaA.js';
import { C as Card, b as Card_header, c as Card_title, f as Card_description, a as Card_content } from './card-D-P3c-kH.js';
import { B as Button } from './button-axqvSO5n.js';
import { L as Label, I as Input } from './label-D2KfWwLz.js';
import './internal2-BaeAYGUQ.js';
import './index-DBqjc0Yf.js';
import './index-jeR0PSLo.js';

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
							for: "price",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Harga Per Siswa (Rp)`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Input($$renderer, {
							id: "price",
							name: "price",
							type: "number",
							value: data.config?.price ?? 0,
							min: "0"
						});
						$$renderer.push(`<!----></div> <div class="flex flex-col gap-2">`);
						Label($$renderer, {
							for: "systemPct",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Persentase Sistem (%)`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Input($$renderer, {
							id: "systemPct",
							name: "systemPct",
							type: "number",
							value: data.config?.systemPct ?? 0,
							min: "0",
							max: "100",
							step: "0.01"
						});
						$$renderer.push(`<!----></div> <div class="flex flex-col gap-2">`);
						Label($$renderer, {
							for: "affiliatorPct",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Persentase Afiliator (%)`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Input($$renderer, {
							id: "affiliatorPct",
							name: "affiliatorPct",
							type: "number",
							value: data.config?.affiliatorPct ?? 0,
							min: "0",
							max: "100",
							step: "0.01"
						});
						$$renderer.push(`<!----></div> <div class="flex flex-col gap-2">`);
						Label($$renderer, {
							for: "counselorPct",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Persentase Guru BK (%)`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Input($$renderer, {
							id: "counselorPct",
							name: "counselorPct",
							type: "number",
							value: data.config?.counselorPct ?? 0,
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
//# sourceMappingURL=_page.svelte-BEE-d38g.js.map
