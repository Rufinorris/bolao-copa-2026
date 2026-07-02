// =============================================
// espn-sync — sincronizacao automatica de placares ao vivo
// Disparada pelo app (on-demand) quando ha jogo na janela e alguem esta olhando.
// Tem THROTTLE: faz no maximo 1 busca real por minuto, nao importa quantos chamem.
// Roda server-side (contorna CORS da ESPN) e fala com o banco via REST + service role.
// Sem dependencias externas (evita BOOT_ERROR de imports). verify_jwt = false.
// =============================================

const ESPN = 'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world';
const THROTTLE_MS = 25000;
const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const NOME_MAP = {
  'United States': 'Estados Unidos', 'USA': 'Estados Unidos', 'Mexico': 'México',
  'Canada': 'Canadá', 'Panama': 'Panamá', 'France': 'França', 'Germany': 'Alemanha',
  'Spain': 'Espanha', 'Portugal': 'Portugal', 'England': 'Inglaterra',
  'Netherlands': 'Países Baixos', 'Holland': 'Países Baixos', 'Morocco': 'Marrocos',
  'Japan': 'Japão', 'Senegal': 'Senegal', 'Australia': 'Austrália',
  'South Korea': 'Coreia do Sul', 'Korea Republic': 'Coreia do Sul',
  'South Africa': 'África do Sul', 'Ecuador': 'Equador', 'Uruguay': 'Uruguai',
  'Colombia': 'Colômbia', 'Chile': 'Chile', 'Brazil': 'Brasil', 'Argentina': 'Argentina',
  'Belgium': 'Bélgica', 'Sweden': 'Suécia', 'Paraguay': 'Paraguai', 'Switzerland': 'Suíça',
  'Croatia': 'Croácia', 'Denmark': 'Dinamarca', 'Serbia': 'Sérvia', 'Poland': 'Polônia',
  'Ukraine': 'Ucrânia', 'Austria': 'Áustria', 'Turkey': 'Turquia', 'Norway': 'Noruega',
  'Venezuela': 'Venezuela', 'Peru': 'Peru', 'Bolivia': 'Bolívia', 'Costa Rica': 'Costa Rica',
  'Honduras': 'Honduras', 'Jamaica': 'Jamaica', 'Trinidad and Tobago': 'Trinidad e Tobago',
  'Nigeria': 'Nigéria', 'Ghana': 'Gana', 'Ivory Coast': 'Costa do Marfim',
  'Cameroon': 'Camarões', 'Egypt': 'Egito', 'Tunisia': 'Tunísia', 'Algeria': 'Argélia',
  'Saudi Arabia': 'Arábia Saudita', 'Iran': 'Irã', 'Qatar': 'Catar', 'Iraq': 'Iraque',
  'China PR': 'China', 'Indonesia': 'Indonésia', 'New Zealand': 'Nova Zelândia',
  'Cape Verde': 'Cabo Verde',
};
const norm = (s) => (NOME_MAP[s] || s || '').toLowerCase().trim();

const STATUS_MAP = {
  STATUS_SCHEDULED: 'scheduled', STATUS_IN_PROGRESS: 'live', STATUS_HALFTIME: 'live',
  STATUS_FIRST_HALF: 'live', STATUS_SECOND_HALF: 'live', STATUS_OVERTIME: 'live',
  STATUS_END_OF_REGULATION: 'live', STATUS_FULL_TIME: 'finished',
  STATUS_FINAL: 'finished', STATUS_FINAL_PEN: 'finished',
};

function ymd(iso) {
  const d = new Date(iso);
  const mm = String(d.getUTCMonth() + 1).padStart(2, '0');
  const dd = String(d.getUTCDate()).padStart(2, '0');
  return '' + d.getUTCFullYear() + mm + dd;
}

