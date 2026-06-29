// Edge Function: buscar-placar
// Chama Claude Haiku + web_search para buscar resultado de um jogo da Copa 2026
// Fallback para quando o ESPN não funcionar

const CORS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: CORS });
  }

  const apiKey = Deno.env.get('ANTHROPIC_API_KEY');
  if (!apiKey) {
    return new Response(
      JSON.stringify({ error: 'ANTHROPIC_API_KEY não configurada nas variáveis de ambiente da Supabase.' }),
      { status: 500, headers: { ...CORS, 'Content-Type': 'application/json' } }
    );
  }

  let body: { time_home: string; time_away: string; data_hora: string; fase: string };
  try {
    body = await req.json();
  } catch {
    return new Response(
      JSON.stringify({ error: 'Body JSON inválido' }),
      { status: 400, headers: { ...CORS, 'Content-Type': 'application/json' } }
    );
  }

  const { time_home, time_away, data_hora, fase } = body;
  const dataFormatada = data_hora
    ? new Date(data_hora).toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric', timeZone: 'America/Sao_Paulo' })
    : 'data desconhecida';

  const faseLabel: Record<string, string> = {
    round32: 'Rodada de 32',
    oitavas: 'Oitavas de Final',
    quartas: 'Quartas de Final',
    semi: 'Semifinal',
    final: 'Final',
  };

  const prompt = `Copa do Mundo FIFA 2026. Busque o resultado atual do jogo:
${time_home} vs ${time_away} — ${faseLabel[fase] || fase} — ${dataFormatada}

Retorne SOMENTE um JSON válido, sem markdown, sem texto extra, no formato:
{
  "placar_home": <número ou null>,
  "placar_away": <número ou null>,
  "status": "<scheduled|live|finished>",
  "artilheiros": ["<nome completo>"],
  "fonte": "<URL ou nome da fonte>"
}

Regras:
- status "scheduled": jogo ainda não começou → placar_home e placar_away = null
- status "live": jogo em andamento → placar atual
- status "finished": jogo encerrado → placar final
- artilheiros: lista de quem marcou gol (vazia se não encontrar)
- Se não encontrar o jogo, retorne { "erro": "jogo não encontrado" }`;

  try {
    const resp = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'anthropic-beta': 'web-search-2025-03-05',
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: 1024,
        tools: [{ type: 'web_search_20250305', name: 'web_search' }],
        messages: [{ role: 'user', content: prompt }],
      }),
    });

    const data = await resp.json();

    if (!resp.ok) {
      return new Response(
        JSON.stringify({ error: `Claude API error: ${data.error?.message || resp.status}` }),
        { status: 502, headers: { ...CORS, 'Content-Type': 'application/json' } }
      );
    }

    // Extrai o último bloco de texto (após tool use)
    let textoFinal = '';
    for (const block of data.content || []) {
      if (block.type === 'text') textoFinal = block.text;
    }

    // Parse JSON da resposta
    const jsonMatch = textoFinal.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      return new Response(
        JSON.stringify({ error: 'Resposta não contém JSON', raw: textoFinal }),
        { status: 502, headers: { ...CORS, 'Content-Type': 'application/json' } }
      );
    }

    const resultado = JSON.parse(jsonMatch[0]);
    return new Response(
      JSON.stringify(resultado),
      { headers: { ...CORS, 'Content-Type': 'application/json' } }
    );
  } catch (e) {
    return new Response(
      JSON.stringify({ error: String(e) }),
      { status: 500, headers: { ...CORS, 'Content-Type': 'application/json' } }
    );
  }
});
