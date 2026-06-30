// =============================================
// espn-proxy — proxy CORS para a API não-oficial da ESPN
// A ESPN bloqueia requisições cross-origin do navegador. Esta function busca
// server-side e devolve a resposta com Access-Control-Allow-Origin: *.
// Uso: /espn-proxy?path=scoreboard?dates=20260629&limit=50
//      /espn-proxy?path=summary?event=<id>
// verify_jwt = false (apenas proxia dados públicos de placares)
// =============================================

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });
  const url = new URL(req.url);
  const path = url.searchParams.get('path') || 'scoreboard';
  const espnUrl = 'https://site.api.espn.com/apis/site/v2/sports/soccer/fifa.world/' + path;
  try {
    const r = await fetch(espnUrl);
    const body = await r.text();
    return new Response(body, { status: r.status, headers: { ...cors, 'Content-Type': 'application/json' } });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 502, headers: { ...cors, 'Content-Type': 'application/json' } });
  }
});
