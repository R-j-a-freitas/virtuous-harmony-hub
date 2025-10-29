-- =====================================================
-- POLÍTICAS RLS PARA PAINEL ADMINISTRATIVO
-- =====================================================
-- Este script cria políticas que permitem UPDATE e DELETE
-- nas tabelas events e testimonials
-- Execute no SQL Editor do Supabase

-- =====================================================
-- POLÍTICAS PARA EVENTOS (UPDATE/DELETE)
-- =====================================================

-- Permitir UPDATE de eventos (todos podem atualizar)
-- Em produção, você deve restringir isso com autenticação real
DROP POLICY IF EXISTS "Anyone can update events" ON public.events;
CREATE POLICY "Anyone can update events"
ON public.events
FOR UPDATE
USING (true)
WITH CHECK (true);

-- Permitir DELETE de eventos
DROP POLICY IF EXISTS "Anyone can delete events" ON public.events;
CREATE POLICY "Anyone can delete events"
ON public.events
FOR DELETE
USING (true);

-- =====================================================
-- POLÍTICAS PARA TESTEMUNHOS (UPDATE/DELETE)
-- =====================================================

-- Permitir UPDATE de testemunhos
DROP POLICY IF EXISTS "Anyone can update testimonials" ON public.testimonials;
CREATE POLICY "Anyone can update testimonials"
ON public.testimonials
FOR UPDATE
USING (true)
WITH CHECK (true);

-- Permitir DELETE de testemunhos
DROP POLICY IF EXISTS "Anyone can delete testimonials" ON public.testimonials;
CREATE POLICY "Anyone can delete testimonials"
ON public.testimonials
FOR DELETE
USING (true);

-- =====================================================
-- VERIFICAÇÃO
-- =====================================================

-- Verificar políticas criadas
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies
WHERE tablename IN ('events', 'testimonials')
ORDER BY tablename, policyname;
