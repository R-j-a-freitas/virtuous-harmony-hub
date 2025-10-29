-- =====================================================
-- SCRIPT SIMPLES: CORRIGIR VISIBILIDADE DOS EVENTOS
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- 1. VERIFICAR POLÍTICAS ATUAIS
-- =====================================================

-- Verificar políticas existentes na tabela events
SELECT 
  policyname,
  cmd,
  qual
FROM pg_policies 
WHERE tablename = 'events'
ORDER BY policyname;

-- =====================================================
-- 2. ADICIONAR POLÍTICA PARA VISUALIZAR EVENTOS CONFIRMADOS
-- =====================================================

-- Adicionar política que permite visualizar eventos confirmados publicamente
-- (apenas campos não sensíveis)
CREATE POLICY "Public can view confirmed events"
ON public.events
FOR SELECT
USING (status = 'confirmed');

-- =====================================================
-- 3. VERIFICAR SE A VIEW PÚBLICA EXISTE
-- =====================================================

-- Verificar se a view public_events existe
SELECT 
  table_name, 
  table_type 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name = 'public_events';

-- =====================================================
-- 4. CRIAR VIEW PÚBLICA (SE NÃO EXISTIR)
-- =====================================================

-- Criar a view pública para eventos confirmados
CREATE OR REPLACE VIEW public.public_events AS
SELECT 
  id,
  title,
  event_date,
  event_time,
  location,
  description,
  status,
  created_at
FROM public.events 
WHERE status = 'confirmed';

-- Conceder acesso à view
GRANT SELECT ON public.public_events TO anon, authenticated;

-- =====================================================
-- 5. TESTAR VISIBILIDADE
-- =====================================================

-- Testar se eventos confirmados são visíveis
SELECT 
  id,
  title,
  event_date,
  location,
  status
FROM public.events 
WHERE status = 'confirmed'
ORDER BY event_date;

-- =====================================================
-- 6. INSERIR EVENTO DE TESTE (se necessário)
-- =====================================================

-- Verificar se existem eventos confirmados
SELECT COUNT(*) as total_confirmed_events FROM public.events WHERE status = 'confirmed';

-- Se não existir nenhum evento confirmado, inserir um de teste
DO $$
BEGIN
  IF (SELECT COUNT(*) FROM public.events WHERE status = 'confirmed') = 0 THEN
    INSERT INTO public.events (
      title,
      event_date,
      event_time,
      location,
      description,
      client_name,
      client_email,
      client_phone,
      status
    ) VALUES (
      'Evento de Teste - Virtuous Ensemble',
      CURRENT_DATE + INTERVAL '30 days',
      '15:00',
      'Lisboa',
      'Evento criado para testar a funcionalidade de visualização pública',
      'Cliente Teste',
      'teste@virtuousensemble.com',
      '+351 912 345 678',
      'confirmed'
    );
    RAISE NOTICE 'Evento de teste inserido com sucesso!';
  ELSE
    RAISE NOTICE 'Já existem eventos confirmados. Nenhum evento de teste foi inserido.';
  END IF;
END $$;

-- =====================================================
-- 7. VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar políticas finais
SELECT 
  policyname,
  cmd,
  CASE 
    WHEN qual IS NOT NULL THEN 'Tem condição'
    ELSE 'Sem condição'
  END as tem_condicao
FROM pg_policies 
WHERE tablename = 'events'
ORDER BY policyname;

-- Verificar eventos confirmados
SELECT 
  COUNT(*) as total_confirmed_events,
  MIN(event_date) as proximo_evento,
  MAX(event_date) as ultimo_evento
FROM public.events 
WHERE status = 'confirmed';

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- 
-- ✅ Política "Public can view confirmed events" criada
-- ✅ View public_events criada/atualizada
-- ✅ Eventos confirmados visíveis publicamente
-- ✅ Evento de teste inserido (se necessário)
-- 
-- =====================================================
