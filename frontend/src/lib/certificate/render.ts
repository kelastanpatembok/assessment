import { browser } from '$app/environment';

/**
 * Server-agnostic, pure-canvas certificate renderer. Draws a formal,
 * brand-themed certificate (A4-landscape proportions) and returns a PNG
 * Blob. The user's photo is drawn as a circular crop when available;
 * otherwise their initials render in a terracotta monogram.
 */

export type CertificateTestKey = 'disc' | 'holland' | 'papi' | 'cfit' | 'ist';

export type CertificateInput = {
  testKey: CertificateTestKey;
  testName: string;
  testDescription: string;
  resultLabel: string;
  resultLines: string[];
  studentName: string;
  avatarUrl?: string | null;
  initials: string;
  issuedAt?: Date;
  studentId?: string;
};

// Brand palette (concrete values — canvas can't resolve CSS custom properties).
const PALETTE = {
  paper: '#f8f1e6',
  paperDeep: '#f1e6d4',
  ink: '#3d3126',
  ink2: '#655648',
  muted: '#7a6b5a',
  rule: '#dccfc0',
  rule2: '#c5b3a0',
  accent: '#b86a47',
  accentDeep: '#8f4f33',
  gold: '#b08d57'
} as const;

const W = 1600;
const H = 1132;

const DISPLAY_FONT = '"Fraunces Variable", Georgia, serif';
const BODY_FONT = '"Figtree Variable", "Figtree", ui-sans-serif, system-ui, sans-serif';

async function ensureFonts() {
  if (!browser) return;
  try {
    await Promise.all([
      document.fonts.load(`600 64px ${DISPLAY_FONT}`),
      document.fonts.load(`560 96px ${DISPLAY_FONT}`),
      document.fonts.load(`400 20px ${BODY_FONT}`),
      document.fonts.load(`600 20px ${BODY_FONT}`),
      document.fonts.ready
    ]);
  } catch {
    // Canvas falls back to Georgia/system-sans — still legible.
  }
}

function wrapLines(ctx: CanvasRenderingContext2D, text: string, maxWidth: number): string[] {
  const words = text.split(/\s+/);
  const lines: string[] = [];
  let line = '';
  for (const word of words) {
    const candidate = line ? `${line} ${word}` : word;
    if (ctx.measureText(candidate).width > maxWidth && line) {
      lines.push(line);
      line = word;
    } else {
      line = candidate;
    }
  }
  if (line) lines.push(line);
  return lines;
}

function centerText(
  ctx: CanvasRenderingContext2D,
  text: string,
  y: number,
  font: string,
  fill: string,
  maxWidth: number,
  letterSpacing = 0
): number {
  ctx.font = font;
  ctx.fillStyle = fill;
  ctx.textAlign = 'center';
  ctx.textBaseline = 'alphabetic';
  if (letterSpacing && 'letterSpacing' in ctx) {
    (ctx as unknown as { letterSpacing: string }).letterSpacing = `${letterSpacing}px`;
  }
  const lines = wrapLines(ctx, text, maxWidth);
  const lineHeight = ctx.measureText('Mg').width * 1.18;
  let yCursor = y;
  for (const line of lines) {
    ctx.fillText(line, W / 2, yCursor);
    yCursor += lineHeight;
  }
  if (letterSpacing && 'letterSpacing' in ctx) {
    (ctx as unknown as { letterSpacing: string }).letterSpacing = '0px';
  }
  return yCursor;
}

function loadImage(url: string): Promise<HTMLImageElement> {
  return new Promise((resolve, reject) => {
    const img = new Image();
    img.crossOrigin = 'anonymous';
    img.onload = () => resolve(img);
    img.onerror = reject;
    img.src = url;
  });
}

