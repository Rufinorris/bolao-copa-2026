// =============================================
// ESPN Unofficial API — Copa 2026
// Sem key, sem custo. Funciona para scores + fixtures.
// =============================================

// A ESPN bloqueia CORS no navegador (Failed to fetch). Por isso passamos por um
// proxy edge function (Supabase) que busca server-side e devolve com CORS liberado.
const ESPN_PROXY = 'https://depjjhmzisjmknechkcv.supabase.co/functions/v1/espn-proxy';
function _espnUrl(rest) { return `${ESPN_PROXY}?path=${encodeURIComponent(rest)}`; }

// Mapa nomes ESPN → nossos nomes
const ESPN_NOME_MAP = {
  'United States': 'Estados Unidos', 'USA': 'Estados Unidos',
  'Mexico': 'México', 'Canada': 'Canadá', 'Panama': 'Panamá',
  'France': 'França', 'Germany': 'Alemanha', 'Spain': 'Espanha',
  'Portugal': 'Portugal', 'England': 'Inglaterra',
  'Netherlands': 'Países Baixos', 'Holland': 'Países Baixos',
  'Morocco': 'Marrocos', 'Japan': 'Japão', 'Senegal': 'Senegal',
  'Australia': 'Austrália', 'South Korea': 'Coreia do Sul',
  'Korea Republic': 'Coreia do Sul', 'South Africa': 'África do Sul',
  'Ecuador': 'Equador', 'Uruguay': 'Uruguai', 'Colombia': 'Colômbia',
  'Chile': 'Chile', 'Brazil': 'Brasil', 'Argentina': 'Argentina',
  'Belgium': 'Bélgica', 'Sweden': 'Suécia', 'Paraguay': 'Paraguai',
  'Switzerland': 'Suíça', 'Croatia': 'Croácia', 'Denmark': 'Dinamarca',
  'Serbia': 'Sérvia', 'Poland': 'Polônia', 'Ukraine': 'Ucrânia',
  'Austria': 'Áustria', 'Turkey': 'Turquia', 'Norway': 'Noruega',
  'Venezuela': 'Venezuela', 'Peru': 'Peru', 'Bolivia': 'Bolívia',
  'Costa Rica': 'Costa Rica', 'Honduras': 'Honduras',
  'Jamaica': 'Jamaica', 'Trinidad and Tobago': 'Trinidad e Tobago',
  'Nigeria': 'Nigéria', 'Ghana': 'Gana', 'Ivory Coast': 'Costa do Marfim',
  'Cameroon': 'Camarões', 'Egypt': 'Egito', 'Tunisia': 'Tunísia',
  'Algeria': 'Argélia', 'Saudi Arabia': 'Arábia Saudita',
  'Iran': 'Irã', 'Qatar': 'Catar', 'Iraq': 'Iraque',
  'China PR': 'China', 'Indonesia': 'Indonésia', 'New Zealand': 'Nova Zelândia',
  'Bosnia and Herzegovina': 'Bósnia e Herzegovina',
  'Bosnia & Herzegovina': 'Bósnia e Herzegovina',
  'Bosnia-Herzegovina': 'Bósnia e Herzegovina',
  'Cape Verde': 'Cabo Verde', 'Cabo Verde': 'Cabo Verde',
  'DR Congo': 'RD Congo', 'Congo DR': 'RD Congo',
  'Democratic Republic of Congo': 'RD Congo', 'Congo, DR': 'RD Congo',
};

// Mapa de flags por nome (nosso)
const FLAGS_MAP = {
  'Estados Unidos': '🇺🇸', 'México': '🇲🇽', 'Canadá': '🇨🇦', 'Panamá': '🇵🇦',
  'Brasil': '🇧🇷', 'Argentina': '🇦🇷', 'Colômbia': '🇨🇴', 'Uruguai': '🇺🇾',
  'Equador': '🇪🇨', 'Chile': '🇨🇱', 'Venezuela': '🇻🇪', 'Peru': '🇵🇪', 'Bolívia': '🇧🇴',
  'Costa Rica': '🇨🇷', 'Honduras': '🇭🇳', 'Jamaica': '🇯🇲', 'Cabo Verde': '🇨🇻',
  'França': '🇫🇷', 'Alemanha': '🇩🇪', 'Espanha': '🇪🇸', 'Portugal': '🇵🇹',
  'Inglaterra': '🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'Países Baixos': '🇳🇱', 'Bélgica': '🇧🇪',
  'Suécia': '🇸🇪', 'Dinamarca': '🇩🇰', 'Noruega': '🇳🇴', 'Suíça': '🇨🇭',
  'Croácia': '🇭🇷', 'Sérvia': '🇷🇸', 'Polônia': '🇵🇱', 'Ucrânia': '🇺🇦',
  'Áustria': '🇦🇹', 'Turquia': '🇹🇷', 'Bósnia e Herzegovina': '🇧🇦',
  'Marrocos': '🇲🇦', 'Nigéria': '🇳🇬', 'Gana': '🇬🇭', 'Costa do Marfim': '🇨🇮',
  'Camarões': '🇨🇲', 'Egito': '🇪🇬', 'Tunísia': '🇹🇳', 'Argélia': '🇩🇿',
  'Senegal': '🇸🇳', 'África do Sul': '🇿🇦',
  'Japão': '🇯🇵', 'Coreia do Sul': '🇰🇷', 'Austrália': '🇦🇺',
  'Arábia Saudita': '🇸🇦', 'Irã': '🇮🇷', 'Catar': '🇶🇦', 'Iraque': '🇮🇶',
  'China': '🇨🇳', 'Indonésia': '🇮🇩', 'Nova Zelândia': '🇳🇿',
  'Paraguai': '🇵🇾', 'RD Congo': '🇨🇩',
};

