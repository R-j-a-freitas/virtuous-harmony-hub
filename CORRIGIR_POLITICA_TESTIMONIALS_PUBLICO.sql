-- =====================================================
-- CORRIGIR POLÍTICA RLS PARA PERMITIR TESTEMUNHOS PÚBLICOS
-- =====================================================
-- Este script corrige a política RLS para permitir que
-- qualquer pessoa (não autenticada) possa enviar testemunhos
-- Execute este script no SQL Editor do Supabase

-- Remover políticas antigas de INSERT
DROP POLICY IF EXISTS "Authenticated users can insert testimonials" ON public.testimonials;
DROP POLICY IF EXISTS "Anyone can insert testimonials" ON public.testimonials;

-- Criar política que permite qualquer pessoa inserir testemunhos
CREATE POLICY "Anyone can insert testimonials"
ON public.testimonials
FOR INSERT
WITH CHECK (true);

-- Verificar se a política de visualização pública existe
DROP POLICY IF EXISTS "Anyone can view approved testimonials" ON public.testimonials;
CREATE POLICY "Anyone can view approved testimonials"
ON public.testimonials
FOR SELECT
USING (approved = true);

-- Manter políticas de admin (se não existirem, serão criadas)
DO $$
BEGIN
  -- Política para admins verem todos os testemunhos
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'testimonials' 
    AND policyname = 'Admins can view all testimonials'
  ) THEN
    CREATE POLICY "Admins can view all testimonials"
    ON public.testimonials
    FOR SELECT
    USING (public.is_admin());
  END IF;

  -- Política para admins/moderadores aprovarem testemunhos
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'testimonials' 
    AND policyname = 'Moderators and admins can approve testimonials'
  ) THEN
    CREATE POLICY "Moderators and admins can approve testimonials"
    ON public.testimonials
    FOR UPDATE
    USING (public.is_moderator_or_admin())
    WITH CHECK (public.is_moderator_or_admin());
  END IF;

  -- Política para admins deletarem testemunhos
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies 
    WHERE schemaname = 'public' 
    AND tablename = 'testimonials' 
    AND policyname = 'Admins can delete testimonials'
  ) THEN
    CREATE POLICY "Admins can delete testimonials"
    ON public.testimonials
    FOR DELETE
    USING (public.is_admin());
  END IF;
END $$;

-- Verificar políticas criadas
SELECT 
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename = 'testimonials'
ORDER BY policyname;

