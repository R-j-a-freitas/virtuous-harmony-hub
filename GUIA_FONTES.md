# Guia de Configuração de Fontes

## ✅ **CONFIGURAÇÃO IMPLEMENTADA**

As fontes foram configuradas no sistema:
- **Títulos** (`font-serif`): Usa "Eyesome Script"
- **Texto Normal** (`font-sans`): Usa "CMU Serif"

## 📁 **ADICIONAR ARQUIVOS DE FONTE**

Para que as fontes funcionem completamente, você precisa adicionar os arquivos de fonte na pasta `public/fonts/`:

### **1. Eyesome Script**
Coloque os seguintes arquivos em `public/fonts/`:
- `eyesomescript.woff2` (recomendado - formato moderno)
- `eyesomescript.woff` (fallback)
- `eyesomescript.ttf` (fallback para navegadores antigos)

### **2. CMU Serif**
Coloque os seguintes arquivos em `public/fonts/`:
- `cmuserif.woff2`
- `cmuserif.woff`
- `cmuserif.ttf`
- `cmuserif-bold.woff2` (para texto em negrito)
- `cmuserif-bold.woff`
- `cmuserif-bold.ttf`
- `cmuserif-italic.woff2` (para texto em itálico)
- `cmuserif-italic.woff`
- `cmuserif-italic.ttf`

## 🔍 **ONDE OBTER AS FONTES**

### **Eyesome Script:**
- Verifique se você tem uma licença para esta fonte
- Pode estar disponível em plataformas como Canva ou fontes similares
- Se não tiver acesso, o sistema usará fontes de fallback (Dancing Script, Brush Script MT)

### **CMU Serif:**
- Disponível gratuitamente em: https://www.cufonfonts.com/font/cmu-serif
- Ou pesquise por "CMU Serif download" ou "Computer Modern Serif download"
- Fontes de fallback: Georgia (se CMU Serif não estiver disponível)

## 🎨 **COMO FUNCIONA**

### **Fallbacks Automáticos:**
Se os arquivos de fonte não estiverem disponíveis, o sistema usa:
- **Títulos**: Eyesome Script → Dancing Script → Brush Script MT → cursive
- **Texto**: CMU Serif → Computer Modern Serif → Georgia → serif

### **Formato de Arquivos:**
- `.woff2` é o formato mais moderno e recomendado
- `.woff` é um fallback para navegadores mais antigos
- `.ttf` é um fallback adicional

## ⚡ **APÓS ADICIONAR OS ARQUIVOS**

1. Limpe o cache do navegador (Ctrl + F5)
2. Recarregue a página
3. As fontes devem aparecer automaticamente

## 🔧 **VERIFICAR SE AS FONTES ESTÃO FUNCIONANDO**

1. Abra o DevTools do navegador (F12)
2. Vá para a aba "Network" (Rede)
3. Filtre por "Font"
4. Recarregue a página
5. Verifique se os arquivos de fonte estão sendo carregados

Se os arquivos não estiverem disponíveis, as fontes de fallback serão usadas automaticamente.
