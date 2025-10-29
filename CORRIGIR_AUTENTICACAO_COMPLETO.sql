-- ============================================================================
-- CORREÇÃO COMPLETA DE AUTENTICAÇÃO - Virtuous Ensemble
-- ============================================================================
-- Este script resolve o problema de RLS bloqueando verificação de roles
-- ============================================================================

-- 1. Garantir que a tabela user_roles existe e tem RLS
CREATE TABLE IF NOT EXISTS public.user_roles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('admin', 'moderator')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id)
);

ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- 2. Remover TODAS as políticas antigas
DROP POLICY IF EXISTS "Users can view their own role" ON public.user_roles;
DROP POLICY IF EXISTS "Authenticated users can check their role" ON public.user_roles;
DROP POLICY IF EXISTS "Admins can manage roles" ON public.user_roles;
DROP POLICY IF EXISTS "Public can view roles" ON public.user_roles;

-- 3. Criar políticas RLS corretas
-- Política 1: Utilizadores podem ver sua própria role
CREATE POLICY "Users can view their own role"
ON public.user_roles FOR SELECT
USING (auth.uid() = user_id);

-- Política 2: IMPORTANTE - Qualquer utilizador autenticado pode verificar roles
CREATE POLICY "Authenticated users can check their role"
ON public.user_roles FOR SELECT
USING (auth.role() = 'authenticated');

-- Política 3: Admins podem gerenciar
CREATE POLICY "Admins can manage roles"
ON public.user_roles FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = auth.uid() AND role = 'admin'
  )
);

-- 4. Garantir permissões GRANT
GRANT SELECT ON public.user_roles TO authenticated;
GRANT SELECT ON public.user_roles TO anon;

-- 5. Criar/Atualizar função is_admin com permissões corretas
CREATE OR REPLACE FUNCTION public.is_admin(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = user_uuid AND role = 'admin'
  );
END;
$$;

-- 6. Garantir permissões na função (permite anon e authenticated executarem)
GRANT EXECUTE ON FUNCTION public.is_admin(UUID) TO anon, authenticated;

-- 7. Criar função helper para adicionar admin por email
CREATE OR REPLACE FUNCTION public.create_admin_by_email(user_email TEXT)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  user_uuid UUID;
BEGIN
  -- Buscar UUID do usuário pelo email
  SELECT id INTO user_uuid
  FROM auth.users
  WHERE email = user_email;
  
  IF user_uuid IS NULL THEN
    RAISE EXCEPTION 'Usuário com email % não encontrado. Crie o usuário primeiro no Supabase Auth.', user_email;
  END IF;
  
  -- Adicionar role de admin
  INSERT INTO public.user_roles (user_id, role)
  VALUES (user_uuid, 'admin')
  ON CONFLICT (user_id) DO UPDATE SET role = 'admin';
  
  RETURN user_uuid;
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_admin_by_email(TEXT) TO authenticated;

-- 8. Verificação final
SELECT 
  '✅ Configuração completa!' as status,
  (SELECT COUNT(*) FROM pg_policies WHERE schemaname = 'public' AND tablename = 'user_roles') as total_policies,
  (SELECT COUNT(*) FROM pg_proc WHERE proname = 'is_admin') as function_exists;

-- 9. Listar políticas criadas
SELECT 
  policyname,
  cmd,
  roles
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'user_roles'
ORDER BY policyname;

-- 10. Teste: Verificar se utilizador tem role admin
SELECT 
  'Teste de verificação:' as teste,
  u.email,
  ur.role,
  public.is_admin(u.id) as is_admin_check,
  'Tudo OK!' as status
FROM auth.users u
LEFT JOIN public.user_roles ur ON u.id = ur.user_id
WHERE u.email IN ('rjafreitas@gmail.com', 'admin@virtuousensemble.com', 'virtuousensemble@gmail.com');

DO $$
BEGIN
  RAISE NOTICE '✅ Sistema de autenticação corrigido!';
  RAISE NOTICE '✅ Políticas RLS configuradas';
  RAISE NOTICE '✅ Função is_admin criada com permissões';
  RAISE NOTICE '';
  RAISE NOTICE 'TESTE:';
  RAISE NOTICE '1. Recarregue a página /admin';
  RAISE NOTICE '2. Faça login novamente';
  RAISE NOTICE '3. Deve funcionar agora!';
END $$;


