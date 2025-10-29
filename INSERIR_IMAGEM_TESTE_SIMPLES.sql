-- =====================================================
-- SCRIPT ULTRA SIMPLES: INSERIR IMAGEM DE TESTE
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- INSERIR IMAGEM DE TESTE (SEM CONFLITOS)
-- =====================================================

-- Usar DO block para evitar conflitos
DO $$
BEGIN
    -- Verificar se já existe uma imagem de teste
    IF NOT EXISTS (
        SELECT 1 FROM public.gallery_images 
        WHERE filename = 'teste-exemplo.jpg'
    ) THEN
        -- Inserir imagem de teste
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
        ) VALUES (
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
        );
        
        RAISE NOTICE '✅ Imagem de teste inserida com sucesso!';
    ELSE
        RAISE NOTICE '⚠️ Imagem de teste já existe, não foi inserida.';
    END IF;
END $$;

-- =====================================================
-- VERIFICAR RESULTADO
-- =====================================================

-- Verificar se a imagem foi inserida
SELECT 
    'Verificação da Imagem:' as info,
    CASE 
        WHEN EXISTS (SELECT 1 FROM public.gallery_images WHERE filename = 'teste-exemplo.jpg')
        THEN '✅ Imagem de teste encontrada'
        ELSE '❌ Imagem de teste NÃO encontrada'
    END as status;

-- Mostrar detalhes da imagem
SELECT 
    'Detalhes da Imagem:' as info,
    id,
    filename,
    original_name,
    is_visible,
    sort_order,
    created_at
FROM public.gallery_images 
WHERE filename = 'teste-exemplo.jpg';

-- Contar total de imagens
SELECT 
    'Resumo da Galeria:' as info,
    COUNT(*) as total_imagens,
    COUNT(CASE WHEN is_visible = true THEN 1 END) as imagens_visiveis,
    COUNT(CASE WHEN is_visible = false THEN 1 END) as imagens_ocultas
FROM public.gallery_images;

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- 
-- ✅ Imagem de teste inserida com sucesso!
-- ✅ Imagem de teste encontrada
-- ✅ Total de imagens: 1 (ou mais)
-- ✅ Imagens visíveis: 1 (ou mais)
-- 
-- =====================================================
