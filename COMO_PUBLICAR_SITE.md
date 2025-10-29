# 🌐 Como Publicar o Site Virtuous Ensemble

Existem várias formas de publicar o site gratuitamente usando o GitHub. As melhores opções para projetos Vite + React são:

---

## 🚀 **OPÇÃO 1: Vercel (RECOMENDADO - Mais Fácil)**

### ✅ **Vantagens:**
- **Totalmente gratuito** para projetos pessoais
- **Muito fácil de configurar** (1-2 minutos)
- **Deploy automático** a cada push para GitHub
- **HTTPS automático**
- **Domínio personalizado** gratuito (ex: `virtuous-ensemble.vercel.app`)
- **CDN global** (site rápido em qualquer lugar)

### 📝 **Passos:**

1. **Acesse**: https://vercel.com
2. **Clique em "Sign Up"** e faça login com sua conta GitHub
3. **Clique em "Add New Project"**
4. **Importe o repositório** `R-j-a-freitas/virtuous-harmony-hub`
5. **Configuração automática**:
   - Framework: **Vite** (detectado automaticamente)
   - Build Command: `npm run build` (já configurado)
   - Output Directory: `dist` (já configurado)
6. **Clique em "Deploy"**
7. **Aguarde 1-2 minutos** → Seu site estará online! 🎉

### 🔗 **Após o deploy:**
- Você receberá uma URL como: `https://virtuous-harmony-hub.vercel.app`
- **Cada vez que fizer push no GitHub**, o site será atualizado automaticamente!

---

## 🌍 **OPÇÃO 2: Netlify**

### ✅ **Vantagens:**
- Gratuito
- Fácil de usar
- Deploy automático

### 📝 **Passos:**

1. **Acesse**: https://www.netlify.com
2. **Sign up** com GitHub
3. **Clique em "Add new site" → "Import an existing project"**
4. **Selecione seu repositório**
5. **Configure**:
   - Build command: `npm run build`
   - Publish directory: `dist`
6. **Clique em "Deploy site"**

---

## 📄 **OPÇÃO 3: GitHub Pages**

### ⚠️ **Nota:** Requer configuração adicional para SPAs

### 📝 **Passos Básicos:**

1. **Criar arquivo `vercel.json`** ou `netlify.toml` (não necessário se usar Vercel/Netlify)
2. **Configurar o build** no GitHub Actions (mais complexo)

**Recomendação:** Use Vercel ou Netlify - são mais simples!

---

## 🔧 **Configuração Adicional (Variáveis de Ambiente)**

### **Se você precisar configurar variáveis de ambiente** (ex: Supabase keys):

#### **No Vercel:**
1. Project Settings → Environment Variables
2. Adicione:
   - `VITE_SUPABASE_URL=...`
   - `VITE_SUPABASE_ANON_KEY=...`
3. Clique em "Redeploy"

#### **No Netlify:**
1. Site settings → Environment variables
2. Adicione as mesmas variáveis
3. Trigger deploy manual

---

## ✅ **Verificação Pós-Deploy**

Após fazer o deploy, verifique:

- [ ] Site carrega corretamente
- [ ] Todas as imagens aparecem
- [ ] Formulário de contacto funciona
- [ ] Links do menu funcionam
- [ ] Admin panel funciona (se necessário)

---

## 🎯 **RECOMENDAÇÃO FINAL**

**Use Vercel** - é a opção mais fácil e rápida:
1. Login com GitHub
2. Importar repositório
3. Deploy automático
4. Pronto! 🚀

**Tempo total: ~2 minutos**

---

## 📱 **Domínio Personalizado**

Depois de fazer o deploy, você pode adicionar um domínio personalizado:

### **Vercel:**
- Settings → Domains
- Adicione seu domínio (ex: `virtuousensemble.com`)

### **Netlify:**
- Domain settings → Add custom domain

---

## 🔄 **Deploy Automático**

Ambas as plataformas (Vercel e Netlify) fazem **deploy automático** sempre que você:
- Fizer push para `main`
- Criar uma pull request

**Não precisa fazer nada manual!** 🎉

