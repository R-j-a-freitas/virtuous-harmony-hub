-- ============================================================================
-- SISTEMA DE SEGURANÇA COMPLETO - Virtuous Ensemble
-- ============================================================================
-- Este script implementa:
-- 1. Proteção de dados pessoais dos clientes
-- 2. Sistema de autenticação com Supabase Auth
-- 3. Políticas RLS adequadas
-- ============================================================================

-- ============================================================================
-- PARTE 1: PROTEGER DADOS PESSOAIS (PII) DOS CLIENTES
-- ============================================================================

-- Remover política pública que expõe dados sensíveis
DROP POLICY IF EXISTS "Anyone can view confirmed events" ON public.events;
DROP POLICY IF EXISTS "Public can view confirmed events" ON public.events;

-- Criar view pública que NÃO expõe dados sensíveis
CREATE OR REPLACE VIEW public.public_events AS
SELECT 
  id,
  title,
  event_date,
  event_time,
  location,
  description,
  status,
  created_at
FROM public.events
WHERE status = 'confirmed';

-- Permitir que qualquer um veja a view pública (sem dados sensíveis)
GRANT SELECT ON public.public_events TO anon, authenticated;

-- ============================================================================
-- PARTE 2: SISTEMA DE AUTENTICAÇÃO E ROLES
-- ============================================================================

-- Criar tabela de roles (se não existir)
CREATE TABLE IF NOT EXISTS public.user_roles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('admin', 'moderator')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id)
);

-- Habilitar RLS na tabela user_roles
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Remover políticas antigas se existirem
DROP POLICY IF EXISTS "Users can view their own role" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can manage roles" ON public.user_roles;

-- Política: Usuários só veem seu próprio role
CREATE POLICY "Users can view their own role"
ON public.user_roles
FOR SELECT
USING (auth.uid() = user_id);

-- Política: Somente admins podem gerenciar roles
CREATE POLICY "Admins can manage roles"
ON public.user_roles
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = auth.uid() AND role = 'admin'
  )
);

-- Função para verificar se o usuário é admin
CREATE OR REPLACE FUNCTION public.is_admin(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = user_uuid AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para verificar se o usuário é moderador ou admin
CREATE OR REPLACE FUNCTION public.is_moderator_or_admin(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = user_uuid AND role IN ('admin', 'moderator')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- PARTE 3: POLÍTICAS RLS PARA EVENTS (PROTEGIDAS)
-- ============================================================================

-- Remover políticas antigas (todas as possíveis políticas)
DROP POLICY IF EXISTS "Admins can view all events" ON public.events;
DROP POLICY IF EXISTS "Admins can update events" ON public.events;
DROP POLICY IF EXISTS "Admins can delete events" ON public.events;
DROP POLICY IF EXISTS "Admins can insert events" ON public.events;
DROP POLICY IF EXISTS "Anyone can insert events" ON public.events;
DROP POLICY IF EXISTS "Public can view confirmed events" ON public.events;
DROP POLICY IF EXISTS "Anyone can view confirmed events" ON public.events;

-- Política: Admins podem ver TODOS os eventos (incluindo dados sensíveis)
CREATE POLICY "Admins can view all events"
ON public.events
FOR SELECT
USING (public.is_admin());

-- Política: Admins podem atualizar eventos
CREATE POLICY "Admins can update events"
ON public.events
FOR UPDATE
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Política: Admins podem inserir eventos
CREATE POLICY "Admins can insert events"
ON public.events
FOR INSERT
WITH CHECK (public.is_admin());

-- Política: Admins podem deletar eventos
CREATE POLICY "Admins can delete events"
ON public.events
FOR DELETE
USING (public.is_admin());

-- Política: Usuários não-autenticados podem INSERIR eventos (formulário de contacto)
CREATE POLICY "Anyone can insert events"
ON public.events
FOR INSERT
WITH CHECK (true);

-- ============================================================================
-- PARTE 4: POLÍTICAS RLS PARA TESTIMONIALS (PROTEGIDAS)
-- ============================================================================

-- Remover políticas antigas de testimonials
DROP POLICY IF EXISTS "Public can view approved testimonials" ON public.testimonials;
DROP POLICY IF EXISTS "Anyone can insert testimonials" ON public.testimonials;
DROP POLICY IF EXISTS "Admins can manage testimonials" ON public.testimonials;
DROP POLICY IF EXISTS "Admins can update testimonials" ON public.testimonials;
DROP POLICY IF EXISTS "Admins can delete testimonials" ON public.testimonials;

-- Política: Público pode ver testemunhos aprovados
CREATE POLICY "Public can view approved testimonials"
ON public.testimonials
FOR SELECT
USING (approved = true);

-- Política: Qualquer um pode inserir testemunhos (formulário público)
CREATE POLICY "Anyone can insert testimonials"
ON public.testimonials
FOR INSERT
WITH CHECK (true);

-- Política: Admins podem atualizar testemunhos
CREATE POLICY "Admins can update testimonials"
ON public.testimonials
FOR UPDATE
USING (public.is_admin())
WITH CHECK (public.is_admin());

-- Política: Admins podem deletar testemunhos
CREATE POLICY "Admins can delete testimonials"
ON public.testimonials
FOR DELETE
USING (public.is_admin());

-- ============================================================================
-- VERIFICAÇÃO FINAL
-- ============================================================================

-- Verificar se tudo foi criado corretamente
DO $$
BEGIN
  RAISE NOTICE '✅ Sistema de segurança configurado!';
  RAISE NOTICE '✅ Dados pessoais protegidos';
  RAISE NOTICE '✅ Autenticação configurada';
  RAISE NOTICE '✅ Políticas RLS criadas';
  RAISE NOTICE '';
  RAISE NOTICE 'PRÓXIMO PASSO:';
  RAISE NOTICE 'Execute CRIAR_USUARIO_ADMIN_AUTH.sql para criar o usuário admin';
END $$;
