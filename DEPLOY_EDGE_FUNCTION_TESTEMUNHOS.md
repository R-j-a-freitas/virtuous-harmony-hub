# 🚀 Deploy da Edge Function send-testimonial-email

## ⚠️ **PROBLEMA ATUAL**

O código deployado no Supabase ainda tem a versão antiga que usa a biblioteca Resend, causando erro de boot:
```
worker boot error: Uncaught SyntaxError: The requested module '/js-beautify@^1.14.11?target=es2022' 
does not provide an export named 'html'
```

## ✅ **SOLUÇÃO: SUBSTITUIR CÓDIGO COMPLETO**

### **PASSO 1: Acessar a Função no Supabase**

1. Acesse: https://supabase.com/dashboard/project/mhzhxwmxnofltgdmshcq/functions
2. Clique na função **`send-testimonial-email`**
3. Vá para a aba **"Code"**

### **PASSO 2: Substituir TODO o Código**

1. **Selecione TODO o código** no editor (Ctrl+A ou Cmd+A)
2. **DELETE tudo** (Delete ou Backspace)
3. **Abra o arquivo local:** `supabase/functions/send-testimonial-email/index.ts`
4. **Copie TODO o conteúdo** (Ctrl+A, Ctrl+C)
5. **Cole no editor do Supabase** (Ctrl+V)
6. **Verifique que não há importação de Resend:**
   - ❌ NÃO deve ter: `import { Resend } from 'https://esm.sh/resend@3.0.0'`
   - ✅ Deve ter apenas: `import { serve }`, `import { createClient }`, `import { z }`
   - ✅ Deve usar: `fetch('https://api.resend.com/emails', ...)`

### **PASSO 3: Fazer Deploy**

1. Clique no botão **"Deploy"** (canto superior direito)
2. Aguarde a confirmação: "Function deployed successfully"
3. Vá para a aba **"Logs"**
4. **Aguarde alguns segundos** e verifique:
   - ✅ Deve aparecer: `booted (time: XXms)` sem erros
   - ❌ NÃO deve aparecer: `worker boot error`

### **PASSO 4: Testar**

1. Abra o site no navegador
2. Abra o console (F12)
3. Vá para a secção de **Testemunhos**
4. Envie um novo testemunho
5. Verifique os logs da edge function:
   - Deve aparecer: `📧 send-testimonial-email function called`
   - Deve aparecer: `📧 Body received:`
   - Deve aparecer: `📧 Resend response status: 200`
   - Deve aparecer: `✅ Testimonial email sent successfully`

---

## 🔍 **VERIFICAÇÕES**

### **Verificar se o Código Está Correto**

O código deve:
- ✅ **NÃO ter:** `import { Resend } from 'https://esm.sh/resend@3.0.0'`
- ✅ **Ter:** `fetch('https://api.resend.com/emails', ...)`
- ✅ **Ter:** Logs com `console.log('📧 ...')`
- ✅ **Ter:** Mesma estrutura da função `resend-email` que funciona

### **Verificar RESEND_API_KEY**

1. No Supabase Dashboard: **Project Settings** → **Edge Functions** → **Secrets**
2. Verifique se `RESEND_API_KEY` existe
3. Se não existir, adicione (a mesma chave do formulário de contacto)

---

## ⚠️ **SE AINDA DER ERRO DE BOOT**

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

---

## 📋 **CHECKLIST FINAL**

- [ ] Código completo substituído no Supabase
- [ ] NÃO há importação de `Resend` library
- [ ] Usa `fetch` diretamente para API do Resend
- [ ] Deploy realizado com sucesso
- [ ] Logs não mostram erros de boot
- [ ] `RESEND_API_KEY` está configurada
- [ ] Teste de envio funciona
- [ ] Email é recebido em `virtuousensemble@gmail.com`

---

## 💡 **DIFERENÇA ENTRE AS FUNÇÕES**

- **`resend-email`** (funciona): Usa `fetch` diretamente ✅
- **`send-testimonial-email`** (não funciona): Estava usando biblioteca Resend ❌

Agora ambas devem usar `fetch` diretamente e funcionar igualmente.

