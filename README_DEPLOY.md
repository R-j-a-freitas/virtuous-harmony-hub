# 🚀 Guia de Deploy Manual - Virtuous Ensemble

Como o servidor tem limitações de memória (limites LVE do CloudLinux), o build deve ser feito localmente e os arquivos compilados enviados para o servidor.

## 📋 Pré-requisitos

- Node.js instalado no seu computador
- Acesso ao cPanel (File Manager e Terminal)

## 🔧 Passo 1: Build Local

Execute no seu computador (na raiz do projeto):

```powershell
# Windows PowerShell
.\build-and-deploy.ps1
```

Ou manualmente:

```bash
npm run build
```

Isso criará a pasta `dist/` com todos os arquivos compilados.

## 📦 Passo 2: Preparar para Upload

O script `build-and-deploy.ps1` cria automaticamente:
- ✅ Pasta `dist/` com arquivos compilados
- ✅ Arquivo `dist/404.html` (para SPA)
- ✅ Arquivo `dist/.htaccess` (para React Router)
- ✅ Arquivo ZIP `dist-virtuous-harmony-hub.zip` pronto para upload

## 📤 Passo 3: Upload para o Servidor

### Opção A: Via File Manager do cPanel

1. Acesse o **File Manager** do cPanel
2. Navegue para: `/home/virtuou2/repositories/virtuous-harmony-hub`
3. Faça **upload** do arquivo: `dist-virtuous-harmony-hub.zip`
4. Clique com botão direito no ZIP → **Extract**
5. Certifique-se de que a pasta `dist/` foi extraída

### Opção B: Via Terminal (SCP - se tiver acesso SSH)

```bash
scp dist-virtuous-harmony-hub.zip virtuou2@seu-servidor:/home/virtuou2/repositories/virtuous-harmony-hub/
```

## 🚀 Passo 4: Deploy no Servidor

### Via Terminal do cPanel:

1. Acesse o **Terminal** do cPanel
2. Execute:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub

# Se ainda não extraiu o ZIP, extraia primeiro:
unzip -o dist-virtuous-harmony-hub.zip

# Executar o script de deploy
chmod +x deploy-to-public-html.sh
./deploy-to-public-html.sh
```

### Ou manualmente:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub

# Limpar public_html
rm -rf /home/virtuou2/public_html/*

# Copiar arquivos
cp -R dist/. /home/virtuou2/public_html/

# Verificar
ls -la /home/virtuou2/public_html/
```

## ✅ Verificação

Após o deploy, verifique:

- [ ] Site carrega: https://virtuousensemble.pt
- [ ] Arquivos JS estão presentes: `ls /home/virtuou2/public_html/*.js`
- [ ] Arquivos CSS estão presentes: `ls /home/virtuou2/public_html/*.css`
- [ ] Arquivo `.htaccess` existe: `ls -la /home/virtuou2/public_html/.htaccess`

## 🔄 Atualizações Futuras

Sempre que fizer alterações no código:

1. Execute `.\build-and-deploy.ps1` localmente
2. Faça upload do novo `dist-virtuous-harmony-hub.zip`
3. Extraia no servidor
4. Execute `./deploy-to-public-html.sh` ou copie manualmente

## ⚠️ Nota Importante

O build não pode ser feito no servidor devido aos limites LVE do CloudLinux (4GB de memória). Esta é a solução recomendada até que o suporte aumente os limites.



