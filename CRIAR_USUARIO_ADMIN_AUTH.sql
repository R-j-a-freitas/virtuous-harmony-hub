-- ============================================================================
-- CRIAR USUÁRIO ADMIN COM SUPABASE AUTH
-- ============================================================================
-- Este script cria um usuário admin usando Supabase Auth
-- IMPORTANTE: Execute este script DEPOIS de criar o usuário no Supabase Dashboard
-- ============================================================================

-- ============================================================================
-- PASSO 1: CRIAR USUÁRIO NO SUPABASE DASHBOARD
-- ============================================================================
-- Você deve criar o usuário manualmente no Supabase Dashboard:
-- 1. Acesse: https://supabase.com/dashboard/project/mhzhxwmxnofltgdmshcq/auth/users
-- 2. Clique em "Add user" → "Create new user"
-- 3. Email: virtuousensemble@gmail.com
-- 4. Password: [escolha uma senha forte]
-- 5. Clique em "Create user"
-- 6. COPIE O UUID do usuário criado
-- ============================================================================

-- ============================================================================
-- PASSO 2: EXECUTAR ESTE SCRIPT COM O UUID DO USUÁRIO
-- ============================================================================
-- Substitua 'USER_UUID_AQUI' pelo UUID do usuário criado no passo 1
-- ============================================================================

-- EXEMPLO (SUBSTITUA PELO UUID REAL):
-- INSERT INTO public.user_roles (user_id, role)
-- VALUES ('00000000-0000-0000-0000-000000000000', 'admin')
-- ON CONFLICT (user_id) DO UPDATE SET role = 'admin';

-- ============================================================================
-- FUNÇÃO AUXILIAR: Criar usuário admin por email
-- ============================================================================
-- Esta função ajuda a encontrar o UUID do usuário pelo email
-- Use assim: SELECT public.create_admin_by_email('virtuousensemble@gmail.com');

CREATE OR REPLACE FUNCTION public.create_admin_by_email(user_email TEXT)
RETURNS UUID AS $$
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
  
  RAISE NOTICE '✅ Usuário admin criado com sucesso! UUID: %', user_uuid;
  
  RETURN user_uuid;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- VERIFICAR USUÁRIOS ADMIN EXISTENTES
-- ============================================================================
-- Execute esta query para ver todos os usuários admin:
-- SELECT u.email, ur.role, ur.created_at
-- FROM auth.users u
-- JOIN public.user_roles ur ON u.id = ur.user_id
-- WHERE ur.role = 'admin';

-- ============================================================================
-- INSTRUÇÕES DE USO
-- ============================================================================
-- 1. Crie o usuário no Supabase Dashboard (Auth → Users → Add user)
-- 2. Execute: SELECT public.create_admin_by_email('virtuousensemble@gmail.com');
-- 3. Verifique: SELECT * FROM public.user_roles WHERE role = 'admin';
-- ============================================================================
