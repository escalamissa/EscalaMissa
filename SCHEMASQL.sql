-- =========================
-- EXTENSIONS
-- =========================
create extension if not exists "pgcrypto";
create extension if not exists "uuid-ossp";

-- =========================
-- ENUMS
-- =========================
do $$
begin
  if not exists (select 1 from pg_type where typname = 'perfil_enum') then
    create type perfil_enum as enum ('admin','padre','secretario','coordenador','voluntario','fiel');
  end if;
  if not exists (select 1 from pg_type where typname = 'status_escala_enum') then
    create type status_escala_enum as enum ('pendente','confirmado','cancelado');
  end if;
end$$;

-- =========================
-- TABELAS PRINCIPAIS
-- =========================

create table if not exists public.paroquias (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  cidade text,
  uf text,
  ativa boolean default true,
  criado_em timestamptz default now()
);

create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  nome text not null,
  telefone text,
  perfil perfil_enum not null default 'fiel',
  paroquia_id uuid references public.paroquias(id),
  ativo boolean default true,
  criado_em timestamptz default now()
);

create table if not exists public.pastorais (
  id uuid primary key default gen_random_uuid(),
  paroquia_id uuid not null references public.paroquias(id) on delete cascade,
  nome text not null,
  coordenador_id uuid references public.users(id),
  criado_em timestamptz default now()
);

create table if not exists public.membros_pastoral (
  id uuid primary key default gen_random_uuid(),
  pastoral_id uuid not null references public.pastorais(id) on delete cascade,
  usuario_id uuid not null references public.users(id) on delete cascade,
  funcao text,
  criado_em timestamptz default now(),
  unique (pastoral_id, usuario_id)
);

create table if not exists public.funcoes (
  id uuid primary key default gen_random_uuid(),
  nome text not null,
  descricao text
);

create table if not exists public.eventos (
  id uuid primary key default gen_random_uuid(),
  paroquia_id uuid not null references public.paroquias(id) on delete cascade,
  titulo text default 'Missa',
  descricao text,
  data_hora timestamptz not null,
  tempo_liturgico text,
  solenidade text,
  local text,
  criado_por uuid references public.users(id),
  criado_em timestamptz default now()
);

create table if not exists public.escalas (
  id uuid primary key default gen_random_uuid(),
  evento_id uuid not null references public.eventos(id) on delete cascade,
  pastoral_id uuid not null references public.pastorais(id) on delete cascade,
  funcao_id uuid references public.funcoes(id),
  voluntario_id uuid references public.users(id),
  status status_escala_enum default 'pendente',
  observacao text,
  criado_em timestamptz default now()
);

create table if not exists public.disponibilidades (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid not null references public.users(id) on delete cascade,
  pastoral_id uuid references public.pastorais(id) on delete set null,
  funcao_id uuid references public.funcoes(id) on delete set null,
  dia date not null,
  hora time,
  observacao text,
  criado_em timestamptz default now()
);

create table if not exists public.avisos (
  id uuid primary key default gen_random_uuid(),
  paroquia_id uuid not null references public.paroquias(id) on delete cascade,
  pastoral_id uuid references public.pastorais(id) on delete set null,
  titulo text not null,
  mensagem text not null,
  criado_por uuid references public.users(id),
  criado_em timestamptz default now()
);

create table if not exists public.outbox_whatsapp (
  id uuid primary key default gen_random_uuid(),
  usuario_id uuid references public.users(id) on delete set null,
  telefone text,
  mensagem text not null,
  payload jsonb,
  scheduled_at timestamptz,
  status text default 'pendente',
  error text,
  criado_em timestamptz default now()
);

-- =========================
-- FUNÇÕES AUXILIARES
-- =========================

create or replace function public.meu_perfil()
returns perfil_enum
language sql
stable
security definer
as $$
  select coalesce(
    (select u.perfil
     from public.users u
     where u.id = auth.uid()
     limit 1),
    'fiel'::perfil_enum
  );
$$;

create or replace function public.mesma_paroquia(po uuid)
returns boolean
language sql stable
as $$
  select exists (
    select 1
    from public.users u
    where u.id = auth.uid()
      and u.paroquia_id = po
  );
$$;

create or replace function public.eh_admin()
returns boolean
language sql stable
as $$ select public.meu_perfil() = 'admin'::perfil_enum; $$;

create or replace function public.eh_padre()
returns boolean
language sql stable
as $$ select public.meu_perfil() = 'padre'::perfil_enum; $$;

create or replace function public.eh_coord()
returns boolean
language sql stable
as $$ select public.meu_perfil() = 'coordenador'::perfil_enum; $$;

create or replace function public.eh_secretario()
returns boolean
language sql stable
as $$ select public.meu_perfil() = 'secretario'::perfil_enum; $$;

-- =========================
-- VIEW
-- =========================

create or replace view public.v_minha_agenda as
select
  e.id as evento_id,
  e.data_hora,
  e.titulo,
  e.tempo_liturgico,
  e.solenidade,
  p.nome as pastoral,
  f.nome as funcao,
  es.status,
  es.voluntario_id
from public.escalas es
join public.eventos e on e.id = es.evento_id
join public.pastorais p on p.id = es.pastoral_id
left join public.funcoes f on f.id = es.funcao_id;

-- =========================
-- ÍNDICES
-- =========================

create index if not exists idx_eventos_paroquia_data on public.eventos(paroquia_id, data_hora);
create index if not exists idx_escalas_evento on public.escalas(evento_id);
create index if not exists idx_dispon_user_dia on public.disponibilidades(usuario_id, dia);
create index if not exists idx_avisos_paroquia_data on public.avisos(paroquia_id, criado_em desc);

