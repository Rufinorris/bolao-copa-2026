-- =============================================
-- BOLÃO COPA 2026 — Schema (idempotente)
-- Seguro para rodar múltiplas vezes
-- =============================================

create extension if not exists "uuid-ossp";

-- =============================================
-- TABELAS
-- =============================================
create table if not exists public.boloes (
  id uuid primary key default uuid_generate_v4(),
  admin_id uuid references auth.users(id) on delete cascade not null,
  nome text not null,
  descricao text,
  foto_capa_url text,
  foto_posicao_y integer not null default 50,
  valor_entrada numeric(10,2) not null default 0,
  chave_pix text,
  slug text unique not null,
  status text not null default 'active' check (status in ('draft','active','finished')),
  pts_placar_exato integer not null default 25,
  pts_vencedor_mais_um_time integer not null default 18,
  pts_vencedor_correto integer not null default 15,
  pts_gols_um_time integer not null default 4,
  mult_round32 numeric(4,1) not null default 1,
  mult_oitavas numeric(4,1) not null default 2,
  mult_quartas numeric(4,1) not null default 3,
  mult_semi numeric(4,1) not null default 4,
  mult_final numeric(4,1) not null default 5,
  bonus_artilheiro_ativo boolean not null default false,
  pts_bonus_artilheiro integer not null default 5,
  palpites_bloqueados boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Colunas adicionadas em migrações posteriores (seguro repetir)
alter table public.boloes add column if not exists foto_posicao_y integer not null default 50;

create table if not exists public.participantes (
  id uuid primary key default uuid_generate_v4(),
  bolao_id uuid references public.boloes(id) on delete cascade not null,
  user_id uuid references auth.users(id) on delete cascade not null,
  nome text not null,
  avatar_url text,
  pagamento_confirmado boolean not null default false,
  pagamento_confirmado_em timestamptz,
  pontos_total integer not null default 0,
  posicao integer,
  created_at timestamptz not null default now(),
  unique(bolao_id, user_id)
);

create table if not exists public.jogos (
  id uuid primary key default uuid_generate_v4(),
  api_match_id text unique,
  fase text not null check (fase in ('round32','oitavas','quartas','semi','final','terceiro')),
  rodada_num integer,
  time_home text not null default 'A definir',
  time_home_flag text,
  time_home_id text,
  time_away text not null default 'A definir',
  time_away_flag text,
  time_away_id text,
  data_hora timestamptz,
  placar_home integer,
  placar_away integer,
  status text not null default 'scheduled' check (status in ('scheduled','live','finished')),
  vencedor text check (vencedor in ('home','away')),
  foi_prorrogacao boolean default false,
  foi_penaltis boolean default false,
  artilheiro_confirmado text[] default '{}',
  proximo_jogo_id uuid references public.jogos(id),
  proximo_posicao text check (proximo_posicao in ('home','away')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Coluna artilheiro_confirmado (seguro repetir)
alter table public.jogos add column if not exists artilheiro_confirmado text[] default '{}';

create table if not exists public.palpites (
  id uuid primary key default uuid_generate_v4(),
  participante_id uuid references public.participantes(id) on delete cascade not null,
  jogo_id uuid references public.jogos(id) on delete cascade not null,
  bolao_id uuid references public.boloes(id) on delete cascade not null,
  placar_home integer not null,
  placar_away integer not null,
  artilheiro text,
  pontos integer,
  calculado boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(participante_id, jogo_id)
);

-- =============================================
-- RLS
-- =============================================
alter table public.boloes enable row level security;
alter table public.participantes enable row level security;
alter table public.jogos enable row level security;
alter table public.palpites enable row level security;

-- Policies (drop + create para ser idempotente)
do $$ begin
  drop policy if exists "boloes_select" on public.boloes;
  drop policy if exists "boloes_insert" on public.boloes;
  drop policy if exists "boloes_update" on public.boloes;
  drop policy if exists "boloes_delete" on public.boloes;
  drop policy if exists "participantes_select" on public.participantes;
  drop policy if exists "participantes_insert" on public.participantes;
  drop policy if exists "participantes_update" on public.participantes;
  drop policy if exists "jogos_select" on public.jogos;
  drop policy if exists "jogos_all" on public.jogos;
  drop policy if exists "palpites_select" on public.palpites;
  drop policy if exists "palpites_insert" on public.palpites;
  drop policy if exists "palpites_update" on public.palpites;
end $$;

create policy "boloes_select"  on public.boloes for select using (true);
create policy "boloes_insert"  on public.boloes for insert with check (auth.uid() = admin_id);
create policy "boloes_update"  on public.boloes for update using (auth.uid() = admin_id);
create policy "boloes_delete"  on public.boloes for delete using (auth.uid() = admin_id);

create policy "participantes_select" on public.participantes for select using (true);
create policy "participantes_insert" on public.participantes for insert with check (auth.uid() = user_id);
create policy "participantes_update" on public.participantes for update using (
  auth.uid() = user_id or
  auth.uid() = (select admin_id from public.boloes where id = bolao_id)
);

create policy "jogos_select" on public.jogos for select using (true);
create policy "jogos_all"    on public.jogos for all   using (true);

create policy "palpites_select" on public.palpites for select using (true);
create policy "palpites_insert" on public.palpites for insert with check (
  auth.uid() = (select user_id from public.participantes where id = participante_id)
);
create policy "palpites_update" on public.palpites for update using (
  auth.uid() = (select user_id from public.participantes where id = participante_id)
);

-- =============================================
-- FUNÇÕES
-- =============================================
create or replace function public.avancar_vencedor_bracket()
returns trigger language plpgsql as $$
declare v_time text; v_flag text;
begin
  if NEW.status = 'finished' and NEW.vencedor is not null and OLD.status != 'finished' then
    if NEW.vencedor = 'home' then v_time := NEW.time_home; v_flag := NEW.time_home_flag;
    else v_time := NEW.time_away; v_flag := NEW.time_away_flag; end if;
    if NEW.proximo_jogo_id is not null then
      if NEW.proximo_posicao = 'home' then
        update public.jogos set time_home = v_time, time_home_flag = v_flag where id = NEW.proximo_jogo_id;
      else
        update public.jogos set time_away = v_time, time_away_flag = v_flag where id = NEW.proximo_jogo_id;
      end if;
    end if;
  end if;
  return NEW;
end;
$$;

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
    select id, row_number() over (order by pontos_total desc, created_at asc) as pos
    from public.participantes where bolao_id = p_bolao_id
  )
  update public.participantes p set posicao = r.pos from ranked r where p.id = r.id;
end;
$$;

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end;
$$;

-- =============================================
-- TRIGGERS (drop + create para idempotência)
-- =============================================
drop trigger if exists jogos_avancar_bracket  on public.jogos;
drop trigger if exists boloes_updated_at      on public.boloes;
drop trigger if exists jogos_updated_at       on public.jogos;
drop trigger if exists palpites_updated_at    on public.palpites;

create trigger jogos_avancar_bracket
  after update on public.jogos
  for each row execute function public.avancar_vencedor_bracket();

create trigger boloes_updated_at   before update on public.boloes    for each row execute function public.set_updated_at();
create trigger jogos_updated_at    before update on public.jogos     for each row execute function public.set_updated_at();
create trigger palpites_updated_at before update on public.palpites  for each row execute function public.set_updated_at();

-- =============================================
-- ÍNDICES
-- =============================================
create index if not exists idx_participantes_bolao on public.participantes(bolao_id);
create index if not exists idx_participantes_user  on public.participantes(user_id);
create index if not exists idx_palpites_participante on public.palpites(participante_id);
create index if not exists idx_palpites_jogo        on public.palpites(jogo_id);
create index if not exists idx_palpites_bolao       on public.palpites(bolao_id);
create index if not exists idx_jogos_fase           on public.jogos(fase);
create index if not exists idx_jogos_proximo        on public.jogos(proximo_jogo_id);
