# Detalhes das Páginas

Esta seção fornece uma análise detalhada de cada página ou tela significativa dentro da aplicação 'Escala Missa UFMS'. Para cada página, ela descreve seu propósito, principais funcionalidades, considerações de UI/UX, dados exibidos e navegação.

## Visão Geral das Telas

Aqui está uma lista das principais telas identificadas no diretório `lib/screens`:

### `admin_panel_screen.dart`
*   **Propósito:** Fornece funcionalidades administrativas, provavelmente para gerenciar usuários, paróquias e configurações globais.
*   **Principais Funcionalidades:** Gerenciamento de usuários, gerenciamento pastoral, supervisão de eventos, geração de relatórios.
*   **Acesso:** Restrito ao perfil 'admin'.

### `aviso_form_screen.dart`
*   **Propósito:** Permite que administradores e coordenadores criem e editem avisos.
*   **Principais Funcionalidades:** Formulário para título, mensagem, pastoral alvo e opções de publicação.
*   **Navegação:** Acessado a partir de `aviso_list_screen` ou de um painel.

### `aviso_list_screen.dart`
*   **Propósito:** Exibe uma lista de avisos relevantes para a paróquia ou pastoral do usuário logado.
*   **Principais Funcionalidades:** Visualizar avisos, filtrar por pastoral, navegar para `aviso_form_screen` (para usuários autorizados).

### `disponibilidade_screen.dart`
*   **Propósito:** Permite que voluntários gerenciem sua disponibilidade para eventos.
*   **Principais Funcionalidades:** Visualização de calendário para selecionar datas/horários disponíveis, especificando funções/pastorais preferenciais.
*   **Acesso:** Principalmente para o perfil 'voluntario'.

### `escala_confirmation_screen.dart`
*   **Propósito:** Fornece uma tela para os voluntários confirmarem ou recusarem suas entradas de escala atribuídas.
*   **Principais Funcionalidades:** Exibir detalhes da escala, ações de confirmação/rejeição.

### `escala_form_screen.dart`
*   **Propósito:** Permite que coordenadores e administradores criem ou editem entradas de escala para eventos.
*   **Principais Funcionalidades:** Formulário para selecionar evento, pastoral, função, voluntário e status.

### `escala_list_screen.dart`
*   **Propósito:** Exibe uma lista de entradas de escala, possivelmente com opções de filtragem e ordenação.
*   **Principais Funcionalidades:** Visualizar escalas, filtrar por evento/pastoral/voluntário, navegar para `escala_form_screen`.

### `event_availability_form_screen.dart`
*   **Propósito:** Provavelmente uma tela para coordenadores gerenciarem a disponibilidade de funções/papéis para um evento específico.
*   **Principais Funcionalidades:** Definir funções necessárias para um evento, definir número de voluntários necessários.

### `event_form_screen.dart`
*   **Propósito:** Permite que usuários autorizados (admin, padre, secretário, coordenador) criem e editem detalhes do evento.
*   **Principais Funcionalidades:** Formulário para título do evento, descrição, data/hora, tempo litúrgico, solenidade, local.

### `event_list_screen.dart`
*   **Propósito:** Exibe uma lista de eventos, com opções para filtrar e visualizar detalhes.
*   **Principais Funcionalidades:** Visualizar próximos eventos, filtrar por data/tipo, navegar para `event_form_screen` ou `escala_list_screen`.

### `event_selection_screen.dart`
*   **Propósito:** Uma tela para selecionar um evento, possivelmente como pré-requisito para outras ações, como a criação de uma escala.

### `function_form_screen.dart`
*   **Propósito:** Permite que administradores criem e editem funções (papéis) para voluntários.
*   **Principais Funcionalidades:** Formulário para nome e descrição da função.

### `function_list_screen.dart`
*   **Propósito:** Exibe uma lista de funções/papéis disponíveis.
*   **Principais Funcionalidades:** Visualizar funções, navegar para `function_form_screen`.

### `home_screen.dart`
*   **Propósito:** O painel principal ou página inicial após o login, fornecendo uma visão geral relevante para o perfil do usuário.
*   **Principais Funcionalidades:** Acesso rápido à agenda pessoal, próximos eventos, avisos e navegação para outras seções.

### `liturgy_screen.dart`
*   **Propósito:** Exibe informações litúrgicas, possivelmente integradas com o arquivo `liturgia.txt`.
*   **Principais Funcionalidades:** Visualizar leituras litúrgicas diárias/semanais, datas especiais.

### `login_screen.dart`
*   **Propósito:** Lida com a autenticação do usuário.
*   **Principais Funcionalidades:** Entrada de credenciais do usuário, botão de login, navegação para registro ou recuperação de senha.

### `package.dart`
*   **Propósito:** O nome deste arquivo sugere que ele pode estar relacionado ao gerenciamento de pacotes ou exportações, e não a uma tela em si. (Investigação adicional necessária se contiver elementos de UI).

### `parish_form_screen.dart`
*   **Propósito:** Permite que administradores criem e editem informações da paróquia.
*   **Principais Funcionalidades:** Formulário para nome da paróquia, cidade, estado e status ativo.

### `parish_list_screen.dart`
*   **Propósito:** Exibe uma lista de paróquias, principalmente para administradores.
*   **Principais Funcionalidades:** Visualizar paróquias, navegar para `parish_form_screen`.

### `pastoral_form_screen.dart`
*   **Propósito:** Permite que administradores e possivelmente padres/secretários criem e editem grupos pastorais.
*   **Principais Funcionalidades:** Formulário para nome da pastoral, paróquia associada e coordenador.

### `pastoral_list_screen.dart`
*   **Propósito:** Exibe uma lista de grupos pastorais, com opções de filtragem e gerenciamento.
*   **Principais Funcionalidades:** Visualizar pastorais, filtrar, navegar para `pastoral_form_screen`.

### `personal_agenda_screen.dart`
*   **Propósito:** Exibe uma agenda personalizada para o usuário logado, mostrando suas escalas e eventos atribuídos.
*   **Principais Funcionalidades:** Visualização de calendário, lista de compromissos pessoais.

### `profile_screen.dart`
*   **Propósito:** Permite que os usuários visualizem e editem suas informações de perfil pessoal.
*   **Principais Funcionalidades:** Exibir detalhes do usuário, editar informações de contato, alterar senha.

### `registration_screen.dart`
*   **Propósito:** Lida com o registro de novos usuários.
*   **Principais Funcionalidades:** Formulário para detalhes do usuário, seleção de perfil (inicial), associação de paróquia.

### `splash_screen.dart`
*   **Propósito:** A tela inicial exibida quando a aplicação é iniciada, frequentemente usada para carregar recursos ou verificar o status de autenticação.
*   **Principais Funcionalidades:** Exibição da marca, indicador de carregamento.

### `statistics_screen.dart`
*   **Propósito:** Fornece insights estatísticos relacionados a escalas, voluntários e eventos.
*   **Principais Funcionalidades:** Gráficos, tabelas e resumos de dados (por exemplo, participação de voluntários, taxas de conclusão de escalas).
*   **Acesso:** Provavelmente para administradores e coordenadores.

### `volunteer_history_screen.dart`
*   **Propósito:** Exibe um histórico das atribuições e participação de um voluntário em escalas passadas.
*   **Principais Funcionalidades:** Lista de escalas passadas, métricas de desempenho.