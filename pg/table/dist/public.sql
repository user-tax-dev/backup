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
CREATE SCHEMA IF NOT EXISTS public;
SET search_path TO public;
SET default_tablespace = '';
CREATE TABLE host (
    id bigint NOT NULL,
    val text NOT NULL
);
CREATE TABLE host_hash (
    id bigint NOT NULL,
    host_id bigint NOT NULL,
    hash_id bigint NOT NULL,
    hash bytea NOT NULL,
    day integer NOT NULL
);
CREATE SEQUENCE host_hash_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 100;
ALTER SEQUENCE host_hash_id_seq OWNED BY host_hash.id;
CREATE SEQUENCE host_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 100;
ALTER SEQUENCE host_id_seq OWNED BY host.id;
ALTER TABLE ONLY host ALTER COLUMN id SET DEFAULT nextval('host_id_seq'::regclass);
ALTER TABLE ONLY host_hash ALTER COLUMN id SET DEFAULT nextval('host_hash_id_seq'::regclass);
ALTER TABLE ONLY host
    ADD CONSTRAINT "host.val" UNIQUE (val);
ALTER TABLE ONLY host_hash
    ADD CONSTRAINT host_hash_host_id_hash_id_key UNIQUE (host_id, hash_id);
ALTER TABLE ONLY host_hash
    ADD CONSTRAINT host_hash_host_id_hash_key UNIQUE (host_id, hash);
ALTER TABLE ONLY host_hash
    ADD CONSTRAINT host_hash_pkey PRIMARY KEY (id);
ALTER TABLE ONLY host
    ADD CONSTRAINT host_pkey PRIMARY KEY (id);