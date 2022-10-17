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

CREATE SCHEMA IF NOT EXIST public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: client_ip; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.client_ip (
    id public.u64 NOT NULL,
    client_id public.u64 NOT NULL,
    ip bytea NOT NULL,
    ctime public.u64 DEFAULT date_part('epoch'::text, now()) NOT NULL
);


--
-- Name: client_ip_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.client_ip_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_ip_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.client_ip_id_seq OWNED BY public.client_ip.id;


--
-- Name: user_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_log (
    id public.u64 NOT NULL,
    oid public.u64 NOT NULL,
    action public.u16 NOT NULL,
    uid public.u64 NOT NULL,
    val bytea DEFAULT '\x'::bytea NOT NULL,
    ctime public.u64 DEFAULT date_part('epoch'::text, now()) NOT NULL,
    client_id public.u64 NOT NULL
);


--
-- Name: user_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_log_id_seq OWNED BY public.user_log.id;


--
-- Name: user_mail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_mail (
    id public.u64 NOT NULL,
    oid public.u64 NOT NULL,
    uid public.u64 NOT NULL,
    mail_id public.u64 NOT NULL
);


--
-- Name: user_mail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_mail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_mail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_mail_id_seq OWNED BY public.user_mail.id;


--
-- Name: user_password; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_password (
    id public.u64 NOT NULL,
    oid public.u64 NOT NULL,
    uid public.u64 NOT NULL,
    hash public.md5hash NOT NULL,
    ctime public.u64 NOT NULL
);


--
-- Name: user_password_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_password_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_password_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_password_id_seq OWNED BY public.user_password.id;


--
-- Name: client_ip id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_ip ALTER COLUMN id SET DEFAULT nextval('public.client_ip_id_seq'::regclass);


--
-- Name: user_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_log ALTER COLUMN id SET DEFAULT nextval('public.user_log_id_seq'::regclass);


--
-- Name: user_mail id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_mail ALTER COLUMN id SET DEFAULT nextval('public.user_mail_id_seq'::regclass);


--
-- Name: user_password id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_password ALTER COLUMN id SET DEFAULT nextval('public.user_password_id_seq'::regclass);


--
-- Name: client_ip client_ip_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_ip
    ADD CONSTRAINT client_ip_pkey PRIMARY KEY (id);


--
-- Name: user_log user_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_log
    ADD CONSTRAINT user_log_pkey PRIMARY KEY (id);


--
-- Name: client_ip user_mail.ip.ctime; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.client_ip
    ADD CONSTRAINT "user_mail.ip.ctime" UNIQUE (ip, ctime);


--
-- Name: user_mail user_mail.oid.mail_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_mail
    ADD CONSTRAINT "user_mail.oid.mail_id" UNIQUE (oid, mail_id);


--
-- Name: user_password user_mail.oid.uid; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_password
    ADD CONSTRAINT "user_mail.oid.uid" UNIQUE (oid, uid);


--
-- Name: user_mail user_mail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_mail
    ADD CONSTRAINT user_mail_pkey PRIMARY KEY (id);


--
-- Name: user_password user_password_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_password
    ADD CONSTRAINT user_password_pkey PRIMARY KEY (id);


--
-- Name: user_log.uid.oid.action.ctime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "user_log.uid.oid.action.ctime" ON public.user_log USING btree (uid, oid, action, ctime DESC);


--
-- Name: user_log.uid.oid.ctime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "user_log.uid.oid.ctime" ON public.user_log USING btree (uid, oid, ctime DESC);


--
-- PostgreSQL database dump complete
--

