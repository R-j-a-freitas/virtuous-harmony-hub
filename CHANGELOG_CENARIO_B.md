# 📝 Alterações Implementadas - Cenário B (Node.js + Passenger)

## ✅ Arquivos Criados

### 1. `server.js` (NOVO)
- Servidor Express em ESM (compatível com `"type": "module"`)
- Serve arquivos estáticos de `dist/`
- Health-check em `/__health` (retorna `200 ok`)
- SPA fallback: todas as rotas vão para `index.html`
- Cache configurado (1h para assets, no-cache para index.html)

### 2. `.cpanel.yml` (ATUALIZADO)
- Simplificado para Cenário B
- Ativa ambiente virtual Node.js 18
- Executa `npm ci --include=dev`
- Executa `npm run build`
- Reinicia Passenger via `touch tmp/restart.txt`

### 3. `.github/workflows/deploy.yml` (NOVO - Opcional)
- Workflow básico para documentar que o deploy é feito pelo cPanel

### 4. `DEPLOY_CENARIO_B.md` (NOVO)
- Guia completo de deploy
- Instruções passo a passo
- Troubleshooting

## ✅ Arquivos Modificados

### 1. `package.json`
- ✅ Adicionado script `"start": "node server.js"`
- ✅ Adicionado `"engines": { "node": ">=18" }`
- ✅ Script `build` simplificado (removido `npx`)
- ✅ Express já estava em `dependencies` ✓

### 2. `vite.config.ts`
- ✅ Adicionado `base: '/'`
- ✅ Adicionado `build.outDir: 'dist'`
- ✅ Adicionado `build.sourcemap: false`

### 3. `.gitignore`
- ✅ Já tinha `dist/` (não commitado) ✓

## 🔍 Verificações de Compatibilidade

- ✅ **ESM vs CommonJS:** Projeto usa `"type": "module"`, então `server.js` está em ESM com `import`/`export`
- ✅ **Express em dependencies:** Já estava correto ✓
- ✅ **Health-check:** Rota `/__health` não conflita (é a primeira rota específica)
- ✅ **SPA fallback:** Rota `*` captura tudo no final (correto)

## 🚀 Próximos Passos

1. **Commit e Push:**
   ```bash
   git add .
   git commit -m "Implementar Cenário B: Node.js + Passenger com Express"
   git push origin main
   ```

2. **No cPanel:**
   - Setup Node.js App → Configurar `server.js` como startup file
   - Git Version Control → Update from Remote → Deploy HEAD Commit

3. **Verificar:**
   - `https://virtuousensemble.pt/__health` → deve retornar `ok`
   - `https://virtuousensemble.pt/` → site deve carregar

## ⚠️ Nota sobre Build

O build agora é feito **no servidor** durante o deploy (via `.cpanel.yml`). 
Se o servidor tiver limitações de memória, pode fazer build localmente e commitar a pasta `dist/` temporariamente, ou usar o método manual descrito em `README_DEPLOY.md`.


