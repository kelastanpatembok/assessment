<script lang="ts">
  type TraitDetail = {
    traitCode: string;
    traitName: string;
    score: number;
    band: 'TINGGI' | 'RENDAH';
  };

  type Props = { traitDetails: TraitDetail[] };
  type Point = { x: number; y: number };

  let { traitDetails }: Props = $props();

  const SIZE = 720;
  const CENTER = SIZE / 2;
  const ZERO_RADIUS = 46;
  const SCORE_RADIUS = 246;
  const TRAIT_INNER_RADIUS = 262;
  const TRAIT_OUTER_RADIUS = 300;
  const CATEGORY_INNER_RADIUS = 306;
  const CATEGORY_OUTER_RADIUS = 342;
  const MAX_SCORE = 9;
  const START_ANGLE = -108;
  const TRAIT_STEP = 18;

  // Official clockwise psychogram order, with G at twelve o'clock.
  const TRAIT_ORDER = ['N', 'G', 'A', 'L', 'P', 'I', 'T', 'V', 'X', 'S', 'B', 'O', 'R', 'D', 'C', 'Z', 'E', 'K', 'F', 'W'];

  const CATEGORIES = [
    { label: 'ARAH KERJA', start: 0, end: 2 },
    { label: 'KEPEMIMPINAN', start: 3, end: 5 },
    { label: 'AKTIVITAS', start: 6, end: 7 },
    { label: 'SIKAP SOSIAL', start: 8, end: 11 },
    { label: 'GAYA KERJA', start: 12, end: 14 },
    { label: 'TEMPERAMEN', start: 15, end: 17 },
    { label: 'KEPATUHAN', start: 18, end: 19 },
  ];

  function polar(radius: number, angle: number): Point {
    const radians = (angle * Math.PI) / 180;
    return {
      x: CENTER + radius * Math.cos(radians),
      y: CENTER + radius * Math.sin(radians),
    };
  }

  function scoreRadius(score: number) {
    const safeScore = Math.min(MAX_SCORE, Math.max(0, score));
    return ZERO_RADIUS + (safeScore / MAX_SCORE) * (SCORE_RADIUS - ZERO_RADIUS);
  }

  function annularSegment(innerRadius: number, outerRadius: number, startAngle: number, endAngle: number) {
    const outerStart = polar(outerRadius, startAngle);
    const outerEnd = polar(outerRadius, endAngle);
    const innerEnd = polar(innerRadius, endAngle);
    const innerStart = polar(innerRadius, startAngle);
    const largeArc = endAngle - startAngle > 180 ? 1 : 0;

    return [
      `M ${outerStart.x} ${outerStart.y}`,
      `A ${outerRadius} ${outerRadius} 0 ${largeArc} 1 ${outerEnd.x} ${outerEnd.y}`,
      `L ${innerEnd.x} ${innerEnd.y}`,
      `A ${innerRadius} ${innerRadius} 0 ${largeArc} 0 ${innerStart.x} ${innerStart.y}`,
      'Z',
    ].join(' ');
  }

  function readableTangentialRotation(angle: number) {
    let rotation = (angle + 90 + 360) % 360;
    if (rotation > 90 && rotation < 270) rotation = (rotation + 180) % 360;
    return rotation;
  }

  let traitsByCode = $derived(new Map(traitDetails.map((trait) => [trait.traitCode.toUpperCase(), trait])));
  let plottedTraits = $derived(
    TRAIT_ORDER.map((code, index) => {
      const trait = traitsByCode.get(code);
      const score = trait?.score ?? 0;
      const angle = START_ANGLE + index * TRAIT_STEP;
      return {
        code,
        angle,
        score,
        name: trait?.traitName ?? code,
        point: polar(scoreRadius(score), angle),
      };
    })
  );
  let profilePoints = $derived(plottedTraits.map((trait) => `${trait.point.x},${trait.point.y}`).join(' '));
</script>

