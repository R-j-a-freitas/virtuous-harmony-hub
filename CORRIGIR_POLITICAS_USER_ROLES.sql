-- ============================================================================
-- CORRIGIR POLÍTICAS RLS DA TABELA user_roles
-- ============================================================================
-- Este script corrige as políticas que podem estar a bloquear a autenticação
-- ============================================================================

-- Remover políticas antigas
DROP POLICY IF EXISTS "Users can view their own role" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can manage roles" ON public.user_roles;
DROP POLICY IF EXISTS "Public can view roles" ON public.user_roles;

-- Garantir que RLS está habilitado
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Política: Utilizadores autenticados podem ver seu próprio role
CREATE POLICY "Users can view their own role"
ON public.user_roles
FOR SELECT
USING (auth.uid() = user_id);

-- IMPORTANTE: Permitir que utilizadores vejam roles durante autenticação
-- Esta política permite que qualquer utilizador autenticado veja roles
-- (necessário para o checkAuth funcionar)
CREATE POLICY "Authenticated users can check their role"
ON public.user_roles
FOR SELECT
USING (auth.role() = 'authenticated');

-- Política: Somente admins podem gerenciar roles (inserir/atualizar/deletar)
CREATE POLICY "Admins can manage roles"
ON public.user_roles
FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = auth.uid() AND role = 'admin'
  )
);

-- Verificar se foi criado corretamente
DO $$
BEGIN
  RAISE NOTICE '✅ Políticas RLS corrigidas para user_roles';
  RAISE NOTICE '✅ Utilizadores autenticados podem agora ver suas roles';
  RAISE NOTICE '';
  RAISE NOTICE 'TESTE AGORA:';
  RAISE NOTICE '1. Faça login em /admin';
  RAISE NOTICE '2. Se não funcionar, verifique o console do browser (F12)';
END $$;

