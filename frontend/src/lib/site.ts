/**
 * Site-level SEO metadata for the Assessment estate.
 *
 * The public hostname comes from the estate's `ecompose.yml`
 * (`assessment.jogjaitcamp.com`). Production deploys set `PUBLIC_SITE_URL`;
 * this fallback keeps OG/absolute URLs correct without it.
 */

const SITE_URL_RAW: string =
	(import.meta.env.PUBLIC_SITE_URL as string | undefined) || 'https://assessment.jogjaitcamp.com';

export const SITE_URL: string = SITE_URL_RAW.replace(/\/+$/, '');
export const SITE_NAME: string = 'Asesmen';
export const SITE_TITLE: string = 'Asesmen — Platform Asesmen Psikometri';
export const SITE_DESCRIPTION: string =
	'Platform asesmen psikometri untuk sekolah, psikolog, dan masyarakat — tes kepribadian, minat karier, dan kecerdasan yang tervalidasi secara ilmiah.';
export const OG_IMAGE: string = `${SITE_URL}/og.png`;
export const OG_LOCALE: string = 'id_ID';
