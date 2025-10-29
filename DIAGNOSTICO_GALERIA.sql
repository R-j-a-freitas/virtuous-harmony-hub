-- =====================================================
-- SCRIPT DE DIAGNÓSTICO: VERIFICAR SISTEMA DE GALERIA
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- 1. VERIFICAR SE A TABELA EXISTE
-- =====================================================

SELECT 
  'Verificação da Tabela:' as info,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'gallery_images' AND table_schema = 'public') 
    THEN '✅ Tabela gallery_images existe'
    ELSE '❌ Tabela gallery_images NÃO existe'
  END as status;

-- =====================================================
-- 2. VERIFICAR ESTRUTURA DA TABELA
-- =====================================================

SELECT 
  'Estrutura da Tabela:' as info,
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns 
WHERE table_name = 'gallery_images' 
  AND table_schema = 'public'
ORDER BY ordinal_position;

-- =====================================================
-- 3. VERIFICAR RLS
-- =====================================================

SELECT 
  'RLS Status:' as info,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM pg_class 
      WHERE relname = 'gallery_images' 
        AND relrowsecurity = true
    ) 
    THEN '✅ RLS habilitado'
    ELSE '❌ RLS NÃO habilitado'
  END as status;

-- =====================================================
-- 4. VERIFICAR POLÍTICAS RLS
-- =====================================================

SELECT 
  'Políticas RLS:' as info,
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'gallery_images'
ORDER BY policyname;

-- =====================================================
-- 5. VERIFICAR STORAGE BUCKET
-- =====================================================

SELECT 
  'Storage Bucket:' as info,
  id,
  name,
  public,
  file_size_limit,
  allowed_mime_types
FROM storage.buckets 
WHERE id = 'gallery-images';

-- =====================================================
-- 6. VERIFICAR POLÍTICAS DE STORAGE
-- =====================================================

SELECT 
  'Políticas de Storage:' as info,
  policyname,
  cmd,
  roles,
  qual,
  with_check
FROM pg_policies 
WHERE schemaname = 'storage' 
  AND tablename = 'objects'
  AND policyname LIKE '%gallery%'
ORDER BY policyname;

-- =====================================================
-- 7. VERIFICAR DADOS EXISTENTES
-- =====================================================

SELECT 
  'Dados na Tabela:' as info,
  COUNT(*) as total_images,
  COUNT(CASE WHEN is_visible = true THEN 1 END) as visible_images,
  COUNT(CASE WHEN is_visible = false THEN 1 END) as hidden_images
FROM public.gallery_images;

-- =====================================================
-- 8. VERIFICAR FUNÇÃO is_admin
-- =====================================================

SELECT 
  'Função is_admin:' as info,
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.routines 
      WHERE routine_name = 'is_admin' 
        AND routine_schema = 'public'
    ) 
    THEN '✅ Função is_admin existe'
    ELSE '❌ Função is_admin NÃO existe'
  END as status;

-- =====================================================
-- 9. VERIFICAR USUÁRIO ADMIN
-- =====================================================

SELECT 
  'Usuário Admin:' as info,
  au.email,
  ur.role,
  CASE 
    WHEN ur.role = 'admin' THEN '✅ Usuário é admin'
    ELSE '❌ Usuário NÃO é admin'
  END as status
FROM auth.users au
LEFT JOIN public.user_roles ur ON au.id = ur.user_id
WHERE au.email = 'virtuousensemble@gmail.com';

-- =====================================================
-- 10. RESUMO FINAL
-- =====================================================

SELECT 
  'RESUMO FINAL:' as info,
  CASE 
    WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'gallery_images' AND table_schema = 'public')
      AND EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'gallery-images')
      AND EXISTS (SELECT 1 FROM information_schema.routines WHERE routine_name = 'is_admin' AND routine_schema = 'public')
    THEN '✅ SISTEMA DE GALERIA CONFIGURADO CORRETAMENTE'
    ELSE '❌ SISTEMA DE GALERIA INCOMPLETO - EXECUTE CRIAR_GALERIA_ESSENCIAL.sql'
  END as status;

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- 
-- Se tudo estiver correto:
-- ✅ Tabela gallery_images existe
-- ✅ RLS habilitado
-- ✅ Políticas RLS criadas
-- ✅ Storage bucket existe
-- ✅ Políticas de storage criadas
-- ✅ Função is_admin existe
-- ✅ Usuário admin existe
-- ✅ SISTEMA DE GALERIA CONFIGURADO CORRETAMENTE
-- 
-- Se algo estiver faltando:
-- ❌ Execute CRIAR_GALERIA_ESSENCIAL.sql primeiro
-- 
-- =====================================================
