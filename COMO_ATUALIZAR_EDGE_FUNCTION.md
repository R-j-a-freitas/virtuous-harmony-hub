# Como Atualizar a Edge Function no Supabase

## 🔧 **INSTRUÇÕES PASSO A PASSO**

### **PASSO 1: Acessar a Edge Function**

1. Acesse: https://supabase.com/dashboard/project/mhzhxwmxnofltgdmshcq/functions
2. Procure por `send-contact-email` na lista
3. Clique no nome da função para abrir

---

### **PASSO 2: Substituir o Código**

1. No editor de código que aparece:
   - **Selecione TODO o código atual** (Ctrl + A)
   - **Delete o código atual**

2. **Copie TODO o conteúdo** do arquivo: `CODIGO_COMPLETO_EDGE_FUNCTION.ts`
   - Abra o arquivo no seu editor
   - Selecione tudo (Ctrl + A)
   - Copie (Ctrl + C)

3. **Cole o código completo** no editor do Supabase:
   - Cole no editor (Ctrl + V)
   - O código deve substituir completamente o código antigo

---

### **PASSO 3: Deploy**

1. Clique no botão **"Deploy"** ou **"Save"** (geralmente no canto superior direito)
2. Aguarde alguns segundos enquanto o Supabase faz o deploy
3. Você verá uma mensagem de confirmação quando terminar

---

### **PASSO 4: Verificar**

1. Certifique-se de que o código foi salvo corretamente
2. Verifique se não há erros de sintaxe (o editor mostra em vermelho)
3. Teste o formulário novamente

---

## ✅ **O QUE O CÓDIGO COMPLETO INCLUI:**

- ✅ Validação completa dos dados (usando Zod)
- ✅ Sanitização contra XSS
- ✅ Rate limiting (proteção contra spam)
- ✅ Email HTML formatado e profissional
- ✅ Tratamento de erros completo
- ✅ Logs detalhados para debug
- ✅ Chave API do Resend atualizada
- ✅ Envio para `virtuousensemble@gmail.com`

---

## ⚠️ **IMPORTANTE:**

- **Substitua TODO o código** - não adicione ao código antigo
- **Certifique-se de copiar tudo** do arquivo `CODIGO_COMPLETO_EDGE_FUNCTION.ts`
- **Clique em Deploy** após colar o código
- **Aguarde alguns segundos** após o deploy

---

## 🧪 **TESTAR APÓS ATUALIZAR:**

1. Preencha o formulário de contacto
2. Envie o formulário
3. Verifique:
   - ✅ Se vê "✅ Sucesso!" = email foi enviado
   - 📧 Se recebeu o email em `virtuousensemble@gmail.com`
   - 📊 Verifique os logs da Edge Function para detalhes

---

## 📋 **CHECKLIST:**

- [ ] Código antigo foi completamente removido
- [ ] Código completo foi colado do arquivo `CODIGO_COMPLETO_EDGE_FUNCTION.ts`
- [ ] Não há erros de sintaxe (código em vermelho)
- [ ] Botão "Deploy" foi clicado
- [ ] Mensagem de confirmação apareceu
- [ ] Formulário foi testado
- [ ] Email foi recebido em `virtuousensemble@gmail.com`
