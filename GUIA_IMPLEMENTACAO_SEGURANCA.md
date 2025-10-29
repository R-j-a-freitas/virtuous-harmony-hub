# 🔧 **Guia Passo a Passo - Implementação de Segurança**

## 📋 **PASSO 1: Aplicar Migrações de Segurança**

### **1.1 Acessar o Dashboard do Supabase**
1. Abra seu navegador e vá para: https://supabase.com/dashboard
2. Faça login na sua conta Supabase
3. Selecione seu projeto "virtuous-harmony-hub"

### **1.2 Executar Primeira Migração (Correção de Dados do Cliente)**
1. No dashboard, vá para **SQL Editor** (ícone de código no menu lateral)
2. Clique em **"New query"**
3. Copie e cole o seguinte código SQL:

```sql
-- CRITICAL SECURITY FIX: Remove customer data exposure
-- This migration fixes the critical security issue where customer personal information
-- was publicly accessible through the events table

-- Drop the problematic policy that exposes customer data
DROP POLICY IF EXISTS "Anyone can view confirmed events" ON public.events;

-- Create a public view that only shows non-sensitive event information
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

-- Create a new RLS policy that only allows viewing the public view
-- This ensures customer data (client_name, client_email, client_phone) remains private
CREATE POLICY "Anyone can view public event information"
ON public.events
FOR SELECT
USING (false); -- This effectively blocks all direct access to the events table

-- Grant access to the public view
GRANT SELECT ON public.public_events TO anon, authenticated;

-- Create admin-only policies for managing events
-- These will be properly secured once authentication is implemented
CREATE POLICY "Admins can view all events"
ON public.events
FOR SELECT
USING (false); -- Will be updated when auth is implemented

CREATE POLICY "Admins can update events"
ON public.events
FOR UPDATE
USING (false); -- Will be updated when auth is implemented

CREATE POLICY "Admins can delete events"
ON public.events
FOR DELETE
USING (false); -- Will be updated when auth is implemented
```

4. Clique em **"Run"** para executar
5. ✅ **Verifique se não há erros** na saída

### **1.3 Executar Segunda Migração (Sistema de Autenticação)**
1. Crie uma nova query no SQL Editor
2. Copie e cole o seguinte código SQL:

```sql
-- AUTHENTICATION AND USER ROLES SETUP
-- This migration creates the authentication system and admin access control

-- Create user_roles table for role-based access control
CREATE TABLE public.user_roles (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('admin', 'moderator')),
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  UNIQUE(user_id)
);

-- Enable RLS on user_roles
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own role
CREATE POLICY "Users can view their own role"
ON public.user_roles
FOR SELECT
USING (auth.uid() = user_id);

-- Policy: Only admins can manage roles (will be updated when we have admin users)
CREATE POLICY "Admins can manage roles"
ON public.user_roles
FOR ALL
USING (false); -- Will be updated when auth is implemented

-- Create function to check if user is admin
CREATE OR REPLACE FUNCTION public.is_admin(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = user_uuid AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to check if user is moderator or admin
CREATE OR REPLACE FUNCTION public.is_moderator_or_admin(user_uuid UUID DEFAULT auth.uid())
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_id = user_uuid AND role IN ('admin', 'moderator')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Update events table policies to use authentication
DROP POLICY IF EXISTS "Admins can view all events" ON public.events;
DROP POLICY IF EXISTS "Admins can update events" ON public.events;
DROP POLICY IF EXISTS "Admins can delete events" ON public.events;

-- New secure policies for events
CREATE POLICY "Admins can view all events"
ON public.events
FOR SELECT
USING (public.is_admin());

CREATE POLICY "Admins can update events"
ON public.events
FOR UPDATE
USING (public.is_admin());

CREATE POLICY "Admins can delete events"
ON public.events
FOR DELETE
USING (public.is_admin());

-- Update testimonials policies to use authentication
DROP POLICY IF EXISTS "Anyone can insert testimonials" ON public.testimonials;

-- Only authenticated users can insert testimonials (prevents spam)
CREATE POLICY "Authenticated users can insert testimonials"
ON public.testimonials
FOR INSERT
WITH CHECK (auth.uid() IS NOT NULL);

-- Add policies for admin management of testimonials
CREATE POLICY "Admins can view all testimonials"
ON public.testimonials
FOR SELECT
USING (public.is_admin());

CREATE POLICY "Moderators and admins can approve testimonials"
ON public.testimonials
FOR UPDATE
USING (public.is_moderator_or_admin());

CREATE POLICY "Admins can delete testimonials"
ON public.testimonials
FOR DELETE
USING (public.is_admin());

-- Create trigger for user_roles timestamp updates
CREATE TRIGGER update_user_roles_updated_at
BEFORE UPDATE ON public.user_roles
FOR EACH ROW
EXECUTE FUNCTION public.update_updated_at_column();
```

