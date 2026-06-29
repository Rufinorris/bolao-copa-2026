#!/usr/bin/env node
// download-fotos.mjs — Baixa fotos dos jogadores via Wikipedia REST API
// Roda no GitHub Actions (IP limpo, sem rate limit)

import { readFileSync, writeFileSync, existsSync, mkdirSync, readdirSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT      = join(__dirname, '..');
const FOTOS_DIR = join(ROOT, 'fotos');
const CDN       = 'https://cdn.jsdelivr.net/gh/Rufinorris/bolao-copa-2026@master/fotos/';
const UA        = 'BolaoCopaDownloader/1.0 (grdfrufino@gmail.com)';

if (!existsSync(FOTOS_DIR)) mkdirSync(FOTOS_DIR);

// ── Ler elencos.js ─────────────────────────────────────────────────────────
const elencosRaw = readFileSync(join(ROOT, 'js', 'elencos.js'), 'utf8');

// NOMES_COMPLETOS: "CAMISA" → "Nome Completo FIFA"
const nomesCompletos = {};
for (const m of elencosRaw.matchAll(/"([^"]+)":\s*"([^"]+)"/g)) {
  nomesCompletos[m[1]] = m[2];
}

// Todos os jogadores únicos (camisa → nome completo ou null)
const allPlayers = new Map();
const timeRe = /"([^"]+)":\s*\{[^}]+GK:\s*\[([^\]]+)\][^}]+DEF:\s*\[([^\]]+)\][^}]+MID:\s*\[([^\]]+)\][^}]+FWD:\s*\[([^\]]+)\]/gs;
for (const m of elencosRaw.matchAll(timeRe)) {
  for (let g = 2; g <= 5; g++) {
    for (const pm of m[g].matchAll(/"([^"]+)"/g)) {
      const camisa = pm[1];
      if (!allPlayers.has(camisa)) {
        allPlayers.set(camisa, nomesCompletos[camisa] ?? null);
      }
    }
  }
}
console.log(`Total de jogadores: ${allPlayers.size}`);

// ── Utilitários ────────────────────────────────────────────────────────────
function safeFilename(nome) {
  return nome
    .normalize('NFD').replace(/[̀-ͯ]/g, '')
    .replace(/[øØ]/g, 'O').replace(/ß/g, 'SS')
    .replace(/[đĐ]/g, 'D').replace(/[łŁ]/g, 'L')
    .replace(/\s+/g, '_').replace(/[^A-Za-z0-9_]/g, '')
    .toUpperCase() + '.jpg';
}

const SKIP = new Set(['DA','DE','DO','DAS','DOS','DI','DEL','VAN','VON','D','EL','AL','BEN']);
function wikiTitle(nomeCompleto) {
  if (!nomeCompleto) return null;
  const parts = nomeCompleto.split(/\s+/);
  if (parts.length < 2) return nomeCompleto;
  let surnameIdx = -1;
  for (let i = 1; i < parts.length; i++) {
    const w = parts[i];
    if (w.length > 1 && w === w.toUpperCase() && !SKIP.has(w)) {
      surnameIdx = i; break;
    }
  }
  if (surnameIdx < 0) return parts.join(' ');
  const surname = parts.slice(surnameIdx)
    .map(w => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase()).join(' ');
  return `${parts[0]} ${surname}`;
}

const sleep = ms => new Promise(r => setTimeout(r, ms));

async function fetchThumb(title) {
  const url = `https://en.wikipedia.org/api/rest_v1/page/summary/${encodeURIComponent(title)}`;
  const r = await fetch(url, {
    headers: { 'User-Agent': UA },
    signal: AbortSignal.timeout(8000),
  });
  if (r.status === 429) return '429';
  if (!r.ok) return null;
  const d = await r.json();
  if (d.type !== 'standard' || !d.thumbnail?.source) return null;
  return d.thumbnail.source;
}

async function downloadImage(url, dest) {
  const r = await fetch(url, {
    headers: { 'User-Agent': UA },
    signal: AbortSignal.timeout(20000),
  });
  if (!r.ok) return false;
  const buf = Buffer.from(await r.arrayBuffer());
  if (buf.length < 1000) return false; // arquivo muito pequeno = erro
  writeFileSync(dest, buf);
  return true;
}

