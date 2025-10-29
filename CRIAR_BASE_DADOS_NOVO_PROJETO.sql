-- =====================================================
-- SCRIPT: VERIFICAR E CRIAR BASE DE DADOS NO NOVO PROJETO
-- =====================================================
-- Execute este script no SQL Editor do Supabase (novo projeto)
-- URL: https://mhzhxwmxnofltgdmshcq.supabase.co
-- Chave API: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1oemh4d214bm9mbHRnZG1zaGNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2NTgxMDksImV4cCI6MjA3NzIzNDEwOX0.K-6RaZxiRbY-xCgSN7wIAkoi4YuBp7YTW26NseStmPA

-- =====================================================
-- 1. VERIFICAR SE AS TABELAS EXISTEM
-- =====================================================

-- Verificar tabelas existentes
SELECT 
  table_name, 
  table_type 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('testimonials', 'events', 'user_roles');

-- =====================================================
-- 2. CRIAR TABELAS SE NÃO EXISTIREM
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

-- Criar tabela user_roles
CREATE TABLE IF NOT EXISTS public.user_roles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('admin', 'moderator')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id)
);

-- =====================================================
-- 3. HABILITAR ROW LEVEL SECURITY
-- =====================================================

ALTER TABLE public.testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- =====================================================
-- 4. CRIAR POLÍTICAS RLS
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

-- Políticas para user_roles
DROP POLICY IF EXISTS "Users can view their own role" ON public.user_roles;
CREATE POLICY "Users can view their own role"
ON public.user_roles
FOR SELECT
USING (auth.uid() = user_id);

-- =====================================================
-- 5. CRIAR FUNÇÕES E TRIGGERS
-- =====================================================

-- Função para atualizar timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- Triggers
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

DROP TRIGGER IF EXISTS update_user_roles_updated_at ON public.user_roles;
CREATE TRIGGER update_user_roles_updated_at
BEFORE UPDATE ON public.user_roles
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();

-- =====================================================
-- 6. CRIAR FUNÇÕES DE VERIFICAÇÃO DE ROLES
-- =====================================================

CREATE OR REPLACE FUNCTION public.is_admin(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = user_uuid AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

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
-- 7. CRIAR VIEW PÚBLICA PARA EVENTOS
-- =====================================================

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

GRANT SELECT ON public.public_events TO anon, authenticated;

-- =====================================================
-- 8. CRIAR USUÁRIO ADMIN
-- =====================================================

-- Inserir usuário admin
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  recovery_sent_at,
  last_sign_in_at,
  raw_app_meta_data,
  raw_user_meta_data,
  created_at,
  updated_at,
  confirmation_token,
  email_change,
  email_change_token_new,
  recovery_token
) VALUES (
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'virtuousensemble@gmail.com',
  crypt('!P4tr1c14+', gen_salt('bf')),
  now(),
  null,
  null,
  '{"provider": "email", "providers": ["email"]}',
  '{}',
  now(),
  now(),
  '',
  '',
  '',
  ''
);

-- Atribuir role de admin
DO $$
DECLARE
  admin_user_id UUID;
BEGIN
  SELECT id INTO admin_user_id 
  FROM auth.users 
  WHERE email = 'virtuousensemble@gmail.com';
  
  INSERT INTO public.user_roles (user_id, role) 
  VALUES (admin_user_id, 'admin');
  
  RAISE NOTICE 'Usuário admin criado com ID: %', admin_user_id;
END $$;

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
-- 10. VERIFICAÇÃO FINAL
-- =====================================================

-- Verificar se tudo foi criado
SELECT 
  '✅ BASE DE DADOS CRIADA COM SUCESSO!' as status,
  (SELECT COUNT(*) FROM public.testimonials) as testimonials_count,
  (SELECT COUNT(*) FROM public.events) as events_count,
  (SELECT COUNT(*) FROM public.user_roles) as admin_users_count;

-- =====================================================
-- INFORMAÇÕES DE LOGIN
-- =====================================================
-- 
-- 📧 Email: virtuousensemble@gmail.com
-- 🔑 Password: !P4tr1c14+
-- 👤 Role: admin
-- 
-- ✅ Base de dados completa criada
-- ✅ Usuário admin criado
-- ✅ Dados de teste inseridos
-- 
-- =====================================================
