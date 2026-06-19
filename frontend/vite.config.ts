import tailwindcss from '@tailwindcss/vite';
import adapter from '@sveltejs/adapter-node';
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig, loadEnv } from 'vite';

export default defineConfig(({ mode }) => {
	const env = loadEnv(mode, process.cwd(), '');
	const port = Number(process.env.PORT || env.PORT) || 5173;

	return {
		plugins: [
			tailwindcss(),
			sveltekit({
				compilerOptions: {
					// Force runes mode for the project, except for libraries. Can be removed in svelte 6.
					runes: ({ filename }) =>
						filename.split(/[/\\]/).includes('node_modules') ? undefined : true
				},
				adapter: adapter()
			})
		],
		server: { port },
		preview: { port },
		// Make sure environment variables with PUBLIC_ prefix are available
		define: {
			'process.env.PUBLIC_API_URL': JSON.stringify(process.env.PUBLIC_API_URL || env.PUBLIC_API_URL),
			'process.env.PUBLIC_AUTH_URL': JSON.stringify(process.env.PUBLIC_AUTH_URL || env.PUBLIC_AUTH_URL)
		}
	};
});
