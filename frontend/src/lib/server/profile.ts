import { PUBLIC_PROFILE_URL } from '$env/static/public';

const PROFILE_BASE = (PUBLIC_PROFILE_URL || 'http://127.0.0.1:1008/api').replace(/\/+$/, '');

export type AuthProfile = {
	id: string;
	name: string;
	username: string;
	email: string;
	avatarUrl: string | null;
};

/**
 * Fetches the current user's profile (name, email, avatar) from the reusable
 * `profile` domain. The domain syncs identity fields (name/avatar) from the
 * `auth` domain on every read, so they are always fresh.
 */
export async function getProfile(userId: string, token: string): Promise<AuthProfile | null> {
	try {
		const res = await fetch(`${PROFILE_BASE}/users/${encodeURIComponent(userId)}`, {
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
