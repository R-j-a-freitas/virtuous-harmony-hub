# 🖼️ Sistema de Galeria Local - Guia Completo

## ✅ **Sistema Implementado:**

### **Funcionalidades:**
- ✅ Upload de imagens para pasta local (`public/images/gallery/`)
- ✅ Gestão de visibilidade (mostrar/ocultar imagens)
- ✅ Edição de informações (texto alternativo, legenda)
- ✅ Exclusão de imagens antigas
- ✅ Interface administrativa completa
- ✅ Galeria pública com imagens locais

### **Estrutura Criada:**
```
public/
  images/
    gallery/
      gallery-data.json    # Dados das imagens
      exemplo-1.jpg        # Imagens de exemplo
      exemplo-2.jpg
      exemplo-3.jpg
```

## 🚀 **Como Usar:**

### **1. Iniciar os Servidores:**
```bash
# Opção 1: Script automático (Windows)
start-servers.cmd

# Opção 2: Manual
# Terminal 1 - Servidor da API
C:\nodejs\node-v20.11.0-win-x64\node.exe server.js

# Terminal 2 - Servidor do Frontend  
C:\nodejs\node-v20.11.0-win-x64\node.exe node_modules\vite\bin\vite.js
```

### **2. Acessar o Sistema:**
- **Site Principal:** http://localhost:8080
- **Painel Admin:** http://localhost:8080/admin
- **API Server:** http://localhost:3001

### **3. Gestão da Galeria:**
1. Acesse o painel admin
2. Faça login com: `virtuousensemble@gmail.com` / `!P4tr1c14+`
3. Vá para a aba "Galeria"
4. Use o botão "Nova Imagem" para fazer upload
5. Gerencie visibilidade, edite informações ou delete imagens

## 📁 **Estrutura dos Arquivos:**

### **Dados da Galeria (`gallery-data.json`):**
```json
{
  "images": [
    {
      "id": "1",
      "filename": "exemplo-1.jpg",
      "alt": "Casamento elegante no jardim",
      "caption": "Um casamento elegante realizado em um belo jardim",
      "isVisible": true,
      "sortOrder": 1,
      "uploadDate": "2025-01-28"
    }
  ]
}
```

### **APIs Disponíveis:**
- `POST /api/gallery/upload` - Upload de nova imagem
- `POST /api/gallery/save` - Salvar dados da galeria
- `DELETE /api/gallery/delete/:id` - Deletar imagem

## 🔧 **Vantagens desta Solução:**

### ✅ **Simplicidade:**
- Sem dependências externas complexas
- Arquivos armazenados localmente
- Fácil backup e migração

### ✅ **Performance:**
- Carregamento direto do servidor
- Sem latência de APIs externas
- Cache nativo do navegador

### ✅ **Controle Total:**
- Gestão completa via painel admin
- Upload, edição e exclusão de imagens
- Controle de visibilidade

### ✅ **Manutenção Fácil:**
- Estrutura de pastas simples
- JSON para metadados
- Sem configurações complexas

## 🎯 **Próximos Passos:**

1. **Execute o script:** `start-servers.cmd`
2. **Acesse:** http://localhost:8080/admin
3. **Faça login** e vá para a aba "Galeria"
4. **Teste o upload** de uma imagem
5. **Verifique** se aparece na galeria pública

## 📝 **Notas Importantes:**

- As imagens são salvas em `public/images/gallery/`
- Os metadados são salvos em `gallery-data.json`
- O sistema funciona offline (sem Supabase Storage)
- Backup: copie a pasta `public/images/gallery/`

---

**Sistema pronto para uso! 🎉**
