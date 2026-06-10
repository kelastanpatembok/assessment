const manifest = (() => {
function __memo(fn) {
	let value;
	return () => value ??= (value = fn());
}

return {
	appDir: "_app",
	appPath: "_app",
	assets: new Set(["robots.txt"]),
	mimeTypes: {".txt":"text/plain"},
	_: {
		client: {start:"_app/immutable/entry/start.y3-adnFu.js",app:"_app/immutable/entry/app.CQAnvnMG.js",imports:["_app/immutable/entry/start.y3-adnFu.js","_app/immutable/chunks/Tkiqu5QU.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/entry/app.CQAnvnMG.js","_app/immutable/chunks/CTl4Pa98.js","_app/immutable/chunks/kNaey6uv.js","_app/immutable/chunks/xihTtKlq.js"],stylesheets:[],fonts:[],uses_env_dynamic_public:false},
		nodes: [
			__memo(() => import('./chunks/0-B7Aqw6lN.js')),
			__memo(() => import('./chunks/1-BYpnm_2i.js')),
			__memo(() => import('./chunks/2-BlR17kDx.js')),
			__memo(() => import('./chunks/3-6Bs4n9ya.js')),
			__memo(() => import('./chunks/4-CotlUt_T.js')),
			__memo(() => import('./chunks/5-C6UGlHCv.js')),
			__memo(() => import('./chunks/6-CLGdRMil.js')),
			__memo(() => import('./chunks/7-CF1rppG3.js')),
			__memo(() => import('./chunks/8-RkOKt18z.js')),
			__memo(() => import('./chunks/9-D67xkOy_.js')),
			__memo(() => import('./chunks/10-Bazu0z4U.js')),
			__memo(() => import('./chunks/11-8WePp7Oc.js')),
			__memo(() => import('./chunks/12-CfuawpLQ.js')),
			__memo(() => import('./chunks/13-CFW0_TGI.js')),
			__memo(() => import('./chunks/14-DJd-i0DD.js')),
			__memo(() => import('./chunks/15-D7_oxmDz.js')),
			__memo(() => import('./chunks/16-D-xGqmK9.js')),
			__memo(() => import('./chunks/17-80CQfjtx.js')),
			__memo(() => import('./chunks/18-Bq1OFaHe.js')),
			__memo(() => import('./chunks/19-C988Qcmd.js')),
			__memo(() => import('./chunks/20-CehuFeXH.js')),
			__memo(() => import('./chunks/21-CIXzYM53.js')),
			__memo(() => import('./chunks/22-Dr__5u69.js')),
			__memo(() => import('./chunks/23-EBgteCu7.js')),
			__memo(() => import('./chunks/24-DMbDmlKx.js')),
			__memo(() => import('./chunks/25-D7l_h7ue.js')),
			__memo(() => import('./chunks/26-DOE-a-nW.js')),
			__memo(() => import('./chunks/27-BSd5fRMH.js')),
			__memo(() => import('./chunks/28-DxRg5QCI.js')),
			__memo(() => import('./chunks/29-BnJnkfZM.js')),
			__memo(() => import('./chunks/30-KVKzerp8.js')),
			__memo(() => import('./chunks/31-C4jckUYk.js'))
		],
		remotes: {
			
		},
		routes: [
			{
				id: "/",
				pattern: /^\/$/,
				params: [],
				page: { layouts: [0,], errors: [1,], leaf: 6 },
				endpoint: null
			},
			{
				id: "/(admin)/admin-assignments",
				pattern: /^\/admin-assignments\/?$/,
				params: [],
				page: { layouts: [0,2,], errors: [1,,], leaf: 7 },
				endpoint: null
			},
			{
				id: "/(admin)/admin-categories",
				pattern: /^\/admin-categories\/?$/,
				params: [],
				page: { layouts: [0,2,], errors: [1,,], leaf: 8 },
				endpoint: null
			},
			{
				id: "/(admin)/admin-dashboard",
				pattern: /^\/admin-dashboard\/?$/,
				params: [],
				page: { layouts: [0,2,], errors: [1,,], leaf: 9 },
				endpoint: null
			},
			{
				id: "/(admin)/admin-fees",
				pattern: /^\/admin-fees\/?$/,
				params: [],
				page: { layouts: [0,2,], errors: [1,,], leaf: 10 },
				endpoint: null
			},
			{
				id: "/(admin)/admin-schools",
				pattern: /^\/admin-schools\/?$/,
				params: [],
				page: { layouts: [0,2,], errors: [1,,], leaf: 11 },
				endpoint: null
			},
			{
				id: "/(admin)/admin-students",
				pattern: /^\/admin-students\/?$/,
				params: [],
				page: { layouts: [0,2,], errors: [1,,], leaf: 12 },
				endpoint: null
			},
			{
				id: "/(admin)/admin-users",
				pattern: /^\/admin-users\/?$/,
				params: [],
				page: { layouts: [0,2,], errors: [1,,], leaf: 13 },
				endpoint: null
			},
			{
				id: "/(afiliator)/afiliator-dashboard",
				pattern: /^\/afiliator-dashboard\/?$/,
				params: [],
				page: { layouts: [0,3,], errors: [1,,], leaf: 14 },
				endpoint: null
			},
			{
				id: "/(afiliator)/afiliator-fees",
				pattern: /^\/afiliator-fees\/?$/,
				params: [],
				page: { layouts: [0,3,], errors: [1,,], leaf: 15 },
				endpoint: null
			},
			{
				id: "/(counselor)/counselor-dashboard",
				pattern: /^\/counselor-dashboard\/?$/,
				params: [],
				page: { layouts: [0,4,], errors: [1,,], leaf: 16 },
				endpoint: null
			},
			{
				id: "/(counselor)/counselor-results",
				pattern: /^\/counselor-results\/?$/,
				params: [],
				page: { layouts: [0,4,], errors: [1,,], leaf: 17 },
				endpoint: null
			},
			{
				id: "/(counselor)/counselor-students",
				pattern: /^\/counselor-students\/?$/,
				params: [],
				page: { layouts: [0,4,], errors: [1,,], leaf: 18 },
				endpoint: null
			},
			{
				id: "/login",
				pattern: /^\/login\/?$/,
				params: [],
				page: { layouts: [0,], errors: [1,], leaf: 30 },
				endpoint: null
			},
			{
				id: "/logout",
				pattern: /^\/logout\/?$/,
				params: [],
				page: { layouts: [0,], errors: [1,], leaf: 31 },
				endpoint: null
			},
			{
				id: "/(student)/student-cfit",
				pattern: /^\/student-cfit\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 19 },
				endpoint: null
			},
			{
				id: "/(student)/student-cfit/result",
				pattern: /^\/student-cfit\/result\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 20 },
				endpoint: null
			},
			{
				id: "/(student)/student-dashboard",
				pattern: /^\/student-dashboard\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 21 },
				endpoint: null
			},
			{
				id: "/(student)/student-disc",
				pattern: /^\/student-disc\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 22 },
				endpoint: null
			},
			{
				id: "/(student)/student-disc/result",
				pattern: /^\/student-disc\/result\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 23 },
				endpoint: null
			},
			{
				id: "/(student)/student-holland",
				pattern: /^\/student-holland\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 24 },
				endpoint: null
			},
			{
				id: "/(student)/student-holland/result",
				pattern: /^\/student-holland\/result\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 25 },
				endpoint: null
			},
			{
				id: "/(student)/student-ist",
				pattern: /^\/student-ist\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 26 },
				endpoint: null
			},
			{
				id: "/(student)/student-ist/result",
				pattern: /^\/student-ist\/result\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 27 },
				endpoint: null
			},
			{
				id: "/(student)/student-papi",
				pattern: /^\/student-papi\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 28 },
				endpoint: null
			},
			{
				id: "/(student)/student-papi/result",
				pattern: /^\/student-papi\/result\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 29 },
				endpoint: null
			}
		],
		prerendered_routes: new Set([]),
		matchers: async () => {
			
			return {  };
		},
		server_assets: {}
	}
}
})();

const prerendered = new Set([]);

const base = "";

export { base, manifest, prerendered };
//# sourceMappingURL=manifest.js.map