function drawCircleImage(ctx: CanvasRenderingContext2D, img: HTMLImageElement, cx: number, cy: number, r: number) {
  ctx.save();
  ctx.beginPath();
  ctx.arc(cx, cy, r, 0, Math.PI * 2);
  ctx.closePath();
  ctx.clip();
  const size = Math.min(img.naturalWidth, img.naturalHeight);
  const sx = (img.naturalWidth - size) / 2;
  const sy = (img.naturalHeight - size) / 2;
  ctx.drawImage(img, sx, sy, size, size, cx - r, cy - r, r * 2, r * 2);
  ctx.restore();
}

function diamond(ctx: CanvasRenderingContext2D, cx: number, cy: number, r: number, fill: string) {
  ctx.fillStyle = fill;
  ctx.beginPath();
  ctx.moveTo(cx, cy - r);
  ctx.lineTo(cx + r, cy);
  ctx.lineTo(cx, cy + r);
  ctx.lineTo(cx - r, cy);
  ctx.closePath();
  ctx.fill();
}

function roundedRect(
  ctx: CanvasRenderingContext2D,
  x: number, y: number, w: number, h: number, r: number
) {
  const maybe = ctx as CanvasRenderingContext2D & { roundRect?: (x: number, y: number, w: number, h: number, r: number) => void };
  if (typeof maybe.roundRect === 'function') {
    maybe.roundRect(x, y, w, h, r);
    return;
  }
  ctx.rect(x, y, w, h);
}

/** Deterministic certificate serial, e.g. ASM-2026-3F4A1C */
export function serialFor(studentId: string | undefined, testKey: string, issuedAt = new Date()): string {
  const seed = `${studentId ?? 'anonymous'}:${testKey}`;
  let hash = 2166136261;
  for (let i = 0; i < seed.length; i++) {
    hash ^= seed.charCodeAt(i);
    hash = Math.imul(hash, 16777619);
  }
  const code = (hash >>> 0).toString(16).toUpperCase().padStart(6, '0').slice(0, 6);
  return `ASM-${issuedAt.getFullYear()}-${code}`;
}

