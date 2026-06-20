# Desafio Final - Arquitetura de Solução em Nuvem na AWS

## Descrição

Este repositório contém a entrega do `Desafio Final` do bootcamp de `Arquiteto(a) de Soluções`, com foco na proposta de uma arquitetura em nuvem na `AWS` para uma aplicação de vendas on-line.

A solução foi desenhada para atender requisitos de:

- alta disponibilidade;
- escalabilidade;
- segurança;
- resiliência;
- recuperação de desastres.

## Entregáveis do Repositório

### 1. Diagrama principal da arquitetura

Arquivo:

- `arquitetura-aws.drawio`

Conteúdo:

- arquitetura completa da solução em `AWS`;
- distribuição em múltiplas `Availability Zones`;
- `Application Load Balancer`;
- `Amazon EC2` com `Auto Scaling`;
- `Amazon RDS Multi-AZ`;
- `IAM`, `CloudWatch` e `AWS Backup`.

### 2. C2 Model

O `C2 Model` está na aba `02-C2` do arquivo:

- `arquitetura-aws.drawio`

Conteúdo:

- containers principais da solução;
- responsabilidades de cada bloco;
- relação entre entrada, aplicação, persistência, observabilidade, backup e acesso.

### 3. C3 Model

O `C3 Model` está na aba `03-C3` do arquivo:

- `arquitetura-aws.drawio`

Conteúdo:

- componentes internos da camada de aplicação;
- relação entre web, API, módulos funcionais e persistência;
- representação do `RDS Multi-AZ` com `Primary` e `Standby`.

### 4. Documento auxiliar

Arquivo:

- `explicacao-diagrama-aws.md`

Conteúdo:

- explicação do diagrama principal;
- explicação do `C2`;
- explicação do `C3`;
- descrição do fluxo da solução;
- função de cada componente;
- justificativa de como a arquitetura atende os requisitos do desafio.

## Como Ler a Entrega

Sugestão de leitura:

1. abrir o arquivo `arquitetura-aws.drawio`;
2. analisar a aba `01-Arquitetura`;
3. analisar a aba `02-C2`;
4. analisar a aba `03-C3`;
5. consultar o documento `explicacao-diagrama-aws.md` como apoio.

## Escopo da Entrega

Itens contemplados:

- diagrama principal;
- `C2 Model`;
- `C3 Model`;
- documento auxiliar.

Itens não priorizados nesta entrega:

- `C1 Model`;
- `C4 Model`;
- implementação com `Terraform`;
- evidências práticas na console AWS.

Esses itens não foram priorizados porque, conforme orientação do professor, não são obrigatórios para nota.

## Resumo Técnico da Solução

A arquitetura proposta utiliza:

- `Amazon Route 53`
- `AWS WAF`
- `Application Load Balancer`
- `Amazon EC2`
- `Auto Scaling Group`
- `Amazon RDS Multi-AZ`
- `IAM Roles`
- `Amazon CloudWatch`
- `AWS Backup`

## Autor

Entrega acadêmica desenvolvida para o `Desafio Final` do bootcamp de `Arquiteto(a) de Soluções`.
