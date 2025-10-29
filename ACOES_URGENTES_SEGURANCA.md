# 🚨 AÇÕES URGENTES DE SEGURANÇA - EXECUTAR AGORA

## ⏰ **PRIORIDADE MÁXIMA** (Executar nos próximos 30 minutos)

### **1. 🔴 ROTACIONAR API KEY DO RESEND** (5 minutos)

**O QUE FAZER:**
1. Acesse: https://resend.com/api-keys
2. **DELETE** a chave: `re_faU39bCe_LTtaa6azqp4PYmEj6Ezgprom`
3. **CRIE** uma nova chave
4. **COPIE** a nova chave

**CONFIGURAR NO SUPABASE:**
1. Acesse: https://supabase.com/dashboard/project/mhzhxwmxnofltgdmshcq/settings/edge-functions
2. Vá em **"Secrets"** ou **"Environment Variables"**
3. Adicione/Atualize:
   - **Nome:** `RESEND_API_KEY`
   - **Valor:** [NOVA_CHAVE_COPIADA]
4. Salve

**VERIFICAR:**
- Verifique logs do Resend para atividade suspeita enquanto a chave estava exposta

---

### **2. 🔴 EXECUTAR SCRIPTS SQL DE SEGURANÇA** (10 minutos)

**PASSO 1: Limpar Políticas Antigas (se necessário)**
1. Abra: https://supabase.com/dashboard/project/mhzhxwmxnofltgdmshcq/editor
2. Nova query SQL
3. Abra o arquivo: `CORRIGIR_POLITICAS_EVENTS.sql`
4. Copie TODO o conteúdo e cole no SQL Editor
5. Execute (F5)

**PASSO 2: Executar Sistema de Segurança**
1. No mesmo SQL Editor
2. Abra o arquivo: `CRIAR_SISTEMA_SEGURANCA_COMPLETO.sql`
3. **COPIE TODO o conteúdo** (começa com `-- =====` não com `#`)
4. Cole no SQL Editor
5. Execute (F5)
6. ✅ Verifique se apareceu: "✅ Sistema de segurança configurado!"

**O QUE ESTE SCRIPT FAZ:**
- ✅ Cria view `public_events` (sem dados sensíveis)
- ✅ Cria tabela `user_roles`
- ✅ Cria função `is_admin()`
- ✅ Aplica políticas RLS seguras
- ✅ Protege dados pessoais dos clientes

---

### **3. 🔴 CRIAR USUÁRIO ADMIN** (5 minutos)

**PASSO 1: Criar Usuário no Supabase Auth**
1. Acesse: https://supabase.com/dashboard/project/mhzhxwmxnofltgdmshcq/auth/users
2. Clique em **"Add user"** → **"Create new user"**
3. Preencha:
   - **Email:** `virtuousensemble@gmail.com`
   - **Password:** [Escolha uma senha FORTE - diferente da antiga!]
   - ✅ **Auto Confirm User:** (marque esta opção)
4. Clique em **"Create user"**
5. **COPIE O UUID** do usuário criado (necessário para o próximo passo)

**PASSO 2: Adicionar Role de Admin**
1. No SQL Editor do Supabase
2. Execute:
```sql
SELECT public.create_admin_by_email('virtuousensemble@gmail.com');
```

**OU** se a função não funcionar, execute manualmente:
```sql
-- Substitua 'USER_UUID_AQUI' pelo UUID copiado no passo anterior
INSERT INTO public.user_roles (user_id, role)
VALUES ('USER_UUID_AQUI', 'admin')
ON CONFLICT (user_id) DO UPDATE SET role = 'admin';
```

**PASSO 3: Verificar**
```sql
SELECT u.email, ur.role, ur.created_at
FROM auth.users u
JOIN public.user_roles ur ON u.id = ur.user_id
WHERE ur.role = 'admin';
```

Deve aparecer o email `virtuousensemble@gmail.com` com role `admin`.

---

### **4. 🟡 TESTAR** (5 minutos)

1. **Teste Login Admin:**
   - Acesse: `/admin`
   - Faça login com: `virtuousensemble@gmail.com` + [nova senha]
   - ✅ Deve funcionar!

2. **Verifique Proteção de Dados:**
   - Acesse a página pública de eventos
   - Verifique que NÃO aparecem:
     - ❌ Nomes dos clientes
     - ❌ Emails dos clientes
     - ❌ Telefones dos clientes
   - ✅ Só devem aparecer: título, data, hora, local

3. **Teste Formulário de Contacto:**
   - Envie um teste
   - ✅ Deve funcionar com a nova API key

---

## ✅ **CHECKLIST FINAL**

Execute na ordem:

- [ ] Rotacionar API key do Resend
- [ ] Configurar nova key no Supabase Edge Functions
- [ ] Executar `CORRIGIR_POLITICAS_EVENTS.sql`
- [ ] Executar `CRIAR_SISTEMA_SEGURANCA_COMPLETO.sql`
- [ ] Criar usuário admin no Supabase Auth
- [ ] Adicionar role admin ao usuário
- [ ] Verificar usuário admin criado
- [ ] Testar login em `/admin`
- [ ] Verificar dados sensíveis protegidos no site público

---

## 🔒 **O QUE FOI CORRIGIDO NO CÓDIGO**

✅ **API Key:** Removido hardcoded, agora requer env var
✅ **Error Handling:** Mensagens genéricas (sem detalhes internos)
✅ **TypeScript:** Adicionada tabela `user_roles` aos tipos
✅ **Admin Panel:** Corrigido erro de tipos

---

## 🆘 **SE TIVER PROBLEMAS**

### **Erro: "RESEND_API_KEY not configured"**
→ Configure a variável de ambiente no Supabase Edge Functions Settings

### **Erro: "user_roles table does not exist"**
→ Execute `CRIAR_SISTEMA_SEGURANCA_COMPLETO.sql` novamente

### **Login não funciona: "Invalid credentials"**
→ Verifique se:
1. Criou o usuário no Supabase Auth
2. "Auto Confirm User" estava marcado
3. A senha está correta

### **Login funciona mas diz "Acesso negado"**
→ Execute o Passo 3.2 novamente para adicionar a role de admin

---

## 📊 **STATUS APÓS CORREÇÕES**

Antes: 🔴 **NÃO SEGURO**
- Dados pessoais expostos
- API key comprometida
- Admin panel não funcional

Depois: 🟢 **SEGURO PARA PRODUÇÃO**
- Dados protegidos
- Credenciais seguras
- Admin funcional

**Execute todas as ações e teste!**

