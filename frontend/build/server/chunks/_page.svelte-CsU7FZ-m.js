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

//#region src/routes/login/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { form } = $$props;
		let loading = false;
		head("1x05zx6", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Masuk — Assessment</title>`);
			});
		});
		$$renderer.push(`<div class="bg-background flex min-h-screen items-center justify-center px-4"><div class="w-full max-w-sm"><div class="mb-8 text-center"><div class="bg-primary text-primary-foreground mx-auto mb-4 flex size-12 items-center justify-center rounded-xl text-xl font-bold">A</div> <h1 class="text-2xl font-bold">Selamat Datang</h1> <p class="text-muted-foreground mt-1 text-sm">Masuk ke platform asesmen psikometri</p></div> `);
		Card($$renderer, {
			children: ($$renderer) => {
				Card_header($$renderer, {
					children: ($$renderer) => {
						Card_title($$renderer, {
							children: ($$renderer) => {
								$$renderer.push(`<!---->Masuk`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Card_description($$renderer, {
							children: ($$renderer) => {
								$$renderer.push(`<!---->Masukkan username dan password Anda`);
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
						$$renderer.push(`<form method="POST" class="flex flex-col gap-4">`);
						if (form?.error) {
							$$renderer.push("<!--[0-->");
							$$renderer.push(`<div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">${escape_html(form.error)}</div>`);
						} else $$renderer.push("<!--[-1-->");
						$$renderer.push(`<!--]--> <div class="flex flex-col gap-2">`);
						Label($$renderer, {
							for: "username",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Username`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Input($$renderer, {
							id: "username",
							name: "username",
							type: "text",
							placeholder: "Masukkan username",
							autocomplete: "username",
							required: true
						});
						$$renderer.push(`<!----></div> <div class="flex flex-col gap-2">`);
						Label($$renderer, {
							for: "password",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Password`);
							},
							$$slots: { default: true }
						});
						$$renderer.push(`<!----> `);
						Input($$renderer, {
							id: "password",
							name: "password",
							type: "password",
							placeholder: "Masukkan password",
							autocomplete: "current-password",
							required: true
						});
						$$renderer.push(`<!----></div> `);
						Button($$renderer, {
							type: "submit",
							class: "w-full",
							disabled: loading,
							children: ($$renderer) => {
								$$renderer.push(`<!---->${escape_html("Masuk")}`);
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
		$$renderer.push(`<!----></div></div>`);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-CsU7FZ-m.js.map
