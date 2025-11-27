# 🚀 Como Executar o Projeto Automaticamente

## Script Automático (Recomendado)

Execute o script que detecta e corrige problemas automaticamente:

```powershell
.\run-auto.ps1
```

Este script:
- ✅ Detecta automaticamente o Node.js em vários locais
- ✅ Adiciona Node.js ao PATH se necessário
- ✅ Verifica e instala dependências automaticamente
- ✅ Corrige problemas comuns
- ✅ Inicia o servidor de desenvolvimento

## Outros Scripts Disponíveis

### `setup-and-run.ps1`
Instala Node.js (se necessário) e executa o projeto:
```powershell
.\setup-and-run.ps1
```

### `run-dev.ps1`
Executa o projeto (assume Node.js já instalado):
```powershell
.\run-dev.ps1
```

### `start-dev.ps1`
Usa um caminho específico do Node.js:
```powershell
.\start-dev.ps1
```

## Requisitos

- Windows PowerShell
- Node.js (será instalado automaticamente se usar `setup-and-run.ps1`)
- npm (vem com Node.js)

## Acesso

Após executar qualquer script, o servidor estará disponível em:
- **http://localhost:8080**

## Solução de Problemas

### Erro: "npm não encontrado"
1. Execute: `.\install-nodejs.ps1`
2. Ou baixe Node.js de: https://nodejs.org/
3. Feche e reabra o PowerShell

### Erro: "Dependências não instaladas"
O script `run-auto.ps1` instala automaticamente. Se falhar:
```powershell
npm install
```

### Erro: "Porta 8080 já em uso"
Altere a porta no `vite.config.ts` ou feche o processo que está usando a porta.




