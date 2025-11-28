# Esquemas

Esta seção detalha os esquemas de banco de dados e modelos de dados usados na aplicação 'Escala Missa UFMS', extraídos principalmente de `sq.sql`, que é um script de configuração abrangente.

## Esquema do Banco de Dados

### Enums

*   `perfil_enum`: Define os perfis de usuário: `admin`, `padre`, `secretario`, `coordenador`, `voluntario`, `fiel`.
*   `status_escala_enum`: Define o status de uma entrada de escala: `pendente`, `confirmado`, `cancelado`.

### Tabelas

1.  **`paroquias`**
    *   `id` (uuid, PRIMARY KEY, DEFAULT gen_random_uuid())
    *   `nome` (text, NOT NULL)
    *   `cidade` (text)
    *   `uf` (text)
    *   `ativa` (boolean, DEFAULT TRUE)
    *   `criado_em` (timestamptz, DEFAULT now())

2.  **`users`**
    *   `id` (uuid, PRIMARY KEY)
    *   `nome` (text, NOT NULL)
    *   `telefone` (text)
    *   `perfil` (`perfil_enum`, NOT NULL, DEFAULT 'fiel')
    *   `paroquia_id` (uuid, REFERENCES `public.paroquias(id)`)
    *   `fcm_token` (TEXT)
    *   `ativo` (boolean, DEFAULT TRUE)
    *   `criado_em` (timestamptz, DEFAULT now())

3.  **`pastorais`**
    *   `id` (uuid, PRIMARY KEY, DEFAULT gen_random_uuid())
    *   `paroquia_id` (uuid, NOT NULL, REFERENCES `public.paroquias(id)` ON DELETE CASCADE)
    *   `nome` (text, NOT NULL)
    *   `coordenador_id` (uuid, REFERENCES `public.users(id)`)
    *   `criado_em` (timestamptz, DEFAULT now())

4.  **`membros_pastoral`**
    *   `id` (uuid, PRIMARY KEY, DEFAULT gen_random_uuid())
    *   `pastoral_id` (uuid, NOT NULL, REFERENCES `public.pastorais(id)` ON DELETE CASCADE)
    *   `usuario_id` (uuid, NOT NULL, REFERENCES `public.users(id)` ON DELETE CASCADE)
    *   `funcao` (text)
    *   `criado_em` (timestamptz, DEFAULT now())
    *   `UNIQUE (pastoral_id, usuario_id)`

5.  **`funcoes`**
    *   `id` (uuid, PRIMARY KEY, DEFAULT gen_random_uuid())
    *   `nome` (text, NOT NULL)
    *   `descricao` (text)

6.  **`eventos`**
    *   `id` (uuid, PRIMARY KEY, DEFAULT gen_random_uuid())
    *   `paroquia_id` (uuid, NOT NULL, REFERENCES `public.paroquias(id)` ON DELETE CASCADE)
    *   `titulo` (text, DEFAULT 'Missa')
    *   `descricao` (text)
    *   `data_hora` (timestamptz, NOT NULL)
    *   `tempo_liturgico` (text)
    *   `solenidade` (text)
    *   `local` (text)
    *   `criado_por` (uuid, REFERENCES `public.users(id)`)
    *   `criado_em` (timestamptz, DEFAULT now())

7.  **`escalas`**
    *   `id` (uuid, PRIMARY KEY, DEFAULT gen_random_uuid())
    *   `paroquia_id` (uuid, NOT NULL, REFERENCES `public.paroquias(id)` ON DELETE CASCADE)
    *   `evento_id` (uuid, NOT NULL, REFERENCES `public.eventos(id)` ON DELETE CASCADE)
    *   `pastoral_id` (uuid, NOT NULL, REFERENCES `public.pastorais(id)` ON DELETE CASCADE)
    *   `funcao_id` (uuid, REFERENCES `public.funcoes(id)`)
    *   `voluntario_id` (uuid, REFERENCES `public.users(id)`)
    *   `status` (`status_escala_enum`, DEFAULT 'pendente')
    *   `observacao` (text)
    *   `criado_em` (timestamptz, DEFAULT now())

