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
		client: {start:"_app/immutable/entry/start.B4T8JvBo.js",app:"_app/immutable/entry/app.CZ9q5iNs.js",imports:["_app/immutable/entry/start.B4T8JvBo.js","_app/immutable/chunks/DW31PRUZ.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/entry/app.CZ9q5iNs.js","_app/immutable/chunks/DL5ld6r-.js","_app/immutable/chunks/kNaey6uv.js","_app/immutable/chunks/xihTtKlq.js"],stylesheets:[],fonts:[],uses_env_dynamic_public:false},
		nodes: [
			__memo(() => import('./chunks/0-B3ecgJjl.js')),
			__memo(() => import('./chunks/1-7cbcyjwQ.js')),
			__memo(() => import('./chunks/2-DFGRZixA.js')),
			__memo(() => import('./chunks/3-BtpkBbLq.js')),
			__memo(() => import('./chunks/4-Co_jv18p.js')),
			__memo(() => import('./chunks/5-D7Ay3_9K.js')),
			__memo(() => import('./chunks/6-CuM3vq1v.js')),
			__memo(() => import('./chunks/7-7PMukI04.js')),
			__memo(() => import('./chunks/8-BZMEcEj3.js')),
			__memo(() => import('./chunks/9-CpsGVtN3.js')),
			__memo(() => import('./chunks/10-VqnmfAHc.js')),
			__memo(() => import('./chunks/11-CBW1a6__.js')),
			__memo(() => import('./chunks/12-COXuPrAk.js')),
			__memo(() => import('./chunks/13-CL6lJ_hE.js')),
			__memo(() => import('./chunks/14-DQXvHXk9.js')),
			__memo(() => import('./chunks/15-DlJXJrB0.js')),
			__memo(() => import('./chunks/16-BcnctJjk.js')),
			__memo(() => import('./chunks/17-B88ETQhh.js')),
			__memo(() => import('./chunks/18-0zTctrD0.js')),
			__memo(() => import('./chunks/19-E7KxJpT-.js')),
			__memo(() => import('./chunks/20-UxC5bTjj.js')),
			__memo(() => import('./chunks/21-CELqMgNt.js')),
			__memo(() => import('./chunks/22-Bt6ks22X.js')),
			__memo(() => import('./chunks/23-Biun3_vK.js')),
			__memo(() => import('./chunks/24-k8O7TabA.js')),
			__memo(() => import('./chunks/25-BaTkfhBo.js')),
			__memo(() => import('./chunks/26-C0FBlLwH.js')),
			__memo(() => import('./chunks/27-DMT1RihA.js')),
			__memo(() => import('./chunks/28-CzJRDU10.js')),
			__memo(() => import('./chunks/29-DAf8bMIF.js')),
			__memo(() => import('./chunks/30-CbqmhK3_.js')),
			__memo(() => import('./chunks/31-CMlaSWXR.js')),
			__memo(() => import('./chunks/32-BW5MxT0N.js'))
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
				page: { layouts: [0,3,], errors: [1,,], leaf: 15 },
				endpoint: null
			},
			{
				id: "/(afiliator)/afiliator-fees",
				pattern: /^\/afiliator-fees\/?$/,
				params: [],
				page: { layouts: [0,3,], errors: [1,,], leaf: 16 },
				endpoint: null
			},
			{
				id: "/(counselor)/counselor-dashboard",
				pattern: /^\/counselor-dashboard\/?$/,
				params: [],
				page: { layouts: [0,4,], errors: [1,,], leaf: 17 },
				endpoint: null
			},
			{
				id: "/(counselor)/counselor-results",
				pattern: /^\/counselor-results\/?$/,
				params: [],
				page: { layouts: [0,4,], errors: [1,,], leaf: 18 },
				endpoint: null
			},
			{
				id: "/(counselor)/counselor-students",
				pattern: /^\/counselor-students\/?$/,
				params: [],
				page: { layouts: [0,4,], errors: [1,,], leaf: 19 },
				endpoint: null
			},
			{
				id: "/(admin)/credentials/new",
				pattern: /^\/credentials\/new\/?$/,
				params: [],
				page: { layouts: [0,2,], errors: [1,,], leaf: 14 },
				endpoint: null
			},
			{
				id: "/login",
				pattern: /^\/login\/?$/,
				params: [],
				page: { layouts: [0,], errors: [1,], leaf: 31 },
				endpoint: null
			},
			{
				id: "/logout",
				pattern: /^\/logout\/?$/,
				params: [],
				page: { layouts: [0,], errors: [1,], leaf: 32 },
				endpoint: null
			},
			{
				id: "/(student)/student-cfit",
				pattern: /^\/student-cfit\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 20 },
				endpoint: null
			},
			{
				id: "/(student)/student-cfit/result",
				pattern: /^\/student-cfit\/result\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 21 },
				endpoint: null
			},
			{
				id: "/(student)/student-dashboard",
				pattern: /^\/student-dashboard\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 22 },
				endpoint: null
			},
			{
				id: "/(student)/student-disc",
				pattern: /^\/student-disc\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 23 },
				endpoint: null
			},
			{
				id: "/(student)/student-disc/result",
				pattern: /^\/student-disc\/result\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 24 },
				endpoint: null
			},
			{
				id: "/(student)/student-holland",
				pattern: /^\/student-holland\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 25 },
				endpoint: null
			},
			{
				id: "/(student)/student-holland/result",
				pattern: /^\/student-holland\/result\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 26 },
				endpoint: null
			},
			{
				id: "/(student)/student-ist",
				pattern: /^\/student-ist\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 27 },
				endpoint: null
			},
			{
				id: "/(student)/student-ist/result",
				pattern: /^\/student-ist\/result\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 28 },
				endpoint: null
			},
			{
				id: "/(student)/student-papi",
				pattern: /^\/student-papi\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 29 },
				endpoint: null
			},
			{
				id: "/(student)/student-papi/result",
				pattern: /^\/student-papi\/result\/?$/,
				params: [],
				page: { layouts: [0,5,], errors: [1,,], leaf: 30 },
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