function normNome(nome) {
  if (!nome) return '';
  return (ESPN_NOME_MAP[nome] || nome).toLowerCase().trim();
}

function nomeEspnParaNosso(nome) {
  return ESPN_NOME_MAP[nome] || nome;
}

// Busca eventos de um scoreboard (aceita data YYYYMMDD ou range YYYYMMDD-YYYYMMDD)
async function espnFetch(dates) {
  const rest = dates ? `scoreboard?dates=${dates}&limit=50` : `scoreboard?limit=50`;
  const r = await fetch(_espnUrl(rest));
  if (!r.ok) throw new Error(`ESPN HTTP ${r.status}`);
  const d = await r.json();
  return d.events || [];
}

// Detalhes de um evento (artilheiros, etc.)
async function espnDetalhes(eventId) {
  const r = await fetch(_espnUrl(`summary?event=${eventId}`));
  if (!r.ok) return null;
  return r.json();
}

// Extrai artilheiro(s) do summary ESPN
function espnArtilheiros(summary) {
  const nomes = [];
  const plays = summary?.scoringPlays || [];
  for (const p of plays) {
    const participantes = p.participants || [];
    if (participantes.length) {
      const nome = participantes[0].athlete?.displayName || participantes[0].athlete?.shortName;
      if (nome && !nomes.includes(nome)) nomes.push(nome);
    }
  }
  return nomes;
}

// Converte um evento ESPN + nosso jogo em objeto de atualização
async function espnBuildUpdate(jogo, evento) {
  const comp = evento.competitions[0];
  const c0 = comp.competitors[0];
  const c1 = comp.competitors[1];
  const c0Nome = nomeEspnParaNosso(c0.team.displayName);
  const c1Nome = nomeEspnParaNosso(c1.team.displayName);

  // Detecta se ESPN retornou home/away na ordem invertida
  const homeNorm = normNome(jogo.time_home);
  const espnC0Norm = normNome(c0.team.displayName);
  const invertido = homeNorm !== 'a definir' && homeNorm !== '' && espnC0Norm !== homeNorm;

  const s0 = parseInt(c0.score || 0) || 0;
  const s1 = parseInt(c1.score || 0) || 0;

  const statusName = evento.status?.type?.name;
  const statusMap = {
    STATUS_SCHEDULED:   'scheduled',
    STATUS_IN_PROGRESS: 'live',
    STATUS_HALFTIME:    'live',
    STATUS_FIRST_HALF:  'live',
    STATUS_SECOND_HALF: 'live',
    STATUS_OVERTIME:    'live',
    STATUS_FULL_TIME:   'finished',
    STATUS_FINAL:       'finished',
    STATUS_FINAL_PEN:   'finished',
  };
  const status = statusMap[statusName] || 'scheduled';

  // Vencedor pelo campo winner da ESPN (vale para prorrogação e pênaltis, onde o placar empata)
  let vencedor = null;
  if (status === 'finished') {
    if (c0.winner) vencedor = invertido ? 'away' : 'home';
    else if (c1.winner) vencedor = invertido ? 'home' : 'away';
  }
  const foi_penaltis = statusName === 'STATUS_FINAL_PEN';

  let artilheiros = [];
  if (status !== 'scheduled') {
    try {
      const det = await espnDetalhes(evento.id);
      artilheiros = espnArtilheiros(det);
    } catch (_) {}
  }

  return {
    id: jogo.id,
    data_hora: evento.date,           // corrige a data/hora com o valor real da ESPN
    time_home:      invertido ? c1Nome : c0Nome,
    time_home_flag: FLAGS_MAP[invertido ? c1Nome : c0Nome] || null,
    time_away:      invertido ? c0Nome : c1Nome,
    time_away_flag: FLAGS_MAP[invertido ? c0Nome : c1Nome] || null,
    placar_home: status !== 'scheduled' ? (invertido ? s1 : s0) : undefined,
    placar_away: status !== 'scheduled' ? (invertido ? s0 : s1) : undefined,
    status,
    vencedor,
    foi_penaltis,
    artilheiros,
  };
}

