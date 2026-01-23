-- Migration: Criar tabela para manter a base de dados ativa
-- Esta tabela será usada pela Edge Function keep-db-active para evitar que a DB entre em pausa

CREATE TABLE IF NOT EXISTS public.db_keepalive (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  note TEXT DEFAULT 'Keepalive ping - manter DB ativa'
);

-- Criar índice para melhor performance nas operações de limpeza
CREATE INDEX IF NOT EXISTS idx_db_keepalive_created_at ON public.db_keepalive(created_at);

-- Comentário na tabela
COMMENT ON TABLE public.db_keepalive IS 'Tabela temporária usada para manter a base de dados Supabase ativa através de operações periódicas';

-- Política RLS: Permitir apenas operações através do service_role
-- A Edge Function usará service_role, então não precisamos de políticas públicas
ALTER TABLE public.db_keepalive ENABLE ROW LEVEL SECURITY;

-- Política para permitir inserção e exclusão apenas via service_role
-- (As Edge Functions com service_role bypassam RLS automaticamente)