8.  **`disponibilidades`**
    *   `id` (uuid, PRIMARY KEY, DEFAULT gen_random_uuid())
    *   `usuario_id` (uuid, NOT NULL, REFERENCES `public.users(id)` ON DELETE CASCADE)
    *   `pastoral_id` (uuid, REFERENCES `public.pastorais(id)` ON DELETE SET NULL)
    *   `funcao_id` (uuid, REFERENCES `public.funcoes(id)` ON DELETE SET NULL)
    *   `dia` (date, NOT NULL)
    *   `hora` (time)
    *   `observacao` (text)
    *   `criado_em` (timestamptz, DEFAULT now())

9.  **`avisos`**
    *   `id` (uuid, PRIMARY KEY, DEFAULT gen_random_uuid())
    *   `paroquia_id` (uuid, NOT NULL, REFERENCES `public.paroquias(id)` ON DELETE CASCADE)
    *   `pastoral_id` (uuid, REFERENCES `public.pastorais(id)` ON DELETE SET NULL)
    *   `titulo` (text, NOT NULL)
    *   `mensagem` (text, NOT NULL)
    *   `criado_por` (uuid, REFERENCES `public.users(id)`)
    *   `criado_em` (timestamptz, DEFAULT now())

10. **`outbox_whatsapp`**
    *   `id` (uuid, PRIMARY KEY, DEFAULT gen_random_uuid())
    *   `usuario_id` (uuid, REFERENCES `public.users(id)` ON DELETE SET NULL)
    *   `telefone` (text)
    *   `mensagem` (text, NOT NULL)
    *   `payload` (jsonb)
    *   `scheduled_at` (timestamptz)
    *   `status` (text, DEFAULT 'pendente')
    *   `error` (text)
    *   `criado_em` (timestamptz, DEFAULT now())

## Views

1.  **`v_minha_agenda`**
    *   `evento_id`
    *   `data_hora`
    *   `titulo`
    *   `tempo_liturgico`
    *   `solenidade`
    *   `pastoral`
    *   `funcao`
    *   `status`
    *   `voluntario_id`

## Esquemas de API

(A ser preenchido com base nas interações da API, se houver)

## Modelos de Dados Locais

Esta seção descreve os modelos de dados Dart usados na aplicação, encontrados no diretório `lib/models`.

### Modelo `AppUser`

Corresponde à tabela `public.users`.

*   **`id`**: `String` (UUID)
*   **`nome`**: `String`
*   **`telefone`**: `String?`
*   **`perfil`**: `Perfil` enum (veja abaixo)
*   **`paroquiaId`**: `String?` (UUID, chave estrangeira para `Paroquia`)
*   **`fcmToken`**: `String?`

### Enum `Perfil`

Corresponde ao `perfil_enum` no banco de dados.

*   `admin`
*   `padre`
*   `secretario`
*   `coordenador`
*   `voluntario`
*   `fiel`

### Modelo `AppFunction`

Corresponde à tabela `public.funcoes`.

*   **`id`**: `String` (UUID)
*   **`name`**: `String` (mapeia para `nome` no BD)

### Modelo `Aviso`

Corresponde à tabela `public.avisos`.

*   **`id`**: `String?` (UUID)
*   **`paroquiaId`**: `String` (UUID, chave estrangeira para `Parish`)
*   **`pastoralId`**: `String?` (UUID, chave estrangeira para `Pastoral`)
*   **`titulo`**: `String`
*   **`mensagem`**: `String`
*   **`criadoPor`**: `String?` (UUID, chave estrangeira para `UserProfile`)
*   **`criadoEm`**: `DateTime?`
*   **`paroquia`**: `Parish?` (objeto aninhado)
*   **`pastoral`**: `Pastoral?` (objeto aninhado)
*   **`autor`**: `UserProfile?` (objeto aninhado)

