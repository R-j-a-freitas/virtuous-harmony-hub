# Resolver: Botão "Deploy HEAD Commit" Inativo

## 🔴 Problema

O botão **"Deploy HEAD Commit"** está desativado (cinza) no cPanel.

## 🔍 Causas Comuns

1. **Mudanças não commitadas no servidor** (mais comum)
2. **Repositório não sincronizado com GitHub**
3. **Arquivos não rastreados no servidor**

## ✅ Solução Passo a Passo

### Passo 1: Verificar Status do Git

No terminal do cPanel:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
git status
```

Isso mostrará:
- Arquivos modificados
- Arquivos não rastreados
- Arquivos staged

### Passo 2: Resolver Mudanças Locais

**Opção A: Descartar todas as mudanças locais (Recomendado)**

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
git fetch origin
git reset --hard origin/main
```

Isso força o repositório do servidor a ficar idêntico ao GitHub.

**Opção B: Fazer commit das mudanças locais (se forem importantes)**

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
git add .
git commit -m "Sincronizar mudanças do servidor"
git push origin main
```

**Opção C: Stash das mudanças (guardar temporariamente)**

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
git stash
```

### Passo 3: Limpar Arquivos Não Rastreados (Opcional)

Se houver arquivos não rastreados que não são necessários:

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
# Ver o que será removido (dry-run)
git clean -n

# Remover arquivos não rastreados (CUIDADO!)
git clean -f
```

### Passo 4: Verificar se Está Limpo

```bash
git status
```

Deve mostrar:
```
On branch main
Your branch is up to date with 'origin/main'.

nothing to commit, working tree clean
```

### Passo 5: Atualizar do GitHub

No cPanel:
1. **Git Version Control** → **Manage**
2. Clique em **"Update from Remote"**
3. Aguarde a conclusão

### Passo 6: Verificar se o Botão Está Ativo

Após o "Update from Remote", o botão **"Deploy HEAD Commit"** deve ficar ativo.

---

## 🔄 Script Automático Completo

Crie um script `fix-deploy-button.sh`:

```bash
#!/bin/bash
# Script para ativar o botão Deploy HEAD Commit

APPROOT="/home/virtuou2/repositories/virtuous-harmony-hub"

echo "==== Ativando botao Deploy HEAD Commit ===="
echo ""

cd "$APPROOT" || exit 1

echo "1. Verificando status do Git..."
git status

echo ""
echo "2. Buscando alteracoes do GitHub..."
git fetch origin

echo ""
echo "3. Descartando mudancas locais e sincronizando..."
git reset --hard origin/main

echo ""
echo "4. Limpando arquivos nao rastreados..."
git clean -fd

echo ""
echo "5. Verificando status final..."
git status

echo ""
echo "==== Concluido! ===="
echo ""
echo "Agora no cPanel:"
echo "1. Va para Git Version Control -> Manage"
echo "2. Clique em 'Update from Remote'"
echo "3. O botao 'Deploy HEAD Commit' deve estar ativo"
echo ""
```

**Para executar:**

```bash
chmod +x fix-deploy-button.sh
./fix-deploy-button.sh
```

---

## 🐛 Se o Botão Ainda Estiver Inativo

### Verificar se há arquivos ignorados causando problema

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
git status --ignored
```

### Verificar se o .cpanel.yml está presente

```bash
ls -la .cpanel.yml
cat .cpanel.yml | head -5
```

O cPanel precisa do `.cpanel.yml` para ativar o botão.

### Verificar logs do cPanel

Procure por mensagens de erro na interface do Git Version Control.

---

## ✅ Checklist

- [ ] `git status` mostra "working tree clean"
- [ ] `git fetch origin` executado
- [ ] `git reset --hard origin/main` executado
- [ ] "Update from Remote" executado no cPanel
- [ ] `.cpanel.yml` existe no servidor
- [ ] Botão "Deploy HEAD Commit" está ativo

---

## 📝 Comandos Rápidos (Copiar e Colar)

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
git status
git fetch origin
git reset --hard origin/main
git clean -fd
git status
# Deve mostrar: "working tree clean"
```

Depois, no cPanel:
1. Git Version Control → Manage
2. Update from Remote
3. Deploy HEAD Commit (deve estar ativo agora)

---

## 💡 Dica

Se o botão continuar inativo após seguir todos os passos, tente:
1. Fazer logout e login novamente no cPanel
2. Limpar cache do navegador
3. Tentar em outro navegador

