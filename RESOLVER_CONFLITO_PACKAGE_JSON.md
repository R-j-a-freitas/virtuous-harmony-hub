# Resolver Conflito do package.json no cPanel

## Problema
O erro indica que há alterações locais no `package.json` no servidor que conflitam com as alterações do GitHub:

```
error: Your local changes to the following files would be overwritten by merge: package.json
Please commit your changes or stash them before you merge. Aborting
```

## Solução Imediata

### Opção 1: Reset Hard (Recomendado - Perde mudanças locais)

**⚠️ ATENÇÃO: Isso apagará TODAS as mudanças não commitadas no servidor!**

**Via Terminal SSH (se tiver acesso):**

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
git fetch origin
git reset --hard origin/main
```

Depois, no cPanel:
1. Vá para **Git™ Version Control**
2. Clique em **"Update from Remote"**
3. Clique em **"Deploy HEAD Commit"**

### Opção 2: Stash das Mudanças Locais

**Via Terminal SSH:**

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
git stash
git pull origin main
```

Depois, no cPanel:
1. Vá para **Git™ Version Control**
2. Clique em **"Update from Remote"**
3. Clique em **"Deploy HEAD Commit"**

### Opção 3: Restaurar package.json Específico

**Via Terminal SSH:**

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
git checkout -- package.json
git pull origin main
```

Depois, no cPanel:
1. Vá para **Git™ Version Control**
2. Clique em **"Update from Remote"**
3. Clique em **"Deploy HEAD Commit"**

### Opção 4: Via File Manager (Se não tiver SSH)

1. No cPanel, vá para **File Manager**
2. Navegue até: `/home/virtuou2/repositories/virtuous-harmony-hub`
3. Abra o arquivo `package.json`
4. **Delete o conteúdo** e cole o conteúdo do `package.json` do GitHub
5. Salve o arquivo
6. Volte para **Git™ Version Control**
7. Clique em **"Update from Remote"**
8. Clique em **"Deploy HEAD Commit"**

## Por que isso aconteceu?

O arquivo `package.json` foi modificado no servidor (provavelmente durante testes ou instalações manuais) e não foi commitado. Quando tentamos fazer pull do GitHub, o Git detectou que o arquivo local seria sobrescrito e abortou a operação por segurança.

## Prevenção Futura

Após resolver o problema, o `.cpanel.yml` garantirá que:
- As dependências sejam instaladas corretamente
- O build seja feito automaticamente
- O Passenger seja reiniciado

## Próximos Passos

Após resolver o conflito e fazer o "Update from Remote":

1. ✅ O repositório será atualizado com o `package.json` correto do GitHub
2. ✅ O deploy será executado automaticamente via `.cpanel.yml`
3. ✅ As dependências serão instaladas
4. ✅ O build será feito
5. ✅ O Passenger será reiniciado
6. ✅ O site será atualizado com as últimas alterações

---

**Nota:** O arquivo `package.json` que está no repositório Git é a versão correta e será restaurado após o "Update from Remote".

