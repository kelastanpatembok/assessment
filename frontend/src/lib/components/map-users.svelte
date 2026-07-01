<script lang="ts">
	import { onMount } from 'svelte';
	import 'leaflet/dist/leaflet.css';
	import { PROVINCE_COORDINATES } from '$lib/data/province-coordinates';

	type User = {
		id: string;
		name: string;
		province?: string | null;
	};

	let {
		users = [],
		selectedProvince = null,
		onProvinceClick = (_province: string | null) => {}
	}: {
		users: User[];
		selectedProvince?: string | null;
		onProvinceClick?: (province: string | null) => void;
	} = $props();

	let mapElement: HTMLDivElement;
	let leaflet: any = null;
	let map: any = null;
	let markers = new Map<string, any>();
	let previousProvinces = new Set<string>();
	let previousCounts: Record<string, number> = {};

	function groupUsersByProvince(items: User[]) {
		return items.reduce<Record<string, number>>((acc, user) => {
			if (user.province) {
				acc[user.province] = (acc[user.province] || 0) + 1;
			}
			return acc;
		}, {});
	}

	function updateMarkers() {
		if (!leaflet || !map) return;

		for (const marker of markers.values()) {
			map.removeLayer(marker);
		}
		markers.clear();

		const usersByProvince = groupUsersByProvince(users);

		for (const [province, count] of Object.entries(usersByProvince)) {
			const coords = PROVINCE_COORDINATES[province];
			if (!coords) continue;

			const marker = leaflet.circleMarker(coords, {
				radius: Math.min(Math.max(count * 2, 8), 25),
				fillColor: '#22c55e',
				color: '#15803d',
				weight: 2,
				opacity: 0.8,
				fillOpacity: 0.7
			});

			marker.on('click', (event: any) => {
				leaflet?.DomEvent.stopPropagation(event);
				onProvinceClick(province);
			});

			marker.addTo(map);

			if (province === selectedProvince) {
				const element = marker.getElement();
				element?.classList.add('pulse-marker');
			}

			const previousCount = previousCounts[province] || 0;
			const isNewProvince = !previousProvinces.has(province);
			const hasIncreased = count > previousCount;

			if (isNewProvince || hasIncreased) {
				let blinkCount = 0;
				const blinkInterval = setInterval(() => {
					blinkCount += 1;
					if (blinkCount > 6) {
						clearInterval(blinkInterval);
						marker.setStyle({ opacity: 0.8, fillOpacity: 0.7, weight: 2 });
						return;
					}

					const visible = blinkCount % 2 === 0;
					marker.setStyle({
						opacity: visible ? 0.95 : 0.35,
						fillOpacity: visible ? 0.95 : 0.2,
						weight: visible ? 4 : 2
					});
				}, 300);
			}

			markers.set(province, marker);
		}

		previousProvinces = new Set(Object.keys(usersByProvince));
		previousCounts = usersByProvince;
	}

	onMount(() => {
		let disposed = false;

		void (async () => {
			leaflet = await import('leaflet');
			if (disposed) return;

			map = leaflet.map(mapElement).setView([-2.5, 113.5], 5);

			leaflet
				.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
					attribution: '&copy; OpenStreetMap contributors',
					maxZoom: 19
				})
				.addTo(map);

			map.on('click', () => onProvinceClick(null));
			updateMarkers();
		})();

		return () => {
			disposed = true;
			for (const marker of markers.values()) {
				map?.removeLayer(marker);
			}
			markers.clear();
			map?.remove();
			map = null;
		};
	});

	$effect(() => {
		users;
		selectedProvince;
		if (map && leaflet) {
			updateMarkers();
		}
	});
</script>

<div bind:this={mapElement} class="h-full w-full"></div>

<style>
	:global(.pulse-marker) {
		animation: pulse 2s infinite;
	}

	@keyframes pulse {
		0%,
		100% {
			opacity: 0.8;
			filter: drop-shadow(0 0 0 rgba(34, 197, 94, 0.35));
		}

		50% {
			opacity: 1;
			filter: drop-shadow(0 0 8px rgba(34, 197, 94, 0.55));
		}
	}
</style>
