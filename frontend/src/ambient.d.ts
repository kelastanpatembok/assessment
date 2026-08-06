declare module 'leaflet';

interface Window {
	__ASSESSMENT_USER__: { userId: string; username: string; role: string } | null;
	SupportWidgetConfig?: {
		ragUrl: string;
		siteName: string;
		requireLogin: boolean;
		signInUrl: string;
		signUpUrl: string;
		sessionMode: 'localStorage' | 'windowGlobal' | 'none';
		sessionKey: string;
	};
	__SUPPORT_WIDGET_LOADED__?: boolean;
}
