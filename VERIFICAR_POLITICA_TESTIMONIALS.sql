-- =====================================================
-- VERIFICAR POLÍTICAS RLS DA TABELA TESTIMONIALS
-- =====================================================
-- Execute este script para verificar as políticas atuais

-- Ver todas as políticas da tabela testimonials
SELECT 
  policyname AS "Nome da Política",
  cmd AS "Comando",
  CASE 
    WHEN cmd = 'SELECT' THEN qual
    WHEN cmd = 'INSERT' THEN with_check
    WHEN cmd = 'UPDATE' THEN qual || ' | WITH CHECK: ' || with_check
    WHEN cmd = 'DELETE' THEN qual
  END AS "Condição"
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename = 'testimonials'
ORDER BY cmd, policyname;

-- Verificar especificamente a política de INSERT
SELECT 
  policyname,
  cmd,
  with_check,
  CASE 
    WHEN with_check = 'true' THEN '✅ CORRETO - Permite inserção pública'
    WHEN with_check LIKE '%auth.uid()%' THEN '❌ ERRADO - Exige autenticação'
    ELSE '⚠️ VERIFICAR - Condição: ' || with_check
  END AS status
FROM pg_policies 
WHERE schemaname = 'public' 
AND tablename = 'testimonials'
AND cmd = 'INSERT'
AND policyname = 'Anyone can insert testimonials';

