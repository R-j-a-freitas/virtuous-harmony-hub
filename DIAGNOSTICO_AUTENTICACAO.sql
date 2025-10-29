-- ============================================================================
-- DIAGNÓSTICO DE AUTENTICAÇÃO ADMIN
-- ============================================================================
-- Execute este script para identificar o problema de autenticação
-- ============================================================================

-- 1. Verificar se o utilizador existe e está confirmado
SELECT 
  '1. VERIFICAR UTILIZADOR' as teste,
  id as user_id,
  email,
  confirmed_at IS NOT NULL as is_confirmed,
  created_at
FROM auth.users
WHERE email = 'virtuousensemble@gmail.com';

-- 2. Verificar se tem role admin
SELECT 
  '2. VERIFICAR ROLE ADMIN' as teste,
  u.email,
  ur.role,
  ur.user_id,
  ur.created_at
FROM auth.users u
LEFT JOIN public.user_roles ur ON u.id = ur.user_id
WHERE u.email = 'virtuousensemble@gmail.com';

-- 3. Verificar políticas RLS na tabela user_roles
SELECT 
  '3. POLÍTICAS RLS user_roles' as teste,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'user_roles';

-- 4. Testar se a função is_admin funciona
SELECT 
  '4. TESTE FUNÇÃO is_admin' as teste,
  id as user_id,
  email,
  public.is_admin(id) as is_admin_check
FROM auth.users
WHERE email = 'virtuousensemble@gmail.com';

-- 5. Verificar se user_roles tem RLS habilitado
SELECT 
  '5. RLS HABILITADO?' as teste,
  schemaname,
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public' AND tablename = 'user_roles';

-- ============================================================================
-- POSSÍVEIS PROBLEMAS E SOLUÇÕES:
-- ============================================================================
-- 
-- PROBLEMA 1: Utilizador não confirmado
-- SOLUÇÃO: No Supabase Dashboard → Auth → Users → Confirm user
--
-- PROBLEMA 2: Não tem role admin
-- SOLUÇÃO: Execute:
--   SELECT public.create_admin_by_email('virtuousensemble@gmail.com');
--
-- PROBLEMA 3: Política RLS está a bloquear
-- SOLUÇÃO: Execute CORRIGIR_POLITICAS_USER_ROLES.sql
--
-- PROBLEMA 4: RLS não está habilitado
-- SOLUÇÃO: Execute ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
-- ============================================================================

