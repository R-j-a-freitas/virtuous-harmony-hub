-- =====================================================
-- SCRIPT COMPLETO: CRIAR BASE DE DADOS VIRTUOUS ENSEMBLE
-- =====================================================
-- Este script cria toda a base de dados necessária para o projeto
-- Execute este script completo no SQL Editor do Supabase

-- =====================================================
-- 1. CRIAR TABELAS PRINCIPAIS
-- =====================================================

-- Criar tabela testimonials
CREATE TABLE IF NOT EXISTS public.testimonials (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  content TEXT NOT NULL,
  rating INTEGER DEFAULT 5 CHECK (rating >= 1 AND rating <= 5),
  event_type TEXT,
  event_date DATE,
  approved BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Criar tabela events
CREATE TABLE IF NOT EXISTS public.events (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  event_date DATE NOT NULL,
  event_time TIME,
  location TEXT NOT NULL,
  description TEXT,
  client_name TEXT,
  client_email TEXT,
  client_phone TEXT,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- =====================================================
-- 2. HABILITAR ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Habilitar RLS nas tabelas
ALTER TABLE public.testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 3. CRIAR POLÍTICAS RLS INICIAIS
-- =====================================================

-- Políticas para testimonials
DROP POLICY IF EXISTS "Anyone can view approved testimonials" ON public.testimonials;
CREATE POLICY "Anyone can view approved testimonials"
ON public.testimonials
FOR SELECT
USING (approved = true);

DROP POLICY IF EXISTS "Anyone can insert testimonials" ON public.testimonials;
CREATE POLICY "Anyone can insert testimonials"
ON public.testimonials
FOR INSERT
WITH CHECK (true);

-- Políticas para events
DROP POLICY IF EXISTS "Anyone can view confirmed events" ON public.events;
CREATE POLICY "Anyone can view confirmed events"
ON public.events
FOR SELECT
USING (status = 'confirmed');

DROP POLICY IF EXISTS "Anyone can insert events" ON public.events;
CREATE POLICY "Anyone can insert events"
ON public.events
FOR INSERT
WITH CHECK (true);

-- =====================================================
-- 4. CRIAR FUNÇÕES E TRIGGERS
-- =====================================================

-- Função para atualizar timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- Triggers para atualização automática de timestamps
DROP TRIGGER IF EXISTS update_testimonials_updated_at ON public.testimonials;
CREATE TRIGGER update_testimonials_updated_at
BEFORE UPDATE ON public.testimonials
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_events_updated_at ON public.events;
CREATE TRIGGER update_events_updated_at
BEFORE UPDATE ON public.events
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- =====================================================
-- 5. CRIAR TABELA DE ROLES DE USUÁRIO
-- =====================================================

-- Criar tabela user_roles para controle de acesso
CREATE TABLE IF NOT EXISTS public.user_roles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('admin', 'moderator')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id)
);

-- Habilitar RLS na tabela user_roles
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Políticas para user_roles
DROP POLICY IF EXISTS "Users can view their own role" ON public.user_roles;
CREATE POLICY "Users can view their own role"
ON public.user_roles
FOR SELECT
USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Admins can manage roles" ON public.user_roles;
CREATE POLICY "Admins can manage roles"
ON public.user_roles
FOR ALL
USING (false); -- Será atualizada quando tivermos admins

-- Trigger para user_roles
DROP TRIGGER IF EXISTS update_user_roles_updated_at ON public.user_roles;
CREATE TRIGGER update_user_roles_updated_at
BEFORE UPDATE ON public.user_roles
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- =====================================================
-- 6. CRIAR FUNÇÕES DE VERIFICAÇÃO DE ROLES
-- =====================================================

-- Função para verificar se usuário é admin
CREATE OR REPLACE FUNCTION public.is_admin(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = user_uuid AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Função para verificar se usuário é moderador ou admin
CREATE OR REPLACE FUNCTION public.is_moderator_or_admin(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = user_uuid AND role IN ('admin', 'moderator')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =====================================================
-- 7. CRIAR VIEW PÚBLICA PARA EVENTOS (SEGURANÇA)
-- =====================================================

-- Criar view pública que não expõe dados do cliente
DROP VIEW IF EXISTS public.public_events;
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

-- Conceder acesso à view pública
GRANT SELECT ON public.public_events TO anon, authenticated;

-- =====================================================
-- 8. ATUALIZAR POLÍTICAS COM AUTENTICAÇÃO
-- =====================================================

-- Atualizar políticas de events para usar autenticação
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

-- Atualizar políticas de testimonials para usar autenticação
DROP POLICY IF EXISTS "Authenticated users can insert testimonials" ON public.testimonials;
CREATE POLICY "Authenticated users can insert testimonials"
ON public.testimonials
FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);

DROP POLICY IF EXISTS "Admins can view all testimonials" ON public.testimonials;
CREATE POLICY "Admins can view all testimonials"
ON public.testimonials
FOR SELECT
USING (public.is_admin());

DROP POLICY IF EXISTS "Moderators and admins can approve testimonials" ON public.testimonials;
CREATE POLICY "Moderators and admins can approve testimonials"
ON public.testimonials
FOR UPDATE
USING (public.is_moderator_or_admin());

DROP POLICY IF EXISTS "Admins can delete testimonials" ON public.testimonials;
CREATE POLICY "Admins can delete testimonials"
ON public.testimonials
FOR DELETE
USING (public.is_admin());

-- =====================================================
-- 9. INSERIR DADOS DE TESTE
-- =====================================================

-- Inserir testemunho de exemplo
INSERT INTO public.testimonials (name, content, rating, event_type, approved) 
VALUES (
  'Maria Silva', 
  'Serviço excepcional! Fizeram do nosso casamento um dia perfeito. Recomendo vivamente!', 
  5, 
  'Casamento', 
  true
);

-- Inserir outro testemunho
INSERT INTO public.testimonials (name, content, rating, event_type, approved) 
VALUES (
  'João Santos', 
  'Profissionais muito competentes e atenciosos. Tudo correu na perfeição.', 
  5, 
  'Aniversário', 
  true
);

-- Inserir evento de exemplo
INSERT INTO public.events (title, event_date, location, status, client_name, client_email, client_phone) 
VALUES (
  'Casamento Maria e João', 
  '2024-06-15', 
  'Lisboa', 
  'confirmed',
  'Maria Silva',
  'maria@email.com',
  '+351 912 345 678'
);

-- =====================================================
-- 10. VERIFICAÇÕES FINAIS
-- =====================================================

-- Verificar se as tabelas foram criadas
SELECT 
  table_name, 
  table_type 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('testimonials', 'events', 'user_roles', 'public_events');

-- Verificar se as políticas foram criadas
SELECT 
  schemaname, 
  tablename, 
  policyname, 
  permissive, 
  roles, 
  cmd 
FROM pg_policies 
WHERE schemaname = 'public';

-- =====================================================
-- SCRIPT CONCLUÍDO COM SUCESSO!
-- =====================================================
-- 
-- ✅ Tabelas criadas: testimonials, events, user_roles
-- ✅ RLS habilitado em todas as tabelas
-- ✅ Políticas de segurança configuradas
-- ✅ Funções de autenticação criadas
-- ✅ Triggers para timestamps funcionando
-- ✅ View pública para eventos criada
-- ✅ Dados de teste inseridos
-- 
-- PRÓXIMOS PASSOS:
-- 1. Criar usuário admin no dashboard
-- 2. Configurar RESEND_API_KEY
-- 3. Testar funcionalidade
-- =====================================================
