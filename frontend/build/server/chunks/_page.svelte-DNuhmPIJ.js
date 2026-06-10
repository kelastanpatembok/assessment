import { ab as head, ad as escape_html, ae as ensure_array_like, ac as attr, a5 as derived } from './dev-DBdtSqNh.js';
import './client-BH3cxpaA.js';
import { C as Card, a as Card_content, b as Card_header, c as Card_title } from './card-D-P3c-kH.js';
import { B as Button } from './button-axqvSO5n.js';
import { L as Label, I as Input } from './label-D2KfWwLz.js';
import { B as Badge } from './badge-DkcqB8h9.js';
import './internal2-BaeAYGUQ.js';
import './index-DBqjc0Yf.js';
import './index-jeR0PSLo.js';

//#region src/routes/(admin)/admin-users/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { data, form } = $$props;
		let showModal = false;
		let loading = false;
		let filterRole = "";
		const roleLabel = {
			superadmin: "Superadmin",
			gurubk: "Guru BK",
			afiliator: "Afiliator",
			siswa: "Siswa"
		};
		let filtered = derived(() => filterRole ? data.users.filter((u) => u.role === filterRole) : data.users);
		head("18s2yhk", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Pengguna</title>`);
			});
		});
		$$renderer.push(`<div class="flex flex-col gap-6"><div class="flex items-center justify-between"><h2 class="text-2xl font-bold">Pengguna</h2> `);
		Button($$renderer, {
			onclick: () => showModal = true,
			children: ($$renderer) => {
				$$renderer.push(`<!---->+ Tambah Pengguna`);
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----></div> `);
		if (form?.error) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<div class="bg-destructive/10 text-destructive rounded-lg px-4 py-3 text-sm">${escape_html(form.error)}</div>`);
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> <div class="flex gap-2">`);
		Button($$renderer, {
			variant: filterRole === "" ? "default" : "outline",
			size: "sm",
			onclick: () => filterRole = "",
			children: ($$renderer) => {
				$$renderer.push(`<!---->Semua`);
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----> `);
		Button($$renderer, {
			variant: filterRole === "gurubk" ? "default" : "outline",
			size: "sm",
			onclick: () => filterRole = "gurubk",
			children: ($$renderer) => {
				$$renderer.push(`<!---->Guru BK`);
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----> `);
		Button($$renderer, {
			variant: filterRole === "afiliator" ? "default" : "outline",
			size: "sm",
			onclick: () => filterRole = "afiliator",
			children: ($$renderer) => {
				$$renderer.push(`<!---->Afiliator`);
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----></div> `);
		Card($$renderer, {
			children: ($$renderer) => {
				Card_content($$renderer, {
					class: "pt-6",
					children: ($$renderer) => {
						$$renderer.push(`<table class="w-full text-sm"><thead><tr class="border-border border-b text-left"><th class="pb-3 font-medium">Nama</th><th class="pb-3 font-medium">Username</th><th class="pb-3 font-medium">Email</th><th class="pb-3 font-medium">Peran</th><th class="pb-3 font-medium">Sekolah</th><th class="pb-3 font-medium">Aksi</th></tr></thead><tbody>`);
						const each_array = ensure_array_like(filtered());
						if (each_array.length !== 0) {
							$$renderer.push("<!--[-->");
							for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
								let user = each_array[$$index];
								$$renderer.push(`<tr class="border-border border-b last:border-0"><td class="py-3 font-medium">${escape_html(user.name)}</td><td class="py-3">${escape_html(user.username)}</td><td class="text-muted-foreground py-3">${escape_html(user.email ?? "-")}</td><td class="py-3">`);
								Badge($$renderer, {
									variant: "secondary",
									children: ($$renderer) => {
										$$renderer.push(`<!---->${escape_html(roleLabel[user.role] ?? user.role)}`);
									},
									$$slots: { default: true }
								});
								$$renderer.push(`<!----></td><td class="text-muted-foreground py-3">${escape_html(user.schoolName ?? "-")}</td><td class="py-3"><form method="POST" action="?/delete"><input type="hidden" name="id"${attr("value", user.authUserId)}/> <button type="submit" class="text-destructive text-xs hover:underline">Hapus</button></form></td></tr>`);
							}
						} else {
							$$renderer.push("<!--[!-->");
							$$renderer.push(`<tr><td colspan="6" class="text-muted-foreground py-6 text-center">Belum ada pengguna</td></tr>`);
						}
						$$renderer.push(`<!--]--></tbody></table>`);
					},
					$$slots: { default: true }
				});
			},
			$$slots: { default: true }
		});
		$$renderer.push(`<!----></div> `);
		if (showModal) {
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<div class="bg-background/80 fixed inset-0 z-50 flex items-center justify-center backdrop-blur-sm">`);
			Card($$renderer, {
				class: "w-full max-w-md",
				children: ($$renderer) => {
					Card_header($$renderer, {
						children: ($$renderer) => {
							Card_title($$renderer, {
								children: ($$renderer) => {
									$$renderer.push(`<!---->Tambah Pengguna`);
								},
								$$slots: { default: true }
							});
						},
						$$slots: { default: true }
					});
					$$renderer.push(`<!----> `);
					Card_content($$renderer, {
						children: ($$renderer) => {
							$$renderer.push(`<form method="POST" action="?/create" class="flex flex-col gap-4"><div class="flex flex-col gap-2">`);
							Label($$renderer, {
								for: "name",
								children: ($$renderer) => {
									$$renderer.push(`<!---->Nama Lengkap`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> `);
							Input($$renderer, {
								id: "name",
								name: "name",
								placeholder: "Nama lengkap",
								required: true
							});
							$$renderer.push(`<!----></div> <div class="flex flex-col gap-2">`);
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
								placeholder: "Username",
								required: true
							});
							$$renderer.push(`<!----></div> <div class="flex flex-col gap-2">`);
							Label($$renderer, {
								for: "email",
								children: ($$renderer) => {
									$$renderer.push(`<!---->Email`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> `);
							Input($$renderer, {
								id: "email",
								name: "email",
								type: "email",
								placeholder: "email@contoh.com"
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
								placeholder: "Password",
								required: true
							});
							$$renderer.push(`<!----></div> <div class="flex flex-col gap-2">`);
							Label($$renderer, {
								for: "role",
								children: ($$renderer) => {
									$$renderer.push(`<!---->Peran`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> <select id="role" name="role" class="border-input bg-background flex h-10 w-full rounded-lg border px-3 text-sm" required="">`);
							$$renderer.option({ value: "" }, ($$renderer) => {
								$$renderer.push(`Pilih peran...`);
							});
							$$renderer.option({ value: "gurubk" }, ($$renderer) => {
								$$renderer.push(`Guru BK`);
							});
							$$renderer.option({ value: "afiliator" }, ($$renderer) => {
								$$renderer.push(`Afiliator`);
							});
							$$renderer.option({ value: "superadmin" }, ($$renderer) => {
								$$renderer.push(`Superadmin`);
							});
							$$renderer.push(`</select></div> <div class="flex flex-col gap-2">`);
							Label($$renderer, {
								for: "schoolId",
								children: ($$renderer) => {
									$$renderer.push(`<!---->Sekolah (opsional)`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> <select id="schoolId" name="schoolId" class="border-input bg-background flex h-10 w-full rounded-lg border px-3 text-sm">`);
							$$renderer.option({ value: "" }, ($$renderer) => {
								$$renderer.push(`Tanpa sekolah`);
							});
							$$renderer.push(`<!--[-->`);
							const each_array_1 = ensure_array_like(data.schools);
							for (let $$index_1 = 0, $$length = each_array_1.length; $$index_1 < $$length; $$index_1++) {
								let s = each_array_1[$$index_1];
								$$renderer.option({ value: s.id }, ($$renderer) => {
									$$renderer.push(`${escape_html(s.schoolName)}`);
								});
							}
							$$renderer.push(`<!--]--></select></div> <div class="flex justify-end gap-2">`);
							Button($$renderer, {
								type: "button",
								variant: "outline",
								onclick: () => showModal = false,
								children: ($$renderer) => {
									$$renderer.push(`<!---->Batal`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----> `);
							Button($$renderer, {
								type: "submit",
								disabled: loading,
								children: ($$renderer) => {
									$$renderer.push(`<!---->${escape_html("Simpan")}`);
								},
								$$slots: { default: true }
							});
							$$renderer.push(`<!----></div></form>`);
						},
						$$slots: { default: true }
					});
					$$renderer.push(`<!---->`);
				},
				$$slots: { default: true }
			});
			$$renderer.push(`<!----></div>`);
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]-->`);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-DNuhmPIJ.js.map
