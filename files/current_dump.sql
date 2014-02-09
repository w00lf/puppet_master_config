--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: foo; Type: TABLE; Schema: public; Owner: pgsql; Tablespace: 
--

CREATE TABLE foo (
    id integer NOT NULL,
    name character varying(225)
);


ALTER TABLE public.foo OWNER TO pgsql;

--
-- Name: foo_id_seq; Type: SEQUENCE; Schema: public; Owner: pgsql
--

CREATE SEQUENCE foo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.foo_id_seq OWNER TO pgsql;

--
-- Name: foo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pgsql
--

ALTER SEQUENCE foo_id_seq OWNED BY foo.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pgsql
--

ALTER TABLE ONLY foo ALTER COLUMN id SET DEFAULT nextval('foo_id_seq'::regclass);


--
-- Data for Name: foo; Type: TABLE DATA; Schema: public; Owner: pgsql
--

COPY foo (id, name) FROM stdin;
1	fooo
2	fooo
3	fooo
4	fooo
5	fooo
6	fooo
7	fooo
8	fooo
9	fooo
\.


--
-- Name: foo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: pgsql
--

SELECT pg_catalog.setval('foo_id_seq', 9, true);


--
-- Name: foo_pkey; Type: CONSTRAINT; Schema: public; Owner: pgsql; Tablespace: 
--

ALTER TABLE ONLY foo
    ADD CONSTRAINT foo_pkey PRIMARY KEY (id);


--
-- Name: public; Type: ACL; Schema: -; Owner: pgsql
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM pgsql;
GRANT ALL ON SCHEMA public TO pgsql;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

