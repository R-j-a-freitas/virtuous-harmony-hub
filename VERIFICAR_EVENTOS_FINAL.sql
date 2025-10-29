-- =====================================================
-- SCRIPT ULTRA SIMPLES: VERIFICAR E CORRIGIR EVENTOS
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- 1. VERIFICAR POLÍTICAS EXISTENTES
-- =====================================================

-- Verificar políticas existentes na tabela events
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

-- =====================================================
-- 2. VERIFICAR EVENTOS CONFIRMADOS
-- =====================================================

-- Verificar se existem eventos confirmados
SELECT 
  COUNT(*) as total_confirmed_events,
  COUNT(CASE WHEN event_date >= CURRENT_DATE THEN 1 END) as eventos_futuros
FROM public.events 
WHERE status = 'confirmed';

-- =====================================================
-- 3. TESTAR VISIBILIDADE ATUAL
-- =====================================================

-- Testar se eventos confirmados são visíveis publicamente
SELECT 
  id,
  title,
  event_date,
  location,
  status
FROM public.events 
WHERE status = 'confirmed'
ORDER BY event_date
LIMIT 5;

-- =====================================================
-- 4. CRIAR VIEW PÚBLICA (SE NÃO EXISTIR)
-- =====================================================

-- Verificar se a view public_events existe
SELECT 
  CASE 
    WHEN EXISTS (
      SELECT 1 FROM information_schema.tables 
      WHERE table_schema = 'public' 
      AND table_name = 'public_events'
    ) THEN 'View já existe'
    ELSE 'View não existe'
  END as status_view;

-- Criar a view pública para eventos confirmados (se não existir)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.tables 
    WHERE table_schema = 'public' 
    AND table_name = 'public_events'
  ) THEN
    CREATE VIEW public.public_events AS
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
    
    GRANT SELECT ON public.public_events TO anon, authenticated;
    RAISE NOTICE 'View public_events criada com sucesso!';
  ELSE
    RAISE NOTICE 'View public_events já existe.';
  END IF;
END $$;

-- =====================================================
-- 5. INSERIR EVENTO DE TESTE (se necessário)
-- =====================================================

-- Inserir evento de teste se não existir nenhum confirmado
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
-- 6. VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar eventos confirmados finais
SELECT 
  COUNT(*) as total_confirmed_events,
  MIN(event_date) as proximo_evento,
  MAX(event_date) as ultimo_evento
FROM public.events 
WHERE status = 'confirmed';

-- Testar se a view funciona
SELECT 
  COUNT(*) as eventos_na_view
FROM public.public_events;

-- =====================================================
-- RESULTADO ESPERADO
-- =====================================================
-- 
-- ✅ Políticas existentes verificadas
-- ✅ Eventos confirmados verificados
-- ✅ View public_events criada (se necessário)
-- ✅ Evento de teste inserido (se necessário)
-- ✅ Tudo funcionando corretamente
-- 
-- =====================================================
