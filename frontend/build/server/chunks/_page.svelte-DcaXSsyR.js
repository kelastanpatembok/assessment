import { ab as head, ad as escape_html } from './dev-DBdtSqNh.js';
import { C as Card, b as Card_header, c as Card_title, a as Card_content } from './card-D-P3c-kH.js';

//#region src/routes/(admin)/admin-dashboard/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data } = $$props;
		head("1axmosg", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Dashboard Admin</title>`);
			});
		});
		$$renderer.push(`<div class="flex flex-col gap-6"><h2 class="text-2xl font-bold">Dashboard</h2> <div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">`);
		Card($$renderer, {
			children: ($$renderer) => {
				Card_header($$renderer, {
					children: ($$renderer) => {
						Card_title($$renderer, {
							class: "text-sm font-medium text-muted-foreground",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Total Sekolah`);
							},
							$$slots: { default: true }
						});
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!----> `);
				Card_content($$renderer, {
					children: ($$renderer) => {
						$$renderer.push(`<p class="text-3xl font-bold">${escape_html(data.schoolCount)}</p>`);
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!---->`);
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----> `);
		Card($$renderer, {
			children: ($$renderer) => {
				Card_header($$renderer, {
					children: ($$renderer) => {
						Card_title($$renderer, {
							class: "text-sm font-medium text-muted-foreground",
							children: ($$renderer) => {
								$$renderer.push(`<!---->Total Pengguna`);
							},
							$$slots: { default: true }
						});
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!----> `);
				Card_content($$renderer, {
					children: ($$renderer) => {
						$$renderer.push(`<p class="text-3xl font-bold">${escape_html(data.userCount)}</p>`);
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!---->`);
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----></div> `);
		Card($$renderer, {
			children: ($$renderer) => {
				Card_header($$renderer, {
					children: ($$renderer) => {
						Card_title($$renderer, {
							children: ($$renderer) => {
								$$renderer.push(`<!---->Akses Cepat`);
							},
							$$slots: { default: true }
						});
					},
					$$slots: { default: true }
				});
				$$renderer.push(`<!----> `);
				Card_content($$renderer, {
					children: ($$renderer) => {
						$$renderer.push(`<div class="flex flex-wrap gap-2"><a href="/admin-schools" class="bg-primary text-primary-foreground rounded-lg px-4 py-2 text-sm hover:opacity-90">Kelola Sekolah</a> <a href="/admin-users" class="bg-secondary text-secondary-foreground rounded-lg px-4 py-2 text-sm hover:opacity-90">Kelola Pengguna</a> <a href="/admin-assignments" class="bg-secondary text-secondary-foreground rounded-lg px-4 py-2 text-sm hover:opacity-90">Kelola Penugasan</a></div>`);
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
//# sourceMappingURL=_page.svelte-DcaXSsyR.js.map
