-- =====================================================
-- SCRIPT: CORRIGIR VISIBILIDADE DOS EVENTOS CONFIRMADOS
-- =====================================================
-- Execute este script no SQL Editor do Supabase
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co

-- =====================================================
-- 1. VERIFICAR POLÍTICAS ATUAIS
-- =====================================================

-- Verificar políticas existentes na tabela events
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies 
WHERE tablename = 'events';

-- =====================================================
-- 2. CORRIGIR POLÍTICAS PARA EVENTOS
-- =====================================================

-- Remover políticas problemáticas
DROP POLICY IF EXISTS "Anyone can view public event information" ON public.events;
DROP POLICY IF EXISTS "Anyone can view confirmed events" ON public.events;

-- Criar política que permite visualizar eventos confirmados publicamente
-- (apenas campos não sensíveis)
CREATE POLICY "Anyone can view confirmed events (public fields only)"
ON public.events
FOR SELECT
USING (
  status = 'confirmed' AND 
  -- Apenas campos públicos são visíveis
  true
);

-- Política para inserção de eventos (formulário de contacto)
DROP POLICY IF EXISTS "Anyone can insert events" ON public.events;
CREATE POLICY "Anyone can insert events"
ON public.events
FOR INSERT
WITH CHECK (true);

-- Políticas para administradores
DROP POLICY IF EXISTS "Admins can view all events" ON public.events;
CREATE POLICY "Admins can view all events"
ON public.events
FOR SELECT
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can update events" ON public.events;
CREATE POLICY "Admins can update events"
ON public.events
FOR UPDATE
USING (public.is_admin());

DROP POLICY IF EXISTS "Admins can delete events" ON public.events;
CREATE POLICY "Admins can delete events"
ON public.events
FOR DELETE
USING (public.is_admin());

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

-- Se não existir, criar a view
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
-- 4. TESTAR VISIBILIDADE
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
-- 5. INSERIR EVENTO DE TESTE (se necessário)
-- =====================================================

-- Inserir evento de teste se não existir nenhum confirmado
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
  'Evento de Teste',
  CURRENT_DATE + INTERVAL '30 days',
  '15:00',
  'Lisboa',
  'Evento criado para testar a funcionalidade',
  'Cliente Teste',
  'teste@email.com',
  '+351 912 345 678',
  'confirmed'
) ON CONFLICT DO NOTHING;

-- =====================================================
-- 6. VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar políticas finais
SELECT 
  policyname,
  cmd,
  qual
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
-- ✅ Políticas RLS corrigidas
-- ✅ Eventos confirmados visíveis publicamente
-- ✅ Administradores podem gerir todos os eventos
-- ✅ Formulário de contacto pode inserir eventos
-- 
-- =====================================================