/** Draws the certificate and resolves with a PNG Blob. */
export async function renderCertificate(input: CertificateInput): Promise<Blob> {
  await ensureFonts();

  const canvas = document.createElement('canvas');
  canvas.width = W;
  canvas.height = H;
  const ctx = canvas.getContext('2d')!;
  const issuedAt = input.issuedAt ?? new Date();

  // ── Background ─────────────────────────────────────────────
  const bg = ctx.createLinearGradient(0, 0, 0, H);
  bg.addColorStop(0, PALETTE.paper);
  bg.addColorStop(1, PALETTE.paperDeep);
  ctx.fillStyle = bg;
  ctx.fillRect(0, 0, W, H);

  // ── Frames ─────────────────────────────────────────────────
  ctx.save();
  ctx.strokeStyle = PALETTE.accentDeep;
  ctx.globalAlpha = 0.85;
  ctx.lineWidth = 2.5;
  ctx.strokeRect(30, 30, W - 60, H - 60);
  ctx.globalAlpha = 0.75;
  ctx.strokeStyle = PALETTE.ink;
  ctx.lineWidth = 1.2;
  ctx.strokeRect(48, 48, W - 96, H - 96);

  // Corner ornaments
  const orn = 10;
  const corners: [number, number][] = [
    [48, 48], [W - 48, 48], [48, H - 48], [W - 48, H - 48]
  ];
  for (const [x, y] of corners) {
    diamond(ctx, x, y, orn, PALETTE.accent);
  }
  ctx.restore();

  // ── Header ─────────────────────────────────────────────────
  ctx.textAlign = 'center';
  centerText(ctx, 'LEMBAGA ASESMEN PSIKOMETRI', 168, `600 15px ${BODY_FONT}`, PALETTE.muted, 900, 4);

  // Brand emblem: rules + accent square + wordmark
  const markY = 216;
  ctx.strokeStyle = PALETTE.rule2;
  ctx.lineWidth = 1.5;
  ctx.beginPath();
  ctx.moveTo(W / 2 - 260, markY);
  ctx.lineTo(W / 2 - 70, markY);
  ctx.moveTo(W / 2 + 70, markY);
  ctx.lineTo(W / 2 + 260, markY);
  ctx.stroke();
  ctx.fillStyle = PALETTE.accent;
  ctx.fillRect(W / 2 - 11, markY - 11, 22, 22);
  diamond(ctx, W / 2 - 48, markY, 5, PALETTE.accent);
  diamond(ctx, W / 2 + 48, markY, 5, PALETTE.accent);
  centerText(ctx, 'Asesmen', markY + 58, `600 46px ${DISPLAY_FONT}`, PALETTE.ink, 700);

  centerText(ctx, 'SERTIFIKAT', 328, `600 68px ${DISPLAY_FONT}`, PALETTE.accentDeep, 900, 6);
  centerText(ctx, 'CERTIFICATE OF ACHIEVEMENT', 380, `500 18px ${BODY_FONT}`, PALETTE.muted, 900, 7);

  // Ornamental divider
  const divY = 424;
  ctx.strokeStyle = PALETTE.accent;
  ctx.globalAlpha = 0.7;
  ctx.lineWidth = 1.6;
  ctx.beginPath();
  ctx.moveTo(W / 2 - 320, divY);
  ctx.lineTo(W / 2 - 26, divY);
  ctx.moveTo(W / 2 + 26, divY);
  ctx.lineTo(W / 2 + 320, divY);
  ctx.stroke();
  ctx.globalAlpha = 1;
  diamond(ctx, W / 2, divY, 9, PALETTE.accentDeep);

  // ── Avatar or initials monogram ────────────────────────────
  const avatarR = 62;
  const avatarCx = W / 2;
  const avatarCy = 506;
  let hasAvatar = false;
  if (input.avatarUrl) {
    try {
      const img = await loadImage(input.avatarUrl);
      drawCircleImage(ctx, img, avatarCx, avatarCy, avatarR);
      hasAvatar = true;
    } catch {
      hasAvatar = false;
    }
  }
  if (!hasAvatar) {
    ctx.save();
    ctx.beginPath();
    ctx.arc(avatarCx, avatarCy, avatarR, 0, Math.PI * 2);
    ctx.fillStyle = PALETTE.accent;
    ctx.fill();
    ctx.lineWidth = 4;
    ctx.strokeStyle = PALETTE.paper;
    ctx.stroke();
    ctx.fillStyle = PALETTE.paper;
    ctx.font = `600 52px ${DISPLAY_FONT}`;
    ctx.textAlign = 'center';
    ctx.textBaseline = 'middle';
    ctx.fillText(input.initials || '?', avatarCx, avatarCy + 2);
    ctx.restore();
  }

  // ── Recipient ──────────────────────────────────────────────
  centerText(ctx, 'DIBERIKAN KEPADA', 612, `600 16px ${BODY_FONT}`, PALETTE.muted, 900, 4);

  ctx.font = `560 72px ${DISPLAY_FONT}`;
  ctx.fillStyle = PALETTE.ink;
  ctx.textAlign = 'center';
  const nameWidth = Math.min(ctx.measureText(input.studentName).width + 40, 1000);
  centerText(ctx, input.studentName, 686, `560 72px ${DISPLAY_FONT}`, PALETTE.ink, 1000);

  // underline
  ctx.strokeStyle = PALETTE.accent;
  ctx.lineWidth = 3;
  ctx.beginPath();
  ctx.moveTo(W / 2 - nameWidth / 2, 706);
  ctx.lineTo(W / 2 + nameWidth / 2, 706);
  ctx.stroke();
  diamond(ctx, W / 2, 706, 6, PALETTE.accentDeep);

  // ── Body intro ─────────────────────────────────────────────
  const bodyY = centerText(
    ctx,
    'telah menyelesaikan tes psikometri berikut dan memperoleh hasil sebagai berikut:',
    748,
    `400 20px ${BODY_FONT}`,
    PALETTE.ink2,
    980
  );

  // ── Test panel ─────────────────────────────────────────────
  const panelX = 210;
  const panelW = W - 420;
  const panelY = 772;
  const panelH = 196;
  ctx.save();
  ctx.fillStyle = 'rgba(248, 241, 230, 0.85)';
  ctx.beginPath();
  roundedRect(ctx, panelX, panelY, panelW, panelH, 16);
  ctx.fill();
  ctx.strokeStyle = PALETTE.rule2;
  ctx.lineWidth = 1.5;
  ctx.stroke();
  ctx.restore();

  centerText(ctx, input.testName, panelY + 40, `600 34px ${DISPLAY_FONT}`, PALETTE.accentDeep, panelW - 80, 1);
  let descY = centerText(
    ctx,
    input.testDescription,
    panelY + 78,
    `400 17px ${BODY_FONT}`,
    PALETTE.ink2,
    panelW - 90
  );
  descY += 16;
  ctx.fillStyle = PALETTE.muted;
  ctx.textAlign = 'center';
  ctx.font = `600 13px ${BODY_FONT}`;
  if ('letterSpacing' in ctx) (ctx as unknown as { letterSpacing: string }).letterSpacing = '3px';
  ctx.fillText(input.resultLabel.toUpperCase(), W / 2, descY);
  if ('letterSpacing' in ctx) (ctx as unknown as { letterSpacing: string }).letterSpacing = '0px';
  centerText(
    ctx,
    input.resultLines.join('  ·  '),
    descY + 30,
    `600 19px ${BODY_FONT}`,
    PALETTE.ink,
    panelW - 90
  );

  // ── Footer ─────────────────────────────────────────────────
  const serial = serialFor(input.studentId, input.testKey, issuedAt);
  const dateStr = issuedAt.toLocaleDateString('id-ID', {
    day: 'numeric', month: 'long', year: 'numeric'
  });

  ctx.textAlign = 'left';
  ctx.textBaseline = 'alphabetic';
  ctx.font = `600 13px ${BODY_FONT}`;
  ctx.fillStyle = PALETTE.muted;
  ctx.fillText('NOMOR SERTIFIKAT', 210, 1010);
  ctx.font = `600 20px ${BODY_FONT}`;
  ctx.fillStyle = PALETTE.ink;
  ctx.fillText(serial, 210, 1036);

  ctx.font = `600 13px ${BODY_FONT}`;
  ctx.fillStyle = PALETTE.muted;
  ctx.fillText('DITERBITKAN PADA', 210, 1074);
  ctx.font = `500 18px ${BODY_FONT}`;
  ctx.fillStyle = PALETTE.ink;
  ctx.fillText(dateStr, 210, 1098);

  // Signature block (right)
  ctx.textAlign = 'right';
  ctx.strokeStyle = PALETTE.ink;
  ctx.globalAlpha = 0.8;
  ctx.lineWidth = 1.4;
  ctx.beginPath();
  ctx.moveTo(W - 210 - 300, 1022);
  ctx.lineTo(W - 210, 1022);
  ctx.stroke();
  ctx.globalAlpha = 1;
  ctx.font = `600 20px ${BODY_FONT}`;
  ctx.fillStyle = PALETTE.ink;
  ctx.fillText('Admin Asesmen', W - 210, 1048);
  ctx.font = `500 14px ${BODY_FONT}`;
  ctx.fillStyle = PALETTE.muted;
  ctx.fillText('Penanggung Jawab', W - 210, 1072);

  // Verification line
  ctx.textAlign = 'center';
  ctx.font = `400 13px ${BODY_FONT}`;
  ctx.fillStyle = PALETTE.muted;
  ctx.fillText('Diverifikasi melalui assessment.jogjaitcamp.com', W / 2, 1102);

  return new Promise<Blob>((resolve, reject) => {
    canvas.toBlob((blob) => {
      if (blob) resolve(blob);
      else reject(new Error('Gagal membuat gambar sertifikat'));
    }, 'image/png');
  });
}
