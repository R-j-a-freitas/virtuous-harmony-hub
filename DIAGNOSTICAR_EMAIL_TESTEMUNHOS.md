# 🔍 Diagnosticar Problema: Email de Testemunhos Não Enviado

## ✅ **TESTEMUNHO FOI CRIADO COM SUCESSO**

O testemunho foi salvo na base de dados, mas o email não foi enviado. Vamos diagnosticar o problema.

---

## 🔍 **PASSO 1: VERIFICAR CONSOLE DO NAVEGADOR**

1. Abra o site no navegador
2. Pressione **F12** para abrir DevTools
3. Vá para a aba **Console**
4. Procure por mensagens relacionadas ao email:
   - ✅ `📧 Attempting to send testimonial email via edge function...`
   - ✅ `📧 Function response received:`
   - ❌ Qualquer erro em vermelho

**O que procurar:**
- Se aparecer `❌ Edge function 'send-testimonial-email' não encontrada` → A função não está deployada
- Se aparecer `❌ Failed to send a request` → Problema de conexão
- Se aparecer `❌ CORS error` → Problema de headers CORS

---

## 🔍 **PASSO 2: VERIFICAR SE A EDGE FUNCTION ESTÁ DEPLOYADA**

1. Acesse: https://supabase.com/dashboard/project/mhzhxwmxnofltgdmshcq/functions
2. Procure por `send-testimonial-email` na lista de funções
3. **Se NÃO existir**, precisa fazer deploy:

### **Fazer Deploy da Edge Function:**

1. No Dashboard, clique em **"Create a new function"**
2. Nome: `send-testimonial-email`
3. Cole o conteúdo completo do arquivo: `supabase/functions/send-testimonial-email/index.ts`
4. Clique em **"Deploy"**
5. Aguarde confirmação

---

## 🔍 **PASSO 3: VERIFICAR LOGS DA EDGE FUNCTION**

1. No Supabase Dashboard, vá para **Edge Functions**
2. Clique em `send-testimonial-email`
3. Vá para a aba **Logs**
4. Procure pelos logs mais recentes

**O que procurar:**
- ✅ `Attempting to send testimonial email to virtuousensemble@gmail.com`
- ✅ `Using API key: SET` (se aparecer `NOT SET`, a chave não está configurada)
- ✅ `✅ Testimonial email sent successfully`
- ❌ `❌ Email sending failed` → Problema com Resend API
- ❌ `❌ RESEND_API_KEY not configured` → Chave não configurada

---

## 🔍 **PASSO 4: VERIFICAR RESEND_API_KEY**

A edge function precisa da chave da API do Resend para enviar emails.

1. No Supabase Dashboard, vá para **Project Settings** → **Edge Functions** → **Secrets**
2. Procure por `RESEND_API_KEY`
3. **Se NÃO existir:**
   - Clique em **"Add new secret"**
   - Nome: `RESEND_API_KEY`
   - Valor: sua chave API do Resend (obtenha em: https://resend.com/api-keys)
   - Clique em **Save**

**Nota:** A mesma chave `RESEND_API_KEY` é usada para o formulário de contacto e testemunhos.

---

## 🔍 **PASSO 5: VERIFICAR CORS NA EDGE FUNCTION**

A edge function precisa retornar headers CORS corretos. Verifique se o código tem:

```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};
```

E retornar esses headers em todas as respostas.

---

## 🧪 **TESTE RÁPIDO**

1. Abra o console do navegador (F12)
2. Vá para a secção de Testemunhos
3. Envie um novo testemunho
4. Observe o console:
   - Deve aparecer: `📧 Attempting to send testimonial email via edge function...`
   - Deve aparecer: `📧 Function response received:`
   - Se aparecer erro, copie a mensagem completa

---

## ⚠️ **PROBLEMAS COMUNS E SOLUÇÕES**

### **Problema 1: "Function not found" ou "404"**
**Causa:** Edge function não está deployada  
**Solução:** Faça deploy da função `send-testimonial-email` no Supabase

### **Problema 2: "RESEND_API_KEY not configured"**
**Causa:** Chave da API não está configurada  
**Solução:** Configure `RESEND_API_KEY` em Project Settings → Edge Functions → Secrets

### **Problema 3: "Email sending failed"**
**Causa:** Problema com a API do Resend  
**Solução:** 
- Verifique se a chave API está correta
- Verifique se o domínio está verificado no Resend
- O código usa `onboarding@resend.dev` que deve funcionar para testes

### **Problema 4: "CORS error"**
**Causa:** Headers CORS não estão configurados  
**Solução:** Verifique se a edge function retorna headers CORS corretos

### **Problema 5: Nenhum erro, mas email não chega**
**Causa:** Email pode estar na pasta de spam ou problema com Resend  
**Solução:**
- Verifique a pasta de spam
- Verifique os logs da edge function para ver se o email foi realmente enviado
- Verifique o dashboard do Resend para ver se há emails enviados

---

## 📋 **CHECKLIST DE VERIFICAÇÃO**

- [ ] Edge function `send-testimonial-email` está deployada
- [ ] `RESEND_API_KEY` está configurada no Supabase
- [ ] Console do navegador mostra tentativa de envio
- [ ] Logs da edge function mostram execução
- [ ] Não há erros no console ou logs
- [ ] Email não está na pasta de spam

---

## 🆘 **SE AINDA NÃO FUNCIONAR**

1. **Copie todos os logs do console** (F12 → Console)
2. **Copie os logs da edge function** (Supabase → Functions → Logs)
3. **Verifique se o formulário de contacto funciona** (para confirmar que Resend está funcionando)
4. **Teste novamente** e observe todos os logs

---

## 💡 **NOTA IMPORTANTE**

O testemunho **será salvo na base de dados** mesmo se o email falhar. O email é apenas uma notificação para o admin. Se o email não funcionar, você ainda pode ver os testemunhos pendentes no painel de administração.

