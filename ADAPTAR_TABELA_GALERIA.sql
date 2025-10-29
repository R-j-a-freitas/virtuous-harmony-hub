-- =====================================================
-- ADAPTAR TABELA GALLERY_IMAGES PARA FUNCIONAR COM O CÓDIGO
-- =====================================================
-- Este script adiciona as colunas necessárias que faltam
-- Mantém compatibilidade com estrutura existente

-- Adicionar colunas se não existirem
DO $$ 
BEGIN
    -- Adicionar image_url se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'gallery_images' 
        AND column_name = 'image_url'
    ) THEN
        ALTER TABLE public.gallery_images 
        ADD COLUMN image_url TEXT;
        
        -- Preencher image_url com base no file_path existente (construir URL pública do Supabase Storage)
        -- Formato: https://{project-ref}.supabase.co/storage/v1/object/public/{bucket}/{file_path}
        UPDATE public.gallery_images 
        SET image_url = 'https://mhzhxwmxnofltgdmshcq.supabase.co/storage/v1/object/public/gallery-images/' || file_path
        WHERE image_url IS NULL AND file_path IS NOT NULL;
        
        RAISE NOTICE 'Coluna image_url adicionada e preenchida';
    END IF;

    -- Adicionar title se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'gallery_images' 
        AND column_name = 'title'
    ) THEN
        ALTER TABLE public.gallery_images 
        ADD COLUMN title TEXT;
        RAISE NOTICE 'Coluna title adicionada';
    END IF;

    -- Adicionar description se não existir (já deve existir, mas garantimos)
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'gallery_images' 
        AND column_name = 'description'
    ) THEN
        ALTER TABLE public.gallery_images 
        ADD COLUMN description TEXT;
        
        -- Preencher description com caption se caption existir e description não
        UPDATE public.gallery_images 
        SET description = caption
        WHERE description IS NULL AND caption IS NOT NULL;
        
        RAISE NOTICE 'Coluna description adicionada';
    END IF;

    -- Adicionar display_order se não existir
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'gallery_images' 
        AND column_name = 'display_order'
    ) THEN
        ALTER TABLE public.gallery_images 
        ADD COLUMN display_order INTEGER DEFAULT 0;
        
        -- Preencher display_order com sort_order se sort_order existir
        UPDATE public.gallery_images 
        SET display_order = COALESCE(sort_order, 0)
        WHERE display_order IS NULL;
        
        RAISE NOTICE 'Coluna display_order adicionada';
    END IF;
END $$;

-- Verificar estrutura final
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'gallery_images'
ORDER BY ordinal_position;

