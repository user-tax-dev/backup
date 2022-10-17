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

CREATE SCHEMA IF NOT EXISTS public;
SET search_path TO public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: client_new(u64, bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION client_new(client_id u64, ip bytea) RETURNS void
    LANGUAGE plpgsql
    AS $$
Declare
BEGIN

INSERT INTO client_ip(client_id,ip) VALUES(client_id,ip) ON CONFLICT DO NOTHING;

END;
$$;


--
-- Name: client_new(u64, bytea, character varying, u32, character varying, u32, character varying, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION client_new(client_id u64, ip bytea, browser_name character varying, browser_ver u32, os_name character varying, os_ver u32, device_vendor character varying, device_model character varying) RETURNS void
    LANGUAGE plpgsql
    AS $$
Declare 
now u64;
browser_id u32;
os_id u32;
device_id u32;
BEGIN

IF browser_name!='' THEN
WITH e AS (INSERT INTO browser (name,ver) VALUES (browser_name,browser_ver) ON CONFLICT(name,ver) DO NOTHING RETURNING id)
SELECT id INTO browser_id FROM e UNION SELECT id FROM browser WHERE name=browser_name and ver=browser_ver;
ELSE
browser_id = 0;
END IF;

IF os_name!='' THEN
WITH e AS (INSERT INTO os (name,ver) VALUES (os_name,os_ver) ON CONFLICT(name,ver) DO NOTHING RETURNING id)
SELECT id INTO os_id FROM e UNION SELECT id FROM os WHERE name=os_name and ver=os_ver;
ELSE
os_id = 0;
END IF;

IF device_vendor!='' THEN
WITH e AS (INSERT INTO device (device_vendor,device_model) VALUES (device_vendor,device_model) ON CONFLICT(vendor,model) DO NOTHING RETURNING id)
SELECT id INTO device_id FROM e UNION SELECT id FROM device WHERE vendor=device_vendor and model=device_model;
ELSE
device_id = 0;
END IF;

now=(date_part('epoch'::text, now()))::integer;

INSERT INTO client_ip(client_id,ip,ctime) VALUES(client_id,ip,now) ON CONFLICT DO NOTHING;
INSERT INTO client_meta (client_id,os_id,browser_id,device_id,ctime) VALUES (client_id,os_id,browser_id,device_id,now);

END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: browser; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE browser (
    id u32 NOT NULL,
    name character varying(255) NOT NULL,
    ver u32 NOT NULL
);


--
-- Name: browser_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE browser_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: browser_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE browser_id_seq OWNED BY browser.id;


--
-- Name: client_ip; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE client_ip (
    id u64 NOT NULL,
    client_id u64 NOT NULL,
    ip bytea NOT NULL,
    ctime u64 DEFAULT (date_part('epoch'::text, now()))::integer NOT NULL
);


--
-- Name: client_ip_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE client_ip_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_ip_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE client_ip_id_seq OWNED BY client_ip.id;


--
-- Name: client_meta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE client_meta (
    id u64 NOT NULL,
    device_id u32 NOT NULL,
    browser_id u32 NOT NULL,
    os_id u32 NOT NULL,
    client_id u64 NOT NULL,
    ctime u64 DEFAULT (date_part('epoch'::text, now()))::integer NOT NULL
);


--
-- Name: client_meta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE client_meta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: client_meta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE client_meta_id_seq OWNED BY client_meta.id;


--
-- Name: device_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE device_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: device; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE device (
    id u32 DEFAULT nextval('device_id_seq'::regclass) NOT NULL,
    vendor character varying(255) NOT NULL,
    model character varying(255) NOT NULL
);


--
-- Name: os; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE os (
    id u64 NOT NULL,
    name character varying(255) NOT NULL,
    ver u32 NOT NULL
);


--
-- Name: os_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE os_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: os_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE os_id_seq OWNED BY os.id;


--
-- Name: user_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_log (
    id u64 NOT NULL,
    oid u64 NOT NULL,
    action u16 NOT NULL,
    uid u64 NOT NULL,
    val bytea DEFAULT '\x'::bytea NOT NULL,
    ctime u64 DEFAULT date_part('epoch'::text, now()) NOT NULL,
    client_id u64 NOT NULL
);


--
-- Name: user_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_log_id_seq OWNED BY user_log.id;


--
-- Name: user_mail; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_mail (
    id u64 NOT NULL,
    oid u64 NOT NULL,
    uid u64 NOT NULL,
    mail_id u64 NOT NULL
);


--
-- Name: user_mail_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_mail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_mail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_mail_id_seq OWNED BY user_mail.id;


--
-- Name: user_password; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_password (
    id u64 NOT NULL,
    oid u64 NOT NULL,
    uid u64 NOT NULL,
    hash md5hash NOT NULL,
    ctime u64 NOT NULL
);


--
-- Name: user_password_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_password_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_password_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_password_id_seq OWNED BY user_password.id;


--
-- Name: browser id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY browser ALTER COLUMN id SET DEFAULT nextval('browser_id_seq'::regclass);


--
-- Name: client_ip id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY client_ip ALTER COLUMN id SET DEFAULT nextval('client_ip_id_seq'::regclass);


--
-- Name: client_meta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY client_meta ALTER COLUMN id SET DEFAULT nextval('client_meta_id_seq'::regclass);


--
-- Name: os id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY os ALTER COLUMN id SET DEFAULT nextval('os_id_seq'::regclass);


--
-- Name: user_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_log ALTER COLUMN id SET DEFAULT nextval('user_log_id_seq'::regclass);


--
-- Name: user_mail id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_mail ALTER COLUMN id SET DEFAULT nextval('user_mail_id_seq'::regclass);


--
-- Name: user_password id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_password ALTER COLUMN id SET DEFAULT nextval('user_password_id_seq'::regclass);


--
-- Name: browser browser.name.ver; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY browser
    ADD CONSTRAINT "browser.name.ver" UNIQUE (name, ver);


--
-- Name: browser browser_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY browser
    ADD CONSTRAINT browser_pkey PRIMARY KEY (id);


--
-- Name: client_ip client_ip_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY client_ip
    ADD CONSTRAINT client_ip_pkey PRIMARY KEY (id);


--
-- Name: client_meta client_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY client_meta
    ADD CONSTRAINT client_meta_pkey PRIMARY KEY (id);


--
-- Name: device device.vendor.model; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY device
    ADD CONSTRAINT "device.vendor.model" UNIQUE (vendor, model);


--
-- Name: device device_model_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY device
    ADD CONSTRAINT device_model_pkey PRIMARY KEY (id);


--
-- Name: os os.name.ver; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY os
    ADD CONSTRAINT "os.name.ver" UNIQUE (name, ver);


--
-- Name: os os_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY os
    ADD CONSTRAINT os_pkey PRIMARY KEY (id);


--
-- Name: user_log user_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_log
    ADD CONSTRAINT user_log_pkey PRIMARY KEY (id);


--
-- Name: client_ip user_mail.ip.ctime; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY client_ip
    ADD CONSTRAINT "user_mail.ip.ctime" UNIQUE (ip, ctime);


--
-- Name: user_mail user_mail.oid.mail_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_mail
    ADD CONSTRAINT "user_mail.oid.mail_id" UNIQUE (oid, mail_id);


--
-- Name: user_password user_mail.oid.uid; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_password
    ADD CONSTRAINT "user_mail.oid.uid" UNIQUE (oid, uid);


--
-- Name: user_mail user_mail_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_mail
    ADD CONSTRAINT user_mail_pkey PRIMARY KEY (id);


--
-- Name: user_password user_password_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_password
    ADD CONSTRAINT user_password_pkey PRIMARY KEY (id);


--
-- Name: user_log.uid.oid.action.ctime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "user_log.uid.oid.action.ctime" ON user_log USING btree (uid, oid, action, ctime DESC);


--
-- Name: user_log.uid.oid.ctime; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "user_log.uid.oid.ctime" ON user_log USING btree (uid, oid, ctime DESC);


--
-- PostgreSQL database dump complete
--

