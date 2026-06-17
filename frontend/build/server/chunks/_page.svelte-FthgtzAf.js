import { $ as head, a1 as escape_html, a0 as attr, ak as bind_props, ae as ensure_array_like, _ as derived } from './dev-Ye9HvMQi.js';
import { I as Input } from './label-CtBNDRHL.js';
import './utils2-BzHbLXAp.js';

//#region src/lib/components/wizard/TestAssignmentSelector.svelte
function TestAssignmentSelector($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		/**
		* TestAssignment interface matches the shape of data from +page.server.ts
		*/
		/**
		* Component props
		* - assignments: list of active test assignments loaded from API
		* - selected: the currently selected assignment (two-way binding)
		*/
		let { assignments = [], selected = null } = $$props;
		let schoolFilter = "";
		let categoryFilter = "";
		/**
		* Filters assignments based on school name and category filters
		* Case-insensitive substring matching
		*/
		let filteredAssignments = derived(() => {
			return assignments.filter((assignment) => {
				const schoolMatch = assignment.school.name.toLowerCase().includes(schoolFilter.toLowerCase());
				const categoryMatch = assignment.category.name.toLowerCase().includes(categoryFilter.toLowerCase());
				return schoolMatch && categoryMatch;
			});
		});
		/**
		* Format date string to readable format (DD/MM/YYYY)
		*/
		function formatDate(dateString) {
			try {
				return new Date(dateString).toLocaleDateString("id-ID", {
					year: "numeric",
					month: "2-digit",
					day: "2-digit"
				});
			} catch {
				return dateString;
			}
		}
		let $$settled = true;
		let $$inner_renderer;
		function $$render_inner($$renderer) {
			$$renderer.push(`<div class="flex flex-col gap-4"><div class="grid grid-cols-1 gap-4 md:grid-cols-2"><div class="flex flex-col gap-2"><label for="school-filter" class="text-sm font-medium">Cari Sekolah</label> `);
			Input($$renderer, {
				id: "school-filter",
				type: "text",
				placeholder: "Nama sekolah...",
				get value() {
					return schoolFilter;
				},
				set value($$value) {
					schoolFilter = $$value;
					$$settled = false;
				}
			});
			$$renderer.push(`<!----></div> <div class="flex flex-col gap-2"><label for="category-filter" class="text-sm font-medium">Cari Kategori Tes</label> `);
			Input($$renderer, {
				id: "category-filter",
				type: "text",
				placeholder: "Kategori tes...",
				get value() {
					return categoryFilter;
				},
				set value($$value) {
					categoryFilter = $$value;
					$$settled = false;
				}
			});
			$$renderer.push(`<!----></div></div> <div class="rounded-lg border border-border overflow-hidden">`);
			if (filteredAssignments().length === 0) {
				$$renderer.push("<!--[0-->");
				$$renderer.push(`<div class="p-8 text-center"><p class="text-muted-foreground text-sm">${escape_html(assignments.length === 0 ? "Tidak ada penugasan tes aktif saat ini" : "Tidak ada penugasan yang cocok dengan filter")}</p></div>`);
			} else {
				$$renderer.push("<!--[-1-->");
				$$renderer.push(`<table class="w-full text-sm"><thead class="bg-muted border-b border-border"><tr><th class="w-12 px-4 py-3 text-left font-semibold">Pilih</th><th class="px-4 py-3 text-left font-semibold">Nama Sekolah</th><th class="px-4 py-3 text-left font-semibold">Kategori Tes</th><th class="px-4 py-3 text-left font-semibold">Tanggal Mulai</th><th class="px-4 py-3 text-left font-semibold">Tanggal Berakhir</th></tr></thead><tbody><!--[-->`);
				const each_array = ensure_array_like(filteredAssignments());
				for (let $$index = 0, $$length = each_array.length; $$index < $$length; $$index++) {
					let assignment = each_array[$$index];
					$$renderer.push(`<tr class="border-b border-border hover:bg-muted/50 transition-colors cursor-pointer"><td class="px-4 py-3"><input type="radio" name="assignment"${attr("value", assignment.id)}${attr("checked", selected?.id === assignment.id, true)} class="w-4 h-4"/></td><td class="px-4 py-3"><div class="font-medium">${escape_html(assignment.school.name)}</div></td><td class="px-4 py-3"><div class="text-muted-foreground">${escape_html(assignment.category.name)}</div></td><td class="px-4 py-3"><div class="text-muted-foreground">${escape_html(formatDate(assignment.startDate))}</div></td><td class="px-4 py-3"><div class="text-muted-foreground">${escape_html(formatDate(assignment.endDate))}</div></td></tr>`);
				}
				$$renderer.push(`<!--]--></tbody></table>`);
			}
			$$renderer.push(`<!--]--></div> `);
			if (selected) {
				$$renderer.push("<!--[0-->");
				$$renderer.push(`<div class="rounded-lg bg-primary/10 p-4"><p class="text-sm font-medium"><span class="text-primary">Dipilih:</span> ${escape_html(selected.school.name)} - ${escape_html(selected.category.name)}</p></div>`);
			} else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--></div>`);
		}
		do {
			$$settled = true;
			$$inner_renderer = $$renderer.copy();
			$$render_inner($$inner_renderer);
		} while (!$$settled);
		$$renderer.subsume($$inner_renderer);
		bind_props($$props, { selected });
	});
}
//#endregion
//#region src/routes/(admin)/credentials/new/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		/**
		* Represents a test assignment that can be selected in step 1
		* Combines school and test category information
		*/
		/**
		* Represents a generated student credential
		* Contains plaintext password for display/export only (never logged or stored)
		*/
		/**
		* Represents the username pattern template
		* Used in step 2 for configuring credential naming
		*/
		let currentStep = 1;
		let selectedAssignment = null;
		let isGenerating = false;
		let { data } = $$props;
		let $$settled = true;
		let $$inner_renderer;
		function $$render_inner($$renderer) {
			head("10ji87h", $$renderer, ($$renderer) => {
				$$renderer.title(($$renderer) => {
					$$renderer.push(`<title>Generate Kredensial Siswa</title>`);
				});
			});
			$$renderer.push(`<div class="flex flex-col gap-6"><div class="flex items-center justify-between"><h2 class="text-2xl font-bold">Generate Kredensial Siswa</h2> <a href="/admin-dashboard" class="text-muted-foreground hover:text-foreground text-sm transition-colors">← Kembali ke Dashboard</a></div> <div class="bg-muted rounded-lg p-3 text-center text-sm"><p>Langkah ${escape_html(currentStep)} dari 3</p></div> `);
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<div class="bg-card border-border rounded-xl border p-6 shadow-sm"><h3 class="mb-4 text-lg font-semibold">Pilih Penugasan Tes</h3> `);
			TestAssignmentSelector($$renderer, {
				assignments: data.assignments,
				get selected() {
					return selectedAssignment;
				},
				set selected($$value) {
					selectedAssignment = $$value;
					$$settled = false;
				}
			});
			$$renderer.push(`<!----></div>`);
			$$renderer.push(`<!--]--> `);
			$$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> `);
			$$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> `);
			$$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> `);
			$$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> <div class="flex justify-between gap-4">`);
			$$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> `);
			$$renderer.push("<!--[0-->");
			$$renderer.push(`<button${attr("disabled", isGenerating, true)} class="px-6 py-2 bg-primary hover:bg-primary/90 disabled:opacity-50 text-primary-foreground rounded-lg font-medium transition-colors ml-auto">${escape_html("Selanjutnya")}</button>`);
			$$renderer.push(`<!--]--></div></div>`);
		}
		do {
			$$settled = true;
			$$inner_renderer = $$renderer.copy();
			$$render_inner($$inner_renderer);
		} while (!$$settled);
		$$renderer.subsume($$inner_renderer);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-FthgtzAf.js.map
