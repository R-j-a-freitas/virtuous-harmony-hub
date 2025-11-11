# Instruções: Após npm install no Servidor

## ❌ Problema Atual

O comando `npm run build` falha porque:
1. `vite` não está no PATH (mesmo após `npm install`)
2. Mesmo usando `npx vite build`, vai falhar por falta de memória WebAssembly

## ✅ Solução: Build Local + Upload

### Passo 1: Verificar se o server.js está configurado

No terminal do cPanel, verifique:

```bash
ls -la server.js
```

Se não existir, você precisa fazer pull do GitHub primeiro:

```bash
git fetch origin
git reset --hard origin/main
```

### Passo 2: Instalar apenas dependências de produção

Como não vamos fazer build no servidor, instale apenas o que o `server.js` precisa:

```bash
npm ci --production
```

Isso instala apenas `express` e outras dependências de produção (não instala `vite` e outras devDependencies).

### Passo 3: Fazer Build Localmente (no seu Windows)

**No seu computador Windows**, execute:

```powershell
.\build-and-deploy.ps1
```

Isso vai criar:
- Pasta `dist/` com os arquivos compilados
- Arquivo `dist-virtuous-harmony-hub.zip` para upload

### Passo 4: Fazer Upload da Pasta dist/

**No cPanel - File Manager:**

1. Vá para **File Manager**
2. Navegue até: `/home/virtuou2/repositories/virtuous-harmony-hub`
3. **Delete a pasta `dist/` existente** (se houver)
4. Faça upload do arquivo `dist-virtuous-harmony-hub.zip`
5. Clique com botão direito no ZIP → **Extract**
6. Verifique se a pasta `dist/` foi criada com arquivos dentro
7. Delete o ZIP após extrair

### Passo 5: Verificar se dist/ foi criada

**No terminal do cPanel:**

```bash
ls -la dist/
```

Deve mostrar arquivos como `index.html`, `assets/`, etc.

### Passo 6: Reiniciar o Passenger

**No terminal do cPanel:**

```bash
mkdir -p tmp
touch tmp/restart.txt
```

Ou no cPanel:
- **Setup Node.js App** → Clique em **RESTART**

### Passo 7: Verificar se Funcionou

```bash
# Health check
curl https://virtuousensemble.pt/__health

# Deve retornar: ok
```

---

## 🔄 Comandos Rápidos (Copiar e Colar)

```bash
# 1. Instalar dependências de produção
npm ci --production

# 2. Verificar se server.js existe
ls -la server.js

# 3. Verificar se dist/ existe (após upload)
ls -la dist/

# 4. Reiniciar Passenger
mkdir -p tmp && touch tmp/restart.txt

# 5. Health check
curl https://virtuousensemble.pt/__health
```

---

## 📝 Notas Importantes

- ✅ **NÃO** tente fazer `npm run build` no servidor (falha por memória)
- ✅ **NÃO** precisa instalar `vite` no servidor (só precisa do `express` para o `server.js`)
- ✅ O build é feito **localmente** no Windows
- ✅ Apenas a pasta `dist/` compilada é enviada ao servidor
- ✅ O `server.js` serve os arquivos estáticos de `dist/`

---

## 🐛 Se dist/ não existir

Se você ainda não fez upload da `dist/`, o site não vai funcionar. 

**Solução:**
1. Faça build localmente: `.\build-and-deploy.ps1` (Windows)
2. Faça upload do `dist-virtuous-harmony-hub.zip` via File Manager
3. Extract o ZIP
4. Reinicie o Passenger: `touch tmp/restart.txt`

---

## ✅ Checklist Final

- [ ] `server.js` existe no servidor
- [ ] `npm ci --production` executado com sucesso
- [ ] Build feito localmente no Windows
- [ ] `dist-virtuous-harmony-hub.zip` feito upload via File Manager
- [ ] ZIP extraído e pasta `dist/` criada
- [ ] Passenger reiniciado (`touch tmp/restart.txt`)
- [ ] Health check retorna `ok`

