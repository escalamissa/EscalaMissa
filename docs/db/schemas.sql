--
-- PostgreSQL database dump
--

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: perfil_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.perfil_enum AS ENUM (
    'admin',
    'padre',
    'secretario',
    'coordenador',
    'voluntario',
    'fiel'
);


--
-- Name: status_escala_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.status_escala_enum AS ENUM (
    'pendente',
    'confirmado',
    'cancelado'
);

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: avisos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.avisos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    paroquia_id uuid NOT NULL,
    pastoral_id uuid,
    titulo text NOT NULL,
    mensagem text NOT NULL,
    criado_por uuid,
    criado_em timestamp with time zone DEFAULT now()
);


--
-- Name: disponibilidades; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disponibilidades (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    usuario_id uuid NOT NULL,
    pastoral_id uuid,
    funcao_id uuid,
    dia date NOT NULL,
    hora time without time zone,
    observacao text,
    criado_em timestamp with time zone DEFAULT now()
);


--
-- Name: escalas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.escalas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    paroquia_id uuid NOT NULL,
    evento_id uuid NOT NULL,
    pastoral_id uuid NOT NULL,
    funcao_id uuid,
    voluntario_id uuid,
    status public.status_escala_enum DEFAULT 'pendente'::public.status_escala_enum,
    observacao text,
    criado_em timestamp with time zone DEFAULT now()
);


--
-- Name: eventos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.eventos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    paroquia_id uuid NOT NULL,
    titulo text DEFAULT 'Missa'::text,
    descricao text,
    data_hora timestamp with time zone NOT NULL,
    tempo_liturgico text,
    solenidade text,
    local text,
    criado_por uuid,
    criado_em timestamp with time zone DEFAULT now()
);


--
-- Name: funcoes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.funcoes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    descricao text
);


--
-- Name: membros_pastoral; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.membros_pastoral (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    pastoral_id uuid NOT NULL,
    usuario_id uuid NOT NULL,
    funcao text,
    criado_em timestamp with time zone DEFAULT now()
);


--
-- Name: paroquias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paroquias (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nome text NOT NULL,
    cidade text,
    uf text,
    ativa boolean DEFAULT true,
    criado_em timestamp with time zone DEFAULT now()
);


--
-- Name: pastorais; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pastorais (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    paroquia_id uuid NOT NULL,
    nome text NOT NULL,
    coordenador_id uuid,
    criado_em timestamp with time zone DEFAULT now()
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid NOT NULL,
    nome text NOT NULL,
    telefone text,
    perfil public.perfil_enum DEFAULT 'fiel'::public.perfil_enum NOT NULL,
    paroquia_id uuid,
    ativo boolean DEFAULT true,
    criado_em timestamp with time zone DEFAULT now(),
    fcm_token text
);


--
-- Name: avisos avisos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avisos
    ADD CONSTRAINT avisos_pkey PRIMARY KEY (id);


--
-- Name: disponibilidades disponibilidades_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disponibilidades
    ADD CONSTRAINT disponibilidades_pkey PRIMARY KEY (id);


--
-- Name: escalas escalas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.escalas
    ADD CONSTRAINT escalas_pkey PRIMARY KEY (id);


--
-- Name: eventos eventos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eventos
    ADD CONSTRAINT eventos_pkey PRIMARY KEY (id);


--
-- Name: funcoes funcoes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.funcoes
    ADD CONSTRAINT funcoes_pkey PRIMARY KEY (id);


--
-- Name: membros_pastoral membros_pastoral_pastoral_id_usuario_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membros_pastoral
    ADD CONSTRAINT membros_pastoral_pastoral_id_usuario_id_key UNIQUE (pastoral_id, usuario_id);


--
-- Name: membros_pastoral membros_pastoral_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membros_pastoral
    ADD CONSTRAINT membros_pastoral_pkey PRIMARY KEY (id);


--
-- Name: paroquias paroquias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paroquias
    ADD CONSTRAINT paroquias_pkey PRIMARY KEY (id);


