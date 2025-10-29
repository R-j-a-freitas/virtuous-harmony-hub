-- =====================================================
-- SCRIPT: CRIAR USUÁRIO ADMIN AUTOMATICAMENTE
-- =====================================================
-- Este script cria o usuário admin e atribui a role de administrador
-- Execute este script no SQL Editor do Supabase

-- =====================================================
-- 1. CRIAR USUÁRIO ADMIN
-- =====================================================

-- Inserir usuário diretamente na tabela auth.users
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  recovery_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
   'virtuousensemble@gmail.com',
  crypt('!P4tr1c14+', gen_salt('bf')),
  now(),
  null,
  null,
  '{"provider": "email", "providers": ["email"]}',
  '{}',
  now(),
  now(),
  '',
  '',
  '',
  ''
);

-- =====================================================
-- 2. OBTER O ID DO USUÁRIO CRIADO
-- =====================================================

-- Criar uma variável temporária com o ID do usuário
DO $$
DECLARE
  admin_user_id UUID;
BEGIN
  -- Obter o ID do usuário admin que acabamos de criar
  SELECT id INTO admin_user_id 
  FROM auth.users 
  WHERE email = 'virtuousensemble@gmail.com';
  
  -- Inserir a role de admin na tabela user_roles
  INSERT INTO public.user_roles (user_id, role) 
  VALUES (admin_user_id, 'admin');
  
  -- Mostrar confirmação
  RAISE NOTICE 'Usuário admin criado com ID: %', admin_user_id;
END $$;

-- =====================================================
-- 3. VERIFICAR SE FOI CRIADO COM SUCESSO
-- =====================================================

-- Verificar se o usuário foi criado
SELECT 
  u.id,
  u.email,
  u.email_confirmed_at,
  u.created_at,
  ur.role
FROM auth.users u
LEFT JOIN public.user_roles ur ON u.id = ur.user_id
WHERE u.email = 'virtuousensemble@gmail.com';

-- =====================================================
-- 4. ATUALIZAR POLÍTICAS PARA PERMITIR ADMIN
-- =====================================================

-- Atualizar política de user_roles para permitir que admins gerenciem roles
DROP POLICY IF EXISTS "Admins can manage roles" ON public.user_roles;
CREATE POLICY "Admins can manage roles"
ON public.user_roles
FOR ALL
USING (public.is_admin());

-- =====================================================
-- 5. CONFIRMAÇÃO FINAL
-- =====================================================

-- Mostrar informações do usuário admin criado
SELECT 
  '✅ USUÁRIO ADMIN CRIADO COM SUCESSO!' as status,
  u.email,
  u.id as user_id,
  ur.role,
  'Login: virtuousensemble@gmail.com' as login_info,
  'Password: !P4tr1c14+' as password_info
FROM auth.users u
JOIN public.user_roles ur ON u.id = ur.user_id
WHERE u.email = 'virtuousensemble@gmail.com';

-- =====================================================
-- INFORMAÇÕES DE LOGIN
-- =====================================================
-- 
-- 📧 Email: virtuousensemble@gmail.com
-- 🔑 Password: !P4tr1c14+
-- 👤 Role: admin
-- 
-- ✅ O usuário pode agora fazer login no dashboard do Supabase
-- ✅ Tem acesso completo a todas as funcionalidades admin
-- ✅ Pode gerenciar testimonials, events e outros usuários
-- 
-- =====================================================
