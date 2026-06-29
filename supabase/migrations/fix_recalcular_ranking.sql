-- Migração: corrigir recalcular_ranking para usar SECURITY DEFINER
-- Isso permite que a função atualize pontos de TODOS os participantes,
-- contornando o RLS que restringe updates apenas ao próprio usuário.
-- Executar no Supabase Dashboard > SQL Editor

CREATE OR REPLACE FUNCTION recalcular_ranking(p_bolao_id uuid)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
  UPDATE participantes p
  SET pontos_total = COALESCE((
    SELECT SUM(pal.pontos)
    FROM palpites pal
    WHERE pal.participante_id = p.id
      AND pal.pontos IS NOT NULL
  ), 0)
  WHERE p.bolao_id = p_bolao_id;
$$;

-- Garante que somente o owner pode chamar diretamente
REVOKE ALL ON FUNCTION recalcular_ranking(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION recalcular_ranking(uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION recalcular_ranking(uuid) TO service_role;
