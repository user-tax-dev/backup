--
-- PostgreSQL database dump
--


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
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
-- Name: upsert_password_hash(bigint, bigint, bigint, bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.upsert_password_hash(oid bigint, ctime bigint, mail_id bigint, password_hash bytea) RETURNS void
    LANGUAGE plpgsql
    AS $$
Declare
pre_id bigint;
pre_ctime bigint;
pre_password_hash md5hash;
BEGIN

SELECT id,mail_user.ctime,mail_user.password_hash INTO pre_id,pre_ctime,pre_password_hash FROM mail_user WHERE mail_user.oid=upsert_password_hash.oid and mail_user.mail_id=upsert_password_hash.mail_id;
 
IF pre_id > 0 THEN
  IF ctime > pre_ctime THEN
    INSERT INTO mail_user_log (oid,ctime,mail_id,password_hash) VALUES (oid,pre_ctime,mail_id,pre_password_hash);
    UPDATE mail_user SET password_hash=upsert_password_hash.password_hash,ctime=upsert_password_hash.ctime WHERE id=pre_id;
  END IF;
ELSE
  INSERT INTO mail_user (oid,ctime,mail_id,password_hash) VALUES (oid,ctime,mail_id,password_hash);
END IF;

END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: mail_user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mail_user (
    id bigint NOT NULL,
    oid bigint NOT NULL,
    ctime bigint NOT NULL,
    mail_id bigint NOT NULL,
    password_hash public.md5hash NOT NULL
);


--
-- Name: mail_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mail_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mail_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mail_user_id_seq OWNED BY public.mail_user.id;


--
-- Name: mail_user_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mail_user_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mail_user_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mail_user_log (
    id bigint DEFAULT nextval('public.mail_user_log_id_seq'::regclass) NOT NULL,
    oid bigint NOT NULL,
    ctime bigint NOT NULL,
    mail_id bigint NOT NULL,
    password_hash public.md5hash NOT NULL
);


--
-- Name: mail_user id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_user ALTER COLUMN id SET DEFAULT nextval('public.mail_user_id_seq'::regclass);


--
-- Name: mail_user mail_user.oid.mail_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_user
    ADD CONSTRAINT "mail_user.oid.mail_id" UNIQUE (oid, mail_id);


--
-- Name: mail_user_log mail_user_bak_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_user_log
    ADD CONSTRAINT mail_user_bak_pkey PRIMARY KEY (id);


--
-- Name: mail_user mail_user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mail_user
    ADD CONSTRAINT mail_user_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

