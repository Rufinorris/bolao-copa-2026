-- =============================================
-- Trash Talk — campo no participante
-- Só quem acertou o último jogo pode editar via UI
-- =============================================

alter table public.participantes
  add column if not exists trash_talk text check (char_length(trash_talk) <= 80);
