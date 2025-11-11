# Copiar Arquivos para public_html

## 🔴 Problema

Os arquivos de `dist/` não estão sendo copiados para `public_html` automaticamente.

## ✅ Solução

Atualizei o `.cpanel.yml` para copiar automaticamente os arquivos de `dist/` para `public_html` durante o deploy.

## 📋 O que foi alterado

O `.cpanel.yml` agora:
1. Verifica se `dist/` existe
2. **Copia todos os arquivos de `dist/` para `public_html`**
3. Reinicia o Passenger

## 🔧 Copiar Manualmente (Se necessário)

Se quiser copiar manualmente no terminal do cPanel:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub

# Limpar public_html
rm -rf /home/virtuou2/public_html/*
rm -rf /home/virtuou2/public_html/.[!.]* 2>/dev/null || true

# Copiar arquivos de dist/ para public_html
cp -R dist/. /home/virtuou2/public_html/

# Verificar
ls -la /home/virtuou2/public_html/
```

## 🚀 Usar Script Automático

Ou use o script `deploy-to-public-html.sh`:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
chmod +x deploy-to-public-html.sh
./deploy-to-public-html.sh
```

## ✅ Verificação

Após copiar, verifique:

```bash
# Verificar se index.html existe
ls -la /home/virtuou2/public_html/index.html

# Verificar se assets/ existe
ls -la /home/virtuou2/public_html/assets/

# Verificar se .htaccess existe
ls -la /home/virtuou2/public_html/.htaccess
```

## 📝 Nota

Com o `.cpanel.yml` atualizado, os arquivos serão copiados automaticamente para `public_html` sempre que você fizer deploy via Git Version Control.

