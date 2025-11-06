# Resolver Conflito do app.js no cPanel

## Problema
O erro indica que há um arquivo `app.js` não rastreado no servidor que está impedindo o Git de fazer o merge/pull:

```
error: The following untracked working tree files would be overwritten by merge: app.js
Please move or remove them before you merge. Aborting
```

## Solução Imediata

### Opção 1: Remover o arquivo via File Manager (Recomendado)

1. No cPanel, vá para **File Manager**
2. Navegue até: `/home/virtuou2/repositories/virtuous-harmony-hub`
3. Procure pelo arquivo `app.js`
4. **Delete o arquivo** `app.js` (ou renomeie para `app.js.backup` se quiser manter uma cópia)
5. Volte para **Git™ Version Control**
6. Clique em **"Update from Remote"**
7. Depois clique em **"Deploy HEAD Commit"**

### Opção 2: Remover via Terminal SSH (se tiver acesso)

```bash
cd /home/virtuou2/repositories/virtuous-harmony-hub
rm -f app.js
```

Depois, no cPanel:
1. Vá para **Git™ Version Control**
2. Clique em **"Update from Remote"**
3. Clique em **"Deploy HEAD Commit"**

## Por que isso aconteceu?

O arquivo `app.js` foi criado manualmente no servidor (provavelmente durante testes anteriores) e não estava rastreado pelo Git. Quando adicionamos o `app.js` ao repositório Git e tentamos fazer pull, o Git detectou que o arquivo local seria sobrescrito e abortou a operação por segurança.

## Prevenção Futura

O arquivo `.cpanel.yml` foi atualizado para automaticamente remover arquivos conflitantes antes do deploy. Após resolver o problema atual, futuros deploys não terão esse problema.

## Próximos Passos

Após remover o `app.js` e fazer o "Update from Remote":

1. ✅ O repositório será atualizado com o `app.js` correto do GitHub
2. ✅ O deploy será executado automaticamente
3. ✅ O site será atualizado com as últimas alterações

---

**Nota:** O arquivo `app.js` que está no repositório Git é a versão correta e será restaurado após o "Update from Remote".

