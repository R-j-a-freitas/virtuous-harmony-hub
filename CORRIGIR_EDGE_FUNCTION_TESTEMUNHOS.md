# 🔧 Corrigir Erro: Edge Function send-testimonial-email

## ❌ **ERRO IDENTIFICADO**

```
worker boot error: Uncaught SyntaxError: The requested module '/js-beautify@^1.14.11?target=es2022' 
does not provide an export named 'html' at https://esm.sh/@react-email/render@0.0.11/es2022/render.mjs:3:132
```

**Causa:** O código deployado no Supabase pode ter uma versão antiga ou problema com dependências.

---

## ✅ **SOLUÇÃO**

### **PASSO 1: Substituir Código Completo no Supabase**

1. Acesse: https://supabase.com/dashboard/project/mhzhxwmxnofltgdmshcq/functions
2. Clique na função **`send-testimonial-email`**
3. **DELETE TODO O CÓDIGO ATUAL** (selecione tudo e delete)
4. **Copie TODO o conteúdo** do arquivo: `supabase/functions/send-testimonial-email/index.ts`
5. **Cole no editor do Supabase** (substitua completamente)
6. **Clique em "Deploy"** (botão no topo direito)
7. Aguarde confirmação de sucesso

---

### **PASSO 2: Verificar se Funcionou**

1. Após fazer deploy, vá para a aba **"Logs"** da função
2. Procure por novos logs (devem aparecer sem erros de boot)
3. Se aparecer erro, copie a mensagem completa

---

### **PASSO 3: Testar**

1. Abra o site no navegador
2. Abra o console (F12)
3. Vá para a secção de Testemunhos
4. Envie um novo testemunho
5. Observe:
   - Console do navegador: deve aparecer `📧 Attempting to send testimonial email...`
   - Logs da edge function: deve aparecer `Attempting to send testimonial email to virtuousensemble@gmail.com`

---

## 🔍 **VERIFICAÇÕES**

### **Verificar se o Código Está Correto**

O código deve ter:
- ✅ Importações corretas (sem react-email ou js-beautify)
- ✅ Apenas: `serve`, `createClient`, `z`, `Resend`
- ✅ Estrutura idêntica à função `send-contact-email` que funciona

### **Verificar RESEND_API_KEY**

1. No Supabase Dashboard: **Project Settings** → **Edge Functions** → **Secrets**
2. Verifique se `RESEND_API_KEY` existe
3. Se não existir, adicione (a mesma chave do formulário de contacto)

---

## ⚠️ **SE AINDA DER ERRO**

1. **Delete a função completamente:**
   - No Dashboard, vá para Edge Functions
   - Clique nos três pontos ao lado de `send-testimonial-email`
   - Selecione "Delete"
   - Confirme

2. **Crie uma nova função:**
   - Clique em "Create a new function"
   - Nome: `send-testimonial-email`
   - Cole o código completo de `supabase/functions/send-testimonial-email/index.ts`
   - Clique em "Deploy"

3. **Verifique os logs novamente**

---

## 📋 **CHECKLIST**

- [ ] Código completo substituído no Supabase
- [ ] Deploy realizado com sucesso
- [ ] Logs não mostram erros de boot
- [ ] `RESEND_API_KEY` está configurada
- [ ] Teste de envio funciona

---

## 💡 **NOTA**

O código foi simplificado e baseado exatamente na função `send-contact-email` que já funciona. Não usa nenhuma dependência problemática como `react-email` ou `js-beautify`.

