-- =============================================
-- LIMPEZA: corrige atribuições erradas do ESPN sync
-- O bug do fallback sequencial escreveu times R32 nos slots de
-- oitavas/quartas/semi/final/terceiro (que têm rodada_num baixos).
-- Rodar no Supabase Dashboard → SQL Editor
-- =============================================

-- 1. Reseta times de fases futuras que foram incorretamente preenchidos
UPDATE public.jogos
SET time_home = 'A definir', time_home_flag = null,
    time_away = 'A definir', time_away_flag = null,
    placar_home = null, placar_away = null,
    status = 'scheduled', vencedor = null
WHERE fase IN ('oitavas', 'quartas', 'semi', 'final', 'terceiro')
  AND status = 'scheduled'
  AND (time_home != 'A definir' OR time_away != 'A definir');

-- 2. Remove palpites do 3º lugar (não entra no bolão)
DELETE FROM public.palpites
WHERE jogo_id IN (SELECT id FROM public.jogos WHERE fase = 'terceiro');

-- 3. Remove o jogo de 3º lugar
DELETE FROM public.jogos WHERE fase = 'terceiro';

-- Verificar resultado:
SELECT api_match_id, fase, time_home, time_away, data_hora
FROM public.jogos
ORDER BY fase, data_hora;
