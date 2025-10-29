-- =====================================================
-- SCRIPT DE DIAGNÓSTICO: VERIFICAR CONFIGURAÇÃO COMPLETA
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- 1. VERIFICAR TABELAS EXISTENTES
-- =====================================================

SELECT 
  table_name, 
  table_type 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('testimonials', 'events', 'user_roles')
ORDER BY table_name;

-- =====================================================
-- 2. VERIFICAR RLS NAS TABELAS
-- =====================================================

SELECT 
  schemaname,
  tablename,
  rowsecurity
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('testimonials', 'events', 'user_roles')
ORDER BY tablename;

-- =====================================================
-- 3. VERIFICAR POLÍTICAS RLS
-- =====================================================

SELECT 
  tablename,
  policyname,
  cmd,
  permissive,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE schemaname = 'public'
  AND tablename IN ('testimonials', 'events', 'user_roles')
ORDER BY tablename, policyname;

-- =====================================================
-- 4. VERIFICAR FUNÇÕES DE AUTENTICAÇÃO
-- =====================================================

SELECT 
  routine_name,
  routine_type,
  data_type
FROM information_schema.routines 
WHERE routine_schema = 'public' 
  AND routine_name IN ('is_admin', 'is_moderator_or_admin')
ORDER BY routine_name;

-- =====================================================
-- 5. VERIFICAR USUÁRIOS ADMIN
-- =====================================================

-- Verificar se existem usuários admin
SELECT 
  ur.role,
  au.email,
  ur.created_at
FROM public.user_roles ur
JOIN auth.users au ON ur.user_id = au.id
WHERE ur.role = 'admin'
ORDER BY ur.created_at;

-- =====================================================
-- 6. VERIFICAR EVENTOS
-- =====================================================

-- Verificar todos os eventos
SELECT 
  status,
  COUNT(*) as quantidade,
  MIN(event_date) as data_mais_antiga,
  MAX(event_date) as data_mais_recente
FROM public.events 
GROUP BY status
ORDER BY status;

-- =====================================================
-- 7. TESTAR ACESSO PÚBLICO AOS EVENTOS
-- =====================================================

-- Testar se eventos confirmados são acessíveis
SELECT 
  'Teste de acesso público' as teste,
  COUNT(*) as eventos_confirmados_visiveis
FROM public.events 
WHERE status = 'confirmed';

-- =====================================================
-- 8. VERIFICAR VIEWS
-- =====================================================

-- Verificar se views existem
SELECT 
  table_name, 
  table_type,
  CASE 
    WHEN table_name = 'public_events' THEN 'View para eventos públicos'
    ELSE 'Outra view'
  END as descricao
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_type = 'VIEW'
ORDER BY table_name;

-- =====================================================
-- 9. TESTE FINAL DE FUNCIONAMENTO
-- =====================================================

-- Teste completo de funcionamento
SELECT 
  'DIAGNÓSTICO COMPLETO' as status,
  (SELECT COUNT(*) FROM public.events WHERE status = 'confirmed') as eventos_confirmados,
  (SELECT COUNT(*) FROM public.testimonials WHERE approved = true) as testemunhos_aprovados,
  (SELECT COUNT(*) FROM public.user_roles WHERE role = 'admin') as admins_criados,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'public_events') 
    THEN 'View existe'
    ELSE 'View não existe'
  END as status_view;

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- 
-- ✅ Todas as tabelas existem
-- ✅ RLS habilitado em todas as tabelas
-- ✅ Políticas RLS configuradas
-- ✅ Funções de autenticação existem
-- ✅ Usuário admin criado
-- ✅ Eventos confirmados disponíveis
-- ✅ View pública funcionando
-- 
-- =====================================================
