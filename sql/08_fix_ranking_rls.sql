-- =============================================
-- Fix: ranking não atualiza após finalizar jogo
--
-- Problema 1: palpites_update bloqueia admin de atualizar pontos/calculado
-- Problema 2: recalcular_ranking sem SECURITY DEFINER falha sob RLS
-- =============================================

-- 1) Permite admin do bolão atualizar palpites dos seus participantes
drop policy if exists "palpites_update" on public.palpites;

create policy "palpites_update" on public.palpites for update using (
  -- participante atualiza o próprio palpite
  auth.uid() = (select user_id from public.participantes where id = participante_id)
  or
  -- admin do bolão atualiza qualquer palpite dos seus participantes
  auth.uid() = (
    select b.admin_id
    from public.boloes b
    join public.participantes pt on pt.bolao_id = b.id
    where pt.id = participante_id
  )
);

-- 2) recalcular_ranking com SECURITY DEFINER para sempre ter permissão de escrever
create or replace function public.recalcular_ranking(p_bolao_id uuid)
returns void language plpgsql
security definer
set search_path = public
as $$
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
