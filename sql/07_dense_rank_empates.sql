-- Fix: usar dense_rank para que empates compartilhem a mesma posição
create or replace function public.recalcular_ranking(p_bolao_id uuid)
returns void language plpgsql as $$
begin
  update public.participantes p
  set pontos_total = coalesce((
    select sum(pa.pontos) from public.palpites pa
    where pa.participante_id = p.id and pa.calculado = true
  ), 0)
  where p.bolao_id = p_bolao_id;

  with ranked as (
    select id, dense_rank() over (order by pontos_total desc) as pos
    from public.participantes where bolao_id = p_bolao_id
  )
  update public.participantes p set posicao = r.pos from ranked r where p.id = r.id;
end;
$$;