--
-- Name: pastorais pastorais_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pastorais
    ADD CONSTRAINT pastorais_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: idx_users_fcm_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_users_fcm_token ON public.users USING btree (fcm_token);


--
-- Name: avisos avisos_criado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avisos
    ADD CONSTRAINT avisos_criado_por_fkey FOREIGN KEY (criado_por) REFERENCES public.users(id);


--
-- Name: avisos avisos_paroquia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avisos
    ADD CONSTRAINT avisos_paroquia_id_fkey FOREIGN KEY (paroquia_id) REFERENCES public.paroquias(id) ON DELETE CASCADE;


--
-- Name: avisos avisos_pastoral_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.avisos
    ADD CONSTRAINT avisos_pastoral_id_fkey FOREIGN KEY (pastoral_id) REFERENCES public.pastorais(id) ON DELETE SET NULL;


--
-- Name: disponibilidades disponibilidades_funcao_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disponibilidades
    ADD CONSTRAINT disponibilidades_funcao_id_fkey FOREIGN KEY (funcao_id) REFERENCES public.funcoes(id) ON DELETE SET NULL;


--
-- Name: disponibilidades disponibilidades_pastoral_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disponibilidades
    ADD CONSTRAINT disponibilidades_pastoral_id_fkey FOREIGN KEY (pastoral_id) REFERENCES public.pastorais(id) ON DELETE SET NULL;


--
-- Name: disponibilidades disponibilidades_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disponibilidades
    ADD CONSTRAINT disponibilidades_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: escalas escalas_evento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.escalas
    ADD CONSTRAINT escalas_evento_id_fkey FOREIGN KEY (evento_id) REFERENCES public.eventos(id) ON DELETE CASCADE;


--
-- Name: escalas escalas_funcao_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.escalas
    ADD CONSTRAINT escalas_funcao_id_fkey FOREIGN KEY (funcao_id) REFERENCES public.funcoes(id) ON DELETE SET NULL;


--
-- Name: escalas escalas_paroquia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.escalas
    ADD CONSTRAINT escalas_paroquia_id_fkey FOREIGN KEY (paroquia_id) REFERENCES public.paroquias(id) ON DELETE CASCADE;


--
-- Name: escalas escalas_pastoral_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.escalas
    ADD CONSTRAINT escalas_pastoral_id_fkey FOREIGN KEY (pastoral_id) REFERENCES public.pastorais(id) ON DELETE CASCADE;


--
-- Name: escalas escalas_voluntario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.escalas
    ADD CONSTRAINT escalas_voluntario_id_fkey FOREIGN KEY (voluntario_id) REFERENCES public.users(id);


--
-- Name: eventos eventos_criado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eventos
    ADD CONSTRAINT eventos_criado_por_fkey FOREIGN KEY (criado_por) REFERENCES public.users(id);


--
-- Name: eventos eventos_paroquia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.eventos
    ADD CONSTRAINT eventos_paroquia_id_fkey FOREIGN KEY (paroquia_id) REFERENCES public.paroquias(id) ON DELETE CASCADE;


--
-- Name: membros_pastoral membros_pastoral_pastoral_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membros_pastoral
    ADD CONSTRAINT membros_pastoral_pastoral_id_fkey FOREIGN KEY (pastoral_id) REFERENCES public.pastorais(id) ON DELETE CASCADE;


--
-- Name: membros_pastoral membros_pastoral_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.membros_pastoral
    ADD CONSTRAINT membros_pastoral_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: pastorais pastorais_coordenador_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pastorais
    ADD CONSTRAINT pastorais_coordenador_id_fkey FOREIGN KEY (coordenador_id) REFERENCES public.users(id);


--
-- Name: pastorais pastorais_paroquia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pastorais
    ADD CONSTRAINT pastorais_paroquia_id_fkey FOREIGN KEY (paroquia_id) REFERENCES public.paroquias(id) ON DELETE CASCADE;


--
-- Name: users users_paroquia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_paroquia_id_fkey FOREIGN KEY (paroquia_id) REFERENCES public.paroquias(id);

