-- ============================================================================
-- CORREÇÃO RÁPIDA: Remover políticas conflitantes de events
-- ============================================================================
-- Execute este script se receber erro "policy already exists"
-- ============================================================================

-- Remover TODAS as políticas antigas de events
DROP POLICY IF EXISTS "Admins can view all events" ON public.events;
DROP POLICY IF EXISTS "Admins can update events" ON public.events;
DROP POLICY IF EXISTS "Admins can delete events" ON public.events;
DROP POLICY IF EXISTS "Admins can insert events" ON public.events;
DROP POLICY IF EXISTS "Anyone can insert events" ON public.events;
DROP POLICY IF EXISTS "Public can view confirmed events" ON public.events;
DROP POLICY IF EXISTS "Anyone can view confirmed events" ON public.events;
DROP POLICY IF EXISTS "Admins can view events" ON public.events;
DROP POLICY IF EXISTS "Public can view events" ON public.events;

-- Verificar políticas removidas
DO $$
BEGIN
  RAISE NOTICE '✅ Todas as políticas antigas de events foram removidas';
  RAISE NOTICE 'Agora pode executar CRIAR_SISTEMA_SEGURANCA_COMPLETO.sql novamente';
END $$;

