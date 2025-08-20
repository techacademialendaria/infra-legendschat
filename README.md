# LibreChat Infrastructure Repository

Este repositório contém toda a infraestrutura como código (IaC) para a aplicação LibreChat no ambiente de produção da Azure, utilizando Terraform e GitHub Actions para automação completa.

## Propósito do Repositório

Este repositório é a única fonte da verdade para a infraestrutura da aplicação LibreChat, gerenciando:

- **Resource Groups** e recursos base da Azure
- **Rede Virtual (VNet)** com sub-redes segregadas
- **Azure Container Registry (ACR)** para armazenamento de imagens
- **Azure Database for MongoDB** para persistência de dados
- **Container Apps Environment** para execução de aplicações
- **Container Apps** para API, Client e Meilisearch
- **Log Analytics Workspace** limitado a 100MB para monitoramento básico
- **Storage Account** para logs do Loki
- **Segurança** e configurações de rede

## Pré-requisitos

### Conta Azure
- Acesso a uma assinatura Azure ativa
- Permissões de Owner ou Contributor + User Access Administrator

### Service Principal
Um Service Principal configurado com as seguintes permissões:
- Contributor no Resource Group de destino
- Storage Account Contributor (para o backend do Terraform)

### GitHub Secrets
Configure os seguintes secrets no repositório:
- `AZURE_CLIENT_ID`: ID do Service Principal
- `AZURE_TENANT_ID`: ID do Tenant Azure
- `AZURE_SUBSCRIPTION_ID`: ID da Assinatura Azure

## Como Usar

### 1. Configuração do Backend

O arquivo `terraform/environments/prod/backend.tf` está configurado para usar um backend remoto. Você precisa:

1. Criar um Storage Account na Azure
2. Criar um container chamado `terraform-state`
3. Atualizar as variáveis no arquivo `backend.tf`:
   ```hcl
   resource_group_name  = "seu-resource-group"
   storage_account_name = "seustorageaccount"
   container_name       = "terraform-state"
   ```

### 2. Configuração das Variáveis

1. Copie o arquivo de exemplo:
   ```bash
   cp terraform/environments/prod/terraform.tfvars.example terraform/environments/prod/terraform.tfvars
   ```

2. Preencha as variáveis no arquivo `terraform.tfvars`:
   ```hcl
   location        = "Brazil South"
   resource_prefix = "librechat"
   mongodb_admin_password = "sua-senha-segura-aqui"
   # Adicione outras variáveis conforme necessário
   ```

### 3. Execução Local

Para executar o Terraform localmente:

```bash
cd terraform/environments/prod

# Inicializar o Terraform
terraform init

# Verificar o plano
terraform plan

# Aplicar as mudanças
terraform apply
```

### 4. Destruir a Infraestrutura

```bash
terraform destroy
```

## Pipeline de CI/CD

O workflow do GitHub Actions (`/.github/workflows/deploy-infra.yml`) automatiza todo o processo de deploy:

### Pull Requests
- Executa `terraform init`, `validate` e `plan`
- Posta o resultado do plano como comentário no PR
- **Não aplica mudanças** - apenas valida e mostra o que seria alterado

### Push para Main
- Executa `terraform init`, `validate` e `plan`
- Aplica automaticamente as mudanças com `terraform apply -auto-approve`
- **Atenção**: Mudanças na main são aplicadas automaticamente!

### Execução Manual
- Use o botão "Run workflow" no GitHub para executar manualmente
- Útil para aplicar mudanças urgentes ou re-aplicar configurações

## Estrutura do Projeto

```
/
├── .github/workflows/
│   └── deploy-infra.yml          # Workflow de CI/CD
├── terraform/
│   ├── modules/
│   │   ├── container-app/        # Módulo para Container Apps
│   │   └── cosmos-db/           # Módulo para Cosmos DB (legado)
│   └── environments/
│       └── prod/                # Configuração de produção
└── README.md                    # Esta documentação
```

## Módulos Terraform

### Container App Module
Módulo reutilizável para criar Container Apps com configurações flexíveis:
- Suporte a ingress público e privado
- Configuração de CPU, memória e replicas
- Injeção de variáveis de ambiente e secrets

### Cosmos DB Module (Legado)
Módulo para criar instâncias do Cosmos DB com API MongoDB (não mais utilizado):
- Configuração de consistência
- Outputs sensíveis para connection string e chave primária

## Recursos de Infraestrutura

### Azure Database for MongoDB
- Cluster MongoDB gerenciado pela Azure
- Configuração de alta disponibilidade
- Backup automático e recuperação de desastres
- Segurança integrada com Azure AD

### Log Analytics Workspace
- **Limitado a 100MB** para controle de custos
- Retenção de 7 dias
- Integração com Container Apps para logs básicos

### Storage Account para Loki
- Armazenamento dedicado para logs do Loki
- Container `loki-logs` para organização
- Configuração de segurança com TLS 1.2

## Segurança

- **Backend Remoto**: Estado do Terraform armazenado de forma segura no Azure Storage
- **OIDC**: Autenticação segura via OpenID Connect no GitHub Actions
- **Secrets**: Dados sensíveis injetados como secrets nos Container Apps
- **Rede**: Container Apps isolados em sub-rede dedicada
- **MongoDB**: Senha de administrador configurável e segura

## Monitoramento

- **Log Analytics Workspace**: Centraliza logs básicos (100MB limit)
- **Storage Account**: Armazenamento para logs do Loki
- **Container Apps**: Integrados automaticamente ao workspace
- **Métricas**: Disponíveis através do Azure Monitor

## Troubleshooting

### Erro de Autenticação
Verifique se os secrets do GitHub estão configurados corretamente:
- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID` 
- `AZURE_SUBSCRIPTION_ID`

### Erro de Backend
Certifique-se de que o Storage Account existe e o container `terraform-state` foi criado.

### Erro de Permissões
O Service Principal precisa ter permissões adequadas no Resource Group e Storage Account.

### Erro de MongoDB
Verifique se a senha do administrador está configurada corretamente no `terraform.tfvars`.

## Contribuição

1. Crie uma branch a partir da `main`
2. Faça suas alterações no código Terraform
3. Abra um Pull Request
4. O workflow validará e mostrará o plano
5. Após aprovação e merge, as mudanças serão aplicadas automaticamente

## Suporte

Para dúvidas ou problemas:
1. Verifique os logs do workflow no GitHub Actions
2. Consulte a documentação do Terraform Azure Provider
3. Abra uma issue no repositório
