# Explicação da Arquitetura AWS

## Objetivo da Solução

Esta entrega apresenta uma arquitetura em `AWS` para uma aplicação de vendas on-line com foco em:

- alta disponibilidade;
- escalabilidade;
- segurança;
- resiliência;
- recuperação de desastres.

A proposta foi desenhada para manter o sistema disponível `24/7`, distribuir carga entre instâncias, permitir crescimento automático da camada de aplicação e proteger os dados com banco gerenciado, monitoramento e backup.

## Artefatos da Entrega

O repositório contém três visões principais da arquitetura:

1. `Diagrama principal`
Mostra a topologia completa da solução em AWS.

2. `C2 Model`
Mostra os containers da solução e as responsabilidades de cada bloco principal.

3. `C3 Model`
Mostra os componentes internos da camada de aplicação e o relacionamento com o banco de dados.

## 1. Explicação do Diagrama Principal

O diagrama principal representa o fluxo completo da aplicação, desde a entrada do usuário até a persistência dos dados.

### Fluxo principal

O fluxo da solução funciona da seguinte forma:

1. o usuário acessa a aplicação pela internet;
2. o `Amazon Route 53` resolve o domínio;
3. o `AWS WAF` aplica filtragem e proteção;
4. o `Application Load Balancer` recebe e distribui o tráfego;
5. as instâncias `Amazon EC2` processam as requisições;
6. a aplicação acessa o `Amazon RDS`;
7. o `Amazon CloudWatch` acompanha logs, métricas e saúde;
8. o `AWS Backup` protege o banco para recuperação.

### Componentes e funções

#### Usuários

Representam os clientes que acessam a aplicação.

Função:

- iniciar requisições para o sistema;
- consumir a aplicação de vendas on-line.

#### Amazon Route 53

Responsável pela resolução de DNS.

Função:

- direcionar o domínio da aplicação;
- encaminhar o acesso para a camada de entrada da arquitetura.

#### AWS WAF

Camada de segurança na borda da aplicação.

Função:

- filtrar tráfego;
- bloquear requisições maliciosas;
- reduzir exposição a ataques comuns.

#### Application Load Balancer

Distribui o tráfego entre várias instâncias de aplicação.

Função:

- balancear carga;
- evitar concentração em uma única instância;
- melhorar disponibilidade da camada web;
- trabalhar junto com health checks.

#### VPC

Representa a rede isolada onde os recursos da aplicação estão implantados.

Função:

- organizar a comunicação entre os componentes;
- separar recursos públicos e privados;
- permitir aplicação de controles de rede.

Dentro da VPC existem:

- `sub-redes públicas`, onde está o `ALB`;
- `sub-redes privadas`, onde ficam `EC2` e `RDS`.

#### Availability Zones

A arquitetura foi distribuída entre duas zonas de disponibilidade.

Função:

- reduzir impacto de falha de infraestrutura;
- manter continuidade do serviço;
- permitir redundância entre zonas.

#### Auto Scaling Group

Controla a quantidade de instâncias da camada de aplicação.

Função:

- manter no mínimo `3` instâncias;
- permitir crescimento até `6` instâncias;
- ajustar a capacidade conforme demanda.

#### Amazon EC2

As instâncias `EC2` executam a aplicação em `Linux`.

Função:

- processar regras de negócio;
- atender requisições do usuário;
- acessar o banco de dados;
- operar de forma distribuída entre as zonas.

#### IAM Role

Controla o acesso da aplicação aos recursos da AWS.

Função:

- conceder permissões mínimas necessárias;
- permitir acesso controlado ao banco;
- reduzir risco de acesso indevido.

#### Amazon RDS Multi-AZ

O banco de dados foi representado explicitamente como `Multi-AZ`.

No diagrama, isso aparece com:

- `RDS Primary - AZ A`
- `RDS Standby - AZ B`
- indicação de `replicação síncrona / failover`

Função:

- armazenar os dados da aplicação;
- garantir alta disponibilidade;
- permitir failover automático entre zonas;
- simplificar a administração do banco por ser um serviço gerenciado.

#### Amazon CloudWatch

Camada de observabilidade da solução.

Função:

- coletar logs;
- acompanhar métricas;
- monitorar saúde de ALB, EC2 e RDS;
- apoiar detecção de falhas e comportamento anormal.

#### AWS Backup

Camada de backup e recuperação.

Função:

- proteger os dados do banco;
- manter backups e snapshots;
- apoiar a estratégia de DR.

## 2. Explicação do C2 Model

O `C2` mostra os containers principais da solução e como eles se relacionam.

### Container 1 - Entrada e Resolução DNS

Representa:

- `Amazon Route 53`
- `AWS WAF`
- `Application Load Balancer`

Função:

- receber o acesso externo;
- resolver DNS;
- filtrar tráfego;
- encaminhar requisições para a aplicação.

### Container 2 - Camada de Aplicação

Representa:

- `Amazon EC2`
- `Auto Scaling Group`

Função:

- executar a aplicação de negócio;
- processar as requisições;
- escalar horizontalmente.

### Container 3 - Persistência de Dados

Representa:

- `Amazon RDS Multi-AZ`
- `Primary + Standby`

Função:

- armazenar os dados da aplicação;
- manter redundância entre zonas;
- permitir failover do banco.

### Container 4 - Observabilidade

Representa:

- `Amazon CloudWatch`

Função:

- logs;
- métricas;
- alarmes;
- visibilidade operacional.

### Container 5 - Backup e Recuperação

Representa:

- `AWS Backup`

Função:

- backup;
- recuperação;
- suporte a desastre e restauração.

### Container 6 - Controle de Acesso

Representa:

- `IAM Roles`
- `IAM Policies`

Função:

- controle de autorização;
- princípio do menor privilégio;
- segurança entre aplicação e banco.

## 3. Explicação do C3 Model

O `C3` detalha a camada de aplicação e mostra como os componentes internos interagem.

### Componente 1 - Balanceamento e Entrada

Representa:

- `ALB`
- `health checks`

Função:

- receber tráfego;
- encaminhar requisições para a camada web.

### Componente 2 - Camada Web

Representa um servidor web, como:

- `Nginx`
- `Apache`

Função:

- receber requisições HTTP/HTTPS;
- encaminhar para a API da aplicação.

### Componente 3 - API da Aplicação

Função:

- centralizar regras de negócio;
- coordenar autenticação, catálogo, checkout e pedidos;
- chamar a camada de persistência.

### Componente 4 - Autenticação e Autorização

Função:

- validar identidades;
- aplicar regras de acesso da aplicação.

### Componente 5 - Catálogo de Produtos

Função:

- expor dados de produtos;
- apoiar consulta e navegação.

### Componente 6 - Carrinho e Checkout

Função:

- concentrar lógica de compra;
- tratar fechamento de pedido.

### Componente 7 - Pedidos e Confirmação

Função:

- registrar pedidos;
- acompanhar confirmação do processo.

### Componente 8 - Camada de Persistência

Representa um padrão de acesso a dados, como:

- `Repository`
- `DAO`

Função:

- encapsular operações de leitura e escrita;
- isolar a aplicação da tecnologia de banco.

### Componente 9 - Observabilidade

Função:

- gerar logs;
- expor métricas;
- apoiar monitoramento da aplicação.

### Banco externo no C3

No `C3`, o banco também foi atualizado para refletir `Multi-AZ`.

A representação agora mostra:

- `RDS Primary - AZ A`
- `RDS Standby - AZ B`
- relação de `replicação síncrona / failover`

Isso deixa o `C3` consistente com o diagrama principal e com o `C2`.

## Como a Arquitetura Atende os Requisitos

### Alta disponibilidade

A arquitetura atende alta disponibilidade por meio de:

- distribuição em múltiplas `Availability Zones`;
- `ALB` para balanceamento;
- `Auto Scaling Group` com várias instâncias;
- `RDS Multi-AZ` com `Primary` e `Standby`.

### Escalabilidade

A arquitetura atende escalabilidade por meio de:

- `Auto Scaling Group`;
- crescimento horizontal entre `3` e `6` instâncias;
- distribuição de carga pelo `ALB`.

### Segurança

A arquitetura atende segurança por meio de:

- `AWS WAF`;
- `IAM Roles`;
- isolamento em `VPC`;
- separação entre sub-redes públicas e privadas;
- `Security Groups` e `NACLs`.

### Resiliência e DR

A arquitetura atende resiliência e DR por meio de:

- redundância entre zonas;
- failover automático do `RDS Multi-AZ`;
- monitoramento com `CloudWatch`;
- backups com `AWS Backup`.

## Conclusão

A versão final dos diagramas apresenta uma arquitetura AWS coerente com os requisitos do desafio e com o critério de avaliação do professor.

Os três níveis estão alinhados:

- o `diagrama principal` mostra a topologia completa;
- o `C2` mostra os containers da solução;
- o `C3` mostra os componentes da camada de aplicação e o detalhamento do banco em `Multi-AZ`.

Com isso, a entrega deixa claro:

- como o tráfego entra;
- como a aplicação escala;
- como os dados persistem;
- como a segurança foi tratada;
- como ocorre a alta disponibilidade;
- como a recuperação de desastres foi considerada.
