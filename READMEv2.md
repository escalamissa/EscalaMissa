# Manual do Projeto: Escala Missa

Este documento serve como um guia completo para o projeto **Escala Missa**, detalhando desde a sua concepção e arquitetura até as instruções para instalação e uso. O projeto foi desenvolvido utilizando Flutter e Supabase, com o auxílio do **Gemini CLI** para acelerar e otilizar o desenvolvimento.

## 1. Lean Inception e Visão do Produto

A metodologia Lean Inception foi utilizada para definir o escopo inicial do projeto, focando em entregar valor rapidamente e validar as hipóteses de negócio.

### Visão do Projeto
Facilitar e organizar as escalas de voluntários para missas, substituindo o uso de WhatsApp e planilhas por uma solução digital intuitiva e acessível via Web e Mobile.

### Objetivos de Negócio
-   **Organizar** a escala de voluntários de forma clara e acessível.
-   **Reduzir** erros, esquecimentos e a sobrecarga dos coordenadores.
-   **Criar** um canal de comunicação oficial e segmentado para as pastorais.
-   **Automatizar** lembretes e o envio da escala diária/semanal.
-   **Tornar** o processo mais acessível para todos os perfis de usuários.

### Personas e Perfis de Usuário
O sistema foi desenhado para atender às necessidades de diferentes perfis de usuários:

-   **Padre:** Aprova e acompanha a agenda geral e os eventos da paróquia.
-   **Secretário(a):** Gerencia a agenda geral, usuários e as escalas de todas as pastorais.
-   **Coordenador(a):** Organiza as escalas e os eventos de suas respectivas pastorais.
-   **Voluntário(a):** Informa sua disponibilidade, escolhe horários para servir e visualiza onde está escalado.
-   **Fiel:** Visualiza a agenda de missas e os comunicados da paróquia.

## 2. Roadmap de Desenvolvimento

O desenvolvimento foi dividido em *sprints* para garantir entregas incrementais e contínuas.

-   **🚀 Sprint 1 – Fundamentos:**
    -   Configuração do Supabase (Auth, Database, RLS).
    -   Estrutura inicial do projeto Flutter.
    -   Implementação de cadastro e login de usuários.

-   **📖 Sprint 2 – Estrutura da Paróquia e Agenda:**
    -   CRUD de paróquias, pastorais e funções.
    -   Cadastro de eventos (missas e solenidades) com integração ao calendário litúrgico.
    -   Tela inicial com a agenda de eventos.

-   **⛪ Sprint 3 – Escalas (MVP Release):**
    -   Criação de escalas associando evento, pastoral, voluntário e função.
    -   Funcionalidade para o voluntário registrar sua disponibilidade.
    -   Sistema de aprovação de escalas pelo coordenador/padre.
    -   Agenda pessoal para o voluntário.
    -   **Entregável:** MVP com o ciclo completo de criação e visualização de escalas.

-   **📢 Sprint 4 – Notificações e Comunicação:**
    -   Implementação de notificações push.
    -   Mural de comunicados gerais e por pastoral.

-   **📊 Sprint 5 – Histórico e Relatórios:**
    -   Histórico de participação do voluntário.
    -   Relatórios de engajamento por pastoral e evento.
    -   Dashboard com estatísticas.

-   **🌍 Sprint 6 – Refinamento e Extras:**
    -   Melhorias de UX/UI e responsividade.
    -   Filtros avançados na agenda.
    -   Funcionalidades extras para facilitar a comunicação.

## 3. Arquitetura e Tecnologias

-   **Frontend:** Flutter (Web e Mobile)
-   **Backend:** Supabase (PostgreSQL, Auth, Storage)
-   **Build & Automação:** Gemini CLI

### Dependências Principais
Abaixo estão as principais bibliotecas utilizadas no projeto:

| Pacote | Versão | Descrição |
| --- | --- | --- |
| `supabase_flutter` | `^2.5.0` | Cliente Dart para integração com o Supabase. |
| `go_router` | `^14.1.0` | Gerenciamento de rotas e navegação. |
| `flutter_dotenv` | `^5.1.0` | Carregamento de variáveis de ambiente. |
| `intl` | `^0.20.2` | Internacionalização e formatação de datas/números. |
| `table_calendar` | `^3.1.1` | Componente de calendário para agendamentos. |
| `firebase_core` | `^4.1.1` | Necessário para usar serviços do Firebase, como o `messaging`. |
| `firebase_messaging` | `^16.0.2` | Para notificações push. |
| `uuid` | `^4.4.0` | Geração de UUIDs. |

Para instalar todas as dependências, execute:
```bash
flutter pub get
```

## 4. Banco de Dados: Schema e RLS

O backend é construído sobre o Supabase, utilizando o PostgreSQL. A segurança é garantida por meio de políticas de RLS (Row Level Security).

### Schema
O schema do banco de dados está definido no arquivo `schemas.sql` e inclui as seguintes tabelas principais:
-   `users`: Armazena os perfis de usuário, incluindo seu perfil e paróquia.
-   `paroquias`: Cadastro das paróquias.
-   `pastorais`: As diferentes pastorais de cada paróquia (ex: Liturgia, Canto).
-   `funcoes`: As funções que um voluntário pode exercer (ex: Leitor, Ministro).
-   `eventos`: As missas e outros eventos litúrgicos.
-   `escalas`: A tabela que conecta usuários, eventos, pastorais e funções.
-   `disponibilidades`: Onde os voluntários informam quando podem servir.
-   `avisos`: Para o mural de comunicados.

### Row Level Security (RLS)
As políticas de RLS, definidas em `rls.sql`, garantem que os usuários só possam acessar e modificar os dados que lhes são permitidos.

