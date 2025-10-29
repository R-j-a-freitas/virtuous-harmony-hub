-- =====================================================
-- SCRIPT ALTERNATIVO: POLÍTICAS DE STORAGE VIA FUNÇÃO
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- TENTAR CRIAR POLÍTICAS USANDO FUNÇÃO ADMIN
-- =====================================================

-- Função para criar políticas de storage
CREATE OR REPLACE FUNCTION create_gallery_storage_policies()
RETURNS TEXT AS $$
DECLARE
    result TEXT := '';
BEGIN
    -- Política 1: Visualizar imagens
    BEGIN
        EXECUTE 'CREATE POLICY "Anyone can view gallery images"
                ON storage.objects
                FOR SELECT
                USING (bucket_id = ''gallery-images'')';
        result := result || '✅ Política de visualização criada' || chr(10);
    EXCEPTION 
        WHEN duplicate_object THEN
            result := result || '⚠️ Política de visualização já existe' || chr(10);
        WHEN OTHERS THEN
            result := result || '❌ Erro ao criar política de visualização: ' || SQLERRM || chr(10);
    END;

    -- Política 2: Upload de imagens
    BEGIN
        EXECUTE 'CREATE POLICY "Admins can upload gallery images"
                ON storage.objects
                FOR INSERT
                WITH CHECK (bucket_id = ''gallery-images'' AND public.is_admin())';
        result := result || '✅ Política de upload criada' || chr(10);
    EXCEPTION 
        WHEN duplicate_object THEN
            result := result || '⚠️ Política de upload já existe' || chr(10);
        WHEN OTHERS THEN
            result := result || '❌ Erro ao criar política de upload: ' || SQLERRM || chr(10);
    END;

    -- Política 3: Atualizar imagens
    BEGIN
        EXECUTE 'CREATE POLICY "Admins can update gallery images"
                ON storage.objects
                FOR UPDATE
                USING (bucket_id = ''gallery-images'' AND public.is_admin())';
        result := result || '✅ Política de atualização criada' || chr(10);
    EXCEPTION 
        WHEN duplicate_object THEN
            result := result || '⚠️ Política de atualização já existe' || chr(10);
        WHEN OTHERS THEN
            result := result || '❌ Erro ao criar política de atualização: ' || SQLERRM || chr(10);
    END;

    -- Política 4: Deletar imagens
    BEGIN
        EXECUTE 'CREATE POLICY "Admins can delete gallery images"
                ON storage.objects
                FOR DELETE
                USING (bucket_id = ''gallery-images'' AND public.is_admin())';
        result := result || '✅ Política de exclusão criada' || chr(10);
    EXCEPTION 
        WHEN duplicate_object THEN
            result := result || '⚠️ Política de exclusão já existe' || chr(10);
        WHEN OTHERS THEN
            result := result || '❌ Erro ao criar política de exclusão: ' || SQLERRM || chr(10);
    END;

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- EXECUTAR A FUNÇÃO
-- =====================================================

-- Executar função para criar políticas
SELECT create_gallery_storage_policies() as resultado;

-- =====================================================
-- VERIFICAR RESULTADO
-- =====================================================

-- Contar políticas criadas
SELECT 
    'Resumo das Políticas:' as info,
    COUNT(*) as total_policies,
    COUNT(CASE WHEN policyname LIKE '%view%' THEN 1 END) as view_policies,
    COUNT(CASE WHEN policyname LIKE '%upload%' THEN 1 END) as upload_policies,
    COUNT(CASE WHEN policyname LIKE '%update%' THEN 1 END) as update_policies,
    COUNT(CASE WHEN policyname LIKE '%delete%' THEN 1 END) as delete_policies
FROM pg_policies 
WHERE schemaname = 'storage' 
    AND tablename = 'objects'
    AND policyname LIKE '%gallery%';

-- =====================================================
-- LIMPAR FUNÇÃO TEMPORÁRIA
-- =====================================================

DROP FUNCTION IF EXISTS create_gallery_storage_policies();

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- 
-- Se funcionar:
-- ✅ Todas as 4 políticas serão criadas
-- ✅ Sistema de galeria totalmente funcional
-- 
-- Se não funcionar:
-- ❌ Mensagens de erro detalhadas
-- ⚠️ Necessário criar manualmente no Dashboard
-- 
-- =====================================================
