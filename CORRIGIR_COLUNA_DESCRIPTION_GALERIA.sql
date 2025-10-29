-- =====================================================
-- CORRIGIR COLUNA DESCRIPTION NA TABELA GALLERY_IMAGES
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- Isso garante que a coluna 'description' existe na tabela

-- Adicionar coluna 'description' se não existir
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = 'gallery_images' 
        AND column_name = 'description'
    ) THEN
        ALTER TABLE public.gallery_images 
        ADD COLUMN description TEXT;
        
        RAISE NOTICE 'Coluna description adicionada à tabela gallery_images';
    ELSE
        RAISE NOTICE 'Coluna description já existe na tabela gallery_images';
    END IF;
END $$;

-- Verificar estrutura da tabela
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
AND table_name = 'gallery_images'
ORDER BY ordinal_position;

