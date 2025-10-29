# Resolver Erro de Envio de Email

## 🔍 **PASSO 1: IDENTIFICAR O ERRO**

Quando enviar o formulário, você verá uma mensagem de erro. Identifique qual é:

### **Erro 1: "Edge function não encontrada" ou "404"**
**Significado:** A edge function não está deployada no Supabase.

**Solução:**
1. Acesse: https://supabase.com/dashboard/project/mhzhxwmxnofltgdmshcq/functions
2. Verifique se `send-contact-email` aparece na lista
3. Se **NÃO aparecer**, faça o deploy:
   - Clique em **"Create a new function"**
   - Nome: `send-contact-email`
   - Cole o conteúdo do arquivo: `supabase/functions/send-contact-email/index.ts`
   - Clique em **Deploy**

---

### **Erro 2: "Invalid API key" ou erro relacionado ao Resend**
**Significado:** A chave da API do Resend não está configurada ou está incorreta.

**Solução:**
1. Obtenha sua chave do Resend: https://resend.com/api-keys
2. No Supabase Dashboard:
   - Vá em: **Project Settings** → **Edge Functions** → **Secrets**
   - Procure por `RESEND_API_KEY`
   - Se não existir, clique em **"Add new secret"**
   - Nome: `RESEND_API_KEY`
   - Valor: sua chave API do Resend
   - Clique em **Save**
3. Aguarde alguns segundos e tente novamente

---

### **Erro 3: "Domain not verified" ou erro de domínio**
**Significado:** O domínio de email não está verificado no Resend.

**Solução Temporária:**
- O código já usa `onboarding@resend.dev` que deve funcionar para testes

**Solução Permanente:**
1. No Resend Dashboard, verifique/adicione seu domínio
2. Configure os registros DNS conforme instruções
3. Atualize o código para usar seu domínio verificado

---

### **Erro 4: Outro erro desconhecido**
**Significado:** Pode haver outro problema.

**Solução:**
1. Abra o console do browser (F12)
2. Copie a mensagem de erro completa
3. Verifique os logs da Edge Function:
   - No Supabase Dashboard: **Edge Functions** → `send-contact-email` → **Logs**
   - Procure pela última execução e veja os erros detalhados

---

## 🧪 **TESTAR DEPOIS DE CORRIGIR**

1. Limpe o cache do navegador (Ctrl + F5)
2. Preencha o formulário novamente
3. Envie o formulário
4. Verifique:
   - ✅ Se vê "✅ Sucesso!" = email foi enviado
   - ❌ Se vê erro = verifique qual erro específico aparece

---

## 📋 **CHECKLIST RÁPIDO**

Execute estes passos na ordem:

1. [ ] Verificar se edge function `send-contact-email` existe no Supabase Dashboard
2. [ ] Se não existir, fazer deploy conforme instruções acima
3. [ ] Verificar se `RESEND_API_KEY` está configurada nos Secrets do Supabase
4. [ ] Se não estiver, adicionar a chave API do Resend
5. [ ] Testar o envio novamente
6. [ ] Verificar console do browser (F12) para mensagens detalhadas
7. [ ] Verificar logs da Edge Function no Supabase para erros detalhados

---

## 🔑 **COMO OBTER A CHAVE DO RESEND**

Se não tiver uma chave do Resend:

1. Acesse: https://resend.com
2. Crie uma conta (se não tiver)
3. Vá em **API Keys**
4. Clique em **Create API Key**
5. Dê um nome (ex: "Virtuous Ensemble")
6. Copie a chave (ela só aparece uma vez!)
7. Cole no Supabase Secrets como `RESEND_API_KEY`

---

## ⚠️ **NOTA IMPORTANTE**

**Os dados do formulário são sempre salvos na base de dados**, mesmo se o email falhar. Você pode:
- Ver os pedidos no painel administrativo: http://localhost:8081/admin
- Contactar diretamente o cliente usando os dados salvos
