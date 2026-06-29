-- Posição vertical da foto de capa (0=topo, 50=centro, 100=base)
alter table public.boloes
  add column if not exists foto_posicao_y integer not null default 50;
