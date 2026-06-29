-- Adiciona coluna artilheiro_confirmado na tabela jogos (array de nomes)
-- Execute no SQL Editor do Supabase APÓS o schema inicial
-- Suporta múltiplos artilheiros por jogo — participante ganha bônus se acertou qualquer um

alter table public.jogos
  add column if not exists artilheiro_confirmado text[] default '{}';
