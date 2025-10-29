-- =====================================================
-- SCRIPT: VERIFICAR SISTEMA DE GALERIA
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- VERIFICAR SE A TABELA EXISTE
-- =====================================================

-- Verificar se a tabela gallery_images existe
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name = 'gallery_images'
    ) 
    THEN '✅ TABELA gallery_images EXISTE'
    ELSE '❌ TABELA gallery_images NÃO EXISTE'
  END as status_tabela;

-- =====================================================
-- VERIFICAR SE O STORAGE BUCKET EXISTE
-- =====================================================

-- Verificar se o bucket gallery-images existe
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM storage.buckets 
      WHERE id = 'gallery-images'
    ) 
    THEN '✅ BUCKET gallery-images EXISTE'
    ELSE '❌ BUCKET gallery-images NÃO EXISTE'
  END as status_bucket;

-- =====================================================
-- VERIFICAR POLÍTICAS RLS
-- =====================================================

-- Verificar políticas da tabela gallery_images
SELECT 
  policyname,
  cmd,
  CASE 
    WHEN qual IS NOT NULL THEN 'Tem condição'
    ELSE 'Sem condição'
  END as tem_condicao
FROM pg_policies 
WHERE tablename = 'gallery_images'
ORDER BY policyname;

-- =====================================================
-- VERIFICAR DADOS DE EXEMPLO
-- =====================================================

-- Verificar se existem imagens de exemplo
SELECT 
  CASE 
    WHEN EXISTS (SELECT 1 FROM public.gallery_images) 
    THEN '✅ EXISTEM IMAGENS NA TABELA'
    ELSE '❌ NÃO EXISTEM IMAGENS NA TABELA'
  END as status_dados;

-- Contar imagens
SELECT 
  COUNT(*) as total_imagens,
  COUNT(CASE WHEN is_visible = true THEN 1 END) as imagens_visiveis,
  COUNT(CASE WHEN is_visible = false THEN 1 END) as imagens_ocultas
FROM public.gallery_images;

-- =====================================================
-- VERIFICAR FUNÇÕES DE AUTENTICAÇÃO
-- =====================================================

-- Verificar se a função is_admin existe
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.routines 
      WHERE routine_schema = 'public' 
      AND routine_name = 'is_admin'
    ) 
    THEN '✅ FUNÇÃO is_admin EXISTE'
    ELSE '❌ FUNÇÃO is_admin NÃO EXISTE'
  END as status_funcao;

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- 
-- Se tudo estiver correto, deve mostrar:
-- ✅ TABELA gallery_images EXISTE
-- ✅ BUCKET gallery-images EXISTE
-- ✅ EXISTEM IMAGENS NA TABELA
-- ✅ FUNÇÃO is_admin EXISTE
-- 
-- Se algo estiver em falta, execute o script:
-- CRIAR_SISTEMA_GALERIA.sql
-- 
-- =====================================================
