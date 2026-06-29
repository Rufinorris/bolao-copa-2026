-- =============================================
-- Correção completa do chaveamento R32
-- Rodar no Supabase Dashboard → SQL Editor
-- Baseado no chaveamento oficial (28/06/2026)
-- =============================================

-- ── R32: Correção dos 6 times errados ─────────────────────────────────────

-- r32_05: Coreia do Sul → Senegal
UPDATE public.jogos SET
  time_away = 'Senegal', time_away_flag = '🇸🇳'
WHERE api_match_id = 'r32_05';

-- r32_08: Gana → Croácia (Gana vai para r32_16)
UPDATE public.jogos SET
  time_away = 'Croácia', time_away_flag = '🇭🇷'
WHERE api_match_id = 'r32_08';

-- r32_11: A definir → Equador
UPDATE public.jogos SET
  time_away = 'Equador', time_away_flag = '🇪🇨'
WHERE api_match_id = 'r32_11';

-- r32_12: Senegal → RD Congo (Senegal vai para r32_05)
UPDATE public.jogos SET
  time_away = 'RD Congo', time_away_flag = '🇨🇩'
WHERE api_match_id = 'r32_12';

-- r32_13: Irã → Argélia
UPDATE public.jogos SET
  time_away = 'Argélia', time_away_flag = '🇩🇿'
WHERE api_match_id = 'r32_13';

-- r32_16: Croácia → Gana (Croácia vai para r32_08)
UPDATE public.jogos SET
  time_away = 'Gana', time_away_flag = '🇬🇭'
WHERE api_match_id = 'r32_16';


-- ── Oitavas: Corrige datas (estavam erradas no SQL 02) ────────────────────

-- o16_03 (Bélgica/Senegal × USA/Bósnia): era 05/07 17h, correto é 06/07 21h
UPDATE public.jogos SET data_hora = '2026-07-06 21:00:00-03' WHERE api_match_id = 'o16_03';

-- o16_04 (Espanha/Áustria × Portugal/Croácia): era 05/07 21h, correto é 06/07 16h
UPDATE public.jogos SET data_hora = '2026-07-06 16:00:00-03' WHERE api_match_id = 'o16_04';

-- o16_05 (Brasil/Japão × C.Marfim/Noruega): era 06/07 16h, correto é 05/07 17h
UPDATE public.jogos SET data_hora = '2026-07-05 17:00:00-03' WHERE api_match_id = 'o16_05';

-- o16_06 (México/Equador × Inglaterra/RD Congo): era 06/07 21h, correto é 05/07 21h
UPDATE public.jogos SET data_hora = '2026-07-05 21:00:00-03' WHERE api_match_id = 'o16_06';

-- o16_08 (Austrália/Egito × Argentina/Cabo Verde): era 07/07 21h, correto é 07/07 13h
UPDATE public.jogos SET data_hora = '2026-07-07 13:00:00-03' WHERE api_match_id = 'o16_08';


-- ── Bracket: Corrige fiação r32_13-16 → oitavas ──────────────────────────
-- Chaveamento correto do lado direito:
--   r32_13 (Suíça/Argélia) + r32_16 (Colômbia/Gana) → o16_07 (07/07 17h)
--   r32_14 (Austrália/Egito) + r32_15 (Argentina/Cabo Verde) → o16_08 (07/07 13h)
-- Estava errado: r32_13+r32_14 → o16_07, r32_15+r32_16 → o16_08

UPDATE public.jogos SET
  proximo_jogo_id = 'f0000000-0000-0000-0000-000000000047',  -- o16_07
  proximo_posicao = 'away'
WHERE api_match_id = 'r32_16';

UPDATE public.jogos SET
  proximo_jogo_id = 'f0000000-0000-0000-0000-000000000048',  -- o16_08
  proximo_posicao = 'home'
WHERE api_match_id = 'r32_14';

UPDATE public.jogos SET
  proximo_jogo_id = 'f0000000-0000-0000-0000-000000000048',  -- o16_08
  proximo_posicao = 'away'
WHERE api_match_id = 'r32_15';


-- ── Verificação final ─────────────────────────────────────────────────────
SELECT api_match_id, time_home, time_away, data_hora
FROM public.jogos
WHERE fase IN ('round32', 'oitavas')
ORDER BY data_hora;
