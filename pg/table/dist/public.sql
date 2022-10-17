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


SET default_tablespace = '';

--
-- Name: host; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.host (
    id bigint NOT NULL,
    val text NOT NULL
);


--
-- Name: host_hash; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.host_hash (
    id bigint NOT NULL,
    host_id bigint NOT NULL,
    hash_id bigint NOT NULL,
    hash bytea NOT NULL,
    day integer NOT NULL
);


--
-- Name: host_hash_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.host_hash_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 100;


--
-- Name: host_hash_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.host_hash_id_seq OWNED BY public.host_hash.id;


--
-- Name: host_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.host_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 100;


--
-- Name: host_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.host_id_seq OWNED BY public.host.id;


--
-- Name: host id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.host ALTER COLUMN id SET DEFAULT nextval('public.host_id_seq'::regclass);


--
-- Name: host_hash id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.host_hash ALTER COLUMN id SET DEFAULT nextval('public.host_hash_id_seq'::regclass);


--
-- Name: host host.val; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.host
    ADD CONSTRAINT "host.val" UNIQUE (val);


--
-- Name: host_hash host_hash_host_id_hash_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.host_hash
    ADD CONSTRAINT host_hash_host_id_hash_id_key UNIQUE (host_id, hash_id);


--
-- Name: host_hash host_hash_host_id_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.host_hash
    ADD CONSTRAINT host_hash_host_id_hash_key UNIQUE (host_id, hash);


--
-- Name: host_hash host_hash_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.host_hash
    ADD CONSTRAINT host_hash_pkey PRIMARY KEY (id);


--
-- Name: host host_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.host
    ADD CONSTRAINT host_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--

