# Comandos para Copiar Manualmente para public_html

## 📋 Comandos Completos (Copiar e Colar)

### Passo 1: Navegar para o Projeto

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
```

### Passo 2: Verificar se dist/ existe

```bash
ls -la dist/index.html
```

Deve mostrar o arquivo. Se não existir, faça upload do ZIP primeiro.

### Passo 3: Limpar public_html

```bash
rm -rf /home/virtuou2/public_html/*
rm -rf /home/virtuou2/public_html/.[!.]* 2>/dev/null || true
```

### Passo 4: Copiar arquivos de dist/ para public_html

```bash
cp -R dist/. /home/virtuou2/public_html/
```

### Passo 5: Verificar se foi copiado

```bash
ls -la /home/virtuou2/public_html/
```

Deve mostrar arquivos como `index.html`, `assets/`, `.htaccess`, etc.

---

## 🔄 Script Completo (Uma Linha)

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub && rm -rf /home/virtuou2/public_html/* /home/virtuou2/public_html/.[!.]* 2>/dev/null || true && cp -R dist/. /home/virtuou2/public_html/ && ls -la /home/virtuou2/public_html/ | head -10
```

---

## ✅ Verificações Finais

### Verificar arquivos específicos:

```bash
# Verificar index.html
ls -la /home/virtuou2/public_html/index.html

# Verificar pasta assets
ls -la /home/virtuou2/public_html/assets/

# Verificar .htaccess
ls -la /home/virtuou2/public_html/.htaccess

# Verificar 404.html
ls -la /home/virtuou2/public_html/404.html
```

### Contar arquivos:

```bash
# Total de arquivos
find /home/virtuou2/public_html -type f | wc -l

# Arquivos JavaScript
find /home/virtuou2/public_html -name "*.js" | wc -l

# Arquivos CSS
find /home/virtuou2/public_html -name "*.css" | wc -l
```

---

## 🚀 Após Copiar

### Reiniciar Passenger (se estiver usando Node.js):

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
mkdir -p tmp
touch tmp/restart.txt
```

### Verificar site:

```bash
# Health check (se tiver server.js)
curl https://virtuousensemble.pt/__health

# Verificar se o site carrega
curl -I https://virtuousensemble.pt/
```

---

## 📝 Comandos Rápidos de Referência

```bash
# 1. Navegar
cd /home/virtuou2/repositories/virtuous-harmony-hub

# 2. Limpar public_html
rm -rf /home/virtuou2/public_html/* /home/virtuou2/public_html/.[!.]* 2>/dev/null || true

# 3. Copiar
cp -R dist/. /home/virtuou2/public_html/

# 4. Verificar
ls -la /home/virtuou2/public_html/

# 5. Reiniciar Passenger (opcional)
touch tmp/restart.txt
```

---

## 🐛 Se der Erro

### Erro: "Permission denied"

```bash
# Verificar permissões
ls -ld /home/virtuou2/public_html

# Se necessário, ajustar permissões
chmod 755 /home/virtuou2/public_html
```

### Erro: "No such file or directory"

```bash
# Verificar se dist/ existe
ls -la dist/

# Se não existir, fazer upload do ZIP primeiro
```

---

## ✅ Checklist

- [ ] `dist/` existe e tem arquivos
- [ ] `public_html` foi limpo
- [ ] Arquivos copiados com sucesso
- [ ] `index.html` existe em `public_html`
- [ ] `assets/` existe em `public_html`
- [ ] `.htaccess` existe em `public_html`
- [ ] Site carrega no navegador