// Sincroniza todos os jogos do mata-mata usando ESPN
// Estratégia de matching em dois passos:
//   1. Jogos com times conhecidos → match por nome dos times
//   2. Jogos "A definir" → match por data/hora (±60min), com fallback sequencial
//      (fallback cobre datas erradas no banco, p.ex. R32 datas mal estimadas na inserção)
async function espnSincronizar(nossoJogos, dataEspecifica) {
  let eventos = [];

  if (dataEspecifica) {
    eventos = await espnFetch(dataEspecifica.replace(/-/g, ''));
  } else {
    // ESPN não suporta range de datas confiável — busca dia a dia
    const dias = [
      '20260611','20260612','20260613','20260614','20260615','20260616', // Fase grupos R1
      '20260617','20260618','20260619','20260620','20260621','20260622', // Fase grupos R1/R2
      '20260623','20260624','20260625','20260626','20260627','20260628', // Fase grupos R2/R3
      '20260629','20260630','20260701','20260702','20260703',            // Fase grupos R3
      '20260704','20260705','20260706','20260707','20260708','20260709','20260710','20260711', // Oitavas + Quartas
      '20260714','20260715','20260719', // Semis + Final
    ];
    const resultados = await Promise.all(dias.map(d => espnFetch(d).catch(() => [])));
    eventos = resultados.flat();
  }

  console.log(`[ESPN] ${eventos.length} evento(s) encontrado(s) no total`);
  if (!eventos.length) return [];

  // Remove duplicatas (mesmo jogo pode aparecer em buscas de datas sobrepostas)
  const uniq = new Map();
  for (const ev of eventos) uniq.set(ev.id, ev);
  eventos = [...uniq.values()];

  // Ordena cronologicamente
  eventos.sort((a, b) => new Date(a.date) - new Date(b.date));

  const atualizacoes = [];
  const usadosIds = new Set();

  // ── Passo 1: games com pelo menos um time conhecido → match por nome ────
  for (const jogo of nossoJogos) {
    if (jogo.time_home === 'A definir' && jogo.time_away === 'A definir') continue;

    const homeNorm = normNome(jogo.time_home);
    const awayNorm = normNome(jogo.time_away);
    const homeConhecido = jogo.time_home !== 'A definir';
    const awayConhecido = jogo.time_away !== 'A definir';

    const evento = eventos.find(ev => {
      if (usadosIds.has(ev.id)) return false;
      const comp = ev.competitions?.[0];
      if (!comp) return false;
      const c0 = normNome(comp.competitors?.[0]?.team?.displayName);
      const c1 = normNome(comp.competitors?.[1]?.team?.displayName);
      if (homeConhecido && awayConhecido) {
        return (c0 === homeNorm && c1 === awayNorm) || (c0 === awayNorm && c1 === homeNorm);
      } else if (homeConhecido) {
        return c0 === homeNorm || c1 === homeNorm;
      } else {
        return c0 === awayNorm || c1 === awayNorm;
      }
    });

    if (!evento) continue;
    usadosIds.add(evento.id);
    atualizacoes.push(await espnBuildUpdate(jogo, evento));
  }

  // ── Passo 2: apenas round32 totalmente indefinidos → match por data (±90min) ─
  // SEM fallback sequencial: evita que fases futuras (oitavas/semi/final) consumam
  // eventos do R32 por coincidência de rodada_num baixo
  const adefinirJogos = nossoJogos
    .filter(j => j.fase === 'round32' && j.time_home === 'A definir' && j.time_away === 'A definir')
    .sort((a, b) => (a.rodada_num || 0) - (b.rodada_num || 0));

  // Pool de eventos R32 ainda não usados, em ordem cronológica
  const pool = eventos.filter(ev => !usadosIds.has(ev.id));

  for (const jogo of adefinirJogos) {
    if (!pool.length) break;
    const jogoData = jogo.data_hora ? new Date(jogo.data_hora) : null;
    if (!jogoData) continue;

    // Só aceita match por data/hora (±90 min) — sem fallback sequencial
    const idx = pool.findIndex(ev => Math.abs(new Date(ev.date) - jogoData) / 60000 < 90);
    if (idx === -1) continue;

    const evento = pool[idx];
    pool.splice(idx, 1);
    usadosIds.add(evento.id);
    atualizacoes.push(await espnBuildUpdate(jogo, evento));
  }

  return atualizacoes;
}
