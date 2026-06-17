import { o as onDestroy } from './index-server-DVlmzpyW.js';
import { $ as head, a1 as escape_html, ak as bind_props, al as spread_props, ai as attributes } from './dev-Ye9HvMQi.js';
import { C as Card, b as Card_header, c as Card_title, a as Card_content, d as Card_description } from './card-D43ruB05.js';
import { Chart, Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, ArcElement, BarController, DoughnutController } from 'chart.js';
import './utils2-BzHbLXAp.js';

//#region node_modules/svelte-chartjs/dist/Chart.svelte
function Chart$1($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		let { type, data, options, plugins, updateMode, chart = null, $$slots, $$events, ...restProps } = $$props;
		onDestroy(() => {
			if (chart) chart.destroy();
			chart = null;
		});
		$$renderer.push(`<canvas${attributes({ ...restProps })}></canvas>`);
		bind_props($$props, { chart });
	});
}
//#endregion
//#region node_modules/svelte-chartjs/dist/Doughnut.svelte
function Doughnut($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		Chart.register(DoughnutController);
		let { chart = null, $$slots, $$events, ...restProps } = $$props;
		let $$settled = true;
		let $$inner_renderer;
		function $$render_inner($$renderer) {
			Chart$1($$renderer, spread_props([
				{ type: "doughnut" },
				restProps,
				{
					get chart() {
						return chart;
					},
					set chart($$value) {
						chart = $$value;
						$$settled = false;
					}
				}
			]));
		}
		do {
			$$settled = true;
			$$inner_renderer = $$renderer.copy();
			$$render_inner($$inner_renderer);
		} while (!$$settled);
		$$renderer.subsume($$inner_renderer);
		bind_props($$props, { chart });
	});
}
//#endregion
//#region node_modules/svelte-chartjs/dist/Bar.svelte
function Bar($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		Chart.register(BarController);
		let { chart = null, $$slots, $$events, ...restProps } = $$props;
		let $$settled = true;
		let $$inner_renderer;
		function $$render_inner($$renderer) {
			Chart$1($$renderer, spread_props([
				{ type: "bar" },
				restProps,
				{
					get chart() {
						return chart;
					},
					set chart($$value) {
						chart = $$value;
						$$settled = false;
					}
				}
			]));
		}
		do {
			$$settled = true;
			$$inner_renderer = $$renderer.copy();
			$$render_inner($$inner_renderer);
		} while (!$$settled);
		$$renderer.subsume($$inner_renderer);
		bind_props($$props, { chart });
	});
}
//#endregion
//#region src/routes/(counselor)/counselor-dashboard/+page.svelte
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		Chart.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, ArcElement);
		let { data } = $$props;
		const { summary } = data;
		const barOptions = {
			responsive: true,
			maintainAspectRatio: false,
			plugins: { legend: { display: false } }
		};
		const doughnutOptions = {
			responsive: true,
			maintainAspectRatio: false
		};
		const discData = {
			labels: Object.keys(summary.discProfileDistribution),
			datasets: [{
				label: "Jumlah Siswa",
				data: Object.values(summary.discProfileDistribution),
				backgroundColor: "rgba(59, 130, 246, 0.8)",
				borderColor: "rgba(59, 130, 246, 1)",
				borderWidth: 1,
				borderRadius: 4
			}]
		};
		const hollandData = {
			labels: Object.keys(summary.hollandTypeDistribution).map((k) => {
				return {
					"R": "Realistic",
					"I": "Investigative",
					"A": "Artistic",
					"S": "Social",
					"E": "Enterprising",
					"C": "Conventional"
				}[k] || k;
			}),
			datasets: [{
				data: Object.values(summary.hollandTypeDistribution),
				backgroundColor: [
					"rgba(239, 68, 68, 0.8)",
					"rgba(245, 158, 11, 0.8)",
					"rgba(16, 185, 129, 0.8)",
					"rgba(59, 130, 246, 0.8)",
					"rgba(139, 92, 246, 0.8)",
					"rgba(236, 72, 153, 0.8)"
				],
				borderWidth: 0
			}]
		};
		head("1m0di0e", $$renderer, ($$renderer) => {
			$$renderer.title(($$renderer) => {
				$$renderer.push(`<title>Dashboard Guru BK - Assessment</title>`);
			});
		});
		$$renderer.push(`<div class="flex-1 space-y-6 p-8 pt-6"><div class="flex items-center justify-between space-y-2"><h2 class="text-3xl font-bold tracking-tight">Dashboard Hasil Evaluasi</h2></div> <div class="grid gap-4 md:grid-cols-2 lg:grid-cols-4">`);
		if (Card) {
			$$renderer.push("<!--[-->");
			Card($$renderer, {
				class: "bg-gradient-to-br from-blue-50 to-white shadow-sm border-blue-100",
				children: ($$renderer) => {
					if (Card_header) {
						$$renderer.push("<!--[-->");
						Card_header($$renderer, {
							class: "flex flex-row items-center justify-between space-y-0 pb-2",
							children: ($$renderer) => {
								if (Card_title) {
									$$renderer.push("<!--[-->");
									Card_title($$renderer, {
										class: "text-sm font-medium",
										children: ($$renderer) => {
											$$renderer.push(`<!---->Total Siswa`);
										},
										$$slots: { default: true }
									});
									$$renderer.push("<!--]-->");
								} else {
									$$renderer.push("<!--[!-->");
									$$renderer.push("<!--]-->");
								}
								$$renderer.push(`<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-blue-500"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path><circle cx="9" cy="7" r="4"></circle><path d="M22 21v-2a4 4 0 0 0-3-3.87"></path><path d="M16 3.13a4 4 0 0 1 0 7.75"></path></svg>`);
							},
							$$slots: { default: true }
						});
						$$renderer.push("<!--]-->");
					} else {
						$$renderer.push("<!--[!-->");
						$$renderer.push("<!--]-->");
					}
					$$renderer.push(` `);
					if (Card_content) {
						$$renderer.push("<!--[-->");
						Card_content($$renderer, {
							children: ($$renderer) => {
								$$renderer.push(`<div class="text-3xl font-bold text-blue-700">${escape_html(summary.totalStudents)}</div> <p class="text-xs text-muted-foreground mt-1">Siswa terdaftar di sekolah ini</p>`);
							},
							$$slots: { default: true }
						});
						$$renderer.push("<!--]-->");
					} else {
						$$renderer.push("<!--[!-->");
						$$renderer.push("<!--]-->");
					}
				},
				$$slots: { default: true }
			});
			$$renderer.push("<!--]-->");
		} else {
			$$renderer.push("<!--[!-->");
			$$renderer.push("<!--]-->");
		}
		$$renderer.push(` `);
		if (Card) {
			$$renderer.push("<!--[-->");
			Card($$renderer, {
				class: "bg-gradient-to-br from-green-50 to-white shadow-sm border-green-100",
				children: ($$renderer) => {
					if (Card_header) {
						$$renderer.push("<!--[-->");
						Card_header($$renderer, {
							class: "flex flex-row items-center justify-between space-y-0 pb-2",
							children: ($$renderer) => {
								if (Card_title) {
									$$renderer.push("<!--[-->");
									Card_title($$renderer, {
										class: "text-sm font-medium",
										children: ($$renderer) => {
											$$renderer.push(`<!---->Tes Selesai`);
										},
										$$slots: { default: true }
									});
									$$renderer.push("<!--]-->");
								} else {
									$$renderer.push("<!--[!-->");
									$$renderer.push("<!--]-->");
								}
								$$renderer.push(`<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-green-500"><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>`);
							},
							$$slots: { default: true }
						});
						$$renderer.push("<!--]-->");
					} else {
						$$renderer.push("<!--[!-->");
						$$renderer.push("<!--]-->");
					}
					$$renderer.push(` `);
					if (Card_content) {
						$$renderer.push("<!--[-->");
						Card_content($$renderer, {
							children: ($$renderer) => {
								$$renderer.push(`<div class="text-3xl font-bold text-green-700">${escape_html(summary.completedTests)}</div> <p class="text-xs text-muted-foreground mt-1">Modul asesmen diselesaikan</p>`);
							},
							$$slots: { default: true }
						});
						$$renderer.push("<!--]-->");
					} else {
						$$renderer.push("<!--[!-->");
						$$renderer.push("<!--]-->");
					}
				},
				$$slots: { default: true }
			});
			$$renderer.push("<!--]-->");
		} else {
			$$renderer.push("<!--[!-->");
			$$renderer.push("<!--]-->");
		}
		$$renderer.push(` `);
		if (Card) {
			$$renderer.push("<!--[-->");
			Card($$renderer, {
				class: "bg-gradient-to-br from-purple-50 to-white shadow-sm border-purple-100",
				children: ($$renderer) => {
					if (Card_header) {
						$$renderer.push("<!--[-->");
						Card_header($$renderer, {
							class: "flex flex-row items-center justify-between space-y-0 pb-2",
							children: ($$renderer) => {
								if (Card_title) {
									$$renderer.push("<!--[-->");
									Card_title($$renderer, {
										class: "text-sm font-medium",
										children: ($$renderer) => {
											$$renderer.push(`<!---->Rata-rata IQ (Estimasi)`);
										},
										$$slots: { default: true }
									});
									$$renderer.push("<!--]-->");
								} else {
									$$renderer.push("<!--[!-->");
									$$renderer.push("<!--]-->");
								}
								$$renderer.push(`<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="text-purple-500"><path d="M2 12h4l3-9 5 18 3-9h5"></path></svg>`);
							},
							$$slots: { default: true }
						});
						$$renderer.push("<!--]-->");
					} else {
						$$renderer.push("<!--[!-->");
						$$renderer.push("<!--]-->");
					}
					$$renderer.push(` `);
					if (Card_content) {
						$$renderer.push("<!--[-->");
						Card_content($$renderer, {
							children: ($$renderer) => {
								$$renderer.push(`<div class="text-3xl font-bold text-purple-700">${escape_html(summary.averageIq)}</div> <p class="text-xs text-muted-foreground mt-1">Berdasarkan hasil IST / CFIT</p>`);
							},
							$$slots: { default: true }
						});
						$$renderer.push("<!--]-->");
					} else {
						$$renderer.push("<!--[!-->");
						$$renderer.push("<!--]-->");
					}
				},
				$$slots: { default: true }
			});
			$$renderer.push("<!--]-->");
		} else {
			$$renderer.push("<!--[!-->");
			$$renderer.push("<!--]-->");
		}
		$$renderer.push(`</div> <div class="grid gap-6 md:grid-cols-2">`);
		if (Card) {
			$$renderer.push("<!--[-->");
			Card($$renderer, {
				class: "shadow-md",
				children: ($$renderer) => {
					if (Card_header) {
						$$renderer.push("<!--[-->");
						Card_header($$renderer, {
							children: ($$renderer) => {
								if (Card_title) {
									$$renderer.push("<!--[-->");
									Card_title($$renderer, {
										children: ($$renderer) => {
											$$renderer.push(`<!---->Distribusi Profil Kepribadian (DISC)`);
										},
										$$slots: { default: true }
									});
									$$renderer.push("<!--]-->");
								} else {
									$$renderer.push("<!--[!-->");
									$$renderer.push("<!--]-->");
								}
								$$renderer.push(` `);
								if (Card_description) {
									$$renderer.push("<!--[-->");
									Card_description($$renderer, {
										children: ($$renderer) => {
											$$renderer.push(`<!---->Mayoritas gaya kerja dan komunikasi siswa.`);
										},
										$$slots: { default: true }
									});
									$$renderer.push("<!--]-->");
								} else {
									$$renderer.push("<!--[!-->");
									$$renderer.push("<!--]-->");
								}
							},
							$$slots: { default: true }
						});
						$$renderer.push("<!--]-->");
					} else {
						$$renderer.push("<!--[!-->");
						$$renderer.push("<!--]-->");
					}
					$$renderer.push(` `);
					if (Card_content) {
						$$renderer.push("<!--[-->");
						Card_content($$renderer, {
							class: "h-[350px]",
							children: ($$renderer) => {
								Bar($$renderer, {
									data: discData,
									options: barOptions
								});
							},
							$$slots: { default: true }
						});
						$$renderer.push("<!--]-->");
					} else {
						$$renderer.push("<!--[!-->");
						$$renderer.push("<!--]-->");
					}
				},
				$$slots: { default: true }
			});
			$$renderer.push("<!--]-->");
		} else {
			$$renderer.push("<!--[!-->");
			$$renderer.push("<!--]-->");
		}
		$$renderer.push(` `);
		if (Card) {
			$$renderer.push("<!--[-->");
			Card($$renderer, {
				class: "shadow-md",
				children: ($$renderer) => {
					if (Card_header) {
						$$renderer.push("<!--[-->");
						Card_header($$renderer, {
							children: ($$renderer) => {
								if (Card_title) {
									$$renderer.push("<!--[-->");
									Card_title($$renderer, {
										children: ($$renderer) => {
											$$renderer.push(`<!---->Distribusi Minat Karier (Holland RIASEC)`);
										},
										$$slots: { default: true }
									});
									$$renderer.push("<!--]-->");
								} else {
									$$renderer.push("<!--[!-->");
									$$renderer.push("<!--]-->");
								}
								$$renderer.push(` `);
								if (Card_description) {
									$$renderer.push("<!--[-->");
									Card_description($$renderer, {
										children: ($$renderer) => {
											$$renderer.push(`<!---->Kecenderungan bidang vokasional dominan siswa.`);
										},
										$$slots: { default: true }
									});
									$$renderer.push("<!--]-->");
								} else {
									$$renderer.push("<!--[!-->");
									$$renderer.push("<!--]-->");
								}
							},
							$$slots: { default: true }
						});
						$$renderer.push("<!--]-->");
					} else {
						$$renderer.push("<!--[!-->");
						$$renderer.push("<!--]-->");
					}
					$$renderer.push(` `);
					if (Card_content) {
						$$renderer.push("<!--[-->");
						Card_content($$renderer, {
							class: "h-[350px] flex items-center justify-center",
							children: ($$renderer) => {
								$$renderer.push(`<div class="w-full max-w-[300px] h-full">`);
								Doughnut($$renderer, {
									data: hollandData,
									options: doughnutOptions
								});
								$$renderer.push(`<!----></div>`);
							},
							$$slots: { default: true }
						});
						$$renderer.push("<!--]-->");
					} else {
						$$renderer.push("<!--[!-->");
						$$renderer.push("<!--]-->");
					}
				},
				$$slots: { default: true }
			});
			$$renderer.push("<!--]-->");
		} else {
			$$renderer.push("<!--[!-->");
			$$renderer.push("<!--]-->");
		}
		$$renderer.push(`</div></div>`);
	});
}

export { _page as default };
//# sourceMappingURL=_page.svelte-CNC0kAYt.js.map