-- =========================
-- RLS ENABLE
-- =========================
alter table public.paroquias enable row level security;
alter table public.users enable row level security;
alter table public.pastorais enable row level security;
alter table public.membros_pastoral enable row level security;
alter table public.funcoes enable row level security;
alter table public.eventos enable row level security;
alter table public.escalas enable row level security;
alter table public.disponibilidades enable row level security;
alter table public.avisos enable row level security;
alter table public.outbox_whatsapp enable row level security;

-- =========================
-- POLICIES
-- =========================

-- PARÓQUIAS
create policy "paroquias_select_all" on public.paroquias
for select to authenticated, anon
using (true);

create policy "paroquias_admin_crud" on public.paroquias
for all to authenticated
using (eh_admin()) with check (eh_admin());

-- USERS
create policy "users_select_self" on public.users
for select to authenticated
using (id = auth.uid() or eh_admin() or eh_coord());

create policy "users_update_self" on public.users
for update to authenticated
using (id = auth.uid() or eh_admin())
with check (id = auth.uid() or eh_admin());

create policy "users_insert_admin" on public.users
for insert to authenticated
with check (eh_admin());

-- PASTORAIS
create policy "pastorais_select_scope" on public.pastorais
for select to authenticated
using (mesma_paroquia(paroquia_id) or eh_admin());

create policy "pastorais_crud_coord_admin" on public.pastorais
for all to authenticated
using (eh_admin() or (eh_coord() and mesma_paroquia(paroquia_id)))
with check (eh_admin() or (eh_coord() and mesma_paroquia(paroquia_id)));

-- MEMBROS
create policy "membros_select_scope" on public.membros_pastoral
for select to authenticated
using (exists (
  select 1 from public.pastorais p
  where p.id = membros_pastoral.pastoral_id
  and (mesma_paroquia(p.paroquia_id) or eh_admin())
));

create policy "membros_crud_coord_admin" on public.membros_pastoral
for all to authenticated
using (eh_admin() or (eh_coord() and exists (
  select 1 from public.pastorais p
  where p.id = membros_pastoral.pastoral_id
  and mesma_paroquia(p.paroquia_id)
)))
with check (eh_admin() or (eh_coord() and exists (
  select 1 from public.pastorais p
  where p.id = membros_pastoral.pastoral_id
  and mesma_paroquia(p.paroquia_id)
)));

-- FUNÇÕES
create policy "funcoes_select_all" on public.funcoes
for select to authenticated
using (true);

create policy "funcoes_admin_crud" on public.funcoes
for all to authenticated
using (eh_admin()) with check (eh_admin());

-- EVENTOS
create policy "eventos_select_scope" on public.eventos
for select to authenticated
using (mesma_paroquia(paroquia_id) or eh_admin() or eh_secretario() or eh_padre());

create policy "eventos_crud_admin_coord_secr" on public.eventos
for all to authenticated
using (eh_admin() or eh_padre() or (eh_coord() and mesma_paroquia(paroquia_id)) or (eh_secretario() and mesma_paroquia(paroquia_id)))
with check (eh_admin() or eh_padre() or (eh_coord() and mesma_paroquia(paroquia_id)) or (eh_secretario() and mesma_paroquia(paroquia_id)));

-- ESCALAS
create policy "escalas_select_scope" on public.escalas
for select to authenticated
using (exists (
  select 1 from public.eventos ev
  where ev.id = escalas.evento_id
  and (mesma_paroquia(ev.paroquia_id) or eh_admin() or eh_padre())
));

create policy "escalas_insert_coord_admin" on public.escalas
for insert to authenticated
with check (exists (
  select 1 from public.eventos ev
  where ev.id = escalas.evento_id
  and (eh_admin() or eh_padre() or (eh_coord() and mesma_paroquia(ev.paroquia_id)))
));

create policy "escalas_update_coord_admin_or_self" on public.escalas
for update to authenticated
using (
  voluntario_id = auth.uid()
  or exists (
    select 1 from public.eventos ev
    where ev.id = escalas.evento_id
    and (eh_admin() or eh_padre() or (eh_coord() and mesma_paroquia(ev.paroquia_id)))
  )
)
with check (
  voluntario_id = auth.uid()
  or exists (
    select 1 from public.eventos ev
    where ev.id = escalas.evento_id
    and (eh_admin() or eh_padre() or (eh_coord() and mesma_paroquia(ev.paroquia_id)))
  )
);

-- DISPONIBILIDADES
create policy "disp_select_self_or_coord" on public.disponibilidades
for select to authenticated
using (
  usuario_id = auth.uid()
  or (eh_admin() or eh_coord() or eh_secretario())
);

create policy "disp_insert_update_self" on public.disponibilidades
for insert to authenticated
with check (usuario_id = auth.uid());

create policy "disp_update_self" on public.disponibilidades
for update to authenticated
using (usuario_id = auth.uid())
with check (usuario_id = auth.uid());

-- AVISOS
create policy "avisos_select_scope" on public.avisos
for select to authenticated
using (mesma_paroquia(paroquia_id) or eh_admin());

create policy "avisos_crud_admin_coord" on public.avisos
for all to authenticated
using (eh_admin() or (eh_coord() and mesma_paroquia(paroquia_id)))
with check (eh_admin() or (eh_coord() and mesma_paroquia(paroquia_id)));

-- OUTBOX WHATSAPP
create policy "outbox_select_admin_coord_self" on public.outbox_whatsapp
for select to authenticated
using (
  eh_admin() or (usuario_id = auth.uid())
);

revoke insert, update, delete on public.outbox_whatsapp from authenticated, anon;
