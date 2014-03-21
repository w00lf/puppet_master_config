--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- Name: ebosh(date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION ebosh(d date) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE record RECORD;
BEGIN
  FOR record IN SELECT * FROM return_affected_fias_addrobjs($1) LOOP
    PERFORM 1 FROM update_add_fields(record.aoid); 
  END LOOP;
  RETURN;
END
$_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: fias_addrobjs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fias_addrobjs (
    aoid character varying(255) NOT NULL,
    aoguid character varying(255),
    formalname character varying(255),
    regioncode character varying(255),
    autocode character varying(255),
    areacode character varying(255),
    citycode character varying(255),
    ctarcode character varying(255),
    placecode character varying(255),
    streetcode character varying(255),
    extrcode character varying(255),
    sextcode character varying(255),
    offname character varying(255),
    postalcode character varying(255),
    ifnsfl character varying(255),
    terrifnsfl character varying(255),
    ifnsul character varying(255),
    terrifnsul character varying(255),
    okato character varying(255),
    oktmo character varying(255),
    shortname character varying(255),
    aolevel character varying(255),
    parentguid character varying(255),
    previd character varying(255),
    nextid character varying(255),
    code character varying(255),
    plaincode character varying(255),
    actstatus character varying(255),
    centstatus character varying(255),
    operstatus character varying(255),
    currstatus character varying(255),
    normdoc character varying(255),
    livestatus character varying(255),
    startdate timestamp without time zone,
    enddate timestamp without time zone,
    updatedate timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    full_address character varying(255),
    textsearchable_index_col tsvector,
    ancestors_guids text,
    ancestors_guids_index_col tsvector
);


--
-- Name: return_affected_fias_addrobjs(date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION return_affected_fias_addrobjs(d date) RETURNS SETOF fias_addrobjs
    LANGUAGE sql
    AS $_$
  WITH RECURSIVE child_to_parents AS (
    SELECT fias_addrobjs.* FROM fias_addrobjs WHERE aoid in (SELECT aoid FROM return_recently_updated($1))
  UNION ALL
    SELECT fias_addrobjs.* FROM fias_addrobjs, child_to_parents
    WHERE fias_addrobjs.parentguid = child_to_parents.aoguid AND fias_addrobjs.currstatus = '0')
  SELECT DISTINCT * FROM child_to_parents
$_$;


--
-- Name: return_ancestors(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION return_ancestors(a text) RETURNS SETOF fias_addrobjs
    LANGUAGE sql
    AS $_$
  WITH RECURSIVE child_to_parents AS (
  SELECT fias_addrobjs.* FROM fias_addrobjs WHERE aoid = $1
    UNION ALL
  SELECT fias_addrobjs.* FROM fias_addrobjs, child_to_parents
    WHERE fias_addrobjs.aoguid = child_to_parents.parentguid AND fias_addrobjs.currstatus = '0')
  SELECT * FROM child_to_parents ORDER BY aolevel
$_$;


--
-- Name: return_ancestors_aoguid(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION return_ancestors_aoguid(a text) RETURNS text
    LANGUAGE sql
    AS $_$
  SELECT array_to_string(array_agg(aoguid), ' ') FROM return_ancestors($1);
$_$;


--
-- Name: return_ancestors_full_address(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION return_ancestors_full_address(a text) RETURNS text
    LANGUAGE sql
    AS $_$
  SELECT array_to_string(array_agg(CONCAT_WS(' ', shortname, formalname)), ', ') FROM return_ancestors($1);
$_$;


--
-- Name: return_ancestors_string(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION return_ancestors_string(a text) RETURNS text
    LANGUAGE sql
    AS $_$
  SELECT array_to_string(array_agg(aoguid), ' ') FROM return_ancestors($1);
$_$;


--
-- Name: return_int(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION return_int() RETURNS integer
    LANGUAGE plpgsql
    AS $$
BEGIN
  RETURN 1;
END
$$;


--
-- Name: return_recently_updated(date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION return_recently_updated(d date) RETURNS SETOF fias_addrobjs
    LANGUAGE sql
    AS $_$
  SELECT * FROM fias_addrobjs WHERE currstatus = '0' AND updated_at::date >= $1
$_$;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    old_name character varying(255)
);


--
-- Name: return_roles(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION return_roles() RETURNS SETOF roles
    LANGUAGE sql
    AS $$
SELECT * FROM roles;
$$;


--
-- Name: update_add_fields(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_add_fields(a text) RETURNS void
    LANGUAGE plpgsql
    AS $_$
BEGIN
    UPDATE fias_addrobjs SET ancestors_guids = return_ancestors_aoguid($1), full_address = return_ancestors_full_address($1) WHERE aoid = $1;
END;
$_$;


--
-- Name: update_all_affected_records(date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION update_all_affected_records(d date) RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE record RECORD;
BEGIN
  FOR record IN SELECT * FROM return_affected_fias_addrobjs($1) LOOP
    PERFORM 1 FROM update_add_fields(record.aoid); 
  END LOOP;
  RETURN;
END
$_$;


--
-- Name: abbreviations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE abbreviations (
    id integer NOT NULL,
    short_name character varying(255),
    long_name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: abbreviations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE abbreviations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: abbreviations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE abbreviations_id_seq OWNED BY abbreviations.id;


--
-- Name: admins; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE admins (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    librarian boolean DEFAULT false,
    first_name character varying(255),
    middle_name character varying(255),
    last_name character varying(255),
    phone character varying(255),
    institution_id integer,
    role character varying(255),
    role_id integer,
    fias_addrobj_id character varying(255)
);


--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE admins_id_seq OWNED BY admins.id;


--
-- Name: audits; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE audits (
    id integer NOT NULL,
    auditable_id integer,
    auditable_type character varying(255),
    associated_id integer,
    associated_type character varying(255),
    user_id integer,
    user_type character varying(255),
    username character varying(255),
    action character varying(255),
    audited_changes text,
    version integer DEFAULT 0,
    comment character varying(255),
    remote_address character varying(255),
    created_at timestamp without time zone
);


--
-- Name: audits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE audits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE audits_id_seq OWNED BY audits.id;


--
-- Name: authors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE authors (
    id integer NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    middle_name character varying(255),
    birth_year integer,
    death_year integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    portrait character varying(255)
);


--
-- Name: authors_books; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE authors_books (
    author_id integer,
    book_id integer
);


--
-- Name: authors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authors_id_seq OWNED BY authors.id;


--
-- Name: book_licenses; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE book_licenses (
    id integer NOT NULL,
    number character varying(255),
    book_id integer,
    expiration_date date,
    deleted_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer
);


--
-- Name: book_licenses_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE book_licenses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: book_licenses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE book_licenses_id_seq OWNED BY book_licenses.id;


--
-- Name: books; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE books (
    id integer NOT NULL,
    category_id integer,
    subject_id integer,
    publisher_id integer,
    digital_right_id integer,
    publish_year integer DEFAULT 2013,
    price numeric(8,2) DEFAULT 0.0 NOT NULL,
    rating integer DEFAULT 0,
    accept_comments boolean,
    approved boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    title character varying(255),
    h_cover character varying(255),
    v_cover character varying(255),
    md_sum character varying(255),
    unit character varying(255),
    book_size integer DEFAULT 100,
    page_size integer DEFAULT 234,
    description text,
    additional_info text,
    book_version integer DEFAULT 1,
    deleted_at timestamp without time zone,
    inappid character varying(255),
    downloaded integer DEFAULT 0,
    target character varying(255)
);


--
-- Name: books_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE books_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE books_id_seq OWNED BY books.id;


--
-- Name: bought_books; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE bought_books (
    id integer NOT NULL,
    book_id integer,
    status character varying(255) DEFAULT 'preparing'::character varying,
    public_key text,
    udid character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    book_name_salt character varying(255),
    device_token character varying(255)
);


--
-- Name: bought_books_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE bought_books_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bought_books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE bought_books_id_seq OWNED BY bought_books.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: ckeditor_assets; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE ckeditor_assets (
    id integer NOT NULL,
    data_file_name character varying(255) NOT NULL,
    data_content_type character varying(255),
    data_file_size integer,
    assetable_id integer,
    assetable_type character varying(30),
    type character varying(30),
    width integer,
    height integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ckeditor_assets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE ckeditor_assets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ckeditor_assets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE ckeditor_assets_id_seq OWNED BY ckeditor_assets.id;


--
-- Name: devices; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE devices (
    id integer NOT NULL,
    title character varying(255),
    "right" boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: devices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE devices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: devices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE devices_id_seq OWNED BY devices.id;


--
-- Name: devices_platforms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE devices_platforms (
    device_id integer,
    platform_id integer
);


--
-- Name: digital_rights; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE digital_rights (
    id integer NOT NULL,
    valid_date date,
    quantity integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    book_id integer
);


--
-- Name: digital_rights_holders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE digital_rights_holders (
    digital_right_id integer,
    holder_id integer
);


--
-- Name: digital_rights_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE digital_rights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: digital_rights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE digital_rights_id_seq OWNED BY digital_rights.id;


--
-- Name: digital_rights_platforms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE digital_rights_platforms (
    platform_id integer,
    digital_right_id integer
);


--
-- Name: email_templates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE email_templates (
    id integer NOT NULL,
    title character varying(255),
    headers text,
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: email_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE email_templates_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE email_templates_id_seq OWNED BY email_templates.id;


--
-- Name: fias_homes; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fias_homes (
    aoguid character varying(255),
    buildnum character varying(255),
    counter character varying(255),
    eststatus character varying(255),
    houseguid character varying(255),
    houseid character varying(255) NOT NULL,
    housenum character varying(255),
    ifnsfl character varying(255),
    ifnsul character varying(255),
    normdoc character varying(255),
    okato character varying(255),
    oktmo character varying(255),
    postalcode character varying(255),
    statstatus character varying(255),
    strstatus character varying(255),
    strucnum character varying(255),
    terrifnsfl character varying(255),
    terrifnsul character varying(255),
    startdate timestamp without time zone,
    enddate timestamp without time zone,
    updatedate timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: help_entries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE help_entries (
    id integer NOT NULL,
    title character varying(255),
    parent_id integer,
    "position" integer,
    content text,
    depth integer,
    children_count integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: help_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE help_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: help_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE help_entries_id_seq OWNED BY help_entries.id;


--
-- Name: help_entries_roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE help_entries_roles (
    role_id integer,
    help_entry_id integer
);


--
-- Name: help_rights; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE help_rights (
    id integer NOT NULL,
    role character varying(255),
    help_entry_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: help_rights_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE help_rights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: help_rights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE help_rights_id_seq OWNED BY help_rights.id;


--
-- Name: holders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE holders (
    id integer NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    middle_name character varying(255),
    email character varying(255),
    phone character varying(255),
    company boolean DEFAULT false,
    company_title character varying(255),
    company_business_address character varying(255),
    company_address character varying(255),
    company_email character varying(255),
    company_phone character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    admin_id integer
);


--
-- Name: holders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE holders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: holders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE holders_id_seq OWNED BY holders.id;


--
-- Name: institutions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE institutions (
    id integer NOT NULL,
    title character varying(1024),
    address character varying(255),
    email character varying(255),
    phone character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    postcode character varying(255),
    city character varying(255),
    latitude double precision,
    longitude double precision,
    fias_home_id character varying(255),
    fias_addrobj_id character varying(255),
    rebind boolean,
    fias_addrobj_city_id character varying(255),
    short_title character varying(255)
);


--
-- Name: institutions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE institutions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: institutions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE institutions_id_seq OWNED BY institutions.id;


--
-- Name: permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE permissions (
    id integer NOT NULL,
    model_name character varying(255),
    value character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    geo_constraint boolean,
    resource_id integer
);


--
-- Name: permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE permissions_id_seq OWNED BY permissions.id;


--
-- Name: platforms; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE platforms (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: platforms_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE platforms_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: platforms_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE platforms_id_seq OWNED BY platforms.id;


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE profiles (
    id integer NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    middle_name character varying(255),
    unit character varying(255),
    birth_date date,
    birth_place character varying(255),
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    phone character varying(255),
    institution_id integer,
    birth_day integer,
    birth_month integer,
    birth_year integer,
    institution_title character varying(255),
    institution_city character varying(255),
    teacher boolean DEFAULT false
);


--
-- Name: profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE profiles_id_seq OWNED BY profiles.id;


--
-- Name: publishers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE publishers (
    id integer NOT NULL,
    title character varying(255),
    address character varying(255),
    phone character varying(255),
    email character varying(255),
    description text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    logo character varying(255)
);


--
-- Name: publishers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE publishers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publishers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE publishers_id_seq OWNED BY publishers.id;


--
-- Name: push_configurations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE push_configurations (
    id integer NOT NULL,
    type character varying(255) NOT NULL,
    app character varying(255) NOT NULL,
    properties text,
    enabled boolean DEFAULT false NOT NULL,
    connections integer DEFAULT 1 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: push_configurations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE push_configurations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: push_configurations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE push_configurations_id_seq OWNED BY push_configurations.id;


--
-- Name: push_feedback; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE push_feedback (
    id integer NOT NULL,
    app character varying(255) NOT NULL,
    device character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    follow_up character varying(255) NOT NULL,
    failed_at timestamp without time zone NOT NULL,
    processed boolean DEFAULT false NOT NULL,
    processed_at timestamp without time zone,
    properties text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: push_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE push_feedback_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: push_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE push_feedback_id_seq OWNED BY push_feedback.id;


--
-- Name: push_messages; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE push_messages (
    id integer NOT NULL,
    app character varying(255) NOT NULL,
    device character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    properties text,
    delivered boolean DEFAULT false NOT NULL,
    delivered_at timestamp without time zone,
    failed boolean DEFAULT false NOT NULL,
    failed_at timestamp without time zone,
    error_code integer,
    error_description character varying(255),
    deliver_after timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: push_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE push_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: push_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE push_messages_id_seq OWNED BY push_messages.id;


--
-- Name: relation_books; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE relation_books (
    id integer NOT NULL,
    book_id integer,
    related_book_id integer,
    status character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: relation_books_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE relation_books_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: relation_books_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE relation_books_id_seq OWNED BY relation_books.id;


--
-- Name: resources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE resources (
    id integer NOT NULL,
    controller character varying(255),
    model character varying(255),
    link character varying(255),
    menu_level integer,
    "position" integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    conditions character varying(255),
    parent_id integer,
    localize_name character varying(255),
    need_geo boolean
);


--
-- Name: resources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE resources_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: resources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE resources_id_seq OWNED BY resources.id;


--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE role_permissions (
    id integer,
    permission_id integer,
    role_id integer
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: sent_emails; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sent_emails (
    id integer NOT NULL,
    email_template_id integer,
    admin_id integer,
    subject character varying(255),
    text text,
    roles character varying(255),
    regions character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    send_count integer,
    total_count integer
);


--
-- Name: sent_emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sent_emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sent_emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sent_emails_id_seq OWNED BY sent_emails.id;


--
-- Name: simple_captcha_data; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE simple_captcha_data (
    id integer NOT NULL,
    key character varying(40),
    value character varying(6),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: simple_captcha_data_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE simple_captcha_data_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: simple_captcha_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE simple_captcha_data_id_seq OWNED BY simple_captcha_data.id;


--
-- Name: subjects; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE subjects (
    id integer NOT NULL,
    title character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: subjects_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE subjects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subjects_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE subjects_id_seq OWNED BY subjects.id;


--
-- Name: supplies; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE supplies (
    id integer NOT NULL,
    quantity integer,
    institution_id integer,
    valid_date date,
    created_on date NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    book_id integer,
    issued integer DEFAULT 0,
    free integer,
    contract_number character varying(255)
);


--
-- Name: supplies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE supplies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supplies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE supplies_id_seq OWNED BY supplies.id;


--
-- Name: supply_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE supply_items (
    id integer NOT NULL,
    book_id integer,
    user_id integer,
    admin_id integer,
    supply_id integer,
    issued_date date,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    expiration_date date,
    udid character varying(255),
    status character varying(255) DEFAULT 'not_ready'::character varying,
    public_key text
);


--
-- Name: supply_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE supply_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: supply_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE supply_items_id_seq OWNED BY supply_items.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying(255) DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying(255),
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    sign_in_count integer DEFAULT 0,
    current_sign_in_at timestamp without time zone,
    last_sign_in_at timestamp without time zone,
    current_sign_in_ip character varying(255),
    last_sign_in_ip character varying(255),
    confirmation_token character varying(255),
    confirmed_at timestamp without time zone,
    confirmation_sent_at timestamp without time zone,
    unconfirmed_email character varying(255),
    authentication_token character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approved boolean DEFAULT false,
    device_token character varying(255),
    udid character varying(255),
    connected boolean DEFAULT true,
    new_udid character varying(255),
    role_id integer,
    connect_date date
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY abbreviations ALTER COLUMN id SET DEFAULT nextval('abbreviations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY admins ALTER COLUMN id SET DEFAULT nextval('admins_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY audits ALTER COLUMN id SET DEFAULT nextval('audits_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authors ALTER COLUMN id SET DEFAULT nextval('authors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY book_licenses ALTER COLUMN id SET DEFAULT nextval('book_licenses_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY books ALTER COLUMN id SET DEFAULT nextval('books_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY bought_books ALTER COLUMN id SET DEFAULT nextval('bought_books_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY ckeditor_assets ALTER COLUMN id SET DEFAULT nextval('ckeditor_assets_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY devices ALTER COLUMN id SET DEFAULT nextval('devices_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY digital_rights ALTER COLUMN id SET DEFAULT nextval('digital_rights_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY email_templates ALTER COLUMN id SET DEFAULT nextval('email_templates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY help_entries ALTER COLUMN id SET DEFAULT nextval('help_entries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY help_rights ALTER COLUMN id SET DEFAULT nextval('help_rights_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY holders ALTER COLUMN id SET DEFAULT nextval('holders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY institutions ALTER COLUMN id SET DEFAULT nextval('institutions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY permissions ALTER COLUMN id SET DEFAULT nextval('permissions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY platforms ALTER COLUMN id SET DEFAULT nextval('platforms_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles ALTER COLUMN id SET DEFAULT nextval('profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY publishers ALTER COLUMN id SET DEFAULT nextval('publishers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY push_configurations ALTER COLUMN id SET DEFAULT nextval('push_configurations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY push_feedback ALTER COLUMN id SET DEFAULT nextval('push_feedback_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY push_messages ALTER COLUMN id SET DEFAULT nextval('push_messages_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY relation_books ALTER COLUMN id SET DEFAULT nextval('relation_books_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY resources ALTER COLUMN id SET DEFAULT nextval('resources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sent_emails ALTER COLUMN id SET DEFAULT nextval('sent_emails_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY simple_captcha_data ALTER COLUMN id SET DEFAULT nextval('simple_captcha_data_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY subjects ALTER COLUMN id SET DEFAULT nextval('subjects_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY supplies ALTER COLUMN id SET DEFAULT nextval('supplies_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY supply_items ALTER COLUMN id SET DEFAULT nextval('supply_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: abbreviations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY abbreviations
    ADD CONSTRAINT abbreviations_pkey PRIMARY KEY (id);


--
-- Name: admins_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: audits_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY audits
    ADD CONSTRAINT audits_pkey PRIMARY KEY (id);


--
-- Name: authors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (id);


--
-- Name: book_licenses_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY book_licenses
    ADD CONSTRAINT book_licenses_pkey PRIMARY KEY (id);


--
-- Name: books_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY books
    ADD CONSTRAINT books_pkey PRIMARY KEY (id);


--
-- Name: bought_books_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bought_books
    ADD CONSTRAINT bought_books_pkey PRIMARY KEY (id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: ckeditor_assets_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ckeditor_assets
    ADD CONSTRAINT ckeditor_assets_pkey PRIMARY KEY (id);


--
-- Name: devices_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: digital_rights_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY digital_rights
    ADD CONSTRAINT digital_rights_pkey PRIMARY KEY (id);


--
-- Name: email_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY email_templates
    ADD CONSTRAINT email_templates_pkey PRIMARY KEY (id);


--
-- Name: fias_addrobjs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fias_addrobjs
    ADD CONSTRAINT fias_addrobjs_pkey PRIMARY KEY (aoid);


--
-- Name: fias_homes_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY fias_homes
    ADD CONSTRAINT fias_homes_pkey PRIMARY KEY (houseid);


--
-- Name: help_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY help_entries
    ADD CONSTRAINT help_entries_pkey PRIMARY KEY (id);


--
-- Name: help_rights_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY help_rights
    ADD CONSTRAINT help_rights_pkey PRIMARY KEY (id);


--
-- Name: holders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY holders
    ADD CONSTRAINT holders_pkey PRIMARY KEY (id);


--
-- Name: institutions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY institutions
    ADD CONSTRAINT institutions_pkey PRIMARY KEY (id);


--
-- Name: permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: platforms_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY platforms
    ADD CONSTRAINT platforms_pkey PRIMARY KEY (id);


--
-- Name: profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- Name: publishers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY publishers
    ADD CONSTRAINT publishers_pkey PRIMARY KEY (id);


--
-- Name: push_configurations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY push_configurations
    ADD CONSTRAINT push_configurations_pkey PRIMARY KEY (id);


--
-- Name: push_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY push_feedback
    ADD CONSTRAINT push_feedback_pkey PRIMARY KEY (id);


--
-- Name: push_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY push_messages
    ADD CONSTRAINT push_messages_pkey PRIMARY KEY (id);


--
-- Name: relation_books_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY relation_books
    ADD CONSTRAINT relation_books_pkey PRIMARY KEY (id);


--
-- Name: resources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY resources
    ADD CONSTRAINT resources_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: sent_emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sent_emails
    ADD CONSTRAINT sent_emails_pkey PRIMARY KEY (id);


--
-- Name: simple_captcha_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY simple_captcha_data
    ADD CONSTRAINT simple_captcha_data_pkey PRIMARY KEY (id);


--
-- Name: subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: supplies_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY supplies
    ADD CONSTRAINT supplies_pkey PRIMARY KEY (id);


--
-- Name: supply_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY supply_items
    ADD CONSTRAINT supply_items_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ancestors_guids_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX ancestors_guids_idx ON fias_addrobjs USING gin (ancestors_guids_index_col);


--
-- Name: associated_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX associated_index ON audits USING btree (associated_id, associated_type);


--
-- Name: auditable_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX auditable_index ON audits USING btree (auditable_id, auditable_type);


--
-- Name: fias_addrobjs_currstatus_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fias_addrobjs_currstatus_idx ON fias_addrobjs USING btree (currstatus);


--
-- Name: fias_addrobjs_updated_at_date_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fias_addrobjs_updated_at_date_idx ON fias_addrobjs USING btree (((updated_at)::date));


--
-- Name: fias_homes_postalcode_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX fias_homes_postalcode_idx ON fias_homes USING btree (postalcode);


--
-- Name: full_address_ids; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX full_address_ids ON fias_addrobjs USING btree (lower((full_address)::text));


--
-- Name: full_address_ids_cs; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX full_address_ids_cs ON fias_addrobjs USING btree (full_address);


--
-- Name: full_address_ids_cs_splitted; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX full_address_ids_cs_splitted ON fias_addrobjs USING btree (regexp_split_to_array((full_address)::text, '[\s\.\,]+'::text));


--
-- Name: full_address_idx_gin; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX full_address_idx_gin ON fias_addrobjs USING gin (to_tsvector('english'::regconfig, (full_address)::text));


--
-- Name: idx_ckeditor_assetable; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_ckeditor_assetable ON ckeditor_assets USING btree (assetable_type, assetable_id);


--
-- Name: idx_ckeditor_assetable_type; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_ckeditor_assetable_type ON ckeditor_assets USING btree (assetable_type, type, assetable_id);


--
-- Name: idx_key; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX idx_key ON simple_captcha_data USING btree (key);


--
-- Name: index_admins_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admins_on_email ON admins USING btree (email);


--
-- Name: index_admins_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_admins_on_reset_password_token ON admins USING btree (reset_password_token);


--
-- Name: index_audits_on_created_at; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_audits_on_created_at ON audits USING btree (created_at);


--
-- Name: index_authors_books_on_author_id_and_book_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_authors_books_on_author_id_and_book_id ON authors_books USING btree (author_id, book_id);


--
-- Name: index_authors_books_on_book_id_and_author_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_authors_books_on_book_id_and_author_id ON authors_books USING btree (book_id, author_id);


--
-- Name: index_book_licenses_on_book_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_book_licenses_on_book_id ON book_licenses USING btree (book_id);


--
-- Name: index_book_licenses_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_book_licenses_on_user_id ON book_licenses USING btree (user_id);


--
-- Name: index_bought_books_on_book_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_bought_books_on_book_id ON bought_books USING btree (book_id);


--
-- Name: index_devices_platforms_on_device_id_and_platform_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_devices_platforms_on_device_id_and_platform_id ON devices_platforms USING btree (device_id, platform_id);


--
-- Name: index_devices_platforms_on_platform_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_devices_platforms_on_platform_id ON devices_platforms USING btree (platform_id);


--
-- Name: index_digital_rights_holders_on_digital_right_id_and_holder_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_digital_rights_holders_on_digital_right_id_and_holder_id ON digital_rights_holders USING btree (digital_right_id, holder_id);


--
-- Name: index_digital_rights_holders_on_holder_id_and_digital_right_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_digital_rights_holders_on_holder_id_and_digital_right_id ON digital_rights_holders USING btree (holder_id, digital_right_id);


--
-- Name: index_fias_addrobjs_on_actstatus; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fias_addrobjs_on_actstatus ON fias_addrobjs USING btree (actstatus);


--
-- Name: index_fias_addrobjs_on_aoguid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fias_addrobjs_on_aoguid ON fias_addrobjs USING btree (aoguid);


--
-- Name: index_fias_addrobjs_on_aolevel; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fias_addrobjs_on_aolevel ON fias_addrobjs USING btree (aolevel);


--
-- Name: index_fias_addrobjs_on_areacode; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fias_addrobjs_on_areacode ON fias_addrobjs USING btree (areacode);


--
-- Name: index_fias_addrobjs_on_formalname; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fias_addrobjs_on_formalname ON fias_addrobjs USING btree (lower((formalname)::text));


--
-- Name: index_fias_addrobjs_on_formalname_normal; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fias_addrobjs_on_formalname_normal ON fias_addrobjs USING btree (formalname);


--
-- Name: index_fias_addrobjs_on_parentguid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fias_addrobjs_on_parentguid ON fias_addrobjs USING btree (parentguid);


--
-- Name: index_fias_addrobjs_on_previd; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fias_addrobjs_on_previd ON fias_addrobjs USING btree (previd);


--
-- Name: index_fias_homes_on_aoguid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fias_homes_on_aoguid ON fias_homes USING btree (aoguid);


--
-- Name: index_fias_homes_on_enddate; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fias_homes_on_enddate ON fias_homes USING btree (enddate);


--
-- Name: index_fias_homes_on_houseguid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fias_homes_on_houseguid ON fias_homes USING btree (houseguid);


--
-- Name: index_fias_homes_on_housenum; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fias_homes_on_housenum ON fias_homes USING btree (lower((housenum)::text));


--
-- Name: index_fias_homes_on_startdate; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_fias_homes_on_startdate ON fias_homes USING btree (startdate);


--
-- Name: index_holders_on_admin_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_holders_on_admin_id ON holders USING btree (admin_id);


--
-- Name: index_institutions_on_city; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_institutions_on_city ON institutions USING btree (city);


--
-- Name: index_institutions_on_fias_addrobj_city_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_institutions_on_fias_addrobj_city_id ON institutions USING btree (fias_addrobj_city_id);


--
-- Name: index_institutions_on_title; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_institutions_on_title ON institutions USING btree (title);


--
-- Name: index_profiles_on_institution_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_profiles_on_institution_id ON profiles USING btree (institution_id);


--
-- Name: index_push_feedback_on_processed; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_push_feedback_on_processed ON push_feedback USING btree (processed);


--
-- Name: index_push_messages_on_delivered_and_failed_and_deliver_after; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_push_messages_on_delivered_and_failed_and_deliver_after ON push_messages USING btree (delivered, failed, deliver_after);


--
-- Name: index_supplies_on_book_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_supplies_on_book_id ON supplies USING btree (book_id);


--
-- Name: index_supplies_on_institution_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_supplies_on_institution_id ON supplies USING btree (institution_id);


--
-- Name: index_supply_items_on_admin_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_supply_items_on_admin_id ON supply_items USING btree (admin_id);


--
-- Name: index_supply_items_on_book_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_supply_items_on_book_id ON supply_items USING btree (book_id);


--
-- Name: index_supply_items_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_supply_items_on_user_id ON supply_items USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON users USING btree (reset_password_token);


--
-- Name: platform_digital_right; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX platform_digital_right ON digital_rights_platforms USING btree (platform_id, digital_right_id);


--
-- Name: textsearch_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX textsearch_idx ON fias_addrobjs USING gin (textsearchable_index_col);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: user_index; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX user_index ON audits USING btree (user_id, user_type);


--
-- Name: fias_ancestors_tsvector_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER fias_ancestors_tsvector_update BEFORE INSERT OR UPDATE ON fias_addrobjs FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('ancestors_guids_index_col', 'pg_catalog.english', 'ancestors_guids');


--
-- Name: fias_tsvector_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER fias_tsvector_update BEFORE INSERT OR UPDATE ON fias_addrobjs FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('textsearchable_index_col', 'pg_catalog.english', 'full_address');


--
-- Name: admins_institution_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY admins
    ADD CONSTRAINT admins_institution_id_fk FOREIGN KEY (institution_id) REFERENCES institutions(id);


--
-- Name: authors_books_author_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authors_books
    ADD CONSTRAINT authors_books_author_id_fk FOREIGN KEY (author_id) REFERENCES authors(id);


--
-- Name: authors_books_book_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authors_books
    ADD CONSTRAINT authors_books_book_id_fk FOREIGN KEY (book_id) REFERENCES books(id);


--
-- Name: book_licenses_book_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY book_licenses
    ADD CONSTRAINT book_licenses_book_id_fk FOREIGN KEY (book_id) REFERENCES books(id);


--
-- Name: books_category_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY books
    ADD CONSTRAINT books_category_id_fk FOREIGN KEY (category_id) REFERENCES categories(id);


--
-- Name: books_publisher_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY books
    ADD CONSTRAINT books_publisher_id_fk FOREIGN KEY (publisher_id) REFERENCES publishers(id);


--
-- Name: books_subject_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY books
    ADD CONSTRAINT books_subject_id_fk FOREIGN KEY (subject_id) REFERENCES subjects(id);


--
-- Name: bought_books_book_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY bought_books
    ADD CONSTRAINT bought_books_book_id_fk FOREIGN KEY (book_id) REFERENCES books(id);


--
-- Name: digital_rights_book_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY digital_rights
    ADD CONSTRAINT digital_rights_book_id_fk FOREIGN KEY (book_id) REFERENCES books(id);


--
-- Name: digital_rights_holders_digital_right_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY digital_rights_holders
    ADD CONSTRAINT digital_rights_holders_digital_right_id_fk FOREIGN KEY (digital_right_id) REFERENCES digital_rights(id);


--
-- Name: digital_rights_holders_holder_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY digital_rights_holders
    ADD CONSTRAINT digital_rights_holders_holder_id_fk FOREIGN KEY (holder_id) REFERENCES holders(id);


--
-- Name: profiles_institution_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_institution_id_fk FOREIGN KEY (institution_id) REFERENCES institutions(id);


--
-- Name: profiles_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY profiles
    ADD CONSTRAINT profiles_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: relation_books_book_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY relation_books
    ADD CONSTRAINT relation_books_book_id_fk FOREIGN KEY (book_id) REFERENCES books(id);


--
-- Name: relation_books_related_book_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY relation_books
    ADD CONSTRAINT relation_books_related_book_id_fk FOREIGN KEY (related_book_id) REFERENCES books(id);


--
-- Name: supplies_book_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supplies
    ADD CONSTRAINT supplies_book_id_fk FOREIGN KEY (book_id) REFERENCES books(id);


--
-- Name: supplies_institution_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supplies
    ADD CONSTRAINT supplies_institution_id_fk FOREIGN KEY (institution_id) REFERENCES institutions(id);


--
-- Name: supply_items_admin_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supply_items
    ADD CONSTRAINT supply_items_admin_id_fk FOREIGN KEY (admin_id) REFERENCES admins(id);


--
-- Name: supply_items_book_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supply_items
    ADD CONSTRAINT supply_items_book_id_fk FOREIGN KEY (book_id) REFERENCES books(id);


--
-- Name: supply_items_supply_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supply_items
    ADD CONSTRAINT supply_items_supply_id_fk FOREIGN KEY (supply_id) REFERENCES supplies(id);


--
-- Name: supply_items_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY supply_items
    ADD CONSTRAINT supply_items_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

INSERT INTO schema_migrations (version) VALUES ('20130422051358');

INSERT INTO schema_migrations (version) VALUES ('20130422055044');

INSERT INTO schema_migrations (version) VALUES ('20130422105204');

INSERT INTO schema_migrations (version) VALUES ('20130422112440');

INSERT INTO schema_migrations (version) VALUES ('20130422112800');

INSERT INTO schema_migrations (version) VALUES ('20130422112838');

INSERT INTO schema_migrations (version) VALUES ('20130422113021');

INSERT INTO schema_migrations (version) VALUES ('20130422113528');

INSERT INTO schema_migrations (version) VALUES ('20130422113738');

INSERT INTO schema_migrations (version) VALUES ('20130422114817');

INSERT INTO schema_migrations (version) VALUES ('20130422120341');

INSERT INTO schema_migrations (version) VALUES ('20130423053537');

INSERT INTO schema_migrations (version) VALUES ('20130423103207');

INSERT INTO schema_migrations (version) VALUES ('20130423120515');

INSERT INTO schema_migrations (version) VALUES ('20130423143338');

INSERT INTO schema_migrations (version) VALUES ('20130423144319');

INSERT INTO schema_migrations (version) VALUES ('20130424073858');

INSERT INTO schema_migrations (version) VALUES ('20130425091354');

INSERT INTO schema_migrations (version) VALUES ('20130425114745');

INSERT INTO schema_migrations (version) VALUES ('20130425115216');

INSERT INTO schema_migrations (version) VALUES ('20130426060809');

INSERT INTO schema_migrations (version) VALUES ('20130426091651');

INSERT INTO schema_migrations (version) VALUES ('20130502125413');

INSERT INTO schema_migrations (version) VALUES ('20130503105744');

INSERT INTO schema_migrations (version) VALUES ('20130503120812');

INSERT INTO schema_migrations (version) VALUES ('20130506144505');

INSERT INTO schema_migrations (version) VALUES ('20130507093748');

INSERT INTO schema_migrations (version) VALUES ('20130507114723');

INSERT INTO schema_migrations (version) VALUES ('20130507114903');

INSERT INTO schema_migrations (version) VALUES ('20130508093347');

INSERT INTO schema_migrations (version) VALUES ('20130508102046');

INSERT INTO schema_migrations (version) VALUES ('20130508110945');

INSERT INTO schema_migrations (version) VALUES ('20130513151122');

INSERT INTO schema_migrations (version) VALUES ('20130513151344');

INSERT INTO schema_migrations (version) VALUES ('20130513161343');

INSERT INTO schema_migrations (version) VALUES ('20130515085158');

INSERT INTO schema_migrations (version) VALUES ('20130515154131');

INSERT INTO schema_migrations (version) VALUES ('20130516110319');

INSERT INTO schema_migrations (version) VALUES ('20130517141325');

INSERT INTO schema_migrations (version) VALUES ('20130517153938');

INSERT INTO schema_migrations (version) VALUES ('20130520102445');

INSERT INTO schema_migrations (version) VALUES ('20130520140637');

INSERT INTO schema_migrations (version) VALUES ('20130522084204');

INSERT INTO schema_migrations (version) VALUES ('20130526103509');

INSERT INTO schema_migrations (version) VALUES ('20130604060612');

INSERT INTO schema_migrations (version) VALUES ('20130604074209');

INSERT INTO schema_migrations (version) VALUES ('20130604074528');

INSERT INTO schema_migrations (version) VALUES ('20130604074718');

INSERT INTO schema_migrations (version) VALUES ('20130604075259');

INSERT INTO schema_migrations (version) VALUES ('20130606091351');

INSERT INTO schema_migrations (version) VALUES ('20130606091511');

INSERT INTO schema_migrations (version) VALUES ('20130611091839');

INSERT INTO schema_migrations (version) VALUES ('20130628103056');

INSERT INTO schema_migrations (version) VALUES ('20130708113728');

INSERT INTO schema_migrations (version) VALUES ('20130710101547');

INSERT INTO schema_migrations (version) VALUES ('20130807123451');

INSERT INTO schema_migrations (version) VALUES ('20130812101510');

INSERT INTO schema_migrations (version) VALUES ('20130905100619');

INSERT INTO schema_migrations (version) VALUES ('20130909103419');

INSERT INTO schema_migrations (version) VALUES ('20130923105502');

INSERT INTO schema_migrations (version) VALUES ('20130923105853');

INSERT INTO schema_migrations (version) VALUES ('20130924131336');

INSERT INTO schema_migrations (version) VALUES ('20131010100653');

INSERT INTO schema_migrations (version) VALUES ('20131014110945');

INSERT INTO schema_migrations (version) VALUES ('20131022104154');

INSERT INTO schema_migrations (version) VALUES ('20131022104243');

INSERT INTO schema_migrations (version) VALUES ('20131022104456');

INSERT INTO schema_migrations (version) VALUES ('20131114122352');

INSERT INTO schema_migrations (version) VALUES ('20131114131314');

INSERT INTO schema_migrations (version) VALUES ('20131114131925');

INSERT INTO schema_migrations (version) VALUES ('20131203093048');

INSERT INTO schema_migrations (version) VALUES ('20131203143612');

INSERT INTO schema_migrations (version) VALUES ('20131204120553');

INSERT INTO schema_migrations (version) VALUES ('20131205110737');

INSERT INTO schema_migrations (version) VALUES ('20131211123106');

INSERT INTO schema_migrations (version) VALUES ('20131212105412');

INSERT INTO schema_migrations (version) VALUES ('20131212111228');

INSERT INTO schema_migrations (version) VALUES ('20131218085246');

INSERT INTO schema_migrations (version) VALUES ('20140110084054');

INSERT INTO schema_migrations (version) VALUES ('20140110084308');

INSERT INTO schema_migrations (version) VALUES ('20140110085646');

INSERT INTO schema_migrations (version) VALUES ('20140110095852');

INSERT INTO schema_migrations (version) VALUES ('20140110122025');

INSERT INTO schema_migrations (version) VALUES ('20140114141353');

INSERT INTO schema_migrations (version) VALUES ('20140117123257');

INSERT INTO schema_migrations (version) VALUES ('20140121113415');

INSERT INTO schema_migrations (version) VALUES ('20140124091314');

INSERT INTO schema_migrations (version) VALUES ('20140127095659');

INSERT INTO schema_migrations (version) VALUES ('20140127104555');

INSERT INTO schema_migrations (version) VALUES ('20140127104609');

INSERT INTO schema_migrations (version) VALUES ('20140127104708');

INSERT INTO schema_migrations (version) VALUES ('20140127132840');

INSERT INTO schema_migrations (version) VALUES ('20140128112029');

INSERT INTO schema_migrations (version) VALUES ('20140128121332');

INSERT INTO schema_migrations (version) VALUES ('20140128124938');

INSERT INTO schema_migrations (version) VALUES ('20140128144306');

INSERT INTO schema_migrations (version) VALUES ('20140129091803');

INSERT INTO schema_migrations (version) VALUES ('20140129124924');

INSERT INTO schema_migrations (version) VALUES ('20140129135228');

INSERT INTO schema_migrations (version) VALUES ('20140131091141');

INSERT INTO schema_migrations (version) VALUES ('20140131092344');

INSERT INTO schema_migrations (version) VALUES ('20140131103135');

INSERT INTO schema_migrations (version) VALUES ('20140131105037');

INSERT INTO schema_migrations (version) VALUES ('20140131125506');

INSERT INTO schema_migrations (version) VALUES ('20140210084712');

INSERT INTO schema_migrations (version) VALUES ('20140210141453');

INSERT INTO schema_migrations (version) VALUES ('20140211105008');

INSERT INTO schema_migrations (version) VALUES ('20140211133158');

INSERT INTO schema_migrations (version) VALUES ('20140225113327');

INSERT INTO schema_migrations (version) VALUES ('20140225132446');