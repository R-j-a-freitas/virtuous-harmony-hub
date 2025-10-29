# 🖼️ Guia Rápido: Políticas de Storage para Galeria

## 🎯 **Problema Resolvido**
O erro `ERROR: 42501: must be owner of table objects` acontece porque não temos permissões para criar políticas na tabela `storage.objects` via SQL.

## ✅ **Solução: Criar Políticas Manualmente**

### 📋 **Passo 1: Executar Script SQL**
1. Executar `CRIAR_GALERIA_ESSENCIAL.sql` no Supabase Dashboard
2. Este script cria a tabela e políticas básicas sem problemas

### 📋 **Passo 2: Criar Políticas de Storage Manualmente**

#### 🔗 **Aceder ao Supabase Dashboard**
- URL: `https://mhzhxwmxnofltgdmshcq.supabase.co`
- Ir para **Authentication** → **Policies**

#### 🎯 **Selecionar Tabela de Storage**
- Clicar em **"storage.objects"**
- Clicar em **"New Policy"**

#### 📝 **Criar 4 Políticas:**

---

### **Política 1: Visualizar Imagens**
- **Name:** `Anyone can view gallery images`
- **Operation:** `SELECT`
- **Target roles:** `anon`, `authenticated`
- **USING expression:**
```sql
bucket_id = 'gallery-images'
```

---

### **Política 2: Upload de Imagens**
- **Name:** `Admins can upload gallery images`
- **Operation:** `INSERT`
- **Target roles:** `authenticated`
- **WITH CHECK expression:**
```sql
bucket_id = 'gallery-images' AND public.is_admin()
```

---

### **Política 3: Atualizar Imagens**
- **Name:** `Admins can update gallery images`
- **Operation:** `UPDATE`
- **Target roles:** `authenticated`
- **USING expression:**
```sql
bucket_id = 'gallery-images' AND public.is_admin()
```

---

### **Política 4: Deletar Imagens**
- **Name:** `Admins can delete gallery images`
- **Operation:** `DELETE`
- **Target roles:** `authenticated`
- **USING expression:**
```sql
bucket_id = 'gallery-images' AND public.is_admin()
```

---

## 🎉 **Após Configurar:**

### ✅ **Sistema Totalmente Funcional**
- **Site:** `http://localhost:8080` → Galeria funcionará
- **Admin:** `http://localhost:8080/admin` → Tab "Galeria" funcionará
- **Upload:** Poderá carregar imagens através do painel administrativo

### 🔧 **Funcionalidades Disponíveis**
- ✅ **Carregar imagens** através do painel administrativo
- ✅ **Controlar visibilidade** - escolher quais imagens aparecem no site
- ✅ **Editar metadados** - texto alternativo, legendas, ordem
- ✅ **Deletar imagens** permanentemente
- ✅ **Gestão completa** através de interface administrativa

## 🚀 **Teste Final**
1. Executar `CRIAR_GALERIA_ESSENCIAL.sql`
2. Criar as 4 políticas de storage manualmente
3. Testar upload de imagem no painel admin
4. Verificar se aparece na galeria do site

**Sistema de galeria totalmente funcional!** 🎉
