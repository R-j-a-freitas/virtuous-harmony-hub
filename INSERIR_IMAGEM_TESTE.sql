-- =====================================================
-- SCRIPT DE TESTE: INSERIR IMAGEM DE EXEMPLO
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- INSERIR IMAGEM DE EXEMPLO PARA TESTE
-- =====================================================

-- =====================================================
-- SCRIPT DE TESTE: INSERIR IMAGEM DE EXEMPLO
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- INSERIR IMAGEM DE EXEMPLO PARA TESTE
-- =====================================================

-- Inserir imagem de exemplo apenas se não existir
INSERT INTO public.gallery_images (
  filename,
  original_name,
  file_path,
  file_size,
  mime_type,
  width,
  height,
  alt_text,
  caption,
  is_visible,
  sort_order
)
SELECT 
  'teste-exemplo.jpg',
  'imagem-teste.jpg',
  'gallery-images/teste-exemplo.jpg',
  500000,
  'image/jpeg',
  800,
  600,
  'Imagem de teste para galeria',
  'Esta é uma imagem de exemplo para testar o sistema de galeria',
  true,
  1
WHERE NOT EXISTS (
  SELECT 1 FROM public.gallery_images 
  WHERE filename = 'teste-exemplo.jpg'
);

-- =====================================================
-- VERIFICAR SE FOI INSERIDA
-- =====================================================

SELECT 
  'Imagem de Teste:' as info,
  id,
  filename,
  original_name,
  is_visible,
  sort_order,
  created_at
FROM public.gallery_images 
WHERE filename = 'teste-exemplo.jpg';

-- =====================================================
-- CONTAR TOTAL DE IMAGENS
-- =====================================================

SELECT 
  'Total de Imagens:' as info,
  COUNT(*) as total,
  COUNT(CASE WHEN is_visible = true THEN 1 END) as visiveis,
  COUNT(CASE WHEN is_visible = false THEN 1 END) as ocultas
FROM public.gallery_images;

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- 
-- ✅ Imagem de teste inserida
-- ✅ Total de imagens: 1 (ou mais se já existirem)
-- ✅ Imagens visíveis: 1 (ou mais)
-- 
-- =====================================================
