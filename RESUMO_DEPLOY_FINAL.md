# Resumo Final: Deploy no cPanel

## ✅ Status Atual

- ✅ Node.js 18 instalado (ambiente virtual ativo)
- ✅ `dist/` existe no servidor
- ✅ `server.js` existe
- ❌ `.cpanel.yml` desatualizado (ainda tenta fazer build)

## 🔧 Solução: Atualizar .cpanel.yml

### No Terminal do cPanel:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub

# 1. Sincronizar com GitHub
git fetch origin
git reset --hard origin/main

# 2. Verificar se .cpanel.yml foi atualizado
cat .cpanel.yml | grep -i build
# NÃO deve mostrar "npm run build"

# 3. Verificar se dist/ existe
ls -la dist/index.html
# Deve mostrar o arquivo
```

### No cPanel (Interface Web):

1. **Git Version Control** → **Manage**
2. Clique em **"Update from Remote"**
3. Verifique se o botão **"Deploy HEAD Commit"** está ativo
4. Se estiver inativo, execute no terminal:
   ```bash
   git status
   # Se mostrar mudanças, execute:
   git reset --hard origin/main
   git clean -fd
   ```
5. Clique em **"Deploy HEAD Commit"**

---

## 📋 Checklist Completo

### Antes do Deploy:

- [ ] `.cpanel.yml` atualizado (sem `npm run build`)
- [ ] `dist/` existe no servidor
- [ ] `server.js` existe
- [ ] `git status` mostra "working tree clean"
- [ ] Botão "Deploy HEAD Commit" está ativo

### Após o Deploy:

- [ ] Deploy executado sem erros
- [ ] Health check funciona: `curl https://virtuousensemble.pt/__health`
- [ ] Site carrega: `curl -I https://virtuousensemble.pt/`

---

## 🔍 Verificações Finais

### Verificar se o deploy funcionou:

```bash
# 1. Verificar se dist/ ainda existe
ls -la dist/index.html

# 2. Verificar se server.js existe
ls -la server.js

# 3. Verificar se express está instalado
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate
npm list express

# 4. Health check
curl https://virtuousensemble.pt/__health
# Deve retornar: ok

# 5. Verificar logs do Passenger (se houver erros)
tail -50 /home/virtuou2/logs/passenger.log
```

---

## 🐛 Troubleshooting

### Se o deploy falhar:

1. **Verificar logs do deploy:**
   ```bash
   cat /home/virtuou2/public_html/deploy_log.txt
   ```

2. **Verificar se dist/ existe:**
   ```bash
   ls -la dist/
   ```
   Se não existir, faça upload via File Manager.

3. **Verificar se express está instalado:**
   ```bash
   source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate
   npm ci --production
   ```

4. **Reiniciar Passenger manualmente:**
   ```bash
   touch tmp/restart.txt
   ```
   Ou no cPanel: **Setup Node.js App** → **RESTART**

---

## 📝 Comandos Rápidos (Copiar e Colar)

```bash
# Sincronizar com GitHub
cd /home/virtuou2/repositories/virtuous-harmony-hub
git fetch origin
git reset --hard origin/main
git clean -fd

# Verificar status
git status
cat .cpanel.yml | grep -i build
ls -la dist/index.html

# Instalar dependências de produção
source /home/virtuou2/nodevenv/repositories/virtuous-harmony-hub/18/bin/activate
npm ci --production

# Reiniciar Passenger
touch tmp/restart.txt

# Health check
curl https://virtuousensemble.pt/__health
```

---

## ✅ O que o .cpanel.yml atualizado faz:

1. ✅ Instala apenas dependências de produção (`npm ci --production`)
2. ✅ Verifica se `dist/` existe (não tenta fazer build)
3. ✅ Reinicia o Passenger (`touch tmp/restart.txt`)

**NÃO** tenta fazer build (isso é feito localmente no Windows).

---

## 🎯 Próximos Passos

1. Execute os comandos acima para sincronizar
2. Faça deploy via cPanel
3. Verifique se o site funciona
4. Se houver problemas, consulte os logs


