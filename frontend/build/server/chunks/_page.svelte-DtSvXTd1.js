import { $ as head, ae as ensure_array_like, a1 as escape_html, aq as stringify } from './dev-Ye9HvMQi.js';
import { C as Card, b as Card_header, c as Card_title, d as Card_description, a as Card_content } from './card-D43ruB05.js';
import { B as Button } from './button-Cw17vFE1.js';
import { B as Badge } from './badge-DyWNom1p.js';
import './utils2-BzHbLXAp.js';
import './index-DpfMhswA.js';

//#region src/routes/(student)/student-dashboard/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data } = $$props;
		head("pgotpo", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Dashboard Siswa</title>`);
			});
		});
		$$renderer.push(`<div class="flex flex-col gap-6"><div><h2 class="text-2xl font-bold">Halo, Selamat Datang!</h2> <p class="text-muted-foreground mt-1">Pilih tes yang tersedia di bawah ini untuk memulai.</p></div> <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3"><!--[-->`);
		const each_array = ensure_array_like(data.tests);
		for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
			let test = each_array[$$index];
			Card($$renderer, {
				class: "flex flex-col",
				children: ($$renderer) => {
					Card_header($$renderer, {
						children: ($$renderer) => {
							$$renderer.push(`<div class="flex items-start justify-between">`);
							Card_title($$renderer, {
								children: ($$renderer) => {
									$$renderer.push(`<!---->${escape_html(test.label)}`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> `);
							if (test.completed) {
								$$renderer.push("<!--[0-->");
								Badge($$renderer, {
									children: ($$renderer) => {
										$$renderer.push(`<!---->Selesai`);
									},
									$$slots: { default: true }
								});
							} else if (test.available) {
								$$renderer.push("<!--[1-->");
								Badge($$renderer, {
									variant: "secondary",
									children: ($$renderer) => {
										$$renderer.push(`<!---->Tersedia`);
									},
									$$slots: { default: true }
								});
							} else {
								$$renderer.push("<!--[-1-->");
								Badge($$renderer, {
									variant: "outline",
									children: ($$renderer) => {
										$$renderer.push(`<!---->Tidak Tersedia`);
									},
									$$slots: { default: true }
								});
							}
							$$renderer.push(`<!--]--></div> `);
							Card_description($$renderer, {
								children: ($$renderer) => {
									if (test.completed) {
										$$renderer.push("<!--[0-->");
										$$renderer.push(`Tes telah diselesaikan`);
									} else if (test.available) {
										$$renderer.push("<!--[1-->");
										$$renderer.push(`Tes tersedia, silakan kerjakan`);
									} else {
										$$renderer.push("<!--[-1-->");
										$$renderer.push(`Tes belum tersedia untuk Anda`);
									}
									$$renderer.push(`<!--]-->`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!---->`);
						},
						$$slots: { default: true }
					});
					$$renderer.push(`<!----> `);
					Card_content($$renderer, {
						class: "mt-auto",
						children: ($$renderer) => {
							if (test.completed) {
								$$renderer.push("<!--[0-->");
								Button($$renderer, {
									href: `${stringify(test.href)}/result`,
									variant: "outline",
									class: "w-full",
									children: ($$renderer) => {
										$$renderer.push(`<!---->Lihat Hasil`);
									},
									$$slots: { default: true }
								});
							} else if (test.available) {
								$$renderer.push("<!--[1-->");
								Button($$renderer, {
									href: test.href,
									class: "w-full",
									children: ($$renderer) => {
										$$renderer.push(`<!---->Mulai Tes`);
									},
									$$slots: { default: true }
								});
							} else {
								$$renderer.push("<!--[-1-->");
								Button($$renderer, {
									disabled: true,
									class: "w-full",
									variant: "outline",
									children: ($$renderer) => {
										$$renderer.push(`<!---->Belum Tersedia`);
									},
									$$slots: { default: true }
								});
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
		$$renderer.push(`<!--]--></div></div>`);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-DtSvXTd1.js.map