// ── Loop principal ─────────────────────────────────────────────────────────
let ok = 0, miss = 0, skipCount = 0, errors = 0;
let i = 0;

for (const [camisa, nc] of allPlayers) {
  i++;
  const fn   = safeFilename(camisa);
  const dest = join(FOTOS_DIR, fn);

  if (existsSync(dest)) { skipCount++; continue; }

  // Tentativas em ordem: nome completo primeiro, depois title-case do camisa
  const attempts = [];
  const wt = wikiTitle(nc);
  if (wt) attempts.push(wt);
  const tc = camisa.split(' ')
    .map(w => w.charAt(0).toUpperCase() + w.slice(1).toLowerCase()).join(' ');
  if (!attempts.includes(tc)) attempts.push(tc);

  let thumbUrl = null;
  for (const title of attempts) {
    let res;
    try { res = await fetchThumb(title); } catch { res = null; }

    if (res === '429') {
      console.log(`[${i}/${allPlayers.size}] 429 — aguardando 30s...`);
      await sleep(30000);
      try { res = await fetchThumb(title); } catch { res = null; }
    }
    if (res && res !== '429') { thumbUrl = res; break; }
    await sleep(300);
  }

  if (thumbUrl) {
    try {
      const downloaded = await downloadImage(thumbUrl, dest);
      if (downloaded) {
        ok++;
        console.log(`[${i}] OK   ${camisa} → ${fn}`);
      } else {
        errors++;
        console.log(`[${i}] ERR  ${camisa} (download falhou)`);
      }
    } catch (e) {
      errors++;
      console.log(`[${i}] ERR  ${camisa}: ${e.message}`);
    }
  } else {
    miss++;
    if (i % 20 === 0 || miss <= 10) {
      console.log(`[${i}] SEM  ${camisa} (${nc ?? 'sem nome completo'})`);
    }
  }

  await sleep(500);
}

console.log(`\n=== RESULTADO ===`);
console.log(`OK:      ${ok}`);
console.log(`Sem foto: ${miss}`);
console.log(`Já tinha: ${skipCount}`);
console.log(`Erros:    ${errors}`);

// ── Gerar fotos.js com URLs jsDelivr ─────────────────────────────────────
const downloaded = new Set(readdirSync(FOTOS_DIR).filter(f => f.endsWith('.jpg')));
const entries = [];
for (const [camisa] of allPlayers) {
  const fn = safeFilename(camisa);
  if (downloaded.has(fn)) {
    entries.push(`  '${camisa.padEnd(16)}': '${CDN}${fn}',`);
  }
}

const fotosJs = `// Fotos dos jogadores — gerado automaticamente via GitHub Actions
// CDN: jsDelivr → github.com/Rufinorris/bolao-copa-2026/fotos/

const FOTOS = {
${entries.join('\n')}
};

// Lookup síncrono — chave = nome de camisa
function getFoto(nome) {
  if (Object.prototype.hasOwnProperty.call(FOTOS, nome)) return FOTOS[nome];
  try {
    const c = sessionStorage.getItem(\`foto_\${nome}\`);
    if (c !== null) return c === '' ? null : c;
  } catch {}
  return null;
}

// Desabilitado: fallback Wikipedia causava imagens erradas (páginas homônimas)
async function _fetchWikiThumbnail(nome) { return null; }

async function precarregarFotos(nomes) {
  const pendentes = nomes.filter(n => {
    if (Object.prototype.hasOwnProperty.call(FOTOS, n)) return false;
    try { if (sessionStorage.getItem(\`foto_\${n}\`) !== null) return false; } catch {}
    return true;
  });
  await Promise.allSettled(pendentes.map(async (nome) => {
    const url = await _fetchWikiThumbnail(nome);
    try { sessionStorage.setItem(\`foto_\${nome}\`, url || ''); } catch {}
  }));
}
`;

writeFileSync(join(ROOT, 'js', 'fotos.js'), fotosJs, 'utf8');
console.log(`\nGerado js/fotos.js com ${entries.length} entradas CDN`);
