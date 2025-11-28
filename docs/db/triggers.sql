--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  begin
    insert into public.users (id, nome, perfil)
    values (new.id, new.email, 'fiel');
    return new;
  end;
  $$;
