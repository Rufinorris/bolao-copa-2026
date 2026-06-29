-- Permite ao admin liberar palpites para um jogo específico,
-- mesmo após o corte de 5 minutos antes do início.
ALTER TABLE public.jogos ADD COLUMN IF NOT EXISTS override_aberto boolean DEFAULT false;
