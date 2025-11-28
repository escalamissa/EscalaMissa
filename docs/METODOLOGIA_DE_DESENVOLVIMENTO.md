# Metodologia de Desenvolvimento do Projeto Escala Missa UFMS

Este documento descreve a metodologia de desenvolvimento adotada para o projeto 'Escala Missa UFMS', abrangendo desde a concepção inicial até a implementação e documentação. O objetivo é fornecer uma visão clara de como o projeto foi estruturado e executado.

## Fase 1: Concepção e Planejamento (Lean Inception)

Nesta fase, o foco foi em alinhar a visão do produto e definir o escopo inicial de forma colaborativa e eficiente, utilizando princípios de Lean Inception. Os principais pontos abordados foram:

*   **Visão do Produto:** Definição clara do propósito e dos objetivos do 'Escala Missa UFMS', conforme detalhado em [Lean Inception](docs/lean_inception.md).
*   **Objetivos:** Estabelecimento dos resultados esperados, como a organização da escala de voluntários, redução de erros e criação de um canal de comunicação segmentado.
*   **Personas:** Identificação dos diferentes tipos de usuários (Padre, Secretário, Coordenador, Voluntário, Fiel) e suas necessidades, expectativas e interações com o sistema. O detalhamento das personas pode ser encontrado em [Lean Inception](docs/lean_inception.md).
*   **Brainstorming de Funcionalidades:** Levantamento inicial das funcionalidades que atenderiam às necessidades das personas e aos objetivos do projeto.
*   **Jornada do Usuário:** Mapeamento das interações dos usuários com o sistema para garantir uma experiência intuitiva e eficiente.
*   **Sequenciador:** Priorização das funcionalidades para a construção do Produto Mínimo Viável (MVP).

## Fase 2: Definição de Requisitos (Criação do MVP)

Com base na concepção inicial, a fase de definição de requisitos focou em detalhar as funcionalidades essenciais para o MVP, bem como os critérios de qualidade e as regras de negócio.

*   **Definição do MVP:** Determinação do conjunto mínimo de funcionalidades que entregariam valor significativo aos usuários e validariam a proposta do projeto. Mais detalhes em [Criação do MVP](docs/mvp_creation.md).
*   **Requisitos Funcionais (RF):** Especificação das ações que o sistema deve ser capaz de realizar, como cadastro de usuários, gestão de eventos e envio de notificações. Consulte [Criação do MVP](docs/mvp_creation.md) para a lista completa.
*   **Requisitos Não Funcionais (RNF):** Definição dos atributos de qualidade do sistema, incluindo ser multiplataforma, ter interface intuitiva, segurança e alta disponibilidade. Detalhes em [Criação do MVP](docs/mvp_creation.md).
*   **Regras de Negócio (RN):** Estabelecimento das políticas e restrições que governam o comportamento do sistema, como o controle de acesso por perfil e as permissões para criação de eventos. As regras de negócio estão em [Criação do MVP](docs/mvp_creation.md).

## Fase 3: Arquitetura e Design (Arquitetura Limpa e Esquemas)

Esta fase concentrou-se na definição da arquitetura do software e no design do banco de dados, garantindo um sistema robusto, escalável e de fácil manutenção.

*   **Arquitetura Limpa:** Adoção da Arquitetura Limpa para garantir a separação de preocupações, testabilidade e independência de frameworks. Uma explicação detalhada dos princípios e da estrutura em camadas pode ser encontrada em [Explicação da Arquitetura Limpa](docs/CA-CLEANARQUITETURE.md).
*   **Design do Esquema do Banco de Dados:** Criação das tabelas, enums, views e relacionamentos no banco de dados, utilizando Supabase como backend. O esquema completo, incluindo a tabela `outbox_whatsapp` e a view `v_minha_agenda`, está documentado em [Esquemas](docs/schemas.md).
*   **Modelos de Dados Locais:** Definição dos modelos de dados Dart (`AppUser`, `Parish`, `Evento`, `Escala`, `Aviso`, `Disponibilidade`, `Pastoral`, `AppFunction`, `UserProfile`) que espelham o esquema do banco de dados e são utilizados na aplicação Flutter. Estes modelos estão detalhados em [Esquemas](docs/schemas.md).
*   **Row Level Security (RLS):** Implementação de políticas de RLS no Supabase para garantir o controle de acesso aos dados com base nos perfis dos usuários, conforme detalhado nos scripts SQL (`rls.sql`, `sq.sql`, `sql.sql`).

## Fase 4: Implementação e Desenvolvimento

Nesta fase, as funcionalidades foram construídas utilizando Flutter para garantir uma experiência multiplataforma (Web e Mobile).

*   **Desenvolvimento Iterativo:** A implementação seguiu um processo iterativo, permitindo feedback contínuo e adaptações.
*   **Tecnologias:** Utilização de Flutter para o frontend, Supabase para o backend (banco de dados, autenticação, RLS) e Firebase para notificações push.
*   **Estrutura de Telas:** Cada tela da aplicação foi desenvolvida com base nos requisitos e no design da interface, com detalhes sobre propósito e funcionalidades em [Detalhes das Páginas](docs/page_details.md).
*   **Serviços:** A lógica de negócio e a interação com o Supabase foram encapsuladas em serviços, seguindo os princípios da Arquitetura Limpa.

## Fase 5: Testes e Garantia de Qualidade

A qualidade do software foi assegurada através de testes contínuos em diferentes níveis.

*   **Testes Unitários:** Verificação de componentes individuais da aplicação.
*   **Testes de Integração:** Garantia de que diferentes módulos e serviços funcionam corretamente juntos.
*   **Testes de UI:** Validação da interface do usuário e da experiência do usuário.
*   **Revisões de Código:** Realização de revisões de código para garantir a conformidade com os padrões e a identificação de possíveis problemas.

## Fase 6: Implantação e Manutenção

Após o desenvolvimento e testes, a aplicação foi preparada para implantação e manutenção contínua.

*   **Implantação:** A aplicação pode ser implantada como um PWA (Progressive Web App) para acesso via Web e como aplicativos nativos para Android e iOS.
*   **Monitoramento:** Configuração de ferramentas de monitoramento para acompanhar o desempenho e identificar problemas em produção.
*   **Manutenção e Atualizações:** Plano para manutenção contínua, incluindo correção de bugs, melhorias de funcionalidades e atualizações de segurança.

## Ferramentas e Tecnologias Utilizadas

*   **Frontend:** Flutter (Dart)
*   **Backend:** Supabase (PostgreSQL, Autenticação, RLS)
*   **Notificações:** Firebase Cloud Messaging (FCM)
*   **Controle de Versão:** Git
*   **Ambiente de Desenvolvimento:** VS Code

Este documento, juntamente com os arquivos de documentação específicos, oferece uma visão completa do processo de desenvolvimento do projeto Escala Missa UFMS.
