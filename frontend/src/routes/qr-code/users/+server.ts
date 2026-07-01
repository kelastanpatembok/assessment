import { env } from '$env/dynamic/private';
import { json } from '@sveltejs/kit';

const authBaseUrl = env.PUBLIC_AUTH_URL || 'http://127.0.0.1:3001/api';
export const prerender = false;

export async function GET() {
	try {
		const response = await fetch(`${authBaseUrl}/users`, {
			cache: 'no-store'
		});
		if (!response.ok) {
			return json(
				{ message: 'Failed to fetch users' },
				{
					status: response.status,
					headers: {
						'cache-control': 'no-store, no-cache, must-revalidate, max-age=0'
					}
				}
			);
		}

		const users = await response.json();
		return json(users, {
			headers: {
				'cache-control': 'no-store, no-cache, must-revalidate, max-age=0'
			}
		});
	} catch (error) {
		console.error('Failed to proxy /users from auth service:', error);
		return json(
			{ message: 'Failed to fetch users' },
			{
				status: 502,
				headers: {
					'cache-control': 'no-store, no-cache, must-revalidate, max-age=0'
				}
			}
		);
	}
}
