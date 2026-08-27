<script lang="ts">
  import { onMount } from 'svelte';
  import SiteHeader from '$lib/components/site/SiteHeader.svelte';
  import SiteFooter from '$lib/components/site/SiteFooter.svelte';
  let { data } = $props();
  let host: HTMLDivElement;
  let selected = $state<any>(null);
  let enabled = $state<Record<string, boolean>>({ 'SMA/MA': true, SMK: true, 'SMP/MTs': true, 'SD/MI': true, Lainnya: true });
  let leaflet = $state<any>(null);
  let map = $state<any>(null);
  let markers: any[] = [];
  const categories = ['SMA/MA', 'SMK', 'SMP/MTs', 'SD/MI', 'Lainnya'];
  const visible = $derived(data.points.filter((point: any) => enabled[point.type]));

  onMount(() => {
    let disposed = false;
    void import('leaflet').then((L) => {
      if (disposed) return;
      leaflet = L;
      map = L.map(host, { scrollWheelZoom: true }).setView([-2.55, 118.0], 5);
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom: 18, attribution: '&copy; OpenStreetMap contributors' }).addTo(map);
    });
    return () => { disposed = true; map?.remove(); };
  });
  $effect(() => {
    if (!leaflet || !map) return;
    const L = leaflet;
    markers.forEach((marker) => marker.remove());
    const color: Record<string,string> = { 'SMA/MA':'#b45309', SMK:'#0f766e', 'SMP/MTs':'#2563eb', 'SD/MI':'#7c3aed', Lainnya:'#64748b' };
    markers = [];
    for (const point of visible) {
      const marker = L.circleMarker([point.latitude, point.longitude], { radius: 6, color: '#fff', weight: 1.5, fillColor: color[point.type] ?? color.Lainnya, fillOpacity: .95 }).addTo(map);
      marker.bindTooltip(point.name, { direction: 'top', opacity: .92 });
      marker.on('click', () => selected = point);
      markers.push(marker);
    }
    if (markers.length) map.fitBounds(L.featureGroup(markers).getBounds().pad(.12));
  });
</script>

<svelte:head><title>Peta Sekolah — Asesmen</title><meta name="description" content="Peta sekolah yang terdaftar pada platform Asesmen." /></svelte:head>
<SiteHeader user={null} profile={null} />
<main class="page">
  <nav class="crumb" aria-label="Breadcrumb"><a href="/">Beranda</a><span>/</span><span>Peta</span></nav>
  <header><h1>Peta Sekolah</h1><p>Cari sekolah terdaftar dan lihat lokasi yang memiliki koordinat terverifikasi dalam data sekolah.</p></header>
  <form class="search" method="GET"><label for="q">Cari nama atau NPSN</label><div><input id="q" name="q" value={data.search} placeholder="Contoh: SMA 3 Yogyakarta"/><button>Cari</button></div></form>
  <div class="layout">
    <section class="map-card"><div bind:this={host} class="map" aria-label="Peta sekolah Indonesia"></div><p class="attribution">Peta © OpenStreetMap contributors. {data.points.length} lokasi dimuat untuk pencarian ini.</p></section>
    <aside>
      <h2>Legenda</h2>
      {#each categories as category}<label class="legend"><input type="checkbox" bind:checked={enabled[category]}/><i class:smama={category==='SMA/MA'} class:smk={category==='SMK'} class:smp={category==='SMP/MTs'} class:sd={category==='SD/MI'}></i>{category}</label>{/each}
      <a class="register" href="/daftarkan-sekolah">Daftarkan Sekolah</a>
      {#if selected}<section class="detail"><h2>{selected.name}</h2><p>{selected.type}{#if selected.npsn} · NPSN {selected.npsn}{/if}</p>{#if selected.address}<p>{selected.address}</p>{/if}{#if selected.city || selected.province}<p>{[selected.city, selected.province].filter(Boolean).join(', ')}</p>{/if}</section>{/if}
    </aside>
  </div>
</main>
<SiteFooter />
<style>@import 'leaflet/dist/leaflet.css';.page{max-width:72rem;margin:0 auto;padding:2rem clamp(1.25rem,4vw,2.5rem) 4rem;color:var(--lp-ink,#34271f)}.crumb{display:flex;gap:.55rem;font-size:.9rem;color:#6d6258}.crumb a{color:#8a4614}header{max-width:48rem;margin:1.4rem 0}h1{font-family:var(--lp-font-display,Georgia,serif);font-size:clamp(2.2rem,5vw,4rem);margin:0}header p{color:#655b52;line-height:1.65}.search{max-width:38rem;margin:1.4rem 0}.search label{display:block;font-weight:650;margin-bottom:.45rem}.search div{display:flex;gap:.5rem}.search input{flex:1;border:1px solid #d7cabc;border-radius:.55rem;padding:.75rem}.search button,.register{background:#7a3b12;color:white;border:0;border-radius:.55rem;padding:.75rem 1rem;font-weight:650}.layout{display:grid;grid-template-columns:minmax(0,1fr) 17rem;gap:1rem}.map-card,aside{border:1px solid #e2d8ce;border-radius:.8rem;background:#fff;overflow:hidden}.map{height:min(68vh,42rem);min-height:30rem}.attribution{margin:0;padding:.65rem .8rem;font-size:.75rem;color:#74695f}aside{padding:1rem;height:max-content}aside h2{font-size:1rem;margin:0 0 .7rem}.legend{display:flex;align-items:center;gap:.55rem;margin:.6rem 0}.legend i{width:.7rem;height:.7rem;border-radius:50%;background:#64748b}.legend i.smama{background:#b45309}.legend i.smk{background:#0f766e}.legend i.smp{background:#2563eb}.legend i.sd{background:#7c3aed}.register{display:block;text-align:center;text-decoration:none;margin-top:1rem}.detail{border-top:1px solid #e2d8ce;margin-top:1rem;padding-top:1rem}.detail p{font-size:.88rem;line-height:1.45;color:#655b52}@media(max-width:760px){.layout{grid-template-columns:1fr}.map{height:55vh;min-height:22rem}}</style>
