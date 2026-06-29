-- =============================================
-- BOLÃO COPA 2026 — Correção R32: times e datas reais
-- Rodar no Supabase Dashboard → SQL Editor
-- Baseado no chaveamento oficial confirmado pós-grupos (26-27/jun/2026)
-- =============================================

-- r32_05: Coreia do Sul confirmada como visitante da Bélgica
UPDATE public.jogos SET
  time_away = 'Coreia do Sul', time_away_flag = '🇰🇷'
WHERE api_match_id = 'r32_05';

-- r32_06: Estados Unidos vs Bósnia e Herzegovina (ambos confirmados, Jul 1 21h ✓)
UPDATE public.jogos SET
  time_home = 'Estados Unidos', time_home_flag = '🇺🇸',
  time_away = 'Bósnia e Herzegovina', time_away_flag = '🇧🇦'
WHERE api_match_id = 'r32_06';

-- r32_07: Espanha vs Áustria + corrige horário (17h→16h BRT)
UPDATE public.jogos SET
  time_home = 'Espanha', time_home_flag = '🇪🇸',
  time_away = 'Áustria', time_away_flag = '🇦🇹',
  data_hora = '2026-07-02 16:00:00-03'
WHERE api_match_id = 'r32_07';

-- r32_08: Portugal vs Gana + corrige horário (21h→20h BRT)
UPDATE public.jogos SET
  time_home = 'Portugal', time_home_flag = '🇵🇹',
  time_away = 'Gana', time_away_flag = '🇬🇭',
  data_hora = '2026-07-02 20:00:00-03'
WHERE api_match_id = 'r32_08';

-- r32_09: BRASIL vs JAPÃO + corrige data (Jul 3 17h → Jun 29 14h BRT)
UPDATE public.jogos SET
  time_home = 'Brasil', time_home_flag = '🇧🇷',
  time_away = 'Japão', time_away_flag = '🇯🇵',
  data_hora = '2026-06-29 14:00:00-03'
WHERE api_match_id = 'r32_09';

-- r32_10: Costa do Marfim vs Noruega + corrige data (Jul 3 21h → Jun 30 14h BRT)
-- Vencedor desta enfrenta o vencedor de Brasil vs Japão nas oitavas
UPDATE public.jogos SET
  time_home = 'Costa do Marfim', time_home_flag = '🇨🇮',
  time_away = 'Noruega', time_away_flag = '🇳🇴',
  data_hora = '2026-06-30 14:00:00-03'
WHERE api_match_id = 'r32_10';

-- r32_11: México + corrige data (Jul 4 17h → Jun 30 22h BRT)
-- Adversário (3º colocado) confirmado via ESPN sync
UPDATE public.jogos SET
  time_home = 'México', time_home_flag = '🇲🇽',
  data_hora = '2026-06-30 22:00:00-03'
WHERE api_match_id = 'r32_11';

-- r32_12: Inglaterra vs Senegal + corrige data (Jul 4 21h → Jul 1 13h BRT)
-- Vencedor desta enfrenta México nas oitavas (o16_06)
UPDATE public.jogos SET
  time_home = 'Inglaterra', time_home_flag = '🏴󠁧󠁢󠁥󠁮󠁧󠁿',
  time_away = 'Senegal', time_away_flag = '🇸🇳',
  data_hora = '2026-07-01 13:00:00-03'
WHERE api_match_id = 'r32_12';

-- r32_13: Suíça vs Irã + corrige data (Jul 5 17h → Jul 3 00h BRT / noite local Vancouver)
UPDATE public.jogos SET
  time_home = 'Suíça', time_home_flag = '🇨🇭',
  time_away = 'Irã', time_away_flag = '🇮🇷',
  data_hora = '2026-07-03 00:00:00-03'
WHERE api_match_id = 'r32_13';

-- r32_14: Austrália vs Egito + corrige data (Jul 5 21h → Jul 3 15h BRT)
UPDATE public.jogos SET
  time_home = 'Austrália', time_home_flag = '🇦🇺',
  time_away = 'Egito', time_away_flag = '🇪🇬',
  data_hora = '2026-07-03 15:00:00-03'
WHERE api_match_id = 'r32_14';

-- r32_15: Argentina vs Cabo Verde + corrige data (Jul 6 17h → Jul 3 19h BRT)
UPDATE public.jogos SET
  time_home = 'Argentina', time_home_flag = '🇦🇷',
  time_away = 'Cabo Verde', time_away_flag = '🇨🇻',
  data_hora = '2026-07-03 19:00:00-03'
WHERE api_match_id = 'r32_15';

-- r32_16: Colômbia vs Croácia + corrige data (Jul 6 21h → Jul 3 22h30 BRT)
UPDATE public.jogos SET
  time_home = 'Colômbia', time_home_flag = '🇨🇴',
  time_away = 'Croácia', time_away_flag = '🇭🇷',
  data_hora = '2026-07-03 22:30:00-03'
WHERE api_match_id = 'r32_16';
