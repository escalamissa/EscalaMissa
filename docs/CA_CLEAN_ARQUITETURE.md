# Explicação da Arquitetura Limpa

Este documento explica a implementação dos princípios da Arquitetura Limpa no projeto 'Escala Missa UFMS'. A Arquitetura Limpa visa criar sistemas independentes de frameworks, testáveis, independentes da UI e independentes de bancos de dados.

## Princípios Fundamentais

*   **Independência de Frameworks:** A arquitetura não depende da existência de alguma biblioteca de software rica em recursos. Isso permite que o sistema seja flexível e adaptável.
*   **Testabilidade:** As regras de negócio podem ser testadas sem a UI, banco de dados, servidor web ou qualquer elemento externo.
*   **Independência da UI:** A UI pode ser alterada facilmente, sem alterar o restante do sistema.
*   **Independência do Banco de Dados:** O banco de dados pode ser trocado facilmente.
*   **Independência de qualquer agência externa:** As regras de negócio simplesmente não sabem nada sobre o mundo exterior.

## Estrutura em Camadas (Inferida da Estrutura do Projeto)

Com base na estrutura típica de um projeto Flutter e nos princípios da Arquitetura Limpa, o projeto provavelmente segue uma abordagem em camadas:

1.  **Entidades (Camada de Domínio):**
    *   Localizadas em `lib/models` (por exemplo, `AppUser`, `Parish`, `Evento`, `Escala`, `Aviso`, `Disponibilidade`, `Pastoral`, `AppFunction`).
    *   São os objetos e regras de negócio, independentes de quaisquer preocupações externas.
    *   Encapsulam as regras mais gerais e de alto nível.

2.  **Casos de Uso (Camada de Aplicação):**
    *   Provavelmente implementados como serviços ou 'interactors' que orquestram o fluxo de dados para e das entidades.
    *   Contêm as regras de negócio específicas da aplicação.
    *   Dependem das Entidades, mas são independentes da UI e do Banco de Dados.
    *   (Uma investigação mais aprofundada em `lib/services` esclareceria casos de uso específicos).

3.  **Adaptadores de Interface (Camadas de Apresentação e Dados):**
    *   **Adaptadores de Apresentação:**
        *   Localizados em `lib/screens` (componentes de UI).
        *   Apresentam dados dos Casos de Uso ao usuário e traduzem a entrada do usuário para um formato adequado aos Casos de Uso.
        *   (por exemplo, `LoginScreen`, `HomeScreen`, `EventListScreen`).
    *   **Adaptadores de Dados:**
        *   Responsáveis pela interação com serviços externos como o banco de dados (Supabase) ou APIs externas.
        *   (por exemplo, Repositórios ou fontes de dados dentro de `lib/services` ou uma camada de dados dedicada).
        *   Convertem dados do formato do banco de dados para o formato da entidade e vice-versa.

4.  **Frameworks & Drivers (Camada Externa):**
    *   Esta é a camada mais externa, consistindo em frameworks e ferramentas como o próprio Flutter, Supabase, Firebase, etc.
    *   São detalhes dos quais as camadas internas não devem ter conhecimento.
    *   (por exemplo, `main.dart` para inicialização da aplicação, `firebase_options.dart` para configuração).

## Regra de Dependência

A regra mais importante na Arquitetura Limpa é a Regra de Dependência. Esta regra afirma que as dependências do código-fonte só podem apontar para dentro. Nada em um círculo interno pode saber algo sobre algo em um círculo externo. Isso significa que:

*   Entidades não sabem nada sobre Casos de Uso, Adaptadores de Interface ou Frameworks.
*   Casos de Uso sabem sobre Entidades, mas nada sobre Adaptadores de Interface ou Frameworks.
*   Adaptadores de Interface sabem sobre Casos de Uso e Entidades, mas nada sobre Frameworks.
*   Frameworks sabem sobre tudo.

## Detalhes da Implementação (Exemplos do Código)

*   **`lib/models`**: Define claramente as entidades centrais, aderindo ao princípio da independência.
*   **`lib/services`**: Provavelmente contém os casos de uso e adaptadores de dados, abstraindo a lógica de negócios da UI e dos detalhes de persistência de dados.
*   **`lib/screens`**: Representa a camada de apresentação, dependendo dos serviços (casos de uso) para executar ações e recuperar dados.

## Benefícios

A Arquitetura Limpa foi provavelmente escolhida para este projeto devido aos seus benefícios:

*   **Manutenibilidade:** Mais fácil de entender e modificar a base de código.
*   **Testabilidade:** A lógica de negócios pode ser testada isoladamente.
*   **Flexibilidade:** Mais fácil de trocar dependências externas (por exemplo, mudar o banco de dados do Supabase para outro).
*   **Escalabilidade:** Suporta o crescimento e as mudanças nos requisitos de forma mais eficaz.