### Modelo `Disponibilidade`

Corresponde à tabela `public.disponibilidades`.

*   **`id`**: `String?` (UUID)
*   **`usuarioId`**: `String` (UUID, chave estrangeira para `AppUser`)
*   **`pastoralId`**: `String?` (UUID, chave estrangeira para `Pastoral`)
*   **`pastoral`**: `Pastoral?` (objeto aninhado)
*   **`funcaoId`**: `String?` (UUID, chave estrangeira para `AppFunction`)
*   **`funcao`**: `AppFunction?` (objeto aninhado)
*   **`dia`**: `String` (YYYY-MM-DD)
*   **`hora`**: `String?` (HH:mm:ss)
*   **`observacao`**: `String?`

### Modelo `Escala`

Corresponde à tabela `public.escalas`.

*   **`id`**: `String?` (UUID)
*   **`eventId`**: `String` (UUID, chave estrangeira para `Evento`)
*   **`pastoralId`**: `String` (UUID, chave estrangeira para `Pastoral`)
*   **`functionId`**: `String` (UUID, chave estrangeira para `AppFunction`)
*   **`volunteerId`**: `String` (UUID, chave estrangeira para `UserProfile`)
*   **`paroquiaId`**: `String` (UUID, chave estrangeira para `Parish`)
*   **`status`**: `String` (mapeia para `status_escala_enum` no BD, padrão 'pendente')
*   **`observation`**: `String?`
*   **`evento`**: `Evento?` (objeto aninhado)
*   **`pastoral`**: `Pastoral?` (objeto aninhado)
*   **`funcao`**: `AppFunction?` (objeto aninhado)
*   **`voluntario`**: `UserProfile?` (objeto aninhado)

### Modelo `Evento`

Corresponde à tabela `public.eventos`.

*   **`id`**: `String` (UUID)
*   **`paroquiaId`**: `String` (UUID, chave estrangeira para `Parish`)
*   **`paroquia`**: `Parish?` (objeto aninhado)
*   **`titulo`**: `String`
*   **`descricao`**: `String?`
*   **`data_hora`**: `String` (string de DateTime)
*   **`local`**: `String?`
*   **`tempoLiturgico`**: `String?`
*   **`solenidade`**: `String?`

### Modelo `Parish`

Corresponde à tabela `public.paroquias`. Nota: Um modelo `Paroquia` simplificado também existe (em `paroquia.dart`) com apenas `id` e `nome`, provavelmente para casos de uso específicos ou por razões de legado.

*   **`id`**: `String?` (UUID)
*   **`nome`**: `String`
*   **`cidade`**: `String?`
*   **`uf`**: `String?`
*   **`isActive`**: `bool` (mapeia para `ativa` no BD, padrão `true`)

### Modelo `Pastoral`

Corresponde à tabela `public.pastorais`.

*   **`id`**: `String` (UUID)
*   **`nome`**: `String`
*   **`paroquiaId`**: `String` (UUID, chave estrangeira para `Parish`)
*   **`paroquia`**: `Parish?` (objeto aninhado)
*   **`coordenadorId`**: `String?` (UUID, chave estrangeira para `UserProfile`)
*   **`coordenador`**: `UserProfile?` (objeto aninhado)
*   **`ativa`**: `bool`

### Modelo `UserProfile`

Corresponde à tabela `public.users`. Este é um modelo de perfil de usuário mais geral, semelhante a `AppUser`, mas sem o `fcmToken`.

*   **`id`**: `String` (UUID)
*   **`nome`**: `String`
*   **`telefone`**: `String?`
*   **`perfil`**: `String` (mapeia para `perfil_enum` no BD)
*   **`paroquiaId`**: `String?` (UUID, chave estrangeira para `Parish`)
*   **`ativo`**: `bool`
*   **`criadoEm`**: `DateTime?`