<div class="papi-chart">
  <svg
    viewBox={`0 0 ${SIZE} ${SIZE}`}
    data-testid="papi-psychogram"
    role="img"
    aria-labelledby="papi-chart-title papi-chart-description"
    preserveAspectRatio="xMidYMid meet"
  >
    <title id="papi-chart-title">Diagram profil PAPI Kostick</title>
    <desc id="papi-chart-description">
      Psikogram melingkar yang memetakan skor nol sampai sembilan untuk dua puluh trait PAPI Kostick.
    </desc>

    <circle class="chart-background" cx={CENTER} cy={CENTER} r={CATEGORY_OUTER_RADIUS + 4} />

    {#each CATEGORIES as category, index}
      {@const startAngle = START_ANGLE + (category.start - 0.5) * TRAIT_STEP}
      {@const endAngle = START_ANGLE + (category.end + 0.5) * TRAIT_STEP}
      {@const middleAngle = (startAngle + endAngle) / 2}
      {@const labelPoint = polar((CATEGORY_INNER_RADIUS + CATEGORY_OUTER_RADIUS) / 2, middleAngle)}
      <path
        class:category-alternate={index % 2 === 1}
        class="category-segment"
        d={annularSegment(CATEGORY_INNER_RADIUS, CATEGORY_OUTER_RADIUS, startAngle, endAngle)}
      />
      <text
        class="category-label"
        x={labelPoint.x}
        y={labelPoint.y}
        transform={`rotate(${readableTangentialRotation(middleAngle)} ${labelPoint.x} ${labelPoint.y})`}
      >{category.label}</text>
    {/each}

    {#each TRAIT_ORDER as code, index}
      {@const angle = START_ANGLE + index * TRAIT_STEP}
      {@const labelPoint = polar((TRAIT_INNER_RADIUS + TRAIT_OUTER_RADIUS) / 2, angle)}
      <path
        class="trait-segment"
        d={annularSegment(
          TRAIT_INNER_RADIUS,
          TRAIT_OUTER_RADIUS,
          angle - TRAIT_STEP / 2,
          angle + TRAIT_STEP / 2
        )}
      />
      <text class="trait-label" x={labelPoint.x} y={labelPoint.y}>{code}</text>
    {/each}

    {#each Array(MAX_SCORE + 1) as _, score}
      <circle class:zero-ring={score === 0} class="score-ring" cx={CENTER} cy={CENTER} r={scoreRadius(score)} />
    {/each}

    {#each plottedTraits as trait}
      {@const inner = polar(ZERO_RADIUS, trait.angle)}
      {@const outer = polar(SCORE_RADIUS, trait.angle)}
      <line class="trait-axis" x1={inner.x} y1={inner.y} x2={outer.x} y2={outer.y}>
        <title>{trait.code} — {trait.name}</title>
      </line>
    {/each}

    {#each Array(MAX_SCORE + 1) as _, score}
      {@const radius = scoreRadius(score)}
      <text class="scale-label" x={CENTER + 7} y={CENTER - radius + 4}>{score}</text>
    {/each}

    <polygon class="profile-area" points={profilePoints} />
    <polyline class="profile-line" points={`${profilePoints} ${plottedTraits[0]?.point.x},${plottedTraits[0]?.point.y}`} />

    {#each plottedTraits as trait}
      <g data-trait={trait.code} data-score={trait.score} transform={`translate(${trait.point.x} ${trait.point.y})`}>
        <title>{trait.code} — {trait.name}: {trait.score} dari {MAX_SCORE}</title>
        <circle class="score-marker-ring" r="10" />
        <circle class="score-marker" r="8" />
        <text class="score-value" y="0.5">{trait.score}</text>
      </g>
    {/each}
  </svg>

  <div class="category-key" aria-label="Kelompok trait PAPI Kostick">
    {#each CATEGORIES as category}
      <span><strong>{category.label}</strong> · {TRAIT_ORDER.slice(category.start, category.end + 1).join(' ')}</span>
    {/each}
  </div>
</div>

<style>
  .papi-chart { width: 100%; }

  svg {
    display: block;
    width: 100%;
    height: auto;
    overflow: visible;
  }

  .chart-background {
    fill: color-mix(in oklab, var(--lp-paper, #fff) 94%, white);
    stroke: var(--lp-rule, #e2d8cb);
    stroke-width: 2;
  }

  .category-segment {
    fill: var(--lp-accent-deep, #74452f);
    stroke: var(--lp-paper, #fff);
    stroke-width: 3;
  }

  .category-segment.category-alternate {
    fill: color-mix(in oklab, var(--lp-accent-deep, #74452f) 86%, black);
  }

  .category-label {
    fill: white;
    font-size: 13px;
    font-weight: 750;
    letter-spacing: 1.2px;
    text-anchor: middle;
    dominant-baseline: middle;
  }

  .trait-segment {
    fill: color-mix(in oklab, var(--lp-paper, #fff) 88%, var(--lp-accent-bg, #dba483));
    stroke: var(--lp-rule, #cfc3b5);
    stroke-width: 1.5;
  }

  .trait-label {
    fill: var(--lp-ink, #3c3024);
    font-size: 20px;
    font-weight: 800;
    text-anchor: middle;
    dominant-baseline: middle;
  }

  .score-ring {
    fill: none;
    stroke: var(--lp-rule, #d8cec2);
    stroke-width: 1;
  }

  .score-ring.zero-ring {
    stroke: var(--lp-ink-2, #57493f);
    stroke-width: 1.5;
  }

  .trait-axis {
    stroke: var(--lp-rule, #d8cec2);
    stroke-width: 1;
  }

  .scale-label {
    fill: var(--lp-muted, #756a61);
    font-size: 10px;
    font-variant-numeric: tabular-nums;
  }

  .profile-area {
    fill: color-mix(in oklab, var(--lp-accent, #b86a47) 20%, transparent);
    stroke: none;
  }

  .profile-line {
    fill: none;
    stroke: var(--lp-accent, #b86a47);
    stroke-linecap: round;
    stroke-linejoin: round;
    stroke-width: 3;
  }

  .score-marker-ring {
    fill: var(--lp-paper, #fff);
    stroke: var(--lp-accent, #b86a47);
    stroke-width: 1.5;
  }

  .score-marker { fill: var(--lp-accent, #b86a47); }

  .score-value {
    fill: white;
    font-size: 9px;
    font-weight: 800;
    text-anchor: middle;
    dominant-baseline: middle;
    pointer-events: none;
  }

  .category-key {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(170px, 1fr));
    gap: 0.4rem 1rem;
    margin-top: 0.75rem;
    color: var(--lp-muted, #756a61);
    font-size: 0.72rem;
    line-height: 1.35;
  }

  .category-key strong {
    color: var(--lp-ink-2, #57493f);
    font-size: 0.68rem;
    letter-spacing: 0.035em;
  }

  @media (max-width: 480px) {
    .category-label {
      font-size: 14px;
      letter-spacing: 0.7px;
    }

    .trait-label { font-size: 22px; }
  }
</style>