3. Clique em **"Run"** para executar
4. ✅ **Verifique se não há erros** na saída

---

## 👤 **PASSO 2: Criar Primeiro Usuário Admin**

### **2.1 Habilitar Autenticação**
1. No dashboard do Supabase, vá para **Authentication** (ícone de usuário)
2. Clique em **"Settings"** no menu lateral
3. Certifique-se de que **"Enable email confirmations"** está ativado
4. Salve as configurações

### **2.2 Criar Usuário Admin**
1. Vá para **Authentication** → **Users**
2. Clique em **"Add user"**
3. Preencha:
   - **Email:** seu email admin (ex: admin@virtuousensemble.com)
   - **Password:** uma senha forte
   - **Email Confirm:** ✅ (marcado)
4. Clique em **"Create user"**
5. **Copie o User ID** que aparece na lista (você precisará dele)

### **2.3 Atribuir Role de Admin**
1. Vá para **SQL Editor**
2. Crie uma nova query
3. Substitua `SEU_USER_ID_AQUI` pelo ID do usuário que você copiou:

```sql
-- Adicionar role de admin ao usuário criado
INSERT INTO public.user_roles (user_id, role) 
VALUES ('SEU_USER_ID_AQUI', 'admin');
```

4. Execute a query
5. ✅ **Verifique se foi inserido com sucesso**

---

## 🔑 **PASSO 3: Configurar RESEND_API_KEY**

### **3.1 Obter Chave da API Resend**
1. Vá para: https://resend.com/
2. Crie uma conta ou faça login
3. Vá para **API Keys**
4. Clique em **"Create API Key"**
5. Dê um nome (ex: "Virtuous Ensemble")
6. **Copie a chave** (começa com `re_`)

### **3.2 Configurar no Supabase**
1. No dashboard do Supabase, vá para **Settings** → **API**
2. Role para baixo até **"Environment Variables"**
3. Clique em **"Add new variable"**
4. Preencha:
   - **Name:** `RESEND_API_KEY`
   - **Value:** sua chave da API Resend
5. Clique em **"Save"**

### **3.3 Configurar Domínio (Opcional mas Recomendado)**
1. No Resend, vá para **Domains**
2. Adicione seu domínio (ex: virtuousensemble.com)
3. Configure os registros DNS conforme instruções
4. Atualize o email no edge function para usar seu domínio

---

## 🧪 **PASSO 4: Testar Funcionalidade**

### **4.1 Testar Formulário de Contato**
1. Abra seu site: `http://localhost:8080`
2. Vá para a seção **"Contacte-nos"**
3. Preencha o formulário com dados válidos
4. Clique em **"Enviar Pedido"**
5. ✅ **Verifique se aparece mensagem de sucesso**

### **4.2 Testar Validação de Formulário**
1. Tente enviar o formulário com campos vazios
2. Tente inserir email inválido
3. Tente inserir nome muito longo
4. ✅ **Verifique se aparecem mensagens de erro apropriadas**

### **4.3 Testar Testemunhos**
1. Vá para a seção **"Testemunhos"**
2. Clique em **"Deixar Testemunho"**
3. Preencha o formulário
4. Clique em **"Enviar Testemunho"**
5. ✅ **Verifique se aparece mensagem de sucesso**

### **4.4 Verificar Banco de Dados**
1. No dashboard do Supabase, vá para **Table Editor**
2. Verifique se os dados foram inseridos nas tabelas:
   - `events` (formulário de contacto)
   - `testimonials` (testemunhos)
3. ✅ **Confirme que os dados estão lá**

---

## ✅ **CHECKLIST FINAL**

- [ ] **Migrações aplicadas** sem erros
- [ ] **Usuário admin criado** e com role atribuído
- [ ] **RESEND_API_KEY configurada** no Supabase
- [ ] **Formulário de contacto** funciona e valida
- [ ] **Testemunhos** funcionam e validam
- [ ] **Dados aparecem** no banco de dados
- [ ] **Emails são enviados** (verificar caixa de entrada)

---

## 🚨 **Se Algo Der Errado**

### **Problemas Comuns:**
1. **Erro nas migrações:** Verifique se não há políticas conflitantes
2. **Usuário não consegue fazer login:** Verifique se o email foi confirmado
3. **Emails não são enviados:** Verifique se a RESEND_API_KEY está correta
4. **Formulários não funcionam:** Verifique se o site está rodando

### **Como Resolver:**
1. Verifique os logs no dashboard do Supabase
2. Teste cada componente individualmente
3. Verifique se todas as variáveis de ambiente estão configuradas

---

**🎉 Parabéns! Sua implementação de segurança está completa!**
