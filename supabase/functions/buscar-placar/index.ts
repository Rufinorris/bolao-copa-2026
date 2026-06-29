import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY") ?? "";

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "authorization, content-type",
      },
    });
  }

  if (!ANTHROPIC_API_KEY) {
    return new Response(
      JSON.stringify({ error: "ANTHROPIC_API_KEY nao configurado" }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }

  let body;
  try { body = await req.json(); } catch { return new Response(JSON.stringify({ error: "Body invalido" }), { status: 400 }); }

  const { time_home, time_away, data_hora, fase } = body;
  if (!time_home || !time_away) {
    return new Response(JSON.stringify({ error: "time_home e time_away obrigatorios" }), { status: 400 });
  }

  const dataStr = data_hora
    ? new Date(data_hora).toLocaleDateString("pt-BR", { day: "2-digit", month: "2-digit", year: "numeric" })
    : "data nao informada";

  const prompt = `Voce e um assistente de futebol. Diga o resultado do jogo da Copa do Mundo 2026:
${time_home} vs ${time_away} em ${dataStr} (${fase ?? "fase nao informada"}).
Responda APENAS um JSON sem markdown:
{"placar_home":numero_ou_null,"placar_away":numero_ou_null,"status":"scheduled|live|finished","artilheiros":["NOME1"],"fonte":"fonte"}
Use nomes de camisa oficiais. Se nao encerrado, placar null e status scheduled.`;

  try {
    const resp = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "x-api-key": ANTHROPIC_API_KEY,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model: "claude-haiku-4-5-20251001",
        max_tokens: 256,
        messages: [{ role: "user", content: prompt }],
      }),
    });

    if (!resp.ok) {
      const err = await resp.text();
      return new Response(JSON.stringify({ error: "Erro Claude API: " + err }), { status: 500 });
    }

    const data = await resp.json();
    const text = data.content?.[0]?.text ?? "";
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (!jsonMatch) {
      return new Response(JSON.stringify({ error: "JSON invalido", raw: text }), { status: 500 });
    }

    const resultado = JSON.parse(jsonMatch[0]);
    return new Response(JSON.stringify(resultado), {
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});
