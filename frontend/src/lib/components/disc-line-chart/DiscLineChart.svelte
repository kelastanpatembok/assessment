<script lang="ts">
  type Props = {
    title: string;
    subtitle: string;
    values: { d: number; i: number; s: number; c: number };
  };

  let { title, subtitle, values }: Props = $props();

  const width = 220;
  const height = 180;
  const padTop = 12;
  const padBottom = 24;
  const padLeft = 28;
  const padRight = 12;
  const plotW = width - padLeft - padRight;
  const plotH = height - padTop - padBottom;

  let points = $derived([
    { label: 'D', value: values.d },
    { label: 'I', value: values.i },
    { label: 'S', value: values.s },
    { label: 'C', value: values.c },
  ]);

  // Domain always includes 0 (the reference baseline every DISC line graph
  // shows), padded ~15% so the line never touches the plot edge.
  let domain = $derived.by(() => {
    const vals = points.map(p => p.value);
    const rawMin = Math.min(0, ...vals);
    const rawMax = Math.max(0, ...vals);
    const span = rawMax - rawMin || 1;
    return { min: rawMin - span * 0.15, max: rawMax + span * 0.15 };
  });

  function yFor(value: number) {
    const { min, max } = domain;
    const t = (value - min) / (max - min || 1);
    return padTop + plotH * (1 - t);
  }

  function xFor(index: number) {
    return padLeft + (plotW * index) / (points.length - 1);
  }

  let linePath = $derived(
    points.map((p, idx) => `${idx === 0 ? 'M' : 'L'} ${xFor(idx)} ${yFor(p.value)}`).join(' ')
  );

  // A handful of "nice" gridline values across the domain, zero always included.
  let gridlines = $derived.by(() => {
    const { min, max } = domain;
    const step = (max - min) / 4;
    const raw = [min, min + step, min + step * 2, min + step * 3, max];
    const rounded = raw.map(v => Math.round(v));
    return Array.from(new Set([...rounded, 0])).sort((a, b) => a - b);
  });
</script>

<div class="flex flex-col items-center gap-1">
  <p class="text-center text-xs font-semibold">{title}</p>
  <p class="text-muted-foreground text-center text-xs">{subtitle}</p>
  <svg viewBox="0 0 {width} {height}" class="mt-1 w-full max-w-[220px]" role="img" aria-label="{title}: {subtitle}">
    {#each gridlines as g}
      <line
        x1={padLeft} x2={width - padRight}
        y1={yFor(g)} y2={yFor(g)}
        style="stroke: {g === 0 ? 'var(--lp-rule-2)' : 'var(--lp-rule)'}"
        stroke-width={g === 0 ? 1.25 : 1}
      />
      <text x={padLeft - 6} y={yFor(g)} dy="0.32em" text-anchor="end" class="text-[9px]" style="fill: var(--lp-muted)">
        {g}
      </text>
    {/each}

    <path d={linePath} fill="none" style="stroke: var(--lp-ink)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" />

    {#each points as p, idx}
      <circle cx={xFor(idx)} cy={yFor(p.value)} r="3" style="fill: var(--lp-ink)">
        <title>{p.label}: {p.value}</title>
      </circle>
      <text x={xFor(idx)} y={height - padBottom + 14} text-anchor="middle" class="text-[10px] font-medium" style="fill: var(--lp-muted)">
        {p.label}
      </text>
    {/each}
  </svg>
</div>
