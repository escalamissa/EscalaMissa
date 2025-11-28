# Criação do MVP

Este documento descreve o processo e as decisões tomadas durante a criação do Produto Mínimo Viável (MVP) para a aplicação 'Escala Missa UFMS'.

## Funcionalidades Principais

*   **Cadastro e Login com Perfis** (padre, secretário, coordenador, voluntário, fiel)
*   **Gestão de Escalas por Pastoral**
    1.  Acolhida, Acólitos/Coroinhas, Ministros, Liturgia, Dízimo, Música
    2.  Voluntários escolhem datas disponíveis
    3.  Coordenadores podem ajustar e confirmar escalas
*   **Notificações e Lembretes**
    *   Envio automático por push ou WhatsApp
*   **Agenda Litúrgica Integrada**
    1.  Ano, mês, dia, dia da semana, horário da missa
    2.  Tempo litúrgico e datas especiais
*   **Mural de Avisos e Comunicados**
    *   Reuniões, cursos, formações específicas por pastoral
*   **Relatórios**
    1.  Escalas por dia ou mês
    2.  Exportação em PDF ou imagem
*   **Web e Mobile** (PWA ou apps nativos)

## Resumo das Funcionalidades Principais

*   Cadastro de missas com data, horário e tempo litúrgico.
*   Gerenciamento das seis pastorais com membros e coordenadores.
*   Voluntários escolhem datas disponíveis para servir.
*   Coordenadores validam e ajustam escalas.
*   Relatórios mensais e diários das escalas.
*   Envio de lembretes automáticos e compartilhamento via WhatsApp.
*   Mural de avisos para cada pastoral.
*   Acesso segmentado por perfil (admin, coordenador, membro).

## Requisitos Funcionais (RF)

1.  O sistema deve permitir o cadastro de usuários com diferentes perfis.
2.  O sistema deve permitir o login autenticado por perfil.
3.  O sistema deve permitir o cadastro, edição e exclusão de eventos.
4.  O sistema deve exibir eventos conforme o perfil do usuário.
5.  O sistema deve gerar uma agenda personalizada para cada usuário.
6.  O sistema deve enviar notificações de lembrete para os eventos.
7.  O sistema deve permitir o controle de acesso por nível de permissão.
8.  O sistema deve possibilitar que os usuários visualizem suas escalas.

## Requisitos Não Funcionais (RNF)

1.  O sistema deve ser multiplataforma (Web e Mobile).
2.  O sistema deve ter uma interface intuitiva, responsiva e acessível.
3.  O sistema deve garantir segurança na autenticação e nos dados dos usuários.
4.  O sistema deve estar disponível 24 horas por dia.
5.  O sistema deve suportar conexões de internet instáveis.
6.  O sistema deve armazenar dados de forma segura.
7.  O sistema não requer integração com redes sociais.

## Regras de Negócio (RN)

1.  Usuários visualizam apenas eventos e escalas conforme sua função na paróquia.
2.  Notificações são enviadas automaticamente para eventos em que o usuário está envolvido.
3.  O cadastro de eventos só pode ser realizado por padres, secretários e coordenadores.
4.  Fiéis não podem editar ou criar eventos, apenas visualizar.

## Requisitos de Interface

A INTERFACE DO ESCALAMISSA DEVE SER MODERNA, ACESSÍVEL E INTUITIVA PARA GARANTIR A USABILIDADE POR TODOS OS PÚBLICOS, INDEPENDENTEMENTE DO NÍVEL DE FAMILIARIDADE COM TECNOLOGIA. Interface limpa, responsiva e amigável para diferentes dispositivos.