const SB = Deno.env.get('SUPABASE_URL');
const KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
const H = { apikey: KEY, Authorization: 'Bearer ' + KEY, 'Content-Type': 'application/json' };
const rest = (path, opts) => fetch(SB + '/rest/v1/' + path, Object.assign({ headers: H }, opts || {}));

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });
  const json = (o, s) => new Response(JSON.stringify(o), { status: s || 200, headers: Object.assign({ 'Content-Type': 'application/json' }, cors) });

  // 1. Throttle global — no maximo 1 sync real por minuto
  const metaArr = await (await rest('app_meta?id=eq.1&select=last_espn_sync')).json();
  const last = metaArr && metaArr[0] && metaArr[0].last_espn_sync ? Date.parse(metaArr[0].last_espn_sync) : 0;
  if (Date.now() - last < THROTTLE_MS) return json({ skipped: 'throttle' });
  await rest('app_meta?id=eq.1', { method: 'PATCH', headers: H, body: JSON.stringify({ last_espn_sync: new Date().toISOString() }) });

  // 2. Ha jogo na janela?
  const jogos = await (await rest('jogos?select=*')).json();
  const now = Date.now();
  const ativos = (jogos || []).filter((j) => {
    if (j.status === 'finished' || !j.data_hora) return false;
    if (j.time_home === 'A definir' || j.time_away === 'A definir') return false;
    const t = Date.parse(j.data_hora);
    return t <= now + 15 * 60000 && t >= now - 4 * 3600000;
  });
  if (!ativos.length) return json({ skipped: 'sem jogo na janela' });

  // 3. Busca ESPN nas datas dos jogos ativos +- 1 dia (a ESPN agrupa por matchday,
  //    que pode cair no dia anterior/seguinte ao horario UTC do confronto)
  const diasSet = new Set();
  for (const j of ativos) {
    const base = Date.parse(j.data_hora);
    for (const off of [-1, 0, 1]) diasSet.add(ymd(new Date(base + off * 86400000).toISOString()));
  }
  const datas = Array.from(diasSet);
  const eventos = [];
  for (const d of datas) {
    try {
      const r = await fetch(ESPN + '/scoreboard?dates=' + d + '&limit=50');
      if (r.ok) { const body = await r.json(); for (const e of (body.events || [])) eventos.push(e); }
    } catch (_) { /* ignora */ }
  }

  // 4. Matching por nome dos times + update
  let n = 0;
  for (const j of ativos) {
    const h = norm(j.time_home), aw = norm(j.time_away);
    const ev = eventos.find((e) => {
      const c = e.competitions && e.competitions[0] && e.competitions[0].competitors;
      if (!c) return false;
      const a = norm(c[0] && c[0].team && c[0].team.displayName);
      const b = norm(c[1] && c[1].team && c[1].team.displayName);
      return (a === h && b === aw) || (a === aw && b === h);
    });
    if (!ev) continue;

    const comp = ev.competitions[0];
    let c0 = comp.competitors[0], c1 = comp.competitors[1];
    if (norm(c0.team.displayName) !== h) { const tmp = c0; c0 = c1; c1 = tmp; }

    const statusName = ev.status && ev.status.type && ev.status.type.name;
    const st = STATUS_MAP[statusName] || 'scheduled';
    const upd = { status: st };
    if (st !== 'scheduled') {
      upd.placar_home = parseInt(c0.score) || 0;
      upd.placar_away = parseInt(c1.score) || 0;
      if (st === 'finished') {
        // Vencedor pelo campo winner da ESPN (vale para prorrogação e pênaltis)
        upd.vencedor = c0.winner ? 'home' : c1.winner ? 'away' : null;
        if (statusName === 'STATUS_FINAL_PEN') upd.foi_penaltis = true;
      }
      try {
        const r = await fetch(ESPN + '/summary?event=' + ev.id);
        if (r.ok) {
          const s = await r.json();
          const nomes = [];
          for (const e of (s.keyEvents || [])) {
            const tipo = (e.type && e.type.text) || '';
            if (!/goal/i.test(tipo) || /own goal/i.test(tipo)) continue;
            const nm = e.participants && e.participants[0] && e.participants[0].athlete && e.participants[0].athlete.displayName;
            if (!nm) continue;
            const teamEspn = e.team && e.team.displayName;
            const nossoTime = NOME_MAP[teamEspn] || teamEspn || '';
            // Converte o nome completo da ESPN no nome de camisa (via tabela jogadores)
            let camisa = nm;
            try {
              const cr = await rest('rpc/converter_artilheiro', { method: 'POST', headers: H, body: JSON.stringify({ p_display: nm, p_time: nossoTime }) });
              if (cr.ok) { const v = await cr.json(); if (v) camisa = v; }
            } catch (_) { /* mantem o nome original */ }
            if (nomes.indexOf(camisa) === -1) nomes.push(camisa);
          }
          if (nomes.length) upd.artilheiro_confirmado = nomes;
        }
      } catch (_) { /* ignora */ }
    }
    await rest('jogos?id=eq.' + j.id, { method: 'PATCH', headers: H, body: JSON.stringify(upd) });
    n++;
  }

  // 5. Vencedor real avança no bracket + recalcula pontos/ranking
  if (n > 0) {
    await rest('rpc/propagar_vencedores', { method: 'POST', headers: H, body: '{}' });
    await rest('rpc/recalcular_tudo', { method: 'POST', headers: H, body: '{}' });
  }

  return json({ ok: true, atualizados: n, datas: datas });
});
