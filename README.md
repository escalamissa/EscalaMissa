# 📅 EscalaMissa

**EscalaMissa** é um sistema Web e Mobile voltado à organização de escalas e eventos religiosos no Santuário de Nossa Senhora Auxiliadora, em Corumbá/MS. A aplicação visa digitalizar e simplificar a gestão das atividades das pastorais, melhorando a comunicação e o engajamento dos voluntários.

## 🧭 Visão Geral

A organização das missas exige a atuação de diversas pastorais (acolhida, acólitos/coroinhas, ministros da comunhão, liturgia, dízimo e músicos). O EscalaMissa surge como uma solução para:

- Reduzir a desorganização causada pelo uso de WhatsApp.
- Evitar esquecimentos e falhas na escala de voluntários.
- Centralizar comunicação, eventos e escalas em um só lugar.

## 👤 Perfis de Usuários

- **Padre**: Aprova escalas e eventos.
- **Secretário**: Gerencia a agenda geral da igreja.
- **Coordenador**: Cria e organiza escalas das pastorais.
- **Voluntário**: Escolhe datas disponíveis e acompanha onde está escalado.
- **Fiel**: Visualiza agenda e eventos da paróquia.

## ✅ Funcionalidades Principais

- Cadastro e autenticação por perfil
- Visualização e seleção de datas disponíveis para serviço
- Criação e edição de eventos
- Escalas por pastoral e função
- Notificações automáticas e lembretes
- Relatórios mensais e diários
- Mural de comunicados e formações
- Exportação de escalas em imagem ou PDF
- Acesso multiplataforma (Web e Mobile)

## 🎯 Requisitos de Interface

- Interface limpa, intuitiva e responsiva
- Tela inicial com resumo da agenda pessoal
- Menu de navegação com:
  - Agenda
  - Escalas
  - Eventos Gerais
- Notificações visíveis para eventos e mudanças de escala

## 🗂️ Requisitos de Dados

- Cadastro de usuários (nome, e-mail, telefone, perfil)
- Cadastro de eventos (nome, data, local, descrição, responsáveis)
- Histórico de eventos passados e futuros
- Dados armazenados em nuvem com acesso via Web e Mobile

## 🚫 Restrições

- Projeto acadêmico com equipe de estudantes
- Recursos financeiros e técnicos limitados
- Prazo condicionado ao calendário acadêmico
- Não há previsão de integração com redes sociais

## 🛠️ Stack Tecnológico (Sugerido)

> A ser confirmado com a equipe, uma sugestão:
- Frontend: EXPO GO + REACT NATIVE
- Backend: Node.js (Express)
- Banco de Dados: Supabase / POSTGREE
- Autenticação: Supabase Auth ou JWT
- Notificações: Firebase Cloud Messaging ou integração com WhatsApp API

## 📌 Status

🚧 Em desenvolvimento inicial – Definição de escopo, prototipação e setup do projeto.

---
## SUPABASE - SQL 
Extensões e tipos (ENUMs)

Tabelas principais

Funções auxiliares (roles helpers)

View (agenda pessoal)

Índices

RLS enable

Policies (por perfil: padre, secretário, coordenador, voluntário, fiel)

Desenvolvido por **Equipe Pythaneiros** – Curso de Sistemas de Informação, 2025.
