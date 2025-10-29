-- ============================================================================
-- CORRIGIR POLÍTICAS RLS - VERSÃO SIMPLES (SEM CONFLITOS)
-- ============================================================================

-- Remover TODAS as políticas antigas primeiro
DROP POLICY IF EXISTS "Users can view their own role" ON public.user_roles;
DROP POLICY IF EXISTS "Authenticated users can check their role" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can manage roles" ON public.user_roles;
DROP POLICY IF EXISTS "Public can view roles" ON public.user_roles;

-- Garantir que RLS está habilitado
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Garantir permissões básicas
GRANT SELECT ON public.user_roles TO authenticated;
GRANT SELECT ON public.user_roles TO anon;

-- Criar políticas (uma de cada vez, sem conflitos)
-- Política 1: Utilizadores podem ver sua própria role
CREATE POLICY "Users can view their own role"
ON public.user_roles
FOR SELECT
USING (auth.uid() = user_id);

-- Política 2: Utilizadores autenticados podem verificar qualquer role
-- (Necessário para verificar permissões durante login)
CREATE POLICY "Authenticated users can check their role"
ON public.user_roles
FOR SELECT
USING (auth.role() = 'authenticated');

-- Política 3: Admins podem gerenciar roles
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
SELECT 
  'Políticas criadas:' as status,
  COUNT(*) as total_policies
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'user_roles';

-- Listar todas as políticas
SELECT 
  policyname,
  cmd,
  roles
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'user_roles'
ORDER BY policyname;

-- Verificar se o utilizador pode ver sua role
SELECT 
  'Teste de verificação:' as teste,
  u.email,
  ur.role,
  'Role encontrada!' as status
FROM auth.users u
LEFT JOIN public.user_roles ur ON u.id = ur.user_id
WHERE u.email = 'rjafreitas@gmail.com';

DO $$
BEGIN
  RAISE NOTICE '✅ Políticas RLS corrigidas!';
  RAISE NOTICE '✅ Utilizadores autenticados podem agora verificar roles';
  RAISE NOTICE '';
  RAISE NOTICE 'TESTE AGORA:';
  RAISE NOTICE '1. Abra /admin';
  RAISE NOTICE '2. Faça login com rjafreitas@gmail.com';
  RAISE NOTICE '3. Deve funcionar agora!';
END $$;

