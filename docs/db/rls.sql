--
-- Name: eh_admin(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.eh_admin() RETURNS boolean
    LANGUAGE sql STABLE
    AS $$ SELECT public.meu_perfil() = 'admin'::perfil_enum; $$;


--
-- Name: eh_coord(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.eh_coord() RETURNS boolean
    LANGUAGE sql STABLE
    AS $$ SELECT public.meu_perfil() = 'coordenador'::perfil_enum; $$;


--
-- Name: eh_padre(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.eh_padre() RETURNS boolean
    LANGUAGE sql STABLE
    AS $$ SELECT public.meu_perfil() = 'padre'::perfil_enum; $$;


--
-- Name: eh_secretario(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.eh_secretario() RETURNS boolean
    LANGUAGE sql STABLE
    AS $$ SELECT public.meu_perfil() = 'secretario'::perfil_enum; $$;


--
-- Name: eh_voluntario(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.eh_voluntario() RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
    select exists(select 1 from public.users u where u.id = auth.uid() and u.perfil = 'voluntario')
  $$;


--
-- Name: mesma_paroquia(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mesma_paroquia(po uuid) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  SELECT EXISTS (SELECT 1 FROM public.users u WHERE u.id = auth.uid() AND u.paroquia_id = po);
$$;


--
-- Name: meu_perfil(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.meu_perfil() RETURNS public.perfil_enum
    LANGUAGE sql STABLE SECURITY DEFINER
    AS $$
  SELECT coalesce((SELECT u.perfil FROM public.users u WHERE u.id = auth.uid() LIMIT 1), 'fiel'::perfil_enum);
$$;


--
-- Name: minha_paroquia(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.minha_paroquia() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
    select paroquia_id from public.users where id = auth.uid()
  $$;


--
-- Name: minha_paroquia_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.minha_paroquia_id() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$ select paroquia_id from public.users where id = auth.uid() limit 1; $$;


--
-- Name: escalas Admins podem atualizar escalas; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins podem atualizar escalas" ON public.escalas FOR UPDATE USING ((public.eh_admin() OR public.eh_padre() OR (public.eh_coord() AND public.mesma_paroquia(paroquia_id)))) WITH CHECK ((public.eh_admin() OR public.eh_padre() OR (public.eh_coord() AND public.mesma_paroquia(paroquia_id))));


--
-- Name: escalas Voluntários podem atualizar suas próprias escalas; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Voluntários podem atualizar suas próprias escalas" ON public.escalas FOR UPDATE USING ((voluntario_id = auth.uid())) WITH CHECK ((voluntario_id = auth.uid()));


--
-- Name: avisos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.avisos ENABLE ROW LEVEL SECURITY;

--
-- Name: avisos avisos_crud_admin_coord; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY avisos_crud_admin_coord ON public.avisos USING ((public.eh_admin() OR (public.eh_coord() AND public.mesma_paroquia(paroquia_id)))) WITH CHECK ((public.eh_admin() OR (public.eh_coord() AND public.mesma_paroquia(paroquia_id))));


--
-- Name: avisos avisos_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY avisos_select_all ON public.avisos FOR SELECT TO authenticated USING (true);


--
-- Name: avisos avisos_select_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY avisos_select_scope ON public.avisos FOR SELECT USING ((public.mesma_paroquia(paroquia_id) OR public.eh_admin()));


--
-- Name: disponibilidades disp_select_self_or_coord; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY disp_select_self_or_coord ON public.disponibilidades FOR SELECT USING (((usuario_id = auth.uid()) OR public.eh_admin() OR public.eh_coord() OR public.eh_secretario()));


--
-- Name: disponibilidades disp_update_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY disp_update_self ON public.disponibilidades USING ((usuario_id = auth.uid())) WITH CHECK ((usuario_id = auth.uid()));


--
-- Name: disponibilidades; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.disponibilidades ENABLE ROW LEVEL SECURITY;

--
-- Name: disponibilidades disponibilidades_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY disponibilidades_select_all ON public.disponibilidades FOR SELECT TO authenticated USING (true);


--
-- Name: escalas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.escalas ENABLE ROW LEVEL SECURITY;

--
-- Name: escalas escalas_crud_scoped; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY escalas_crud_scoped ON public.escalas USING (((voluntario_id = auth.uid()) OR public.eh_admin() OR public.eh_padre() OR (public.eh_coord() AND public.mesma_paroquia(paroquia_id)))) WITH CHECK ((public.eh_admin() OR public.eh_padre() OR (public.eh_coord() AND public.mesma_paroquia(paroquia_id))));


--
-- Name: escalas escalas_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY escalas_select_all ON public.escalas FOR SELECT TO authenticated USING (true);


--
-- Name: escalas escalas_select_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY escalas_select_scope ON public.escalas FOR SELECT USING ((public.mesma_paroquia(paroquia_id) OR public.eh_admin()));


--
-- Name: eventos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.eventos ENABLE ROW LEVEL SECURITY;

--
-- Name: eventos eventos_crud_scoped; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY eventos_crud_scoped ON public.eventos USING ((public.eh_admin() OR public.eh_padre() OR (public.eh_coord() AND public.mesma_paroquia(paroquia_id)) OR (public.eh_secretario() AND public.mesma_paroquia(paroquia_id)))) WITH CHECK ((public.eh_admin() OR public.eh_padre() OR (public.eh_coord() AND public.mesma_paroquia(paroquia_id)) OR (public.eh_secretario() AND public.mesma_paroquia(paroquia_id))));


--
-- Name: eventos eventos_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY eventos_select_all ON public.eventos FOR SELECT TO authenticated USING (true);


--
-- Name: eventos eventos_select_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY eventos_select_scope ON public.eventos FOR SELECT USING ((public.mesma_paroquia(paroquia_id) OR public.eh_admin()));


--
-- Name: funcoes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.funcoes ENABLE ROW LEVEL SECURITY;

--
-- Name: funcoes funcoes_admin_crud; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY funcoes_admin_crud ON public.funcoes USING (public.eh_admin()) WITH CHECK (public.eh_admin());


--
-- Name: funcoes funcoes_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY funcoes_select_all ON public.funcoes FOR SELECT USING (true);


--
-- Name: membros_pastoral; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.membros_pastoral ENABLE ROW LEVEL SECURITY;

--
-- Name: membros_pastoral membros_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY membros_select_all ON public.membros_pastoral FOR SELECT TO authenticated USING (true);


--
-- Name: membros_pastoral membros_select_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY membros_select_scope ON public.membros_pastoral FOR SELECT USING ((EXISTS ( SELECT 1
   FROM public.pastorais p
  WHERE ((p.id = membros_pastoral.pastoral_id) AND public.mesma_paroquia(p.paroquia_id)))));


--
-- Name: paroquias; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.paroquias ENABLE ROW LEVEL SECURITY;

--
-- Name: paroquias paroquias_admin_crud; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY paroquias_admin_crud ON public.paroquias USING (public.eh_admin()) WITH CHECK (public.eh_admin());


--
-- Name: paroquias paroquias_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY paroquias_select_all ON public.paroquias FOR SELECT USING (true);


--
-- Name: pastorais; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.pastorais ENABLE ROW LEVEL SECURITY;

--
-- Name: pastorais pastorais_crud_coord_admin; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY pastorais_crud_coord_admin ON public.pastorais USING ((public.eh_admin() OR ((public.eh_coord() OR public.eh_padre()) AND public.mesma_paroquia(paroquia_id)))) WITH CHECK ((public.eh_admin() OR ((public.eh_coord() OR public.eh_padre()) AND public.mesma_paroquia(paroquia_id))));


--
-- Name: pastorais pastorais_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY pastorais_select_all ON public.pastorais FOR SELECT TO authenticated USING (true);


--
-- Name: pastorais pastorais_select_scope; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY pastorais_select_scope ON public.pastorais FOR SELECT USING ((public.mesma_paroquia(paroquia_id) OR public.eh_admin()));


--
-- Name: users; Type: ROW SECURITY; Schema: public; public; Owner: -
--

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

--
-- Name: users users_select_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_select_all ON public.users FOR SELECT TO authenticated USING (true);


--
-
-- Name: users users_select_self_and_scoped; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_select_self_and_scoped ON public.users FOR SELECT USING (((id = auth.uid()) OR public.eh_admin() OR ((public.eh_coord() OR public.eh_padre() OR public.eh_secretario()) AND public.mesma_paroquia(paroquia_id))));


--
-- Name: users users_update_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY users_update_self ON public.users FOR UPDATE USING ((id = auth.uid())) WITH CHECK ((id = auth.uid()));
