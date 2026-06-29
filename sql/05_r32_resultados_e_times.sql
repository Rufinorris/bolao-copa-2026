-- =============================================
-- R32: Confirma todos os confrontos e resultados já disponíveis
-- Rodar no Supabase Dashboard → SQL Editor
-- Atualizado em 28/06/2026
-- =============================================

-- r32_01: África do Sul vs Canadá — JÁ ENCERRADO 1×0
UPDATE public.jogos SET
  time_home = 'África do Sul', time_home_flag = '🇿🇦',
  time_away = 'Canadá', time_away_flag = '🇨🇦',
  placar_home = 1, placar_away = 0,
  status = 'finished', vencedor = 'home',
  data_hora = '2026-06-28 16:00:00-03'
WHERE api_match_id = 'r32_01';

-- r32_02: Países Baixos vs Marrocos (29/jun 22h)
-- times já corretos no banco — confirmar se necessário
UPDATE public.jogos SET
  time_home = 'Países Baixos', time_home_flag = '🇳🇱',
  time_away = 'Marrocos', time_away_flag = '🇲🇦',
  data_hora = '2026-06-29 22:00:00-03'
WHERE api_match_id = 'r32_02';

-- r32_03: Alemanha vs Paraguai (29/jun 17h30)
UPDATE public.jogos SET
  time_home = 'Alemanha', time_home_flag = '🇩🇪',
  time_away = 'Paraguai', time_away_flag = '🇵🇾',
  data_hora = '2026-06-29 17:30:00-03'
WHERE api_match_id = 'r32_03';

-- r32_04: França vs Suécia (30/jun 18h)
UPDATE public.jogos SET
  time_home = 'França', time_home_flag = '🇫🇷',
  time_away = 'Suécia', time_away_flag = '🇸🇪',
  data_hora = '2026-06-30 18:00:00-03'
WHERE api_match_id = 'r32_04';

-- r32_05: Bélgica vs Coreia do Sul (já no banco via SQL 03)
-- r32_06: Estados Unidos vs Bósnia e Herzegovina (já no banco)
-- r32_07: Espanha vs Áustria (já no banco)
-- r32_08: Portugal vs Gana (já no banco)
-- r32_09: Brasil vs Japão (já no banco)
-- r32_10: Costa do Marfim vs Noruega (já no banco)
-- r32_11: México vs ??? — preencher adversário quando confirmado
-- r32_12: Inglaterra vs Senegal (já no banco)
-- r32_13: Suíça vs Irã (já no banco)
-- r32_14: Austrália vs Egito (já no banco)
-- r32_15: Argentina vs Cabo Verde (já no banco)
-- r32_16: Colômbia vs Croácia (já no banco)

-- Recalcula ranking (precaução)
SELECT api_match_id, time_home, time_away, placar_home, placar_away, status, data_hora
FROM public.jogos
WHERE fase = 'round32'
ORDER BY data_hora;