**Exemplos de Políticas:**
-   **`users_update_self`**: Permite que um usuário atualize apenas seu próprio perfil.
-   **`pastorais_crud_coord_admin`**: Apenas `Admins`, `Coordenadores` ou `Padres` podem criar, ler, atualizar ou deletar pastorais, e apenas dentro de sua própria paróquia.
-   **`escalas_select_scope`**: Um usuário pode ver todas as escalas de sua paróquia, mas só pode editar aquelas para as quais tem permissão (seja por ser coordenador da pastoral ou admin).
-   **`Voluntários podem atualizar suas próprias escalas`**: Um voluntário pode aceitar ou recusar um convite para uma escala.

Essas regras são implementadas com funções SQL como `auth.uid()`, que retorna o ID do usuário autenticado, e funções customizadas como `eh_admin()` e `mesma_paroquia()`, que verificam o perfil e a paróquia do usuário.

## 5. Estrutura do Projeto Flutter

O código-fonte está organizado na pasta `lib/` seguindo uma abordagem de *feature-first* e Clean Architecture.

```
lib/
├── models/         # Modelos de dados (ex: AppUser, Escala, Evento)
├── screens/        # Widgets que representam cada tela da aplicação
│   ├── home/
│   ├── login/
│   ├── profile/
│   └── ...
├── services/       # Lógica de negócio e comunicação com APIs (Supabase)
├── utils/          # Funções utilitárias e helpers
├── widgets/        # Widgets reutilizáveis (ex: CustomButton, LoadingSpinner)
└── main.dart       # Ponto de entrada da aplicação e configuração de rotas
```

## 6. Como Executar o Projeto

### Pré-requisitos
-   Flutter SDK instalado.
-   Conta no Supabase com um projeto criado.
-   Arquivo `.env` na raiz do projeto com as credenciais do Supabase:
    ```
    SUPABASE_URL=URL_DO_SEU_PROJETO
    SUPABASE_ANON_KEY=SUA_CHAVE_ANON
    ```

### Comandos
1.  **Instalar dependências:**
    ```bash
    flutter pub get
    ```

2.  **Executar a aplicação (Mobile):**
    ```bash
    flutter run
    ```

3.  **Executar a aplicação (Web):**
    ```bash
    flutter run -d chrome
    ```

## 7. Construído com Gemini CLI

O **Gemini CLI** foi uma ferramenta fundamental na construção deste projeto. Ele foi utilizado para:

-   **Análise de Código:** Compreender a estrutura do projeto e o impacto de novas mudanças.
-   **Geração de Código:** Criar widgets, modelos e serviços a partir de descrições em linguagem natural.
-   **Refatoração:** Otimizar e reorganizar o código, como na separação dos arquivos SQL (`dumpv1.sql` em `schemas.sql`, `rls.sql`, etc.).
-   **Documentação:** Gerar e atualizar este manual (`READMEv2.md`) com base no estado atual do projeto.
-   **Automação de Tarefas:** Executar comandos de build, testes e formatação de maneira automatizada.

O uso do Gemini CLI permitiu um desenvolvimento mais ágil, seguro e com maior qualidade de código.

## 8. Deploy para a Vercel

É possível fazer o deploy da versão Web do aplicativo para a Vercel seguindo os passos abaixo.

### 1. Preparando o Repositório no GitHub
-   Certifique-se de que seu projeto está em um repositório no GitHub.
-   Adicione os arquivos `vercel.json` e `vercel-build.sh` na raiz do projeto.

### 2. Configurando o Projeto na Vercel
1.  Crie uma conta na [Vercel](https://vercel.com) e faça o login.
2.  No seu dashboard, clique em **"Add New... > Project"**.
3.  Importe o repositório do GitHub que você preparou.
4.  Durante a configuração, a Vercel pode detectar que é um projeto Flutter, mas vamos customizar as configurações de build.

### 3. Configurações de Build na Vercel
Na tela de configuração do projeto, expanda a seção **"Build & Development Settings"** e configure da seguinte forma:
-   **FRAMEWORK PRESET:** Selecione `Other`.
-   **BUILD COMMAND:** Insira `sh vercel-build.sh`.
-   **OUTPUT DIRECTORY:** Insira `build/web`.
-   **INSTALL COMMAND:** Deixe em branco ou use `flutter pub get`.

### 4. Variáveis de Ambiente
Como o arquivo `.env` não é enviado para o repositório, você precisa configurar as variáveis de ambiente diretamente na Vercel:
1.  Ainda na tela de configuração do projeto, vá para a aba **"Environment Variables"**.
2.  Adicione as mesmas variáveis que estão no seu arquivo `.env`:
    -   `SUPABASE_URL`: A URL do seu projeto Supabase.
    -   `SUPABASE_ANON_KEY`: A chave anônima do seu projeto Supabase.

    **Importante:** Para que o Flutter acesse essas variáveis durante o build, os nomes na Vercel devem ser prefixados com `FLUTTER_`.
    -   `FLUTTER_SUPABASE_URL`
    -   `FLUTTER_SUPABASE_ANON_KEY`

### 5. Finalizando
-   Clique em **"Deploy"**.
-   A Vercel irá clonar o repositório, executar o script `vercel-build.sh` para buildar a aplicação Web e, em seguida, fará o deploy do conteúdo da pasta `build/web`.
-   O arquivo `vercel.json` garantirá que a navegação (deep linking) funcione corretamente na sua SPA Flutter.

Após o deploy, você receberá uma URL onde sua aplicação estará disponível. A Vercel fará o deploy automático a cada novo push para a branch principal do seu repositório.
