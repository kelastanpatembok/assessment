import { PUBLIC_AUTH_URL } from '$env/static/public';

const AUTH_BASE = (PUBLIC_AUTH_URL || 'http://127.0.0.1:1007/api').replace(/\/+$/, '');

export type AuthProfile = {
	id: string;
	name: string;
	username: string;
	email: string;
	avatarUrl: string | null;
};

/**
 * Fetches the current user's public profile (name, email, avatar) from the
 * shared auth domain. Returns null when the profile can't be resolved.
 */
export async function getAuthProfile(
	userId: string,
	token: string
): Promise<AuthProfile | null> {
	try {
		const res = await fetch(`${AUTH_BASE}/users/${encodeURIComponent(userId)}`, {
			headers: { Authorization: `Bearer ${token}` }
		});
		if (!res.ok) return null;
		const d = await res.json();
		return {
			id: d.id,
			name: d.name ?? d.username,
			username: d.username,
			email: d.email,
			avatarUrl: d.avatarUrl ?? null
		};
	} catch {
		return null;
	}
}
