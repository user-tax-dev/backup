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
COMMENT ON SCHEMA public IS 'standard public schema';
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
CREATE FUNCTION drop_func(_name text, OUT functions_dropped integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
   _sql text;
BEGIN
   SELECT count(*)::int
        , 'DROP FUNCTION ' || string_agg(oid::regprocedure::text, '; DROP FUNCTION ')
   FROM   pg_catalog.pg_proc
   WHERE  proname = _name
   AND    pg_function_is_visible(oid)  -- restrict to current search_path
   INTO   functions_dropped, _sql;     -- count only returned if subsequent DROPs succeed
   IF functions_dropped > 0 THEN       -- only if function(s) found
     EXECUTE _sql;
   END IF;
END
$$;
CREATE FUNCTION signup_mail(client_id u64, oid u64, mail_id u64, ctime u64, password_hash bytea) RETURNS u64
    LANGUAGE plpgsql
    AS $$
  DECLARE
    user_id u64;
  BEGIN
    SELECT uid INTO user_id
    FROM user_mail
    WHERE user_mail.oid = signup_mail.oid
      AND user_mail.mail_id = signup_mail.mail_id;
    IF user_id IS NULL THEN
      SELECT uid INTO user_id
      FROM user_mail
      WHERE user_mail.mail_id = signup_mail.mail_id
      ORDER BY id
      LIMIT 1;
      IF (user_id IS NULL) OR EXISTS (
      SELECT 1
      FROM user_mail
      WHERE signup_mail.oid = user_mail.oid AND uid = user_id) THEN
        SELECT nextval('uid'::regclass) INTO user_id;
        INSERT INTO user_mail (oid, uid, mail_id)
          VALUES (oid, user_id, mail_id);
      END IF;
    END IF;
    INSERT INTO user_log (client_id, oid, uid, ctime, action, val)
      VALUES (client_id, oid, user_id, ctime, 1, password_hash);
    INSERT INTO user_log (client_id, oid, uid, ctime, action, val)
      VALUES (client_id, oid, user_id, ctime, 2, mail_id);
    INSERT INTO user_password (oid, uid, hash, ctime)
      VALUES (oid, user_id, password_hash, ctime)
    ON CONFLICT (oid, uid)
      DO UPDATE SET hash = password_hash, user_password.ctime = signup_mail.ctime;
    RETURN user_id;
  END;
  $$;
SET default_tablespace = '';
SET default_table_access_method = heap;
CREATE TABLE browser (
    id u32 NOT NULL,
    name character varying(255) NOT NULL,
    ver u32 NOT NULL
);
CREATE SEQUENCE browser_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE browser_id_seq OWNED BY browser.id;
CREATE TABLE client_ip (
    id u64 NOT NULL,
    client_id u64 NOT NULL,
    ip bytea NOT NULL,
    ctime u64 DEFAULT (date_part('epoch'::text, now()))::integer NOT NULL
);
CREATE SEQUENCE client_ip_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE client_ip_id_seq OWNED BY client_ip.id;
CREATE TABLE client_meta (
    id u64 NOT NULL,
    device_id u32 NOT NULL,
    browser_id u32 NOT NULL,
    os_id u32 NOT NULL,
    client_id u64 NOT NULL,
    ctime u64 DEFAULT (date_part('epoch'::text, now()))::integer NOT NULL
);
CREATE SEQUENCE client_meta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE client_meta_id_seq OWNED BY client_meta.id;
CREATE SEQUENCE device_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE TABLE device (
    id u32 DEFAULT nextval('device_id_seq'::regclass) NOT NULL,
    vendor character varying(255) NOT NULL,
    model character varying(255) NOT NULL
);
CREATE TABLE os (
    id u64 NOT NULL,
    name character varying(255) NOT NULL,
    ver u32 NOT NULL
);
CREATE SEQUENCE os_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE os_id_seq OWNED BY os.id;
CREATE SEQUENCE uid
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE TABLE user_log (
    id u64 NOT NULL,
    oid u64 NOT NULL,
    action u16 NOT NULL,
    uid u64 NOT NULL,
    val bytea DEFAULT '\x'::bytea NOT NULL,
    ctime u64 DEFAULT date_part('epoch'::text, now()) NOT NULL,
    client_id u64 NOT NULL
);
CREATE SEQUENCE user_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE user_log_id_seq OWNED BY user_log.id;
CREATE TABLE user_mail (
    id u64 NOT NULL,
    oid u64 NOT NULL,
    uid u64 NOT NULL,
    mail_id u64 NOT NULL
);
CREATE SEQUENCE user_mail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE user_mail_id_seq OWNED BY user_mail.id;
CREATE TABLE user_password (
    id u64 NOT NULL,
    oid u64 NOT NULL,
    uid u64 NOT NULL,
    hash md5hash NOT NULL,
    ctime u64 NOT NULL
);
CREATE SEQUENCE user_password_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE user_password_id_seq OWNED BY user_password.id;
ALTER TABLE ONLY browser ALTER COLUMN id SET DEFAULT nextval('browser_id_seq'::regclass);
ALTER TABLE ONLY client_ip ALTER COLUMN id SET DEFAULT nextval('client_ip_id_seq'::regclass);
ALTER TABLE ONLY client_meta ALTER COLUMN id SET DEFAULT nextval('client_meta_id_seq'::regclass);
ALTER TABLE ONLY os ALTER COLUMN id SET DEFAULT nextval('os_id_seq'::regclass);
ALTER TABLE ONLY user_log ALTER COLUMN id SET DEFAULT nextval('user_log_id_seq'::regclass);
ALTER TABLE ONLY user_mail ALTER COLUMN id SET DEFAULT nextval('user_mail_id_seq'::regclass);
ALTER TABLE ONLY user_password ALTER COLUMN id SET DEFAULT nextval('user_password_id_seq'::regclass);
ALTER TABLE ONLY browser
    ADD CONSTRAINT "browser.name.ver" UNIQUE (name, ver);
ALTER TABLE ONLY browser
    ADD CONSTRAINT browser_pkey PRIMARY KEY (id);
ALTER TABLE ONLY client_ip
    ADD CONSTRAINT client_ip_pkey PRIMARY KEY (id);
ALTER TABLE ONLY client_meta
    ADD CONSTRAINT client_meta_pkey PRIMARY KEY (id);
ALTER TABLE ONLY device
    ADD CONSTRAINT "device.vendor.model" UNIQUE (vendor, model);
ALTER TABLE ONLY device
    ADD CONSTRAINT device_model_pkey PRIMARY KEY (id);
ALTER TABLE ONLY os
    ADD CONSTRAINT "os.name.ver" UNIQUE (name, ver);
ALTER TABLE ONLY os
    ADD CONSTRAINT os_pkey PRIMARY KEY (id);
ALTER TABLE ONLY user_log
    ADD CONSTRAINT user_log_pkey PRIMARY KEY (id);
ALTER TABLE ONLY client_ip
    ADD CONSTRAINT "user_mail.ip.ctime" UNIQUE (ip, ctime);
ALTER TABLE ONLY user_mail
    ADD CONSTRAINT "user_mail.oid.mail_id" UNIQUE (oid, mail_id);
ALTER TABLE ONLY user_password
    ADD CONSTRAINT "user_mail.oid.uid" UNIQUE (oid, uid);
ALTER TABLE ONLY user_mail
    ADD CONSTRAINT user_mail_pkey PRIMARY KEY (id);
ALTER TABLE ONLY user_password
    ADD CONSTRAINT user_password_pkey PRIMARY KEY (id);
CREATE INDEX "user_log.uid.oid.action.ctime" ON user_log USING btree (uid, oid, action, ctime DESC);
CREATE INDEX "user_log.uid.oid.ctime" ON user_log USING btree (uid, oid, ctime DESC);