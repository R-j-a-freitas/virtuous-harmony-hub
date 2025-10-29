-- =====================================================
-- SCRIPT: CRIAR USUÁRIO ADMIN COM PASSWORD SIMPLES
-- =====================================================
-- Este script cria um novo usuário admin com password mais simples
-- Execute este script no SQL Editor do Supabase

-- =====================================================
-- 1. DELETAR USUÁRIO EXISTENTE (SE NECESSÁRIO)
-- =====================================================

-- Descomente a linha abaixo se quiser deletar o usuário existente
-- DELETE FROM auth.users WHERE email = 'virtuousensemble@gmail.com';

-- =====================================================
-- 2. CRIAR NOVO USUÁRIO ADMIN
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
  'admin@virtuousensemble.com',
  crypt('admin123', gen_salt('bf')),
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
-- 3. OBTER O ID DO USUÁRIO CRIADO E ATRIBUIR ROLE
-- =====================================================

DO $$
DECLARE
  admin_user_id UUID;
BEGIN
  -- Obter o ID do usuário admin que acabamos de criar
  SELECT id INTO admin_user_id 
  FROM auth.users 
  WHERE email = 'admin@virtuousensemble.com';
  
  -- Inserir a role de admin na tabela user_roles
  INSERT INTO public.user_roles (user_id, role) 
  VALUES (admin_user_id, 'admin');
  
  -- Mostrar confirmação
  RAISE NOTICE 'Usuário admin criado com ID: %', admin_user_id;
END $$;

-- =====================================================
-- 4. VERIFICAR SE FOI CRIADO COM SUCESSO
-- =====================================================

-- Verificar se o usuário foi criado
SELECT 
  '✅ USUÁRIO ADMIN CRIADO COM SUCESSO!' as status,
  u.email,
  u.id as user_id,
  ur.role,
  'Login: admin@virtuousensemble.com' as login_info,
  'Password: admin123' as password_info
FROM auth.users u
JOIN public.user_roles ur ON u.id = ur.user_id
WHERE u.email = 'admin@virtuousensemble.com';

-- =====================================================
-- INFORMAÇÕES DE LOGIN SIMPLIFICADAS
-- =====================================================
-- 
-- 📧 Email: admin@virtuousensemble.com
-- 🔑 Password: admin123
-- 👤 Role: admin
-- 
-- ✅ Password mais simples para facilitar o login
-- ✅ Usuário confirmado automaticamente
-- ✅ Role de admin atribuída
-- 
-- =====================================================
