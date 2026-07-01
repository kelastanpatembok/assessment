--
-- PostgreSQL database dump
--

\restrict 7s3ZyMH7JlDMk7dHwlMreXhUn11XqnhE0hfHVoc5xUewNQLmuhKxZZRrXtiWvpP

-- Dumped from database version 18.4 (Postgres.app)
-- Dumped by pg_dump version 18.4 (Postgres.app)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE IF EXISTS ONLY public.test_assignments DROP CONSTRAINT IF EXISTS test_assignments_student_id_fkey;
ALTER TABLE IF EXISTS ONLY public.test_assignments DROP CONSTRAINT IF EXISTS test_assignments_school_id_fkey;
ALTER TABLE IF EXISTS ONLY public.test_assignments DROP CONSTRAINT IF EXISTS test_assignments_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.papi_results DROP CONSTRAINT IF EXISTS papi_results_auth_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.papi_results DROP CONSTRAINT IF EXISTS papi_results_assignment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ist_results DROP CONSTRAINT IF EXISTS ist_results_auth_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.ist_results DROP CONSTRAINT IF EXISTS ist_results_assignment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.holland_results DROP CONSTRAINT IF EXISTS holland_results_auth_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.holland_results DROP CONSTRAINT IF EXISTS holland_results_assignment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.fee_shares DROP CONSTRAINT IF EXISTS fee_shares_student_id_fkey;
ALTER TABLE IF EXISTS ONLY public.fee_shares DROP CONSTRAINT IF EXISTS fee_shares_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.fee_config DROP CONSTRAINT IF EXISTS fee_config_category_id_fkey;
ALTER TABLE IF EXISTS ONLY public.disc_results DROP CONSTRAINT IF EXISTS disc_results_auth_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.disc_results DROP CONSTRAINT IF EXISTS disc_results_assignment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cfit_results DROP CONSTRAINT IF EXISTS cfit_results_auth_user_id_fkey;
ALTER TABLE IF EXISTS ONLY public.cfit_results DROP CONSTRAINT IF EXISTS cfit_results_assignment_id_fkey;
ALTER TABLE IF EXISTS ONLY public.assessment_users DROP CONSTRAINT IF EXISTS assessment_users_school_id_fkey;
DROP INDEX IF EXISTS public.idx_papi_q_trait;
DROP INDEX IF EXISTS public.idx_papi_q_pair;
DROP INDEX IF EXISTS public.idx_ist_q_subtest;
DROP INDEX IF EXISTS public.idx_holland_q_group;
DROP INDEX IF EXISTS public.idx_fee_shares_student;
DROP INDEX IF EXISTS public.idx_fee_shares_afiliator;
DROP INDEX IF EXISTS public.idx_disc_results_user;
DROP INDEX IF EXISTS public.idx_disc_q_block;
DROP INDEX IF EXISTS public.idx_cfit_q_subtest;
DROP INDEX IF EXISTS public.idx_assignments_student;
DROP INDEX IF EXISTS public.idx_assignments_school;
DROP INDEX IF EXISTS public.idx_assignments_category;
DROP INDEX IF EXISTS public.idx_assessment_users_school;
DROP INDEX IF EXISTS public.idx_assessment_users_role;
DROP INDEX IF EXISTS public.idx_assessment_users_afil;
DROP INDEX IF EXISTS public.idx_activity_user;
DROP INDEX IF EXISTS public.idx_activity_test;
DROP INDEX IF EXISTS public.flyway_schema_history_s_idx;
ALTER TABLE IF EXISTS ONLY public.test_categories DROP CONSTRAINT IF EXISTS test_categories_slug_key;
ALTER TABLE IF EXISTS ONLY public.test_categories DROP CONSTRAINT IF EXISTS test_categories_pkey;
ALTER TABLE IF EXISTS ONLY public.test_assignments DROP CONSTRAINT IF EXISTS test_assignments_pkey;
ALTER TABLE IF EXISTS ONLY public.schools DROP CONSTRAINT IF EXISTS schools_pkey;
ALTER TABLE IF EXISTS ONLY public.papi_results DROP CONSTRAINT IF EXISTS papi_results_pkey;
ALTER TABLE IF EXISTS ONLY public.papi_results DROP CONSTRAINT IF EXISTS papi_results_auth_user_id_key;
ALTER TABLE IF EXISTS ONLY public.papi_questions DROP CONSTRAINT IF EXISTS papi_questions_pkey;
ALTER TABLE IF EXISTS ONLY public.papi_questions DROP CONSTRAINT IF EXISTS papi_questions_pair_no_item_letter_key;
ALTER TABLE IF EXISTS ONLY public.papi_descriptions DROP CONSTRAINT IF EXISTS papi_descriptions_trait_code_key;
ALTER TABLE IF EXISTS ONLY public.papi_descriptions DROP CONSTRAINT IF EXISTS papi_descriptions_pkey;
ALTER TABLE IF EXISTS ONLY public.ist_zr_questions DROP CONSTRAINT IF EXISTS ist_zr_questions_pkey;
ALTER TABLE IF EXISTS ONLY public.ist_zr_questions DROP CONSTRAINT IF EXISTS ist_zr_questions_item_no_key;
ALTER TABLE IF EXISTS ONLY public.ist_wu_questions DROP CONSTRAINT IF EXISTS ist_wu_questions_pkey;
ALTER TABLE IF EXISTS ONLY public.ist_wu_questions DROP CONSTRAINT IF EXISTS ist_wu_questions_item_no_key;
ALTER TABLE IF EXISTS ONLY public.ist_results DROP CONSTRAINT IF EXISTS ist_results_pkey;
ALTER TABLE IF EXISTS ONLY public.ist_results DROP CONSTRAINT IF EXISTS ist_results_auth_user_id_key;
ALTER TABLE IF EXISTS ONLY public.ist_questions DROP CONSTRAINT IF EXISTS ist_questions_subtest_code_item_no_key;
ALTER TABLE IF EXISTS ONLY public.ist_questions DROP CONSTRAINT IF EXISTS ist_questions_pkey;
ALTER TABLE IF EXISTS ONLY public.ist_norma DROP CONSTRAINT IF EXISTS ist_norma_subtest_code_raw_score_key;
ALTER TABLE IF EXISTS ONLY public.ist_norma DROP CONSTRAINT IF EXISTS ist_norma_pkey;
ALTER TABLE IF EXISTS ONLY public.ist_me_pairs DROP CONSTRAINT IF EXISTS ist_me_pairs_pkey;
ALTER TABLE IF EXISTS ONLY public.ist_me_pairs DROP CONSTRAINT IF EXISTS ist_me_pairs_item_no_key;
ALTER TABLE IF EXISTS ONLY public.ist_iq_bands DROP CONSTRAINT IF EXISTS ist_iq_bands_wert_min_wert_max_key;
ALTER TABLE IF EXISTS ONLY public.ist_iq_bands DROP CONSTRAINT IF EXISTS ist_iq_bands_pkey;
ALTER TABLE IF EXISTS ONLY public.holland_results DROP CONSTRAINT IF EXISTS holland_results_pkey;
ALTER TABLE IF EXISTS ONLY public.holland_results DROP CONSTRAINT IF EXISTS holland_results_auth_user_id_key;
ALTER TABLE IF EXISTS ONLY public.holland_questions DROP CONSTRAINT IF EXISTS holland_questions_pkey;
ALTER TABLE IF EXISTS ONLY public.holland_questions DROP CONSTRAINT IF EXISTS holland_questions_group_code_item_no_key;
ALTER TABLE IF EXISTS ONLY public.holland_descriptions DROP CONSTRAINT IF EXISTS holland_descriptions_riasec_type_key;
ALTER TABLE IF EXISTS ONLY public.holland_descriptions DROP CONSTRAINT IF EXISTS holland_descriptions_pkey;
ALTER TABLE IF EXISTS ONLY public.flyway_schema_history DROP CONSTRAINT IF EXISTS flyway_schema_history_pk;
ALTER TABLE IF EXISTS ONLY public.fee_shares DROP CONSTRAINT IF EXISTS fee_shares_pkey;
ALTER TABLE IF EXISTS ONLY public.fee_config DROP CONSTRAINT IF EXISTS fee_config_pkey;
ALTER TABLE IF EXISTS ONLY public.fee_config DROP CONSTRAINT IF EXISTS fee_config_category_id_key;
ALTER TABLE IF EXISTS ONLY public.disc_scoring_most DROP CONSTRAINT IF EXISTS disc_scoring_most_pkey;
ALTER TABLE IF EXISTS ONLY public.disc_scoring_most DROP CONSTRAINT IF EXISTS disc_scoring_most_d_score_i_score_s_score_c_score_key;
ALTER TABLE IF EXISTS ONLY public.disc_scoring_least DROP CONSTRAINT IF EXISTS disc_scoring_least_pkey;
ALTER TABLE IF EXISTS ONLY public.disc_scoring_least DROP CONSTRAINT IF EXISTS disc_scoring_least_d_score_i_score_s_score_c_score_key;
ALTER TABLE IF EXISTS ONLY public.disc_scoring_dif DROP CONSTRAINT IF EXISTS disc_scoring_dif_pkey;
ALTER TABLE IF EXISTS ONLY public.disc_scoring_dif DROP CONSTRAINT IF EXISTS disc_scoring_dif_d_score_i_score_s_score_c_score_key;
ALTER TABLE IF EXISTS ONLY public.disc_results DROP CONSTRAINT IF EXISTS disc_results_pkey;
ALTER TABLE IF EXISTS ONLY public.disc_results DROP CONSTRAINT IF EXISTS disc_results_auth_user_id_key;
ALTER TABLE IF EXISTS ONLY public.disc_questions DROP CONSTRAINT IF EXISTS disc_questions_pkey;
ALTER TABLE IF EXISTS ONLY public.disc_questions DROP CONSTRAINT IF EXISTS disc_questions_block_no_item_no_key;
ALTER TABLE IF EXISTS ONLY public.disc_personality_profiles DROP CONSTRAINT IF EXISTS disc_personality_profiles_pkey;
ALTER TABLE IF EXISTS ONLY public.disc_personality_profiles DROP CONSTRAINT IF EXISTS disc_personality_profiles_most_key_least_key_dif_key_key;
ALTER TABLE IF EXISTS ONLY public.cfit_results DROP CONSTRAINT IF EXISTS cfit_results_pkey;
ALTER TABLE IF EXISTS ONLY public.cfit_results DROP CONSTRAINT IF EXISTS cfit_results_auth_user_id_key;
ALTER TABLE IF EXISTS ONLY public.cfit_questions DROP CONSTRAINT IF EXISTS cfit_questions_subtest_no_item_no_key;
ALTER TABLE IF EXISTS ONLY public.cfit_questions DROP CONSTRAINT IF EXISTS cfit_questions_pkey;
ALTER TABLE IF EXISTS ONLY public.cfit_descriptions DROP CONSTRAINT IF EXISTS cfit_descriptions_pkey;
ALTER TABLE IF EXISTS ONLY public.assessment_users DROP CONSTRAINT IF EXISTS assessment_users_pkey;
ALTER TABLE IF EXISTS ONLY public.activity_logs DROP CONSTRAINT IF EXISTS activity_logs_pkey;
ALTER TABLE IF EXISTS public.test_categories ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.test_assignments ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.schools ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.papi_results ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.papi_questions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.papi_descriptions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.ist_zr_questions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.ist_wu_questions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.ist_results ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.ist_questions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.ist_norma ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.ist_me_pairs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.ist_iq_bands ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.holland_results ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.holland_questions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.holland_descriptions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.fee_shares ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.fee_config ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.disc_scoring_most ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.disc_scoring_least ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.disc_scoring_dif ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.disc_results ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.disc_questions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.disc_personality_profiles ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.cfit_results ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.cfit_questions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.cfit_descriptions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE IF EXISTS public.activity_logs ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE IF EXISTS public.test_categories_id_seq;
DROP TABLE IF EXISTS public.test_categories;
DROP SEQUENCE IF EXISTS public.test_assignments_id_seq;
DROP TABLE IF EXISTS public.test_assignments;
DROP SEQUENCE IF EXISTS public.schools_id_seq;
DROP TABLE IF EXISTS public.schools;
DROP SEQUENCE IF EXISTS public.papi_results_id_seq;
DROP TABLE IF EXISTS public.papi_results;
DROP SEQUENCE IF EXISTS public.papi_questions_id_seq;
DROP TABLE IF EXISTS public.papi_questions;
DROP SEQUENCE IF EXISTS public.papi_descriptions_id_seq;
DROP TABLE IF EXISTS public.papi_descriptions;
DROP SEQUENCE IF EXISTS public.ist_zr_questions_id_seq;
DROP TABLE IF EXISTS public.ist_zr_questions;
DROP SEQUENCE IF EXISTS public.ist_wu_questions_id_seq;
DROP TABLE IF EXISTS public.ist_wu_questions;
DROP SEQUENCE IF EXISTS public.ist_results_id_seq;
DROP TABLE IF EXISTS public.ist_results;
DROP SEQUENCE IF EXISTS public.ist_questions_id_seq;
DROP TABLE IF EXISTS public.ist_questions;
DROP SEQUENCE IF EXISTS public.ist_norma_id_seq;
DROP TABLE IF EXISTS public.ist_norma;
DROP SEQUENCE IF EXISTS public.ist_me_pairs_id_seq;
DROP TABLE IF EXISTS public.ist_me_pairs;
DROP SEQUENCE IF EXISTS public.ist_iq_bands_id_seq;
DROP TABLE IF EXISTS public.ist_iq_bands;
DROP SEQUENCE IF EXISTS public.holland_results_id_seq;
DROP TABLE IF EXISTS public.holland_results;
DROP SEQUENCE IF EXISTS public.holland_questions_id_seq;
DROP TABLE IF EXISTS public.holland_questions;
DROP SEQUENCE IF EXISTS public.holland_descriptions_id_seq;
DROP TABLE IF EXISTS public.holland_descriptions;
DROP TABLE IF EXISTS public.flyway_schema_history;
DROP SEQUENCE IF EXISTS public.fee_shares_id_seq;
DROP TABLE IF EXISTS public.fee_shares;
DROP SEQUENCE IF EXISTS public.fee_config_id_seq;
DROP TABLE IF EXISTS public.fee_config;
DROP SEQUENCE IF EXISTS public.disc_scoring_most_id_seq;
DROP TABLE IF EXISTS public.disc_scoring_most;
DROP SEQUENCE IF EXISTS public.disc_scoring_least_id_seq;
DROP TABLE IF EXISTS public.disc_scoring_least;
DROP SEQUENCE IF EXISTS public.disc_scoring_dif_id_seq;
DROP TABLE IF EXISTS public.disc_scoring_dif;
DROP SEQUENCE IF EXISTS public.disc_results_id_seq;
DROP TABLE IF EXISTS public.disc_results;
DROP SEQUENCE IF EXISTS public.disc_questions_id_seq;
DROP TABLE IF EXISTS public.disc_questions;
DROP SEQUENCE IF EXISTS public.disc_personality_profiles_id_seq;
DROP TABLE IF EXISTS public.disc_personality_profiles;
DROP SEQUENCE IF EXISTS public.cfit_results_id_seq;
DROP TABLE IF EXISTS public.cfit_results;
DROP SEQUENCE IF EXISTS public.cfit_questions_id_seq;
DROP TABLE IF EXISTS public.cfit_questions;
DROP SEQUENCE IF EXISTS public.cfit_descriptions_id_seq;
DROP TABLE IF EXISTS public.cfit_descriptions;
DROP TABLE IF EXISTS public.assessment_users;
DROP SEQUENCE IF EXISTS public.activity_logs_id_seq;
DROP TABLE IF EXISTS public.activity_logs;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activity_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.activity_logs (
    id bigint NOT NULL,
    auth_user_id character varying(64) NOT NULL,
    test_type character varying(20) NOT NULL,
    event_type character varying(20) NOT NULL,
    metadata jsonb,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: activity_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.activity_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: activity_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.activity_logs_id_seq OWNED BY public.activity_logs.id;


--
-- Name: assessment_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.assessment_users (
    auth_user_id character varying(64) NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    username character varying(100) NOT NULL,
    role character varying(30) NOT NULL,
    school_id bigint,
    afiliator_id character varying(64),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: cfit_descriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cfit_descriptions (
    id bigint NOT NULL,
    score_min integer NOT NULL,
    score_max integer NOT NULL,
    iq_min integer,
    iq_max integer,
    category character varying(50),
    description text
);


--
-- Name: cfit_descriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cfit_descriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cfit_descriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cfit_descriptions_id_seq OWNED BY public.cfit_descriptions.id;


--
-- Name: cfit_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cfit_questions (
    id bigint NOT NULL,
    subtest_no integer NOT NULL,
    item_no integer NOT NULL,
    question_text text,
    image_url character varying(500),
    options jsonb,
    correct_answer character varying(1) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT cfit_questions_subtest_no_check CHECK (((subtest_no >= 1) AND (subtest_no <= 4)))
);


--
-- Name: cfit_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cfit_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cfit_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cfit_questions_id_seq OWNED BY public.cfit_questions.id;


--
-- Name: cfit_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cfit_results (
    id bigint NOT NULL,
    auth_user_id character varying(64) NOT NULL,
    student_name character varying(255),
    school_name character varying(255),
    assignment_id bigint,
    sub1_score integer DEFAULT 0 NOT NULL,
    sub2_score integer DEFAULT 0 NOT NULL,
    sub3_score integer DEFAULT 0 NOT NULL,
    sub4_score integer DEFAULT 0 NOT NULL,
    total_score integer DEFAULT 0 NOT NULL,
    iq_score integer,
    category character varying(50),
    description text,
    answers jsonb,
    completed_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: cfit_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cfit_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cfit_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cfit_results_id_seq OWNED BY public.cfit_results.id;


--
-- Name: disc_personality_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disc_personality_profiles (
    id bigint NOT NULL,
    most_key character varying(10) NOT NULL,
    least_key character varying(10) NOT NULL,
    dif_key character varying(10) NOT NULL,
    title character varying(100) NOT NULL,
    description text
);


--
-- Name: disc_personality_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disc_personality_profiles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disc_personality_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disc_personality_profiles_id_seq OWNED BY public.disc_personality_profiles.id;


--
-- Name: disc_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disc_questions (
    id bigint NOT NULL,
    block_no integer NOT NULL,
    item_no integer NOT NULL,
    category character varying(1) NOT NULL,
    statement text NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: disc_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disc_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disc_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disc_questions_id_seq OWNED BY public.disc_questions.id;


--
-- Name: disc_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disc_results (
    id bigint NOT NULL,
    auth_user_id character varying(64) NOT NULL,
    student_name character varying(255),
    school_name character varying(255),
    assignment_id bigint,
    d_most integer DEFAULT 0 NOT NULL,
    i_most integer DEFAULT 0 NOT NULL,
    s_most integer DEFAULT 0 NOT NULL,
    c_most integer DEFAULT 0 NOT NULL,
    d_least integer DEFAULT 0 NOT NULL,
    i_least integer DEFAULT 0 NOT NULL,
    s_least integer DEFAULT 0 NOT NULL,
    c_least integer DEFAULT 0 NOT NULL,
    d_dif integer DEFAULT 0 NOT NULL,
    i_dif integer DEFAULT 0 NOT NULL,
    s_dif integer DEFAULT 0 NOT NULL,
    c_dif integer DEFAULT 0 NOT NULL,
    most_key character varying(10),
    least_key character varying(10),
    dif_key character varying(10),
    profile_title character varying(100),
    profile_desc text,
    answers jsonb,
    completed_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: disc_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disc_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disc_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disc_results_id_seq OWNED BY public.disc_results.id;


--
-- Name: disc_scoring_dif; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disc_scoring_dif (
    id bigint NOT NULL,
    d_score integer NOT NULL,
    i_score integer NOT NULL,
    s_score integer NOT NULL,
    c_score integer NOT NULL,
    key character varying(10) NOT NULL
);


--
-- Name: disc_scoring_dif_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disc_scoring_dif_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disc_scoring_dif_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disc_scoring_dif_id_seq OWNED BY public.disc_scoring_dif.id;


--
-- Name: disc_scoring_least; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disc_scoring_least (
    id bigint NOT NULL,
    d_score integer NOT NULL,
    i_score integer NOT NULL,
    s_score integer NOT NULL,
    c_score integer NOT NULL,
    key character varying(10) NOT NULL
);


--
-- Name: disc_scoring_least_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disc_scoring_least_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disc_scoring_least_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disc_scoring_least_id_seq OWNED BY public.disc_scoring_least.id;


--
-- Name: disc_scoring_most; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.disc_scoring_most (
    id bigint NOT NULL,
    d_score integer NOT NULL,
    i_score integer NOT NULL,
    s_score integer NOT NULL,
    c_score integer NOT NULL,
    key character varying(10) NOT NULL
);


--
-- Name: disc_scoring_most_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.disc_scoring_most_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: disc_scoring_most_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.disc_scoring_most_id_seq OWNED BY public.disc_scoring_most.id;


--
-- Name: fee_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fee_config (
    id bigint NOT NULL,
    category_id bigint,
    student_fee numeric(14,2) DEFAULT 0 NOT NULL,
    afiliator_share_pct numeric(5,2) DEFAULT 0 NOT NULL,
    gurubk_share_pct numeric(5,2) DEFAULT 0 NOT NULL,
    platform_share_pct numeric(5,2) DEFAULT 100 NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: fee_config_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fee_config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fee_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fee_config_id_seq OWNED BY public.fee_config.id;


--
-- Name: fee_shares; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.fee_shares (
    id bigint NOT NULL,
    student_id character varying(64) NOT NULL,
    category_id bigint NOT NULL,
    afiliator_id character varying(64),
    gurubk_id character varying(64),
    total_fee numeric(14,2) DEFAULT 0 NOT NULL,
    afiliator_share numeric(14,2) DEFAULT 0 NOT NULL,
    gurubk_share numeric(14,2) DEFAULT 0 NOT NULL,
    platform_share numeric(14,2) DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: fee_shares_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.fee_shares_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: fee_shares_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.fee_shares_id_seq OWNED BY public.fee_shares.id;


--
-- Name: flyway_schema_history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


--
-- Name: holland_descriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.holland_descriptions (
    id bigint NOT NULL,
    riasec_type character varying(1) NOT NULL,
    name character varying(50) NOT NULL,
    description text,
    careers text
);


--
-- Name: holland_descriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.holland_descriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: holland_descriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.holland_descriptions_id_seq OWNED BY public.holland_descriptions.id;


--
-- Name: holland_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.holland_questions (
    id bigint NOT NULL,
    group_code character varying(3) NOT NULL,
    item_no integer NOT NULL,
    riasec_type character varying(1) NOT NULL,
    statement text NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: holland_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.holland_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: holland_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.holland_questions_id_seq OWNED BY public.holland_questions.id;


--
-- Name: holland_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.holland_results (
    id bigint NOT NULL,
    auth_user_id character varying(64) NOT NULL,
    student_name character varying(255),
    school_name character varying(255),
    assignment_id bigint,
    r_score integer DEFAULT 0 NOT NULL,
    i_score integer DEFAULT 0 NOT NULL,
    a_score integer DEFAULT 0 NOT NULL,
    s_score integer DEFAULT 0 NOT NULL,
    e_score integer DEFAULT 0 NOT NULL,
    c_score integer DEFAULT 0 NOT NULL,
    type1 character varying(1),
    type2 character varying(1),
    type3 character varying(1),
    holland_code character varying(3),
    type1_name character varying(50),
    type1_desc text,
    answers jsonb,
    completed_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: holland_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.holland_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: holland_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.holland_results_id_seq OWNED BY public.holland_results.id;


--
-- Name: ist_iq_bands; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ist_iq_bands (
    id bigint NOT NULL,
    wert_min integer NOT NULL,
    wert_max integer NOT NULL,
    iq_min integer NOT NULL,
    iq_max integer NOT NULL,
    category character varying(50)
);


--
-- Name: ist_iq_bands_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ist_iq_bands_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ist_iq_bands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ist_iq_bands_id_seq OWNED BY public.ist_iq_bands.id;


--
-- Name: ist_me_pairs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ist_me_pairs (
    id bigint NOT NULL,
    item_no integer NOT NULL,
    word1 character varying(100) NOT NULL,
    word2 character varying(100) NOT NULL,
    options jsonb,
    correct_answer character varying(50) NOT NULL
);


--
-- Name: ist_me_pairs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ist_me_pairs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ist_me_pairs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ist_me_pairs_id_seq OWNED BY public.ist_me_pairs.id;


--
-- Name: ist_norma; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ist_norma (
    id bigint NOT NULL,
    subtest_code character varying(3) NOT NULL,
    raw_score integer NOT NULL,
    wert integer NOT NULL
);


--
-- Name: ist_norma_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ist_norma_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ist_norma_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ist_norma_id_seq OWNED BY public.ist_norma.id;


--
-- Name: ist_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ist_questions (
    id bigint NOT NULL,
    subtest_code character varying(3) NOT NULL,
    item_no integer NOT NULL,
    question_text text,
    image_url character varying(500),
    options jsonb,
    correct_answer character varying(20),
    time_limit_sec integer,
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: ist_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ist_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ist_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ist_questions_id_seq OWNED BY public.ist_questions.id;


--
-- Name: ist_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ist_results (
    id bigint NOT NULL,
    auth_user_id character varying(64) NOT NULL,
    student_name character varying(255),
    school_name character varying(255),
    assignment_id bigint,
    subtest_scores jsonb DEFAULT '{}'::jsonb NOT NULL,
    total_wert integer,
    iq_score integer,
    iq_category character varying(50),
    answers jsonb,
    completed_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: ist_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ist_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ist_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ist_results_id_seq OWNED BY public.ist_results.id;


--
-- Name: ist_wu_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ist_wu_questions (
    id bigint NOT NULL,
    item_no integer NOT NULL,
    statement text NOT NULL,
    correct_answer character varying(10) NOT NULL
);


--
-- Name: ist_wu_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ist_wu_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ist_wu_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ist_wu_questions_id_seq OWNED BY public.ist_wu_questions.id;


--
-- Name: ist_zr_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ist_zr_questions (
    id bigint NOT NULL,
    item_no integer NOT NULL,
    sequence_text text NOT NULL,
    correct_answer integer NOT NULL
);


--
-- Name: ist_zr_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ist_zr_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ist_zr_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ist_zr_questions_id_seq OWNED BY public.ist_zr_questions.id;


--
-- Name: papi_descriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.papi_descriptions (
    id bigint NOT NULL,
    trait_code character varying(2) NOT NULL,
    trait_name character varying(100) NOT NULL,
    description text,
    high_desc text,
    low_desc text
);


--
-- Name: papi_descriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.papi_descriptions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: papi_descriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.papi_descriptions_id_seq OWNED BY public.papi_descriptions.id;


--
-- Name: papi_questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.papi_questions (
    id bigint NOT NULL,
    pair_no integer NOT NULL,
    item_letter character varying(1) NOT NULL,
    trait_code character varying(2) NOT NULL,
    statement text NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: papi_questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.papi_questions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: papi_questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.papi_questions_id_seq OWNED BY public.papi_questions.id;


--
-- Name: papi_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.papi_results (
    id bigint NOT NULL,
    auth_user_id character varying(64) NOT NULL,
    student_name character varying(255),
    school_name character varying(255),
    assignment_id bigint,
    trait_scores jsonb DEFAULT '{}'::jsonb NOT NULL,
    answers jsonb,
    completed_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: papi_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.papi_results_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: papi_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.papi_results_id_seq OWNED BY public.papi_results.id;


--
-- Name: schools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schools (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    address text,
    city character varying(100),
    province character varying(100),
    phone character varying(30),
    email character varying(255),
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: schools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.schools_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: schools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.schools_id_seq OWNED BY public.schools.id;


--
-- Name: test_assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_assignments (
    id bigint NOT NULL,
    category_id bigint NOT NULL,
    school_id bigint,
    student_id character varying(64),
    assigned_by character varying(64) NOT NULL,
    window_start timestamp without time zone,
    window_end timestamp without time zone,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT ck_assignment_target CHECK (((school_id IS NOT NULL) OR (student_id IS NOT NULL)))
);


--
-- Name: test_assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.test_assignments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: test_assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.test_assignments_id_seq OWNED BY public.test_assignments.id;


--
-- Name: test_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_categories (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    slug character varying(100) NOT NULL,
    description text,
    tests text[] DEFAULT '{}'::text[] NOT NULL,
    price numeric(14,2) DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: test_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.test_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: test_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.test_categories_id_seq OWNED BY public.test_categories.id;


--
-- Name: activity_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_logs ALTER COLUMN id SET DEFAULT nextval('public.activity_logs_id_seq'::regclass);


--
-- Name: cfit_descriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfit_descriptions ALTER COLUMN id SET DEFAULT nextval('public.cfit_descriptions_id_seq'::regclass);


--
-- Name: cfit_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfit_questions ALTER COLUMN id SET DEFAULT nextval('public.cfit_questions_id_seq'::regclass);


--
-- Name: cfit_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfit_results ALTER COLUMN id SET DEFAULT nextval('public.cfit_results_id_seq'::regclass);


--
-- Name: disc_personality_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_personality_profiles ALTER COLUMN id SET DEFAULT nextval('public.disc_personality_profiles_id_seq'::regclass);


--
-- Name: disc_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_questions ALTER COLUMN id SET DEFAULT nextval('public.disc_questions_id_seq'::regclass);


--
-- Name: disc_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_results ALTER COLUMN id SET DEFAULT nextval('public.disc_results_id_seq'::regclass);


--
-- Name: disc_scoring_dif id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_scoring_dif ALTER COLUMN id SET DEFAULT nextval('public.disc_scoring_dif_id_seq'::regclass);


--
-- Name: disc_scoring_least id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_scoring_least ALTER COLUMN id SET DEFAULT nextval('public.disc_scoring_least_id_seq'::regclass);


--
-- Name: disc_scoring_most id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_scoring_most ALTER COLUMN id SET DEFAULT nextval('public.disc_scoring_most_id_seq'::regclass);


--
-- Name: fee_config id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_config ALTER COLUMN id SET DEFAULT nextval('public.fee_config_id_seq'::regclass);


--
-- Name: fee_shares id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_shares ALTER COLUMN id SET DEFAULT nextval('public.fee_shares_id_seq'::regclass);


--
-- Name: holland_descriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.holland_descriptions ALTER COLUMN id SET DEFAULT nextval('public.holland_descriptions_id_seq'::regclass);


--
-- Name: holland_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.holland_questions ALTER COLUMN id SET DEFAULT nextval('public.holland_questions_id_seq'::regclass);


--
-- Name: holland_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.holland_results ALTER COLUMN id SET DEFAULT nextval('public.holland_results_id_seq'::regclass);


--
-- Name: ist_iq_bands id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_iq_bands ALTER COLUMN id SET DEFAULT nextval('public.ist_iq_bands_id_seq'::regclass);


--
-- Name: ist_me_pairs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_me_pairs ALTER COLUMN id SET DEFAULT nextval('public.ist_me_pairs_id_seq'::regclass);


--
-- Name: ist_norma id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_norma ALTER COLUMN id SET DEFAULT nextval('public.ist_norma_id_seq'::regclass);


--
-- Name: ist_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_questions ALTER COLUMN id SET DEFAULT nextval('public.ist_questions_id_seq'::regclass);


--
-- Name: ist_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_results ALTER COLUMN id SET DEFAULT nextval('public.ist_results_id_seq'::regclass);


--
-- Name: ist_wu_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_wu_questions ALTER COLUMN id SET DEFAULT nextval('public.ist_wu_questions_id_seq'::regclass);


--
-- Name: ist_zr_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_zr_questions ALTER COLUMN id SET DEFAULT nextval('public.ist_zr_questions_id_seq'::regclass);


--
-- Name: papi_descriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papi_descriptions ALTER COLUMN id SET DEFAULT nextval('public.papi_descriptions_id_seq'::regclass);


--
-- Name: papi_questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papi_questions ALTER COLUMN id SET DEFAULT nextval('public.papi_questions_id_seq'::regclass);


--
-- Name: papi_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papi_results ALTER COLUMN id SET DEFAULT nextval('public.papi_results_id_seq'::regclass);


--
-- Name: schools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools ALTER COLUMN id SET DEFAULT nextval('public.schools_id_seq'::regclass);


--
-- Name: test_assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_assignments ALTER COLUMN id SET DEFAULT nextval('public.test_assignments_id_seq'::regclass);


--
-- Name: test_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_categories ALTER COLUMN id SET DEFAULT nextval('public.test_categories_id_seq'::regclass);


--
-- Data for Name: activity_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.activity_logs (id, auth_user_id, test_type, event_type, metadata, created_at) FROM stdin;
1	6a2e78f6572208361f6edc48	disc	START	{}	2026-06-14 17:16:56.824524
2	6a2e78f6572208361f6edc48	disc	FINISH	{"resultId": 1}	2026-06-14 17:16:56.896616
3	6a2e78f6572208361f6edc48	holland	START	{}	2026-06-14 17:18:22.167213
4	6a2e78f6572208361f6edc48	holland	FINISH	{"resultId": 1}	2026-06-14 17:18:22.217805
5	6a2e78f6572208361f6edc48	papi	START	{}	2026-06-14 17:18:58.772235
6	6a2e78f6572208361f6edc48	papi	FINISH	{"resultId": 1}	2026-06-14 17:18:58.823115
7	6a2e78f6572208361f6edc48	cfit	START	{}	2026-06-14 17:19:45.579379
8	6a2e78f6572208361f6edc48	cfit	FINISH	{"resultId": 1}	2026-06-14 17:19:45.622902
9	6a2e78f6572208361f6edc48	ist	START	{}	2026-06-14 17:20:56.201597
10	6a2e78f6572208361f6edc48	ist	FINISH	{"resultId": 1}	2026-06-14 17:20:56.24245
11	system	credential	GENERATE	{"count": 1, "schoolName": "SMP Muhammadiyah Yogyakarta 2", "description": "Generated 1 student credentials for SMP Muhammadiyah Yogyakarta 2 - Paket Lengkap (by admin)", "testCategory": "Paket Lengkap", "adminUsername": "admin"}	2026-06-19 15:52:48.868455
12	system	credential	GENERATE	{"count": 1, "schoolName": "SMP Muhammadiyah Yogyakarta 2", "description": "Generated 1 student credentials for SMP Muhammadiyah Yogyakarta 2 - Paket Lengkap (by admin)", "testCategory": "Paket Lengkap", "adminUsername": "admin"}	2026-06-19 15:53:45.637994
13	system	credential	GENERATE	{"count": 1, "schoolName": "SMP Muhammadiyah Yogyakarta 2", "description": "Generated 1 student credentials for SMP Muhammadiyah Yogyakarta 2 - Paket Lengkap (by admin)", "testCategory": "Paket Lengkap", "adminUsername": "admin"}	2026-06-19 15:54:45.094903
14	system	credential	GENERATE	{"count": 100, "schoolName": "SMP Muhammadiyah Yogyakarta 2", "description": "Generated 100 student credentials for SMP Muhammadiyah Yogyakarta 2 - Paket Lengkap (by admin)", "testCategory": "Paket Lengkap", "adminUsername": "admin"}	2026-06-19 15:57:08.747336
15	system	credential	GENERATE	{"count": 100, "schoolName": "SMP Muhammadiyah Yogyakarta 2", "description": "Generated 100 student credentials for SMP Muhammadiyah Yogyakarta 2 - Paket Lengkap (by admin)", "testCategory": "Paket Lengkap", "adminUsername": "admin"}	2026-06-19 16:07:12.802703
16	system	credential	GENERATE	{"count": 20, "schoolName": "SMP Muhammadiyah Yogyakarta 2", "description": "Generated 20 student credentials for SMP Muhammadiyah Yogyakarta 2 - Paket Lengkap (by admin)", "testCategory": "Paket Lengkap", "adminUsername": "admin"}	2026-06-19 16:34:54.284201
\.


--
-- Data for Name: assessment_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.assessment_users (auth_user_id, name, email, username, role, school_id, afiliator_id, created_at, updated_at) FROM stdin;
6a3502ebc3f01f1a8a28f0cf	Student SMPMUHAMMA_PAKETLENG_001	SMPMUHAMMA_PAKETLENG_001@generated.local	SMPMUHAMMA_PAKETLENG_001	siswa	1	\N	2026-06-19 15:50:52.311457	2026-06-19 15:50:52.311457
cc2f0f8a-59a3-4a5e-9bfe-1c670c519393	Siswa 1	siswa1_smpmuh2@example.com	siswa2_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
6a2f938428122e3f5678ee04	afiliator	afiliator@gmail.com	afiliator	afiliator	\N	\N	2026-06-15 12:54:13.348585	2026-06-15 12:54:13.348585
474fa60f-cac7-4e68-bd73-29445b913130	Bapak Budi (Guru BK)	gurubk_smpmuh2@example.com	gurubk_smpmuh2	gurubk	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
1654ba45-7070-4d1b-a8d2-f09e3f64c11e	Siswa 2	siswa2_smpmuh2@example.com	siswa3_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
4c9ca049-08a2-4b28-a5d8-c8b69ec084bf	Siswa 3	siswa3_smpmuh2@example.com	siswa4_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
1e6a9e81-1ac2-46b5-a700-4c76ed08536d	Siswa 4	siswa4_smpmuh2@example.com	siswa5_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
4ca82485-a400-43b5-bbdb-0292a8b19538	Siswa 5	siswa5_smpmuh2@example.com	siswa6_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
266c53e9-355e-4176-bebd-c7c0f088e93c	Siswa 6	siswa6_smpmuh2@example.com	siswa7_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
a0355bd2-dd2f-4e2e-b188-8e24fc0247fc	Siswa 7	siswa7_smpmuh2@example.com	siswa8_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
9657db6a-b9fc-4ab5-99ba-b1dce9318094	Siswa 8	siswa8_smpmuh2@example.com	siswa9_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
82d8f94b-dedb-4e9d-8d60-420d022ad08e	Siswa 9	siswa9_smpmuh2@example.com	siswa10_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
2d1666f6-f176-47d6-91b0-3d1af8045d49	Siswa 10	siswa10_smpmuh2@example.com	siswa11_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
d608456c-2cf9-4b7d-af93-7fec87443402	Siswa 11	siswa11_smpmuh2@example.com	siswa12_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
15419209-5200-46da-b3f9-c8a63d1d57d2	Siswa 12	siswa12_smpmuh2@example.com	siswa13_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
0532d0ed-4f72-45ea-a2a9-4c3a818ec580	Siswa 13	siswa13_smpmuh2@example.com	siswa14_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
eef746bc-85f4-47dd-93c6-9cedb993e8ef	Siswa 14	siswa14_smpmuh2@example.com	siswa15_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
21e9cce0-931e-4a32-b8a6-a38e52ecfd40	Siswa 15	siswa15_smpmuh2@example.com	siswa16_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
5a32cb0e-557a-46c7-9b68-9864b80d0976	Siswa 16	siswa16_smpmuh2@example.com	siswa17_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
1fa0df89-40ec-4307-9fdd-346b68185bf2	Siswa 17	siswa17_smpmuh2@example.com	siswa18_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
c8065771-c617-4db7-87ba-8a948282e8f6	Siswa 18	siswa18_smpmuh2@example.com	siswa19_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
c3c2f6d7-0d35-4d04-922d-0146a7270185	Siswa 19	siswa19_smpmuh2@example.com	siswa20_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
83ee8be1-1151-4ff3-951c-b722dbf4d232	Siswa 20	siswa20_smpmuh2@example.com	siswa21_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
a3223597-2552-4dd8-8931-41775fd19d10	Siswa 21	siswa21_smpmuh2@example.com	siswa22_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
6e98e408-5a17-41ae-ad00-037080b85e0d	Siswa 22	siswa22_smpmuh2@example.com	siswa23_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
efcc2939-2506-44c2-9bd4-6e19395b5451	Siswa 23	siswa23_smpmuh2@example.com	siswa24_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
0ca8b3ea-875d-421c-b230-10857175c683	Siswa 24	siswa24_smpmuh2@example.com	siswa25_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
9ad7e7fb-8086-4fb3-bef4-62a3a181187d	Siswa 25	siswa25_smpmuh2@example.com	siswa26_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
c5a84425-3349-4ad8-9240-e1b68d62d6ef	Siswa 26	siswa26_smpmuh2@example.com	siswa27_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
e7a9d7b1-835e-4edd-ac5d-2ba67d5bad47	Siswa 27	siswa27_smpmuh2@example.com	siswa28_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
e1721a26-bee5-48f4-84ad-452212c07821	Siswa 28	siswa28_smpmuh2@example.com	siswa29_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
16c5ab27-122e-4684-bab9-bfad23cbae2d	Siswa 29	siswa29_smpmuh2@example.com	siswa30_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
250b647f-4439-4350-b1c2-52c65cc97a10	Siswa 30	siswa30_smpmuh2@example.com	siswa31_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
d082f677-513d-4b8f-9cef-c73b784503b6	Siswa 31	siswa31_smpmuh2@example.com	siswa32_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
cf9649b8-de12-454a-a441-6950a18718b9	Siswa 32	siswa32_smpmuh2@example.com	siswa33_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
7a1b13e6-55be-48e1-81d1-251ce6e50878	Siswa 34	siswa34_smpmuh2@example.com	siswa35_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
baa619f4-f59f-492e-bf41-67073f934db4	Siswa 35	siswa35_smpmuh2@example.com	siswa36_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
b3e99c8c-5f9d-46ac-88de-e305679eb454	Siswa 36	siswa36_smpmuh2@example.com	siswa37_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
edf1feed-3035-4133-ac3b-6c46e0ad3ef8	Siswa 37	siswa37_smpmuh2@example.com	siswa38_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
893c6a6a-37c1-4e20-a1cc-f6f7878a5883	Siswa 38	siswa38_smpmuh2@example.com	siswa39_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
4358ed04-3f46-45dc-804d-9cb71671cba8	Siswa 39	siswa39_smpmuh2@example.com	siswa40_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
3efb78be-bc11-400c-968b-49a1bef666d6	Siswa 40	siswa40_smpmuh2@example.com	siswa41_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
02b4ff08-2975-44ec-931a-7ac911e503b5	Siswa 41	siswa41_smpmuh2@example.com	siswa42_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
9977dfc6-4374-4406-9059-a4a50b9a1373	Siswa 42	siswa42_smpmuh2@example.com	siswa43_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
e2f4031c-750d-4283-8740-75d0c7d9b5fe	Siswa 43	siswa43_smpmuh2@example.com	siswa44_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
ef6dc49d-8639-4636-b4cc-2e3fa40d9a94	Siswa 44	siswa44_smpmuh2@example.com	siswa45_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
5516a843-6fdf-4a4d-9264-88d932b7197a	Siswa 45	siswa45_smpmuh2@example.com	siswa46_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
55492aef-4a9e-4cbf-8a66-940afc571470	Siswa 46	siswa46_smpmuh2@example.com	siswa47_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
9b2e0574-8b56-4126-9576-e50eeb80d2f7	Siswa 47	siswa47_smpmuh2@example.com	siswa48_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
ecd99560-cb6f-4359-af98-4b0d65690cda	Siswa 48	siswa48_smpmuh2@example.com	siswa49_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
6a3503d4c3f01f1a8a28f0d1	Student SMPMUHAMMA_PAKETLENGK_001	SMPMUHAMMA_PAKETLENGK_001@generated.local	SMPMUHAMMA_PAKETLENGK_001	siswa	1	\N	2026-06-19 15:54:45.086926	2026-06-19 15:54:45.086926
7130a9fd-8021-402a-a29f-0e820a9805d0	Siswa 50	siswa50_smpmuh2@example.com	siswa51_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
3dd7f158-22c1-4969-94e5-3685d27635f8	Siswa 51	siswa51_smpmuh2@example.com	siswa52_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
00a1036d-78e4-4a5d-9274-f64b86710af4	Siswa 52	siswa52_smpmuh2@example.com	siswa53_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
8c53f9b7-bca2-495e-b7a1-1e72f3ae1d66	Siswa 53	siswa53_smpmuh2@example.com	siswa54_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
cecc9511-5026-4181-b1bd-b5fc24db8166	Siswa 54	siswa54_smpmuh2@example.com	siswa55_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
b210a83a-93df-4e56-994c-e9c507868513	Siswa 55	siswa55_smpmuh2@example.com	siswa56_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
3772b413-138d-405f-bfdd-61477808fc92	Siswa 56	siswa56_smpmuh2@example.com	siswa57_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
eacc4913-7529-40d2-ba62-446d8c45bd9b	Siswa 57	siswa57_smpmuh2@example.com	siswa58_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
daab5116-420e-46e1-9e00-bfdcba51edd7	Siswa 58	siswa58_smpmuh2@example.com	siswa59_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
42dab708-e9d7-4cc4-a9ab-99448dcec05e	Siswa 59	siswa59_smpmuh2@example.com	siswa60_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
3128126c-b3f9-4c19-a435-9cbb527b790f	Siswa 60	siswa60_smpmuh2@example.com	siswa61_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
94dc98e0-d52c-47a0-9cf7-7d1d29f50eae	Siswa 61	siswa61_smpmuh2@example.com	siswa62_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
6b13554f-3f28-4133-8afe-9bd13881e537	Siswa 63	siswa63_smpmuh2@example.com	siswa64_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
777088a3-62f1-4fd5-9217-3f32ce9df6d5	Siswa 64	siswa64_smpmuh2@example.com	siswa65_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
5dd63582-e883-4d1f-a1cf-50b620b064ab	Siswa 65	siswa65_smpmuh2@example.com	siswa66_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
a072eb9a-9e4a-465f-aba5-f4f76b5d048e	Siswa 66	siswa66_smpmuh2@example.com	siswa67_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
19547fce-f299-4d3e-9e7e-6f42941fcae5	Siswa 67	siswa67_smpmuh2@example.com	siswa68_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
3e4dc158-b6b8-4568-b00d-ebf3f05e5628	Siswa 68	siswa68_smpmuh2@example.com	siswa69_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
be826c3a-3e6c-40fb-a45c-4438e13955b6	Siswa 69	siswa69_smpmuh2@example.com	siswa70_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
22c1d10b-7f72-4e29-9fab-501730285e9e	Siswa 70	siswa70_smpmuh2@example.com	siswa71_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
b7e9e71d-78c9-4ee5-8a48-4758ad727519	Siswa 71	siswa71_smpmuh2@example.com	siswa72_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
29f5cfd4-3500-4041-9ddf-4093e31b9631	Siswa 72	siswa72_smpmuh2@example.com	siswa73_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
ebdb9225-b8ec-42aa-b832-bb8ca1d97d47	Siswa 73	siswa73_smpmuh2@example.com	siswa74_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
f063965e-80d2-4aea-889f-3f033cdda727	Siswa 74	siswa74_smpmuh2@example.com	siswa75_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
18f6f0e3-b262-4721-a232-0134fa8a9f98	Siswa 75	siswa75_smpmuh2@example.com	siswa76_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
053b5809-ea38-4b14-9604-e3d5da6b1275	Siswa 76	siswa76_smpmuh2@example.com	siswa77_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
3a686abb-e5a8-43c9-8441-a33d8ff8441e	Siswa 77	siswa77_smpmuh2@example.com	siswa78_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
4db68934-6182-45d0-b02e-6981bab3b2df	Siswa 78	siswa78_smpmuh2@example.com	siswa79_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
4be374fe-b85f-4cfc-8a68-47c37488bcee	Siswa 79	siswa79_smpmuh2@example.com	siswa80_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
f6f5609b-876b-4818-a86e-1fb5cb4da5b0	Siswa 80	siswa80_smpmuh2@example.com	siswa81_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
0261a557-ad1d-4251-8de5-25dcb08f5b1d	Siswa 81	siswa81_smpmuh2@example.com	siswa82_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
b9c6b67e-40b7-4141-96c4-4b4fbe774248	Siswa 82	siswa82_smpmuh2@example.com	siswa83_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
5aa6f2b9-8377-4b81-b08c-18e00ba94d4d	Siswa 83	siswa83_smpmuh2@example.com	siswa84_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
d83f973c-bb87-461d-a593-bb25f37d75af	Siswa 84	siswa84_smpmuh2@example.com	siswa85_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
d8747d4a-517a-41af-b213-1b9151670cff	Siswa 85	siswa85_smpmuh2@example.com	siswa86_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
47437537-c0a6-47c7-85b0-014c3ef9d12e	Siswa 86	siswa86_smpmuh2@example.com	siswa87_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
7f50cd56-4c37-4d16-84a5-792d845d850c	Siswa 87	siswa87_smpmuh2@example.com	siswa88_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
ff1ecf9d-14ee-4bf2-8f7e-812cee075d43	Siswa 88	siswa88_smpmuh2@example.com	siswa89_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
5b0903ae-1b3f-4f4f-86bc-c25cbae5d3da	Siswa 89	siswa89_smpmuh2@example.com	siswa90_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
bd7953c5-edff-4661-89bb-58b0c746109e	Siswa 90	siswa90_smpmuh2@example.com	siswa91_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
d8870e3a-2487-47fb-a744-2617f4f48016	Siswa 91	siswa91_smpmuh2@example.com	siswa92_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
51f6c406-63f1-4d67-9231-d413ee3b7850	Siswa 92	siswa92_smpmuh2@example.com	siswa93_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
71137d1d-f54b-4da3-a744-ad37a5cefb35	Siswa 93	siswa93_smpmuh2@example.com	siswa94_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
b48324bf-3b8f-45d5-bb00-d53cdacae86e	Siswa 94	siswa94_smpmuh2@example.com	siswa95_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
bcbbae99-2847-4fa0-8e59-324f1044eb61	Siswa 95	siswa95_smpmuh2@example.com	siswa96_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
d7dbe66b-d1dc-46e2-98ed-b5a34fa12d64	Siswa 96	siswa96_smpmuh2@example.com	siswa97_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
a32f588f-cb2b-43f5-9d59-8e95c1ea45a8	Siswa 97	siswa97_smpmuh2@example.com	siswa98_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
f91ac970-7e66-4360-b5d4-925cda81f2ba	Siswa 98	siswa98_smpmuh2@example.com	siswa99_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
110a7494-a769-4528-b123-660f821c6a9d	Siswa 100	siswa100_smpmuh2@example.com	siswa101_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
6a2f936628122e3f5678ee03	bk	bk@gmail.com	bk	gurubk	999	\N	2026-06-15 12:53:43.868218	2026-06-15 12:53:43.87332
6a2e78f6572208361f6edc48	Al-Kahf Muhammad Zanjabiil	kahfi@gmail.com	siswa1_smpmuh2	siswa	1	\N	2026-06-14 16:48:39.738976	2026-06-14 17:15:09.915545
bf1c1871-e40f-4ec7-8fc5-90b215a913fd	Siswa 33	siswa33_smpmuh2@example.com	siswa34_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
8c9fd6a7-b10e-4ced-b73d-7e1ca604e8ca	Siswa 49	siswa49_smpmuh2@example.com	siswa50_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
a8cd6eb8-a42c-4fa6-a6c4-61c668e62783	Siswa 62	siswa62_smpmuh2@example.com	siswa63_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
bda5f54a-8294-40ca-b5f2-3670f5a9eb18	Siswa 99	siswa99_smpmuh2@example.com	siswa100_smpmuh2	siswa	999	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
6a3502f2c3f01f1a8a28f0d0	Student SMPMUHAMMA_PAKETLENG_002	SMPMUHAMMA_PAKETLENG_002@generated.local	SMPMUHAMMA_PAKETLENG_002	siswa	1	\N	2026-06-19 15:50:59.223739	2026-06-19 15:53:45.633076
6a350427c3f01f1a8a28f0d3	Student SMPMUHAMMA_PAKETLENGK_002	SMPMUHAMMA_PAKETLENGK_002@generated.local	SMPMUHAMMA_PAKETLENGK_002	siswa	1	\N	2026-06-19 15:56:07.963725	2026-06-19 15:56:07.963725
6a350428c3f01f1a8a28f0d4	Student SMPMUHAMMA_PAKETLENGK_003	SMPMUHAMMA_PAKETLENGK_003@generated.local	SMPMUHAMMA_PAKETLENGK_003	siswa	1	\N	2026-06-19 15:56:08.584308	2026-06-19 15:56:08.584308
6a350428c3f01f1a8a28f0d5	Student SMPMUHAMMA_PAKETLENGK_004	SMPMUHAMMA_PAKETLENGK_004@generated.local	SMPMUHAMMA_PAKETLENGK_004	siswa	1	\N	2026-06-19 15:56:09.199045	2026-06-19 15:56:09.199045
6a350429c3f01f1a8a28f0d6	Student SMPMUHAMMA_PAKETLENGK_005	SMPMUHAMMA_PAKETLENGK_005@generated.local	SMPMUHAMMA_PAKETLENGK_005	siswa	1	\N	2026-06-19 15:56:09.817407	2026-06-19 15:56:09.817407
6a350429c3f01f1a8a28f0d7	Student SMPMUHAMMA_PAKETLENGK_006	SMPMUHAMMA_PAKETLENGK_006@generated.local	SMPMUHAMMA_PAKETLENGK_006	siswa	1	\N	2026-06-19 15:56:10.435659	2026-06-19 15:56:10.435659
6a35042ac3f01f1a8a28f0d8	Student SMPMUHAMMA_PAKETLENGK_007	SMPMUHAMMA_PAKETLENGK_007@generated.local	SMPMUHAMMA_PAKETLENGK_007	siswa	1	\N	2026-06-19 15:56:11.049148	2026-06-19 15:56:11.049148
6a35042bc3f01f1a8a28f0d9	Student SMPMUHAMMA_PAKETLENGK_008	SMPMUHAMMA_PAKETLENGK_008@generated.local	SMPMUHAMMA_PAKETLENGK_008	siswa	1	\N	2026-06-19 15:56:11.66552	2026-06-19 15:56:11.66552
6a35042bc3f01f1a8a28f0da	Student SMPMUHAMMA_PAKETLENGK_009	SMPMUHAMMA_PAKETLENGK_009@generated.local	SMPMUHAMMA_PAKETLENGK_009	siswa	1	\N	2026-06-19 15:56:12.290695	2026-06-19 15:56:12.290695
6a35042cc3f01f1a8a28f0db	Student SMPMUHAMMA_PAKETLENGK_010	SMPMUHAMMA_PAKETLENGK_010@generated.local	SMPMUHAMMA_PAKETLENGK_010	siswa	1	\N	2026-06-19 15:56:12.904509	2026-06-19 15:56:12.904509
6a35042dc3f01f1a8a28f0dc	Student SMPMUHAMMA_PAKETLENGK_011	SMPMUHAMMA_PAKETLENGK_011@generated.local	SMPMUHAMMA_PAKETLENGK_011	siswa	1	\N	2026-06-19 15:56:13.528526	2026-06-19 15:56:13.528526
6a35042dc3f01f1a8a28f0dd	Student SMPMUHAMMA_PAKETLENGK_012	SMPMUHAMMA_PAKETLENGK_012@generated.local	SMPMUHAMMA_PAKETLENGK_012	siswa	1	\N	2026-06-19 15:56:14.152208	2026-06-19 15:56:14.152208
6a35042ec3f01f1a8a28f0de	Student SMPMUHAMMA_PAKETLENGK_013	SMPMUHAMMA_PAKETLENGK_013@generated.local	SMPMUHAMMA_PAKETLENGK_013	siswa	1	\N	2026-06-19 15:56:14.778016	2026-06-19 15:56:14.778016
6a35042ec3f01f1a8a28f0df	Student SMPMUHAMMA_PAKETLENGK_014	SMPMUHAMMA_PAKETLENGK_014@generated.local	SMPMUHAMMA_PAKETLENGK_014	siswa	1	\N	2026-06-19 15:56:15.404828	2026-06-19 15:56:15.404828
6a35042fc3f01f1a8a28f0e0	Student SMPMUHAMMA_PAKETLENGK_015	SMPMUHAMMA_PAKETLENGK_015@generated.local	SMPMUHAMMA_PAKETLENGK_015	siswa	1	\N	2026-06-19 15:56:16.026466	2026-06-19 15:56:16.026466
6a350430c3f01f1a8a28f0e1	Student SMPMUHAMMA_PAKETLENGK_016	SMPMUHAMMA_PAKETLENGK_016@generated.local	SMPMUHAMMA_PAKETLENGK_016	siswa	1	\N	2026-06-19 15:56:16.653401	2026-06-19 15:56:16.653401
6a350430c3f01f1a8a28f0e2	Student SMPMUHAMMA_PAKETLENGK_017	SMPMUHAMMA_PAKETLENGK_017@generated.local	SMPMUHAMMA_PAKETLENGK_017	siswa	1	\N	2026-06-19 15:56:17.281698	2026-06-19 15:56:17.281698
6a350431c3f01f1a8a28f0e3	Student SMPMUHAMMA_PAKETLENGK_018	SMPMUHAMMA_PAKETLENGK_018@generated.local	SMPMUHAMMA_PAKETLENGK_018	siswa	1	\N	2026-06-19 15:56:17.899467	2026-06-19 15:56:17.899467
6a350432c3f01f1a8a28f0e4	Student SMPMUHAMMA_PAKETLENGK_019	SMPMUHAMMA_PAKETLENGK_019@generated.local	SMPMUHAMMA_PAKETLENGK_019	siswa	1	\N	2026-06-19 15:56:18.524571	2026-06-19 15:56:18.524571
6a350432c3f01f1a8a28f0e5	Student SMPMUHAMMA_PAKETLENGK_020	SMPMUHAMMA_PAKETLENGK_020@generated.local	SMPMUHAMMA_PAKETLENGK_020	siswa	1	\N	2026-06-19 15:56:19.145647	2026-06-19 15:56:19.145647
6a350433c3f01f1a8a28f0e6	Student SMPMUHAMMA_PAKETLENGK_021	SMPMUHAMMA_PAKETLENGK_021@generated.local	SMPMUHAMMA_PAKETLENGK_021	siswa	1	\N	2026-06-19 15:56:19.762452	2026-06-19 16:34:54.020218
6a350433c3f01f1a8a28f0e7	Student SMPMUHAMMA_PAKETLENGK_022	SMPMUHAMMA_PAKETLENGK_022@generated.local	SMPMUHAMMA_PAKETLENGK_022	siswa	1	\N	2026-06-19 15:56:20.387051	2026-06-19 16:34:54.090423
6a350435c3f01f1a8a28f0e9	Student SMPMUHAMMA_PAKETLENGK_024	SMPMUHAMMA_PAKETLENGK_024@generated.local	SMPMUHAMMA_PAKETLENGK_024	siswa	1	\N	2026-06-19 15:56:21.634464	2026-06-19 16:34:54.118806
6a350435c3f01f1a8a28f0ea	Student SMPMUHAMMA_PAKETLENGK_025	SMPMUHAMMA_PAKETLENGK_025@generated.local	SMPMUHAMMA_PAKETLENGK_025	siswa	1	\N	2026-06-19 15:56:22.250807	2026-06-19 16:34:54.12989
6a350436c3f01f1a8a28f0eb	Student SMPMUHAMMA_PAKETLENGK_026	SMPMUHAMMA_PAKETLENGK_026@generated.local	SMPMUHAMMA_PAKETLENGK_026	siswa	1	\N	2026-06-19 15:56:22.867415	2026-06-19 16:34:54.1408
6a350436c3f01f1a8a28f0ec	Student SMPMUHAMMA_PAKETLENGK_027	SMPMUHAMMA_PAKETLENGK_027@generated.local	SMPMUHAMMA_PAKETLENGK_027	siswa	1	\N	2026-06-19 15:56:23.492342	2026-06-19 16:34:54.150854
6a350437c3f01f1a8a28f0ed	Student SMPMUHAMMA_PAKETLENGK_028	SMPMUHAMMA_PAKETLENGK_028@generated.local	SMPMUHAMMA_PAKETLENGK_028	siswa	1	\N	2026-06-19 15:56:24.113092	2026-06-19 16:34:54.161648
6a350438c3f01f1a8a28f0ee	Student SMPMUHAMMA_PAKETLENGK_029	SMPMUHAMMA_PAKETLENGK_029@generated.local	SMPMUHAMMA_PAKETLENGK_029	siswa	1	\N	2026-06-19 15:56:24.734503	2026-06-19 16:34:54.171972
6a350438c3f01f1a8a28f0ef	Student SMPMUHAMMA_PAKETLENGK_030	SMPMUHAMMA_PAKETLENGK_030@generated.local	SMPMUHAMMA_PAKETLENGK_030	siswa	1	\N	2026-06-19 15:56:25.354508	2026-06-19 16:34:54.18149
6a350439c3f01f1a8a28f0f0	Student SMPMUHAMMA_PAKETLENGK_031	SMPMUHAMMA_PAKETLENGK_031@generated.local	SMPMUHAMMA_PAKETLENGK_031	siswa	1	\N	2026-06-19 15:56:25.970769	2026-06-19 16:34:54.191668
6a35043ac3f01f1a8a28f0f1	Student SMPMUHAMMA_PAKETLENGK_032	SMPMUHAMMA_PAKETLENGK_032@generated.local	SMPMUHAMMA_PAKETLENGK_032	siswa	1	\N	2026-06-19 15:56:26.590059	2026-06-19 16:34:54.200488
6a35043ac3f01f1a8a28f0f2	Student SMPMUHAMMA_PAKETLENGK_033	SMPMUHAMMA_PAKETLENGK_033@generated.local	SMPMUHAMMA_PAKETLENGK_033	siswa	1	\N	2026-06-19 15:56:27.207593	2026-06-19 16:34:54.21006
6a35043bc3f01f1a8a28f0f3	Student SMPMUHAMMA_PAKETLENGK_034	SMPMUHAMMA_PAKETLENGK_034@generated.local	SMPMUHAMMA_PAKETLENGK_034	siswa	1	\N	2026-06-19 15:56:27.824366	2026-06-19 16:34:54.219927
6a35043bc3f01f1a8a28f0f4	Student SMPMUHAMMA_PAKETLENGK_035	SMPMUHAMMA_PAKETLENGK_035@generated.local	SMPMUHAMMA_PAKETLENGK_035	siswa	1	\N	2026-06-19 15:56:28.443544	2026-06-19 16:34:54.229541
6a35043cc3f01f1a8a28f0f5	Student SMPMUHAMMA_PAKETLENGK_036	SMPMUHAMMA_PAKETLENGK_036@generated.local	SMPMUHAMMA_PAKETLENGK_036	siswa	1	\N	2026-06-19 15:56:29.060936	2026-06-19 16:34:54.243264
6a35043fc3f01f1a8a28f0fa	Student SMPMUHAMMA_PAKETLENGK_041	SMPMUHAMMA_PAKETLENGK_041@generated.local	SMPMUHAMMA_PAKETLENGK_041	siswa	1	\N	2026-06-19 15:56:32.163882	2026-06-19 15:56:32.163882
6a350440c3f01f1a8a28f0fb	Student SMPMUHAMMA_PAKETLENGK_042	SMPMUHAMMA_PAKETLENGK_042@generated.local	SMPMUHAMMA_PAKETLENGK_042	siswa	1	\N	2026-06-19 15:56:32.785045	2026-06-19 15:56:32.785045
6a350440c3f01f1a8a28f0fc	Student SMPMUHAMMA_PAKETLENGK_043	SMPMUHAMMA_PAKETLENGK_043@generated.local	SMPMUHAMMA_PAKETLENGK_043	siswa	1	\N	2026-06-19 15:56:33.401122	2026-06-19 15:56:33.401122
6a350441c3f01f1a8a28f0fd	Student SMPMUHAMMA_PAKETLENGK_044	SMPMUHAMMA_PAKETLENGK_044@generated.local	SMPMUHAMMA_PAKETLENGK_044	siswa	1	\N	2026-06-19 15:56:34.024323	2026-06-19 15:56:34.024323
6a350442c3f01f1a8a28f0fe	Student SMPMUHAMMA_PAKETLENGK_045	SMPMUHAMMA_PAKETLENGK_045@generated.local	SMPMUHAMMA_PAKETLENGK_045	siswa	1	\N	2026-06-19 15:56:34.643091	2026-06-19 15:56:34.643091
6a350442c3f01f1a8a28f0ff	Student SMPMUHAMMA_PAKETLENGK_046	SMPMUHAMMA_PAKETLENGK_046@generated.local	SMPMUHAMMA_PAKETLENGK_046	siswa	1	\N	2026-06-19 15:56:35.256206	2026-06-19 15:56:35.256206
6a350443c3f01f1a8a28f100	Student SMPMUHAMMA_PAKETLENGK_047	SMPMUHAMMA_PAKETLENGK_047@generated.local	SMPMUHAMMA_PAKETLENGK_047	siswa	1	\N	2026-06-19 15:56:35.876423	2026-06-19 15:56:35.876423
6a350443c3f01f1a8a28f101	Student SMPMUHAMMA_PAKETLENGK_048	SMPMUHAMMA_PAKETLENGK_048@generated.local	SMPMUHAMMA_PAKETLENGK_048	siswa	1	\N	2026-06-19 15:56:36.492462	2026-06-19 15:56:36.492462
6a350444c3f01f1a8a28f102	Student SMPMUHAMMA_PAKETLENGK_049	SMPMUHAMMA_PAKETLENGK_049@generated.local	SMPMUHAMMA_PAKETLENGK_049	siswa	1	\N	2026-06-19 15:56:37.111872	2026-06-19 15:56:37.111872
6a350445c3f01f1a8a28f103	Student SMPMUHAMMA_PAKETLENGK_050	SMPMUHAMMA_PAKETLENGK_050@generated.local	SMPMUHAMMA_PAKETLENGK_050	siswa	1	\N	2026-06-19 15:56:37.728582	2026-06-19 15:56:37.728582
6a350445c3f01f1a8a28f104	Student SMPMUHAMMA_PAKETLENGK_051	SMPMUHAMMA_PAKETLENGK_051@generated.local	SMPMUHAMMA_PAKETLENGK_051	siswa	1	\N	2026-06-19 15:56:38.350208	2026-06-19 15:56:38.350208
6a350446c3f01f1a8a28f105	Student SMPMUHAMMA_PAKETLENGK_052	SMPMUHAMMA_PAKETLENGK_052@generated.local	SMPMUHAMMA_PAKETLENGK_052	siswa	1	\N	2026-06-19 15:56:38.968245	2026-06-19 15:56:38.968245
6a350447c3f01f1a8a28f106	Student SMPMUHAMMA_PAKETLENGK_053	SMPMUHAMMA_PAKETLENGK_053@generated.local	SMPMUHAMMA_PAKETLENGK_053	siswa	1	\N	2026-06-19 15:56:39.588182	2026-06-19 15:56:39.588182
6a350447c3f01f1a8a28f107	Student SMPMUHAMMA_PAKETLENGK_054	SMPMUHAMMA_PAKETLENGK_054@generated.local	SMPMUHAMMA_PAKETLENGK_054	siswa	1	\N	2026-06-19 15:56:40.212263	2026-06-19 15:56:40.212263
6a350448c3f01f1a8a28f108	Student SMPMUHAMMA_PAKETLENGK_055	SMPMUHAMMA_PAKETLENGK_055@generated.local	SMPMUHAMMA_PAKETLENGK_055	siswa	1	\N	2026-06-19 15:56:40.823935	2026-06-19 15:56:40.823935
6a350448c3f01f1a8a28f109	Student SMPMUHAMMA_PAKETLENGK_056	SMPMUHAMMA_PAKETLENGK_056@generated.local	SMPMUHAMMA_PAKETLENGK_056	siswa	1	\N	2026-06-19 15:56:41.438798	2026-06-19 15:56:41.438798
6a350449c3f01f1a8a28f10a	Student SMPMUHAMMA_PAKETLENGK_057	SMPMUHAMMA_PAKETLENGK_057@generated.local	SMPMUHAMMA_PAKETLENGK_057	siswa	1	\N	2026-06-19 15:56:42.051606	2026-06-19 15:56:42.051606
6a35044ac3f01f1a8a28f10b	Student SMPMUHAMMA_PAKETLENGK_058	SMPMUHAMMA_PAKETLENGK_058@generated.local	SMPMUHAMMA_PAKETLENGK_058	siswa	1	\N	2026-06-19 15:56:42.666748	2026-06-19 15:56:42.666748
6a35044ac3f01f1a8a28f10c	Student SMPMUHAMMA_PAKETLENGK_059	SMPMUHAMMA_PAKETLENGK_059@generated.local	SMPMUHAMMA_PAKETLENGK_059	siswa	1	\N	2026-06-19 15:56:43.288572	2026-06-19 15:56:43.288572
6a35044bc3f01f1a8a28f10d	Student SMPMUHAMMA_PAKETLENGK_060	SMPMUHAMMA_PAKETLENGK_060@generated.local	SMPMUHAMMA_PAKETLENGK_060	siswa	1	\N	2026-06-19 15:56:43.908321	2026-06-19 15:56:43.908321
6a35044cc3f01f1a8a28f10e	Student SMPMUHAMMA_PAKETLENGK_061	SMPMUHAMMA_PAKETLENGK_061@generated.local	SMPMUHAMMA_PAKETLENGK_061	siswa	1	\N	2026-06-19 15:56:44.524941	2026-06-19 15:56:44.524941
6a35044cc3f01f1a8a28f10f	Student SMPMUHAMMA_PAKETLENGK_062	SMPMUHAMMA_PAKETLENGK_062@generated.local	SMPMUHAMMA_PAKETLENGK_062	siswa	1	\N	2026-06-19 15:56:45.144644	2026-06-19 15:56:45.144644
6a35044dc3f01f1a8a28f110	Student SMPMUHAMMA_PAKETLENGK_063	SMPMUHAMMA_PAKETLENGK_063@generated.local	SMPMUHAMMA_PAKETLENGK_063	siswa	1	\N	2026-06-19 15:56:45.762024	2026-06-19 15:56:45.762024
6a35044dc3f01f1a8a28f111	Student SMPMUHAMMA_PAKETLENGK_064	SMPMUHAMMA_PAKETLENGK_064@generated.local	SMPMUHAMMA_PAKETLENGK_064	siswa	1	\N	2026-06-19 15:56:46.381376	2026-06-19 15:56:46.381376
6a35044ec3f01f1a8a28f112	Student SMPMUHAMMA_PAKETLENGK_065	SMPMUHAMMA_PAKETLENGK_065@generated.local	SMPMUHAMMA_PAKETLENGK_065	siswa	1	\N	2026-06-19 15:56:47.00322	2026-06-19 15:56:47.00322
6a35044fc3f01f1a8a28f113	Student SMPMUHAMMA_PAKETLENGK_066	SMPMUHAMMA_PAKETLENGK_066@generated.local	SMPMUHAMMA_PAKETLENGK_066	siswa	1	\N	2026-06-19 15:56:47.622334	2026-06-19 15:56:47.622334
6a35044fc3f01f1a8a28f114	Student SMPMUHAMMA_PAKETLENGK_067	SMPMUHAMMA_PAKETLENGK_067@generated.local	SMPMUHAMMA_PAKETLENGK_067	siswa	1	\N	2026-06-19 15:56:48.241408	2026-06-19 15:56:48.241408
6a350450c3f01f1a8a28f115	Student SMPMUHAMMA_PAKETLENGK_068	SMPMUHAMMA_PAKETLENGK_068@generated.local	SMPMUHAMMA_PAKETLENGK_068	siswa	1	\N	2026-06-19 15:56:48.864341	2026-06-19 15:56:48.864341
6a350450c3f01f1a8a28f116	Student SMPMUHAMMA_PAKETLENGK_069	SMPMUHAMMA_PAKETLENGK_069@generated.local	SMPMUHAMMA_PAKETLENGK_069	siswa	1	\N	2026-06-19 15:56:49.487345	2026-06-19 15:56:49.487345
6a350451c3f01f1a8a28f117	Student SMPMUHAMMA_PAKETLENGK_070	SMPMUHAMMA_PAKETLENGK_070@generated.local	SMPMUHAMMA_PAKETLENGK_070	siswa	1	\N	2026-06-19 15:56:50.111578	2026-06-19 15:56:50.111578
6a350452c3f01f1a8a28f118	Student SMPMUHAMMA_PAKETLENGK_071	SMPMUHAMMA_PAKETLENGK_071@generated.local	SMPMUHAMMA_PAKETLENGK_071	siswa	1	\N	2026-06-19 15:56:50.73225	2026-06-19 15:56:50.73225
6a350452c3f01f1a8a28f119	Student SMPMUHAMMA_PAKETLENGK_072	SMPMUHAMMA_PAKETLENGK_072@generated.local	SMPMUHAMMA_PAKETLENGK_072	siswa	1	\N	2026-06-19 15:56:51.351411	2026-06-19 15:56:51.351411
6a350453c3f01f1a8a28f11a	Student SMPMUHAMMA_PAKETLENGK_073	SMPMUHAMMA_PAKETLENGK_073@generated.local	SMPMUHAMMA_PAKETLENGK_073	siswa	1	\N	2026-06-19 15:56:51.974054	2026-06-19 15:56:51.974054
6a350454c3f01f1a8a28f11b	Student SMPMUHAMMA_PAKETLENGK_074	SMPMUHAMMA_PAKETLENGK_074@generated.local	SMPMUHAMMA_PAKETLENGK_074	siswa	1	\N	2026-06-19 15:56:52.599614	2026-06-19 15:56:52.599614
6a350454c3f01f1a8a28f11c	Student SMPMUHAMMA_PAKETLENGK_075	SMPMUHAMMA_PAKETLENGK_075@generated.local	SMPMUHAMMA_PAKETLENGK_075	siswa	1	\N	2026-06-19 15:56:53.218293	2026-06-19 15:56:53.218293
6a350455c3f01f1a8a28f11d	Student SMPMUHAMMA_PAKETLENGK_076	SMPMUHAMMA_PAKETLENGK_076@generated.local	SMPMUHAMMA_PAKETLENGK_076	siswa	1	\N	2026-06-19 15:56:53.838572	2026-06-19 15:56:53.838572
6a350455c3f01f1a8a28f11e	Student SMPMUHAMMA_PAKETLENGK_077	SMPMUHAMMA_PAKETLENGK_077@generated.local	SMPMUHAMMA_PAKETLENGK_077	siswa	1	\N	2026-06-19 15:56:54.459353	2026-06-19 15:56:54.459353
6a35043dc3f01f1a8a28f0f7	Student SMPMUHAMMA_PAKETLENGK_038	SMPMUHAMMA_PAKETLENGK_038@generated.local	SMPMUHAMMA_PAKETLENGK_038	siswa	1	\N	2026-06-19 15:56:30.301754	2026-06-19 16:34:54.261286
6a35043ec3f01f1a8a28f0f8	Student SMPMUHAMMA_PAKETLENGK_039	SMPMUHAMMA_PAKETLENGK_039@generated.local	SMPMUHAMMA_PAKETLENGK_039	siswa	1	\N	2026-06-19 15:56:30.914106	2026-06-19 16:34:54.27018
6a35043fc3f01f1a8a28f0f9	Student SMPMUHAMMA_PAKETLENGK_040	SMPMUHAMMA_PAKETLENGK_040@generated.local	SMPMUHAMMA_PAKETLENGK_040	siswa	1	\N	2026-06-19 15:56:31.538068	2026-06-19 16:34:54.278789
6a350456c3f01f1a8a28f11f	Student SMPMUHAMMA_PAKETLENGK_078	SMPMUHAMMA_PAKETLENGK_078@generated.local	SMPMUHAMMA_PAKETLENGK_078	siswa	1	\N	2026-06-19 15:56:55.081188	2026-06-19 15:56:55.081188
6a350457c3f01f1a8a28f120	Student SMPMUHAMMA_PAKETLENGK_079	SMPMUHAMMA_PAKETLENGK_079@generated.local	SMPMUHAMMA_PAKETLENGK_079	siswa	1	\N	2026-06-19 15:56:55.704994	2026-06-19 15:56:55.704994
6a350457c3f01f1a8a28f121	Student SMPMUHAMMA_PAKETLENGK_080	SMPMUHAMMA_PAKETLENGK_080@generated.local	SMPMUHAMMA_PAKETLENGK_080	siswa	1	\N	2026-06-19 15:56:56.325792	2026-06-19 15:56:56.325792
6a350458c3f01f1a8a28f122	Student SMPMUHAMMA_PAKETLENGK_081	SMPMUHAMMA_PAKETLENGK_081@generated.local	SMPMUHAMMA_PAKETLENGK_081	siswa	1	\N	2026-06-19 15:56:56.944963	2026-06-19 15:56:56.944963
6a350459c3f01f1a8a28f123	Student SMPMUHAMMA_PAKETLENGK_082	SMPMUHAMMA_PAKETLENGK_082@generated.local	SMPMUHAMMA_PAKETLENGK_082	siswa	1	\N	2026-06-19 15:56:57.568486	2026-06-19 15:56:57.568486
6a350459c3f01f1a8a28f124	Student SMPMUHAMMA_PAKETLENGK_083	SMPMUHAMMA_PAKETLENGK_083@generated.local	SMPMUHAMMA_PAKETLENGK_083	siswa	1	\N	2026-06-19 15:56:58.188976	2026-06-19 15:56:58.188976
6a35045ac3f01f1a8a28f125	Student SMPMUHAMMA_PAKETLENGK_084	SMPMUHAMMA_PAKETLENGK_084@generated.local	SMPMUHAMMA_PAKETLENGK_084	siswa	1	\N	2026-06-19 15:56:58.814828	2026-06-19 15:56:58.814828
6a35045ac3f01f1a8a28f126	Student SMPMUHAMMA_PAKETLENGK_085	SMPMUHAMMA_PAKETLENGK_085@generated.local	SMPMUHAMMA_PAKETLENGK_085	siswa	1	\N	2026-06-19 15:56:59.440602	2026-06-19 15:56:59.440602
6a35045bc3f01f1a8a28f127	Student SMPMUHAMMA_PAKETLENGK_086	SMPMUHAMMA_PAKETLENGK_086@generated.local	SMPMUHAMMA_PAKETLENGK_086	siswa	1	\N	2026-06-19 15:57:00.059875	2026-06-19 15:57:00.059875
6a35045cc3f01f1a8a28f128	Student SMPMUHAMMA_PAKETLENGK_087	SMPMUHAMMA_PAKETLENGK_087@generated.local	SMPMUHAMMA_PAKETLENGK_087	siswa	1	\N	2026-06-19 15:57:00.681127	2026-06-19 15:57:00.681127
6a35045cc3f01f1a8a28f129	Student SMPMUHAMMA_PAKETLENGK_088	SMPMUHAMMA_PAKETLENGK_088@generated.local	SMPMUHAMMA_PAKETLENGK_088	siswa	1	\N	2026-06-19 15:57:01.301343	2026-06-19 15:57:01.301343
6a35045dc3f01f1a8a28f12a	Student SMPMUHAMMA_PAKETLENGK_089	SMPMUHAMMA_PAKETLENGK_089@generated.local	SMPMUHAMMA_PAKETLENGK_089	siswa	1	\N	2026-06-19 15:57:01.92141	2026-06-19 15:57:01.92141
6a35045ec3f01f1a8a28f12b	Student SMPMUHAMMA_PAKETLENGK_090	SMPMUHAMMA_PAKETLENGK_090@generated.local	SMPMUHAMMA_PAKETLENGK_090	siswa	1	\N	2026-06-19 15:57:02.544016	2026-06-19 15:57:02.544016
6a35045ec3f01f1a8a28f12c	Student SMPMUHAMMA_PAKETLENGK_091	SMPMUHAMMA_PAKETLENGK_091@generated.local	SMPMUHAMMA_PAKETLENGK_091	siswa	1	\N	2026-06-19 15:57:03.168869	2026-06-19 15:57:03.168869
6a35045fc3f01f1a8a28f12d	Student SMPMUHAMMA_PAKETLENGK_092	SMPMUHAMMA_PAKETLENGK_092@generated.local	SMPMUHAMMA_PAKETLENGK_092	siswa	1	\N	2026-06-19 15:57:03.790802	2026-06-19 15:57:03.790802
6a35045fc3f01f1a8a28f12e	Student SMPMUHAMMA_PAKETLENGK_093	SMPMUHAMMA_PAKETLENGK_093@generated.local	SMPMUHAMMA_PAKETLENGK_093	siswa	1	\N	2026-06-19 15:57:04.414541	2026-06-19 15:57:04.414541
6a350460c3f01f1a8a28f12f	Student SMPMUHAMMA_PAKETLENGK_094	SMPMUHAMMA_PAKETLENGK_094@generated.local	SMPMUHAMMA_PAKETLENGK_094	siswa	1	\N	2026-06-19 15:57:05.036805	2026-06-19 15:57:05.036805
6a350461c3f01f1a8a28f130	Student SMPMUHAMMA_PAKETLENGK_095	SMPMUHAMMA_PAKETLENGK_095@generated.local	SMPMUHAMMA_PAKETLENGK_095	siswa	1	\N	2026-06-19 15:57:05.652887	2026-06-19 15:57:05.652887
6a350461c3f01f1a8a28f131	Student SMPMUHAMMA_PAKETLENGK_096	SMPMUHAMMA_PAKETLENGK_096@generated.local	SMPMUHAMMA_PAKETLENGK_096	siswa	1	\N	2026-06-19 15:57:06.270396	2026-06-19 15:57:06.270396
6a350462c3f01f1a8a28f132	Student SMPMUHAMMA_PAKETLENGK_097	SMPMUHAMMA_PAKETLENGK_097@generated.local	SMPMUHAMMA_PAKETLENGK_097	siswa	1	\N	2026-06-19 15:57:06.892368	2026-06-19 15:57:06.892368
6a350462c3f01f1a8a28f133	Student SMPMUHAMMA_PAKETLENGK_098	SMPMUHAMMA_PAKETLENGK_098@generated.local	SMPMUHAMMA_PAKETLENGK_098	siswa	1	\N	2026-06-19 15:57:07.512304	2026-06-19 15:57:07.512304
6a350463c3f01f1a8a28f134	Student SMPMUHAMMA_PAKETLENGK_099	SMPMUHAMMA_PAKETLENGK_099@generated.local	SMPMUHAMMA_PAKETLENGK_099	siswa	1	\N	2026-06-19 15:57:08.128659	2026-06-19 15:57:08.128659
6a350464c3f01f1a8a28f135	Student SMPMUHAMMA_PAKETLENGK_100	SMPMUHAMMA_PAKETLENGK_100@generated.local	SMPMUHAMMA_PAKETLENGK_100	siswa	1	\N	2026-06-19 15:57:08.742925	2026-06-19 15:57:08.742925
6a350426c3f01f1a8a28f0d2	Student SMPMUHAMMA_PAKETLENGK_101	SMPMUHAMMA_PAKETLENGK_101@generated.local	SMPMUHAMMA_PAKETLENGK_101	siswa	1	\N	2026-06-19 15:56:07.344416	2026-06-19 16:06:10.863205
6a350682c3f01f1a8a28f136	Student SMPMUHAMMA_PAKETLENGK_102	SMPMUHAMMA_PAKETLENGK_102@generated.local	SMPMUHAMMA_PAKETLENGK_102	siswa	1	\N	2026-06-19 16:06:11.482224	2026-06-19 16:06:11.482224
6a350683c3f01f1a8a28f137	Student SMPMUHAMMA_PAKETLENGK_103	SMPMUHAMMA_PAKETLENGK_103@generated.local	SMPMUHAMMA_PAKETLENGK_103	siswa	1	\N	2026-06-19 16:06:12.105817	2026-06-19 16:06:12.105817
6a350684c3f01f1a8a28f138	Student SMPMUHAMMA_PAKETLENGK_104	SMPMUHAMMA_PAKETLENGK_104@generated.local	SMPMUHAMMA_PAKETLENGK_104	siswa	1	\N	2026-06-19 16:06:12.7271	2026-06-19 16:06:12.7271
6a350684c3f01f1a8a28f139	Student SMPMUHAMMA_PAKETLENGK_105	SMPMUHAMMA_PAKETLENGK_105@generated.local	SMPMUHAMMA_PAKETLENGK_105	siswa	1	\N	2026-06-19 16:06:13.348528	2026-06-19 16:06:13.348528
6a350685c3f01f1a8a28f13a	Student SMPMUHAMMA_PAKETLENGK_106	SMPMUHAMMA_PAKETLENGK_106@generated.local	SMPMUHAMMA_PAKETLENGK_106	siswa	1	\N	2026-06-19 16:06:13.971761	2026-06-19 16:06:13.971761
6a350686c3f01f1a8a28f13b	Student SMPMUHAMMA_PAKETLENGK_107	SMPMUHAMMA_PAKETLENGK_107@generated.local	SMPMUHAMMA_PAKETLENGK_107	siswa	1	\N	2026-06-19 16:06:14.591835	2026-06-19 16:06:14.591835
6a350686c3f01f1a8a28f13c	Student SMPMUHAMMA_PAKETLENGK_108	SMPMUHAMMA_PAKETLENGK_108@generated.local	SMPMUHAMMA_PAKETLENGK_108	siswa	1	\N	2026-06-19 16:06:15.215511	2026-06-19 16:06:15.215511
6a350687c3f01f1a8a28f13d	Student SMPMUHAMMA_PAKETLENGK_109	SMPMUHAMMA_PAKETLENGK_109@generated.local	SMPMUHAMMA_PAKETLENGK_109	siswa	1	\N	2026-06-19 16:06:15.84178	2026-06-19 16:06:15.84178
6a350687c3f01f1a8a28f13e	Student SMPMUHAMMA_PAKETLENGK_110	SMPMUHAMMA_PAKETLENGK_110@generated.local	SMPMUHAMMA_PAKETLENGK_110	siswa	1	\N	2026-06-19 16:06:16.460527	2026-06-19 16:06:16.460527
6a350688c3f01f1a8a28f13f	Student SMPMUHAMMA_PAKETLENGK_111	SMPMUHAMMA_PAKETLENGK_111@generated.local	SMPMUHAMMA_PAKETLENGK_111	siswa	1	\N	2026-06-19 16:06:17.075494	2026-06-19 16:06:17.075494
6a350689c3f01f1a8a28f140	Student SMPMUHAMMA_PAKETLENGK_112	SMPMUHAMMA_PAKETLENGK_112@generated.local	SMPMUHAMMA_PAKETLENGK_112	siswa	1	\N	2026-06-19 16:06:17.692826	2026-06-19 16:06:17.692826
6a350689c3f01f1a8a28f141	Student SMPMUHAMMA_PAKETLENGK_113	SMPMUHAMMA_PAKETLENGK_113@generated.local	SMPMUHAMMA_PAKETLENGK_113	siswa	1	\N	2026-06-19 16:06:18.30792	2026-06-19 16:06:18.30792
6a35068ac3f01f1a8a28f142	Student SMPMUHAMMA_PAKETLENGK_114	SMPMUHAMMA_PAKETLENGK_114@generated.local	SMPMUHAMMA_PAKETLENGK_114	siswa	1	\N	2026-06-19 16:06:18.927412	2026-06-19 16:06:18.927412
6a35068bc3f01f1a8a28f143	Student SMPMUHAMMA_PAKETLENGK_115	SMPMUHAMMA_PAKETLENGK_115@generated.local	SMPMUHAMMA_PAKETLENGK_115	siswa	1	\N	2026-06-19 16:06:19.543398	2026-06-19 16:06:19.543398
6a35068bc3f01f1a8a28f144	Student SMPMUHAMMA_PAKETLENGK_116	SMPMUHAMMA_PAKETLENGK_116@generated.local	SMPMUHAMMA_PAKETLENGK_116	siswa	1	\N	2026-06-19 16:06:20.163205	2026-06-19 16:06:20.163205
6a35068cc3f01f1a8a28f145	Student SMPMUHAMMA_PAKETLENGK_117	SMPMUHAMMA_PAKETLENGK_117@generated.local	SMPMUHAMMA_PAKETLENGK_117	siswa	1	\N	2026-06-19 16:06:20.778543	2026-06-19 16:06:20.778543
6a35068cc3f01f1a8a28f146	Student SMPMUHAMMA_PAKETLENGK_118	SMPMUHAMMA_PAKETLENGK_118@generated.local	SMPMUHAMMA_PAKETLENGK_118	siswa	1	\N	2026-06-19 16:06:21.396507	2026-06-19 16:06:21.396507
6a35068dc3f01f1a8a28f147	Student SMPMUHAMMA_PAKETLENGK_119	SMPMUHAMMA_PAKETLENGK_119@generated.local	SMPMUHAMMA_PAKETLENGK_119	siswa	1	\N	2026-06-19 16:06:22.015934	2026-06-19 16:06:22.015934
6a35068ec3f01f1a8a28f148	Student SMPMUHAMMA_PAKETLENGK_120	SMPMUHAMMA_PAKETLENGK_120@generated.local	SMPMUHAMMA_PAKETLENGK_120	siswa	1	\N	2026-06-19 16:06:22.634464	2026-06-19 16:06:22.634464
6a35068ec3f01f1a8a28f149	Student SMPMUHAMMA_PAKETLENGK_121	SMPMUHAMMA_PAKETLENGK_121@generated.local	SMPMUHAMMA_PAKETLENGK_121	siswa	1	\N	2026-06-19 16:06:23.252176	2026-06-19 16:06:23.252176
6a35068fc3f01f1a8a28f14a	Student SMPMUHAMMA_PAKETLENGK_122	SMPMUHAMMA_PAKETLENGK_122@generated.local	SMPMUHAMMA_PAKETLENGK_122	siswa	1	\N	2026-06-19 16:06:23.87348	2026-06-19 16:06:23.87348
6a35068fc3f01f1a8a28f14b	Student SMPMUHAMMA_PAKETLENGK_123	SMPMUHAMMA_PAKETLENGK_123@generated.local	SMPMUHAMMA_PAKETLENGK_123	siswa	1	\N	2026-06-19 16:06:24.496648	2026-06-19 16:06:24.496648
6a350690c3f01f1a8a28f14c	Student SMPMUHAMMA_PAKETLENGK_124	SMPMUHAMMA_PAKETLENGK_124@generated.local	SMPMUHAMMA_PAKETLENGK_124	siswa	1	\N	2026-06-19 16:06:25.11084	2026-06-19 16:06:25.11084
6a350691c3f01f1a8a28f14d	Student SMPMUHAMMA_PAKETLENGK_125	SMPMUHAMMA_PAKETLENGK_125@generated.local	SMPMUHAMMA_PAKETLENGK_125	siswa	1	\N	2026-06-19 16:06:25.730654	2026-06-19 16:06:25.730654
6a350691c3f01f1a8a28f14e	Student SMPMUHAMMA_PAKETLENGK_126	SMPMUHAMMA_PAKETLENGK_126@generated.local	SMPMUHAMMA_PAKETLENGK_126	siswa	1	\N	2026-06-19 16:06:26.352498	2026-06-19 16:06:26.352498
6a350692c3f01f1a8a28f14f	Student SMPMUHAMMA_PAKETLENGK_127	SMPMUHAMMA_PAKETLENGK_127@generated.local	SMPMUHAMMA_PAKETLENGK_127	siswa	1	\N	2026-06-19 16:06:26.969669	2026-06-19 16:06:26.969669
6a350693c3f01f1a8a28f150	Student SMPMUHAMMA_PAKETLENGK_128	SMPMUHAMMA_PAKETLENGK_128@generated.local	SMPMUHAMMA_PAKETLENGK_128	siswa	1	\N	2026-06-19 16:06:27.59317	2026-06-19 16:06:27.59317
6a350693c3f01f1a8a28f151	Student SMPMUHAMMA_PAKETLENGK_129	SMPMUHAMMA_PAKETLENGK_129@generated.local	SMPMUHAMMA_PAKETLENGK_129	siswa	1	\N	2026-06-19 16:06:28.214895	2026-06-19 16:06:28.214895
6a350694c3f01f1a8a28f152	Student SMPMUHAMMA_PAKETLENGK_130	SMPMUHAMMA_PAKETLENGK_130@generated.local	SMPMUHAMMA_PAKETLENGK_130	siswa	1	\N	2026-06-19 16:06:28.835258	2026-06-19 16:06:28.835258
6a350694c3f01f1a8a28f153	Student SMPMUHAMMA_PAKETLENGK_131	SMPMUHAMMA_PAKETLENGK_131@generated.local	SMPMUHAMMA_PAKETLENGK_131	siswa	1	\N	2026-06-19 16:06:29.453366	2026-06-19 16:06:29.453366
6a350695c3f01f1a8a28f154	Student SMPMUHAMMA_PAKETLENGK_132	SMPMUHAMMA_PAKETLENGK_132@generated.local	SMPMUHAMMA_PAKETLENGK_132	siswa	1	\N	2026-06-19 16:06:30.076907	2026-06-19 16:06:30.076907
6a350696c3f01f1a8a28f155	Student SMPMUHAMMA_PAKETLENGK_133	SMPMUHAMMA_PAKETLENGK_133@generated.local	SMPMUHAMMA_PAKETLENGK_133	siswa	1	\N	2026-06-19 16:06:30.693656	2026-06-19 16:06:30.693656
6a350696c3f01f1a8a28f156	Student SMPMUHAMMA_PAKETLENGK_134	SMPMUHAMMA_PAKETLENGK_134@generated.local	SMPMUHAMMA_PAKETLENGK_134	siswa	1	\N	2026-06-19 16:06:31.317251	2026-06-19 16:06:31.317251
6a350697c3f01f1a8a28f157	Student SMPMUHAMMA_PAKETLENGK_135	SMPMUHAMMA_PAKETLENGK_135@generated.local	SMPMUHAMMA_PAKETLENGK_135	siswa	1	\N	2026-06-19 16:06:31.939088	2026-06-19 16:06:31.939088
6a350698c3f01f1a8a28f158	Student SMPMUHAMMA_PAKETLENGK_136	SMPMUHAMMA_PAKETLENGK_136@generated.local	SMPMUHAMMA_PAKETLENGK_136	siswa	1	\N	2026-06-19 16:06:32.559669	2026-06-19 16:06:32.559669
6a350698c3f01f1a8a28f159	Student SMPMUHAMMA_PAKETLENGK_137	SMPMUHAMMA_PAKETLENGK_137@generated.local	SMPMUHAMMA_PAKETLENGK_137	siswa	1	\N	2026-06-19 16:06:33.179659	2026-06-19 16:06:33.179659
6a350699c3f01f1a8a28f15a	Student SMPMUHAMMA_PAKETLENGK_138	SMPMUHAMMA_PAKETLENGK_138@generated.local	SMPMUHAMMA_PAKETLENGK_138	siswa	1	\N	2026-06-19 16:06:33.803059	2026-06-19 16:06:33.803059
6a350699c3f01f1a8a28f15b	Student SMPMUHAMMA_PAKETLENGK_139	SMPMUHAMMA_PAKETLENGK_139@generated.local	SMPMUHAMMA_PAKETLENGK_139	siswa	1	\N	2026-06-19 16:06:34.422666	2026-06-19 16:06:34.422666
6a35069ac3f01f1a8a28f15c	Student SMPMUHAMMA_PAKETLENGK_140	SMPMUHAMMA_PAKETLENGK_140@generated.local	SMPMUHAMMA_PAKETLENGK_140	siswa	1	\N	2026-06-19 16:06:35.044216	2026-06-19 16:06:35.044216
6a35069bc3f01f1a8a28f15d	Student SMPMUHAMMA_PAKETLENGK_141	SMPMUHAMMA_PAKETLENGK_141@generated.local	SMPMUHAMMA_PAKETLENGK_141	siswa	1	\N	2026-06-19 16:06:35.660386	2026-06-19 16:06:35.660386
6a35069bc3f01f1a8a28f15e	Student SMPMUHAMMA_PAKETLENGK_142	SMPMUHAMMA_PAKETLENGK_142@generated.local	SMPMUHAMMA_PAKETLENGK_142	siswa	1	\N	2026-06-19 16:06:36.28524	2026-06-19 16:06:36.28524
6a35069cc3f01f1a8a28f15f	Student SMPMUHAMMA_PAKETLENGK_143	SMPMUHAMMA_PAKETLENGK_143@generated.local	SMPMUHAMMA_PAKETLENGK_143	siswa	1	\N	2026-06-19 16:06:36.902664	2026-06-19 16:06:36.902664
6a35069dc3f01f1a8a28f160	Student SMPMUHAMMA_PAKETLENGK_144	SMPMUHAMMA_PAKETLENGK_144@generated.local	SMPMUHAMMA_PAKETLENGK_144	siswa	1	\N	2026-06-19 16:06:37.518449	2026-06-19 16:06:37.518449
6a35069dc3f01f1a8a28f161	Student SMPMUHAMMA_PAKETLENGK_145	SMPMUHAMMA_PAKETLENGK_145@generated.local	SMPMUHAMMA_PAKETLENGK_145	siswa	1	\N	2026-06-19 16:06:38.13664	2026-06-19 16:06:38.13664
6a35069ec3f01f1a8a28f162	Student SMPMUHAMMA_PAKETLENGK_146	SMPMUHAMMA_PAKETLENGK_146@generated.local	SMPMUHAMMA_PAKETLENGK_146	siswa	1	\N	2026-06-19 16:06:38.754426	2026-06-19 16:06:38.754426
6a35069ec3f01f1a8a28f163	Student SMPMUHAMMA_PAKETLENGK_147	SMPMUHAMMA_PAKETLENGK_147@generated.local	SMPMUHAMMA_PAKETLENGK_147	siswa	1	\N	2026-06-19 16:06:39.373535	2026-06-19 16:06:39.373535
6a35069fc3f01f1a8a28f164	Student SMPMUHAMMA_PAKETLENGK_148	SMPMUHAMMA_PAKETLENGK_148@generated.local	SMPMUHAMMA_PAKETLENGK_148	siswa	1	\N	2026-06-19 16:06:39.994911	2026-06-19 16:06:39.994911
6a3506a0c3f01f1a8a28f165	Student SMPMUHAMMA_PAKETLENGK_149	SMPMUHAMMA_PAKETLENGK_149@generated.local	SMPMUHAMMA_PAKETLENGK_149	siswa	1	\N	2026-06-19 16:06:40.683755	2026-06-19 16:06:40.683755
6a3506a0c3f01f1a8a28f166	Student SMPMUHAMMA_PAKETLENGK_150	SMPMUHAMMA_PAKETLENGK_150@generated.local	SMPMUHAMMA_PAKETLENGK_150	siswa	1	\N	2026-06-19 16:06:41.315167	2026-06-19 16:06:41.315167
6a3506a1c3f01f1a8a28f167	Student SMPMUHAMMA_PAKETLENGK_151	SMPMUHAMMA_PAKETLENGK_151@generated.local	SMPMUHAMMA_PAKETLENGK_151	siswa	1	\N	2026-06-19 16:06:41.939034	2026-06-19 16:06:41.939034
6a3506a2c3f01f1a8a28f168	Student SMPMUHAMMA_PAKETLENGK_152	SMPMUHAMMA_PAKETLENGK_152@generated.local	SMPMUHAMMA_PAKETLENGK_152	siswa	1	\N	2026-06-19 16:06:42.635562	2026-06-19 16:06:42.635562
6a3506a2c3f01f1a8a28f169	Student SMPMUHAMMA_PAKETLENGK_153	SMPMUHAMMA_PAKETLENGK_153@generated.local	SMPMUHAMMA_PAKETLENGK_153	siswa	1	\N	2026-06-19 16:06:43.262042	2026-06-19 16:06:43.262042
6a3506a3c3f01f1a8a28f16a	Student SMPMUHAMMA_PAKETLENGK_154	SMPMUHAMMA_PAKETLENGK_154@generated.local	SMPMUHAMMA_PAKETLENGK_154	siswa	1	\N	2026-06-19 16:06:43.889769	2026-06-19 16:06:43.889769
6a3506a4c3f01f1a8a28f16b	Student SMPMUHAMMA_PAKETLENGK_155	SMPMUHAMMA_PAKETLENGK_155@generated.local	SMPMUHAMMA_PAKETLENGK_155	siswa	1	\N	2026-06-19 16:06:44.520835	2026-06-19 16:06:44.520835
6a3506a4c3f01f1a8a28f16c	Student SMPMUHAMMA_PAKETLENGK_156	SMPMUHAMMA_PAKETLENGK_156@generated.local	SMPMUHAMMA_PAKETLENGK_156	siswa	1	\N	2026-06-19 16:06:45.152966	2026-06-19 16:06:45.152966
6a3506a5c3f01f1a8a28f16d	Student SMPMUHAMMA_PAKETLENGK_157	SMPMUHAMMA_PAKETLENGK_157@generated.local	SMPMUHAMMA_PAKETLENGK_157	siswa	1	\N	2026-06-19 16:06:45.773158	2026-06-19 16:06:45.773158
6a3506a5c3f01f1a8a28f16e	Student SMPMUHAMMA_PAKETLENGK_158	SMPMUHAMMA_PAKETLENGK_158@generated.local	SMPMUHAMMA_PAKETLENGK_158	siswa	1	\N	2026-06-19 16:06:46.394128	2026-06-19 16:06:46.394128
6a3506a6c3f01f1a8a28f16f	Student SMPMUHAMMA_PAKETLENGK_159	SMPMUHAMMA_PAKETLENGK_159@generated.local	SMPMUHAMMA_PAKETLENGK_159	siswa	1	\N	2026-06-19 16:06:47.018245	2026-06-19 16:06:47.018245
6a3506a7c3f01f1a8a28f170	Student SMPMUHAMMA_PAKETLENGK_160	SMPMUHAMMA_PAKETLENGK_160@generated.local	SMPMUHAMMA_PAKETLENGK_160	siswa	1	\N	2026-06-19 16:06:47.675886	2026-06-19 16:06:47.675886
6a3506a7c3f01f1a8a28f171	Student SMPMUHAMMA_PAKETLENGK_161	SMPMUHAMMA_PAKETLENGK_161@generated.local	SMPMUHAMMA_PAKETLENGK_161	siswa	1	\N	2026-06-19 16:06:48.320166	2026-06-19 16:06:48.320166
6a3506a8c3f01f1a8a28f172	Student SMPMUHAMMA_PAKETLENGK_162	SMPMUHAMMA_PAKETLENGK_162@generated.local	SMPMUHAMMA_PAKETLENGK_162	siswa	1	\N	2026-06-19 16:06:49.005731	2026-06-19 16:06:49.005731
6a3506a9c3f01f1a8a28f173	Student SMPMUHAMMA_PAKETLENGK_163	SMPMUHAMMA_PAKETLENGK_163@generated.local	SMPMUHAMMA_PAKETLENGK_163	siswa	1	\N	2026-06-19 16:06:49.629576	2026-06-19 16:06:49.629576
6a3506a9c3f01f1a8a28f174	Student SMPMUHAMMA_PAKETLENGK_164	SMPMUHAMMA_PAKETLENGK_164@generated.local	SMPMUHAMMA_PAKETLENGK_164	siswa	1	\N	2026-06-19 16:06:50.254144	2026-06-19 16:06:50.254144
6a3506aac3f01f1a8a28f175	Student SMPMUHAMMA_PAKETLENGK_165	SMPMUHAMMA_PAKETLENGK_165@generated.local	SMPMUHAMMA_PAKETLENGK_165	siswa	1	\N	2026-06-19 16:06:50.876134	2026-06-19 16:06:50.876134
6a3506aac3f01f1a8a28f176	Student SMPMUHAMMA_PAKETLENGK_166	SMPMUHAMMA_PAKETLENGK_166@generated.local	SMPMUHAMMA_PAKETLENGK_166	siswa	1	\N	2026-06-19 16:06:51.499203	2026-06-19 16:06:51.499203
6a3506abc3f01f1a8a28f177	Student SMPMUHAMMA_PAKETLENGK_167	SMPMUHAMMA_PAKETLENGK_167@generated.local	SMPMUHAMMA_PAKETLENGK_167	siswa	1	\N	2026-06-19 16:06:52.142546	2026-06-19 16:06:52.142546
6a3506acc3f01f1a8a28f178	Student SMPMUHAMMA_PAKETLENGK_168	SMPMUHAMMA_PAKETLENGK_168@generated.local	SMPMUHAMMA_PAKETLENGK_168	siswa	1	\N	2026-06-19 16:06:52.77336	2026-06-19 16:06:52.77336
6a3506acc3f01f1a8a28f179	Student SMPMUHAMMA_PAKETLENGK_169	SMPMUHAMMA_PAKETLENGK_169@generated.local	SMPMUHAMMA_PAKETLENGK_169	siswa	1	\N	2026-06-19 16:06:53.402569	2026-06-19 16:06:53.402569
6a3506adc3f01f1a8a28f17a	Student SMPMUHAMMA_PAKETLENGK_170	SMPMUHAMMA_PAKETLENGK_170@generated.local	SMPMUHAMMA_PAKETLENGK_170	siswa	1	\N	2026-06-19 16:06:54.024679	2026-06-19 16:06:54.024679
6a3506aec3f01f1a8a28f17b	Student SMPMUHAMMA_PAKETLENGK_171	SMPMUHAMMA_PAKETLENGK_171@generated.local	SMPMUHAMMA_PAKETLENGK_171	siswa	1	\N	2026-06-19 16:06:54.641703	2026-06-19 16:06:54.641703
6a3506aec3f01f1a8a28f17c	Student SMPMUHAMMA_PAKETLENGK_172	SMPMUHAMMA_PAKETLENGK_172@generated.local	SMPMUHAMMA_PAKETLENGK_172	siswa	1	\N	2026-06-19 16:06:55.262965	2026-06-19 16:06:55.262965
6a3506afc3f01f1a8a28f17d	Student SMPMUHAMMA_PAKETLENGK_173	SMPMUHAMMA_PAKETLENGK_173@generated.local	SMPMUHAMMA_PAKETLENGK_173	siswa	1	\N	2026-06-19 16:06:55.884805	2026-06-19 16:06:55.884805
6a3506afc3f01f1a8a28f17e	Student SMPMUHAMMA_PAKETLENGK_174	SMPMUHAMMA_PAKETLENGK_174@generated.local	SMPMUHAMMA_PAKETLENGK_174	siswa	1	\N	2026-06-19 16:06:56.513161	2026-06-19 16:06:56.513161
6a3506b0c3f01f1a8a28f17f	Student SMPMUHAMMA_PAKETLENGK_175	SMPMUHAMMA_PAKETLENGK_175@generated.local	SMPMUHAMMA_PAKETLENGK_175	siswa	1	\N	2026-06-19 16:06:57.156465	2026-06-19 16:06:57.156465
6a3506b1c3f01f1a8a28f180	Student SMPMUHAMMA_PAKETLENGK_176	SMPMUHAMMA_PAKETLENGK_176@generated.local	SMPMUHAMMA_PAKETLENGK_176	siswa	1	\N	2026-06-19 16:06:57.795737	2026-06-19 16:06:57.795737
6a3506b1c3f01f1a8a28f181	Student SMPMUHAMMA_PAKETLENGK_177	SMPMUHAMMA_PAKETLENGK_177@generated.local	SMPMUHAMMA_PAKETLENGK_177	siswa	1	\N	2026-06-19 16:06:58.462235	2026-06-19 16:06:58.462235
6a3506b2c3f01f1a8a28f182	Student SMPMUHAMMA_PAKETLENGK_178	SMPMUHAMMA_PAKETLENGK_178@generated.local	SMPMUHAMMA_PAKETLENGK_178	siswa	1	\N	2026-06-19 16:06:59.104382	2026-06-19 16:06:59.104382
6a3506b3c3f01f1a8a28f183	Student SMPMUHAMMA_PAKETLENGK_179	SMPMUHAMMA_PAKETLENGK_179@generated.local	SMPMUHAMMA_PAKETLENGK_179	siswa	1	\N	2026-06-19 16:06:59.726154	2026-06-19 16:06:59.726154
6a3506b3c3f01f1a8a28f184	Student SMPMUHAMMA_PAKETLENGK_180	SMPMUHAMMA_PAKETLENGK_180@generated.local	SMPMUHAMMA_PAKETLENGK_180	siswa	1	\N	2026-06-19 16:07:00.348028	2026-06-19 16:07:00.348028
6a3506b4c3f01f1a8a28f185	Student SMPMUHAMMA_PAKETLENGK_181	SMPMUHAMMA_PAKETLENGK_181@generated.local	SMPMUHAMMA_PAKETLENGK_181	siswa	1	\N	2026-06-19 16:07:00.967979	2026-06-19 16:07:00.967979
6a3506b5c3f01f1a8a28f186	Student SMPMUHAMMA_PAKETLENGK_182	SMPMUHAMMA_PAKETLENGK_182@generated.local	SMPMUHAMMA_PAKETLENGK_182	siswa	1	\N	2026-06-19 16:07:01.596078	2026-06-19 16:07:01.596078
6a3506b5c3f01f1a8a28f187	Student SMPMUHAMMA_PAKETLENGK_183	SMPMUHAMMA_PAKETLENGK_183@generated.local	SMPMUHAMMA_PAKETLENGK_183	siswa	1	\N	2026-06-19 16:07:02.214473	2026-06-19 16:07:02.214473
6a3506b6c3f01f1a8a28f188	Student SMPMUHAMMA_PAKETLENGK_184	SMPMUHAMMA_PAKETLENGK_184@generated.local	SMPMUHAMMA_PAKETLENGK_184	siswa	1	\N	2026-06-19 16:07:02.878267	2026-06-19 16:07:02.878267
6a3506b6c3f01f1a8a28f189	Student SMPMUHAMMA_PAKETLENGK_185	SMPMUHAMMA_PAKETLENGK_185@generated.local	SMPMUHAMMA_PAKETLENGK_185	siswa	1	\N	2026-06-19 16:07:03.497898	2026-06-19 16:07:03.497898
6a3506b7c3f01f1a8a28f18a	Student SMPMUHAMMA_PAKETLENGK_186	SMPMUHAMMA_PAKETLENGK_186@generated.local	SMPMUHAMMA_PAKETLENGK_186	siswa	1	\N	2026-06-19 16:07:04.11794	2026-06-19 16:07:04.11794
6a3506b8c3f01f1a8a28f18b	Student SMPMUHAMMA_PAKETLENGK_187	SMPMUHAMMA_PAKETLENGK_187@generated.local	SMPMUHAMMA_PAKETLENGK_187	siswa	1	\N	2026-06-19 16:07:04.738238	2026-06-19 16:07:04.738238
6a3506b8c3f01f1a8a28f18c	Student SMPMUHAMMA_PAKETLENGK_188	SMPMUHAMMA_PAKETLENGK_188@generated.local	SMPMUHAMMA_PAKETLENGK_188	siswa	1	\N	2026-06-19 16:07:05.357038	2026-06-19 16:07:05.357038
6a3506b9c3f01f1a8a28f18d	Student SMPMUHAMMA_PAKETLENGK_189	SMPMUHAMMA_PAKETLENGK_189@generated.local	SMPMUHAMMA_PAKETLENGK_189	siswa	1	\N	2026-06-19 16:07:05.989383	2026-06-19 16:07:05.989383
6a3506bac3f01f1a8a28f18e	Student SMPMUHAMMA_PAKETLENGK_190	SMPMUHAMMA_PAKETLENGK_190@generated.local	SMPMUHAMMA_PAKETLENGK_190	siswa	1	\N	2026-06-19 16:07:06.609905	2026-06-19 16:07:06.609905
6a3506bac3f01f1a8a28f18f	Student SMPMUHAMMA_PAKETLENGK_191	SMPMUHAMMA_PAKETLENGK_191@generated.local	SMPMUHAMMA_PAKETLENGK_191	siswa	1	\N	2026-06-19 16:07:07.233836	2026-06-19 16:07:07.233836
6a3506bbc3f01f1a8a28f190	Student SMPMUHAMMA_PAKETLENGK_192	SMPMUHAMMA_PAKETLENGK_192@generated.local	SMPMUHAMMA_PAKETLENGK_192	siswa	1	\N	2026-06-19 16:07:07.853678	2026-06-19 16:07:07.853678
6a3506bbc3f01f1a8a28f191	Student SMPMUHAMMA_PAKETLENGK_193	SMPMUHAMMA_PAKETLENGK_193@generated.local	SMPMUHAMMA_PAKETLENGK_193	siswa	1	\N	2026-06-19 16:07:08.47446	2026-06-19 16:07:08.47446
6a3506bcc3f01f1a8a28f192	Student SMPMUHAMMA_PAKETLENGK_194	SMPMUHAMMA_PAKETLENGK_194@generated.local	SMPMUHAMMA_PAKETLENGK_194	siswa	1	\N	2026-06-19 16:07:09.091225	2026-06-19 16:07:09.091225
6a3506bdc3f01f1a8a28f193	Student SMPMUHAMMA_PAKETLENGK_195	SMPMUHAMMA_PAKETLENGK_195@generated.local	SMPMUHAMMA_PAKETLENGK_195	siswa	1	\N	2026-06-19 16:07:09.707334	2026-06-19 16:07:09.707334
6a3506bdc3f01f1a8a28f194	Student SMPMUHAMMA_PAKETLENGK_196	SMPMUHAMMA_PAKETLENGK_196@generated.local	SMPMUHAMMA_PAKETLENGK_196	siswa	1	\N	2026-06-19 16:07:10.326311	2026-06-19 16:07:10.326311
6a3506bec3f01f1a8a28f195	Student SMPMUHAMMA_PAKETLENGK_197	SMPMUHAMMA_PAKETLENGK_197@generated.local	SMPMUHAMMA_PAKETLENGK_197	siswa	1	\N	2026-06-19 16:07:10.944182	2026-06-19 16:07:10.944182
6a3506bfc3f01f1a8a28f196	Student SMPMUHAMMA_PAKETLENGK_198	SMPMUHAMMA_PAKETLENGK_198@generated.local	SMPMUHAMMA_PAKETLENGK_198	siswa	1	\N	2026-06-19 16:07:11.565072	2026-06-19 16:07:11.565072
6a3506bfc3f01f1a8a28f197	Student SMPMUHAMMA_PAKETLENGK_199	SMPMUHAMMA_PAKETLENGK_199@generated.local	SMPMUHAMMA_PAKETLENGK_199	siswa	1	\N	2026-06-19 16:07:12.178799	2026-06-19 16:07:12.178799
6a3506c0c3f01f1a8a28f198	Student SMPMUHAMMA_PAKETLENGK_200	SMPMUHAMMA_PAKETLENGK_200@generated.local	SMPMUHAMMA_PAKETLENGK_200	siswa	1	\N	2026-06-19 16:07:12.798156	2026-06-19 16:07:12.798156
6a350434c3f01f1a8a28f0e8	Student SMPMUHAMMA_PAKETLENGK_023	SMPMUHAMMA_PAKETLENGK_023@generated.local	SMPMUHAMMA_PAKETLENGK_023	siswa	1	\N	2026-06-19 15:56:21.011956	2026-06-19 16:34:54.105593
6a35043dc3f01f1a8a28f0f6	Student SMPMUHAMMA_PAKETLENGK_037	SMPMUHAMMA_PAKETLENGK_037@generated.local	SMPMUHAMMA_PAKETLENGK_037	siswa	1	\N	2026-06-19 15:56:29.683667	2026-06-19 16:34:54.251907
\.


--
-- Data for Name: cfit_descriptions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cfit_descriptions (id, score_min, score_max, iq_min, iq_max, category, description) FROM stdin;
1	36	45	130	145	Sangat Tinggi	Kemampuan intelektual sangat superior. Cepat dalam memproses informasi dan memecahkan masalah.
2	28	35	115	129	Tinggi	Kemampuan intelektual di atas rata-rata. Mampu berpikir abstrak dengan baik.
3	20	27	90	114	Rata-rata	Kemampuan intelektual rata-rata. Mampu menangani tugas sehari-hari dengan baik.
4	12	19	70	89	Rendah	Kemampuan intelektual di bawah rata-rata. Memerlukan dukungan tambahan.
5	0	11	50	69	Sangat Rendah	Kemampuan intelektual jauh di bawah rata-rata. Perlu evaluasi mendalam.
\.


--
-- Data for Name: cfit_questions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cfit_questions (id, subtest_no, item_no, question_text, image_url, options, correct_answer, is_active) FROM stdin;
1	1	1	Pilih gambar yang melanjutkan pola deretan berikut: Segitiga → Persegi → Pentagon → ?	\N	{"A": "Hexagon", "B": "Lingkaran", "C": "Bintang", "D": "Segitiga"}	A	t
2	1	2	Mana yang tidak termasuk dalam kelompok: Merah, Biru, Hijau, Keras?	\N	{"A": "Merah", "B": "Biru", "C": "Hijau", "D": "Keras"}	D	t
3	1	3	Pola: 2, 4, 8, 16, ... Angka selanjutnya adalah?	\N	{"A": "24", "B": "32", "C": "20", "D": "18"}	B	t
4	2	1	Jika semua kucing adalah hewan, dan semua hewan bernapas, maka kucing...	\N	{"A": "tidak bernapas", "B": "adalah hewan saja", "C": "bernapas", "D": "bukan hewan"}	C	t
5	2	2	Mana yang memiliki hubungan sama dengan: Panas : Dingin	\N	{"A": "Gelap : Malam", "B": "Terang : Siang", "C": "Hitam : Putih", "D": "Langit : Biru"}	C	t
6	3	1	Sebuah bujur sangkar dengan sisi 6 cm memiliki luas?	\N	{"A": "12 cm2", "B": "24 cm2", "C": "36 cm2", "D": "18 cm2"}	C	t
7	3	2	Jika 5 pekerja bisa menyelesaikan pekerjaan dalam 8 hari, berapa lama 10 pekerja?	\N	{"A": "16 hari", "B": "4 hari", "C": "8 hari", "D": "2 hari"}	B	t
8	4	1	Antonim dari kata RAMAH adalah...	\N	{"A": "Sopan", "B": "Kasar", "C": "Tenang", "D": "Bijaksana"}	B	t
9	4	2	Sinonim dari kata CERDAS adalah...	\N	{"A": "Bodoh", "B": "Lambat", "C": "Pandai", "D": "Malas"}	C	t
\.


--
-- Data for Name: cfit_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cfit_results (id, auth_user_id, student_name, school_name, assignment_id, sub1_score, sub2_score, sub3_score, sub4_score, total_score, iq_score, category, description, answers, completed_at) FROM stdin;
1	6a2e78f6572208361f6edc48	Al-Kahf Muhammad Zanjabiil	SMP Muhammadiyah Yogyakarta 2	1	0	0	0	0	0	50	Sangat Rendah	Kemampuan intelektual jauh di bawah rata-rata. Perlu evaluasi mendalam.	[{"answer": "3", "itemNo": 1, "subtestNo": 1}, {"answer": "27", "itemNo": 2, "subtestNo": 1}, {"answer": "11", "itemNo": 3, "subtestNo": 1}, {"answer": "79", "itemNo": 1, "subtestNo": 2}, {"answer": "71", "itemNo": 2, "subtestNo": 2}, {"answer": "27", "itemNo": 1, "subtestNo": 3}, {"answer": "39", "itemNo": 2, "subtestNo": 3}, {"answer": "51", "itemNo": 1, "subtestNo": 4}, {"answer": "31", "itemNo": 2, "subtestNo": 4}]	2026-06-14 17:19:45.613929
2	cc2f0f8a-59a3-4a5e-9bfe-1c670c519393	\N	\N	999	0	7	6	9	22	138	\N	\N	\N	2026-06-15 14:11:48.225022
3	1654ba45-7070-4d1b-a8d2-f09e3f64c11e	\N	\N	999	0	10	2	8	20	81	\N	\N	\N	2026-06-15 14:11:48.225022
4	4c9ca049-08a2-4b28-a5d8-c8b69ec084bf	\N	\N	999	8	10	6	2	26	81	\N	\N	\N	2026-06-15 14:11:48.225022
5	1e6a9e81-1ac2-46b5-a700-4c76ed08536d	\N	\N	999	9	0	8	9	26	92	\N	\N	\N	2026-06-15 14:11:48.225022
6	4ca82485-a400-43b5-bbdb-0292a8b19538	\N	\N	999	6	3	0	10	19	102	\N	\N	\N	2026-06-15 14:11:48.225022
7	266c53e9-355e-4176-bebd-c7c0f088e93c	\N	\N	999	4	7	2	5	18	118	\N	\N	\N	2026-06-15 14:11:48.225022
8	a0355bd2-dd2f-4e2e-b188-8e24fc0247fc	\N	\N	999	0	3	5	9	17	106	\N	\N	\N	2026-06-15 14:11:48.225022
9	9657db6a-b9fc-4ab5-99ba-b1dce9318094	\N	\N	999	0	7	6	5	18	95	\N	\N	\N	2026-06-15 14:11:48.225022
10	82d8f94b-dedb-4e9d-8d60-420d022ad08e	\N	\N	999	3	4	1	3	11	114	\N	\N	\N	2026-06-15 14:11:48.225022
11	2d1666f6-f176-47d6-91b0-3d1af8045d49	\N	\N	999	5	8	5	3	21	108	\N	\N	\N	2026-06-15 14:11:48.225022
12	d608456c-2cf9-4b7d-af93-7fec87443402	\N	\N	999	6	7	4	1	18	130	\N	\N	\N	2026-06-15 14:11:48.225022
13	15419209-5200-46da-b3f9-c8a63d1d57d2	\N	\N	999	4	2	7	1	14	128	\N	\N	\N	2026-06-15 14:11:48.225022
14	0532d0ed-4f72-45ea-a2a9-4c3a818ec580	\N	\N	999	0	2	7	4	13	127	\N	\N	\N	2026-06-15 14:11:48.225022
15	eef746bc-85f4-47dd-93c6-9cedb993e8ef	\N	\N	999	10	9	6	4	29	91	\N	\N	\N	2026-06-15 14:11:48.225022
16	21e9cce0-931e-4a32-b8a6-a38e52ecfd40	\N	\N	999	7	10	7	3	27	96	\N	\N	\N	2026-06-15 14:11:48.225022
17	5a32cb0e-557a-46c7-9b68-9864b80d0976	\N	\N	999	8	3	10	5	26	91	\N	\N	\N	2026-06-15 14:11:48.225022
18	1fa0df89-40ec-4307-9fdd-346b68185bf2	\N	\N	999	3	7	4	1	15	125	\N	\N	\N	2026-06-15 14:11:48.225022
19	c8065771-c617-4db7-87ba-8a948282e8f6	\N	\N	999	5	4	3	7	19	119	\N	\N	\N	2026-06-15 14:11:48.225022
20	c3c2f6d7-0d35-4d04-922d-0146a7270185	\N	\N	999	3	4	7	2	16	96	\N	\N	\N	2026-06-15 14:11:48.225022
21	83ee8be1-1151-4ff3-951c-b722dbf4d232	\N	\N	999	5	0	0	0	5	132	\N	\N	\N	2026-06-15 14:11:48.225022
22	a3223597-2552-4dd8-8931-41775fd19d10	\N	\N	999	7	3	9	3	22	127	\N	\N	\N	2026-06-15 14:11:48.225022
23	6e98e408-5a17-41ae-ad00-037080b85e0d	\N	\N	999	5	6	6	3	20	119	\N	\N	\N	2026-06-15 14:11:48.225022
24	efcc2939-2506-44c2-9bd4-6e19395b5451	\N	\N	999	5	10	9	0	24	81	\N	\N	\N	2026-06-15 14:11:48.225022
25	0ca8b3ea-875d-421c-b230-10857175c683	\N	\N	999	2	2	6	6	16	125	\N	\N	\N	2026-06-15 14:11:48.225022
26	9ad7e7fb-8086-4fb3-bef4-62a3a181187d	\N	\N	999	0	7	6	8	21	93	\N	\N	\N	2026-06-15 14:11:48.225022
27	c5a84425-3349-4ad8-9240-e1b68d62d6ef	\N	\N	999	9	9	10	0	28	122	\N	\N	\N	2026-06-15 14:11:48.225022
28	e7a9d7b1-835e-4edd-ac5d-2ba67d5bad47	\N	\N	999	9	8	0	1	18	130	\N	\N	\N	2026-06-15 14:11:48.225022
29	e1721a26-bee5-48f4-84ad-452212c07821	\N	\N	999	4	9	5	5	23	91	\N	\N	\N	2026-06-15 14:11:48.225022
30	16c5ab27-122e-4684-bab9-bfad23cbae2d	\N	\N	999	10	2	9	10	31	89	\N	\N	\N	2026-06-15 14:11:48.225022
31	250b647f-4439-4350-b1c2-52c65cc97a10	\N	\N	999	3	9	9	3	24	115	\N	\N	\N	2026-06-15 14:11:48.225022
32	d082f677-513d-4b8f-9cef-c73b784503b6	\N	\N	999	3	10	1	1	15	123	\N	\N	\N	2026-06-15 14:11:48.225022
33	cf9649b8-de12-454a-a441-6950a18718b9	\N	\N	999	2	5	4	1	12	102	\N	\N	\N	2026-06-15 14:11:48.225022
34	bf1c1871-e40f-4ec7-8fc5-90b215a913fd	\N	\N	999	8	3	2	1	14	86	\N	\N	\N	2026-06-15 14:11:48.225022
35	7a1b13e6-55be-48e1-81d1-251ce6e50878	\N	\N	999	1	10	6	3	20	125	\N	\N	\N	2026-06-15 14:11:48.225022
36	baa619f4-f59f-492e-bf41-67073f934db4	\N	\N	999	7	9	2	10	28	134	\N	\N	\N	2026-06-15 14:11:48.225022
37	b3e99c8c-5f9d-46ac-88de-e305679eb454	\N	\N	999	2	9	7	9	27	109	\N	\N	\N	2026-06-15 14:11:48.225022
38	edf1feed-3035-4133-ac3b-6c46e0ad3ef8	\N	\N	999	8	0	10	0	18	116	\N	\N	\N	2026-06-15 14:11:48.225022
39	893c6a6a-37c1-4e20-a1cc-f6f7878a5883	\N	\N	999	6	2	1	4	13	110	\N	\N	\N	2026-06-15 14:11:48.225022
40	4358ed04-3f46-45dc-804d-9cb71671cba8	\N	\N	999	10	10	8	0	28	121	\N	\N	\N	2026-06-15 14:11:48.225022
41	3efb78be-bc11-400c-968b-49a1bef666d6	\N	\N	999	0	0	6	7	13	104	\N	\N	\N	2026-06-15 14:11:48.225022
42	02b4ff08-2975-44ec-931a-7ac911e503b5	\N	\N	999	8	8	6	3	25	116	\N	\N	\N	2026-06-15 14:11:48.225022
43	9977dfc6-4374-4406-9059-a4a50b9a1373	\N	\N	999	2	5	3	6	16	100	\N	\N	\N	2026-06-15 14:11:48.225022
44	e2f4031c-750d-4283-8740-75d0c7d9b5fe	\N	\N	999	0	6	10	1	17	119	\N	\N	\N	2026-06-15 14:11:48.225022
45	ef6dc49d-8639-4636-b4cc-2e3fa40d9a94	\N	\N	999	0	0	3	5	8	130	\N	\N	\N	2026-06-15 14:11:48.225022
46	5516a843-6fdf-4a4d-9264-88d932b7197a	\N	\N	999	10	10	7	10	37	133	\N	\N	\N	2026-06-15 14:11:48.225022
47	55492aef-4a9e-4cbf-8a66-940afc571470	\N	\N	999	7	6	6	1	20	110	\N	\N	\N	2026-06-15 14:11:48.225022
48	9b2e0574-8b56-4126-9576-e50eeb80d2f7	\N	\N	999	2	10	1	7	20	109	\N	\N	\N	2026-06-15 14:11:48.225022
49	ecd99560-cb6f-4359-af98-4b0d65690cda	\N	\N	999	6	3	8	7	24	124	\N	\N	\N	2026-06-15 14:11:48.225022
50	8c9fd6a7-b10e-4ced-b73d-7e1ca604e8ca	\N	\N	999	1	10	1	8	20	101	\N	\N	\N	2026-06-15 14:11:48.225022
51	7130a9fd-8021-402a-a29f-0e820a9805d0	\N	\N	999	4	3	1	7	15	83	\N	\N	\N	2026-06-15 14:11:48.225022
52	3dd7f158-22c1-4969-94e5-3685d27635f8	\N	\N	999	3	5	5	0	13	118	\N	\N	\N	2026-06-15 14:11:48.225022
53	00a1036d-78e4-4a5d-9274-f64b86710af4	\N	\N	999	1	6	7	3	17	119	\N	\N	\N	2026-06-15 14:11:48.225022
54	8c53f9b7-bca2-495e-b7a1-1e72f3ae1d66	\N	\N	999	4	7	7	1	19	84	\N	\N	\N	2026-06-15 14:11:48.225022
55	cecc9511-5026-4181-b1bd-b5fc24db8166	\N	\N	999	3	1	7	1	12	102	\N	\N	\N	2026-06-15 14:11:48.225022
56	b210a83a-93df-4e56-994c-e9c507868513	\N	\N	999	5	2	4	2	13	88	\N	\N	\N	2026-06-15 14:11:48.225022
57	3772b413-138d-405f-bfdd-61477808fc92	\N	\N	999	7	1	4	4	16	119	\N	\N	\N	2026-06-15 14:11:48.225022
58	eacc4913-7529-40d2-ba62-446d8c45bd9b	\N	\N	999	3	6	0	0	9	133	\N	\N	\N	2026-06-15 14:11:48.225022
59	daab5116-420e-46e1-9e00-bfdcba51edd7	\N	\N	999	1	9	8	7	25	126	\N	\N	\N	2026-06-15 14:11:48.225022
60	42dab708-e9d7-4cc4-a9ab-99448dcec05e	\N	\N	999	2	5	6	5	18	83	\N	\N	\N	2026-06-15 14:11:48.225022
61	3128126c-b3f9-4c19-a435-9cbb527b790f	\N	\N	999	1	5	6	9	21	124	\N	\N	\N	2026-06-15 14:11:48.225022
62	94dc98e0-d52c-47a0-9cf7-7d1d29f50eae	\N	\N	999	10	5	5	8	28	117	\N	\N	\N	2026-06-15 14:11:48.225022
63	a8cd6eb8-a42c-4fa6-a6c4-61c668e62783	\N	\N	999	9	0	1	10	20	98	\N	\N	\N	2026-06-15 14:11:48.225022
64	6b13554f-3f28-4133-8afe-9bd13881e537	\N	\N	999	5	10	2	2	19	91	\N	\N	\N	2026-06-15 14:11:48.225022
65	777088a3-62f1-4fd5-9217-3f32ce9df6d5	\N	\N	999	6	1	10	4	21	124	\N	\N	\N	2026-06-15 14:11:48.225022
66	5dd63582-e883-4d1f-a1cf-50b620b064ab	\N	\N	999	9	10	0	8	27	82	\N	\N	\N	2026-06-15 14:11:48.225022
67	a072eb9a-9e4a-465f-aba5-f4f76b5d048e	\N	\N	999	3	6	0	7	16	111	\N	\N	\N	2026-06-15 14:11:48.225022
68	19547fce-f299-4d3e-9e7e-6f42941fcae5	\N	\N	999	8	5	1	8	22	85	\N	\N	\N	2026-06-15 14:11:48.225022
69	3e4dc158-b6b8-4568-b00d-ebf3f05e5628	\N	\N	999	7	10	0	5	22	138	\N	\N	\N	2026-06-15 14:11:48.225022
70	be826c3a-3e6c-40fb-a45c-4438e13955b6	\N	\N	999	6	7	2	8	23	133	\N	\N	\N	2026-06-15 14:11:48.225022
71	22c1d10b-7f72-4e29-9fab-501730285e9e	\N	\N	999	3	2	8	9	22	88	\N	\N	\N	2026-06-15 14:11:48.225022
72	b7e9e71d-78c9-4ee5-8a48-4758ad727519	\N	\N	999	6	0	3	1	10	120	\N	\N	\N	2026-06-15 14:11:48.225022
73	29f5cfd4-3500-4041-9ddf-4093e31b9631	\N	\N	999	0	3	6	10	19	114	\N	\N	\N	2026-06-15 14:11:48.225022
74	ebdb9225-b8ec-42aa-b832-bb8ca1d97d47	\N	\N	999	7	2	8	3	20	123	\N	\N	\N	2026-06-15 14:11:48.225022
75	f063965e-80d2-4aea-889f-3f033cdda727	\N	\N	999	7	6	5	4	22	119	\N	\N	\N	2026-06-15 14:11:48.225022
76	18f6f0e3-b262-4721-a232-0134fa8a9f98	\N	\N	999	10	8	8	4	30	95	\N	\N	\N	2026-06-15 14:11:48.225022
77	053b5809-ea38-4b14-9604-e3d5da6b1275	\N	\N	999	7	6	8	10	31	87	\N	\N	\N	2026-06-15 14:11:48.225022
78	3a686abb-e5a8-43c9-8441-a33d8ff8441e	\N	\N	999	10	1	8	8	27	137	\N	\N	\N	2026-06-15 14:11:48.225022
79	4db68934-6182-45d0-b02e-6981bab3b2df	\N	\N	999	2	6	6	6	20	91	\N	\N	\N	2026-06-15 14:11:48.225022
80	4be374fe-b85f-4cfc-8a68-47c37488bcee	\N	\N	999	9	2	0	0	11	85	\N	\N	\N	2026-06-15 14:11:48.225022
81	f6f5609b-876b-4818-a86e-1fb5cb4da5b0	\N	\N	999	10	8	3	4	25	107	\N	\N	\N	2026-06-15 14:11:48.225022
82	0261a557-ad1d-4251-8de5-25dcb08f5b1d	\N	\N	999	2	1	6	6	15	102	\N	\N	\N	2026-06-15 14:11:48.225022
83	b9c6b67e-40b7-4141-96c4-4b4fbe774248	\N	\N	999	3	6	1	3	13	101	\N	\N	\N	2026-06-15 14:11:48.225022
84	5aa6f2b9-8377-4b81-b08c-18e00ba94d4d	\N	\N	999	5	7	5	0	17	132	\N	\N	\N	2026-06-15 14:11:48.225022
85	d83f973c-bb87-461d-a593-bb25f37d75af	\N	\N	999	9	1	9	4	23	130	\N	\N	\N	2026-06-15 14:11:48.225022
86	d8747d4a-517a-41af-b213-1b9151670cff	\N	\N	999	8	9	2	8	27	126	\N	\N	\N	2026-06-15 14:11:48.225022
87	47437537-c0a6-47c7-85b0-014c3ef9d12e	\N	\N	999	0	4	1	1	6	96	\N	\N	\N	2026-06-15 14:11:48.225022
88	7f50cd56-4c37-4d16-84a5-792d845d850c	\N	\N	999	4	6	5	7	22	107	\N	\N	\N	2026-06-15 14:11:48.225022
89	ff1ecf9d-14ee-4bf2-8f7e-812cee075d43	\N	\N	999	6	7	5	6	24	84	\N	\N	\N	2026-06-15 14:11:48.225022
90	5b0903ae-1b3f-4f4f-86bc-c25cbae5d3da	\N	\N	999	1	5	8	1	15	126	\N	\N	\N	2026-06-15 14:11:48.225022
91	bd7953c5-edff-4661-89bb-58b0c746109e	\N	\N	999	9	1	3	8	21	113	\N	\N	\N	2026-06-15 14:11:48.225022
92	d8870e3a-2487-47fb-a744-2617f4f48016	\N	\N	999	7	8	1	7	23	113	\N	\N	\N	2026-06-15 14:11:48.225022
93	51f6c406-63f1-4d67-9231-d413ee3b7850	\N	\N	999	7	3	6	1	17	121	\N	\N	\N	2026-06-15 14:11:48.225022
94	71137d1d-f54b-4da3-a744-ad37a5cefb35	\N	\N	999	3	4	10	10	27	121	\N	\N	\N	2026-06-15 14:11:48.225022
95	b48324bf-3b8f-45d5-bb00-d53cdacae86e	\N	\N	999	2	9	10	4	25	100	\N	\N	\N	2026-06-15 14:11:48.225022
96	bcbbae99-2847-4fa0-8e59-324f1044eb61	\N	\N	999	9	3	6	4	22	110	\N	\N	\N	2026-06-15 14:11:48.225022
97	d7dbe66b-d1dc-46e2-98ed-b5a34fa12d64	\N	\N	999	5	9	3	9	26	132	\N	\N	\N	2026-06-15 14:11:48.225022
98	a32f588f-cb2b-43f5-9d59-8e95c1ea45a8	\N	\N	999	3	7	3	7	20	93	\N	\N	\N	2026-06-15 14:11:48.225022
99	f91ac970-7e66-4360-b5d4-925cda81f2ba	\N	\N	999	4	8	6	2	20	112	\N	\N	\N	2026-06-15 14:11:48.225022
100	bda5f54a-8294-40ca-b5f2-3670f5a9eb18	\N	\N	999	0	9	1	3	13	125	\N	\N	\N	2026-06-15 14:11:48.225022
101	110a7494-a769-4528-b123-660f821c6a9d	\N	\N	999	4	6	7	3	20	118	\N	\N	\N	2026-06-15 14:11:48.225022
\.


--
-- Data for Name: disc_personality_profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.disc_personality_profiles (id, most_key, least_key, dif_key, title, description) FROM stdin;
1	D	S	D	Pengendali	Tipe dominan yang menyukai kontrol dan hasil cepat. Tegas, berorientasi tujuan, dan kompetitif.
2	I	C	I	Influencer	Komunikatif, antusias, dan persuasif. Menyukai interaksi sosial dan memotivasi orang lain.
3	S	D	S	Pendukung	Sabar, setia, dan konsisten. Lebih menyukai stabilitas dan bekerja dalam tim yang harmonis.
4	C	I	C	Analis	Cermat, sistematis, dan berorientasi kualitas. Mengandalkan data dan prosedur dalam bekerja.
5	DI	SC	D	Pemimpin Dinamis	Kombinasi dominan dan pengaruh — pemimpin yang energik dan menginspirasi.
6	IS	DC	I	Konsultan Empatik	Ramah dan suportif, mahir membangun relasi dan mendukung orang lain.
7	SC	DI	S	Pelaksana Teliti	Stabil dan hati-hati, bekerja dengan metodis dan terstruktur.
8	DC	IS	C	Strategis	Analitis dan tegas, menetapkan standar tinggi dan memastikan kepatuhan prosedur.
9	X	X	X	Seimbang	Profil yang seimbang di semua dimensi — fleksibel dalam berbagai situasi.
\.


--
-- Data for Name: disc_questions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.disc_questions (id, block_no, item_no, category, statement, is_active) FROM stdin;
1	1	1	D	Saya suka memimpin dan mengambil keputusan	t
2	1	2	I	Saya mudah bergaul dan memengaruhi orang lain	t
3	1	3	S	Saya setia dan sabar dalam mengerjakan tugas	t
4	1	4	C	Saya cermat dan teliti dalam segala hal	t
5	2	1	D	Saya berani menghadapi tantangan baru	t
6	2	2	I	Saya antusias dalam kegiatan kelompok	t
7	2	3	S	Saya menyelesaikan pekerjaan dengan konsisten	t
8	2	4	C	Saya mengikuti prosedur dengan ketat	t
9	3	1	D	Saya tidak suka mengalah dalam debat	t
10	3	2	I	Saya senang menjadi pusat perhatian	t
11	3	3	S	Saya mendukung orang lain dengan tulus	t
12	3	4	C	Saya sangat memperhatikan detail	t
13	4	1	D	Saya cepat dalam mengambil tindakan	t
14	4	2	I	Saya suka berbicara di depan umum	t
15	4	3	S	Saya lebih suka rutinitas yang teratur	t
16	4	4	C	Saya suka menganalisis sebelum bertindak	t
17	5	1	D	Saya selalu ingin hasil terbaik	t
18	5	2	I	Saya mudah bersemangat dan optimis	t
19	5	3	S	Saya tidak terburu-buru dalam bekerja	t
20	5	4	C	Saya suka membuat perencanaan yang rinci	t
21	6	1	D	Saya tegas dalam mempertahankan pendapat	t
22	6	2	I	Saya mudah membangun hubungan baru	t
23	6	3	S	Saya menghargai keharmonisan tim	t
24	6	4	C	Saya mengandalkan data dan fakta	t
25	7	1	D	Saya suka kompetisi dan tantangan	t
26	7	2	I	Saya menghibur orang di sekitar saya	t
27	7	3	S	Saya membantu orang lain dengan senang hati	t
28	7	4	C	Saya menghindari kesalahan dengan hati-hati	t
29	8	1	D	Saya tidak mudah menyerah	t
30	8	2	I	Saya ekspresif dalam mengungkapkan perasaan	t
31	8	3	S	Saya lebih suka kerja tim daripada individu	t
32	8	4	C	Saya butuh waktu untuk mempertimbangkan keputusan	t
\.


--
-- Data for Name: disc_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.disc_results (id, auth_user_id, student_name, school_name, assignment_id, d_most, i_most, s_most, c_most, d_least, i_least, s_least, c_least, d_dif, i_dif, s_dif, c_dif, most_key, least_key, dif_key, profile_title, profile_desc, answers, completed_at) FROM stdin;
1	6a2e78f6572208361f6edc48	Al-Kahf Muhammad Zanjabiil	SMP Muhammadiyah Yogyakarta 2	1	1	3	4	0	0	1	3	4	1	2	1	-4	S	C	I	Profil Beragam	Kombinasi unik dari beberapa dimensi kepribadian.	[{"blockNo": 1, "mostItemNo": 3, "leastItemNo": 4}, {"blockNo": 2, "mostItemNo": 1, "leastItemNo": 2}, {"blockNo": 3, "mostItemNo": 3, "leastItemNo": 4}, {"blockNo": 4, "mostItemNo": 3, "leastItemNo": 3}, {"blockNo": 5, "mostItemNo": 3, "leastItemNo": 4}, {"blockNo": 6, "mostItemNo": 2, "leastItemNo": 4}, {"blockNo": 7, "mostItemNo": 2, "leastItemNo": 3}, {"blockNo": 8, "mostItemNo": 2, "leastItemNo": 3}]	2026-06-14 17:16:56.883205
12	cc2f0f8a-59a3-4a5e-9bfe-1c670c519393	\N	\N	999	1	5	0	2	5	6	8	2	0	0	0	0	\N	\N	\N	Pengendali	\N	\N	2026-06-15 14:11:48.225022
13	1654ba45-7070-4d1b-a8d2-f09e3f64c11e	\N	\N	999	7	4	10	0	7	6	9	8	0	0	0	0	\N	\N	\N	Strategis	\N	\N	2026-06-15 14:11:48.225022
14	4c9ca049-08a2-4b28-a5d8-c8b69ec084bf	\N	\N	999	9	0	4	8	6	3	1	10	0	0	0	0	\N	\N	\N	Seimbang	\N	\N	2026-06-15 14:11:48.225022
15	1e6a9e81-1ac2-46b5-a700-4c76ed08536d	\N	\N	999	8	8	5	3	1	4	8	10	0	0	0	0	\N	\N	\N	Seimbang	\N	\N	2026-06-15 14:11:48.225022
16	4ca82485-a400-43b5-bbdb-0292a8b19538	\N	\N	999	0	7	9	1	1	4	10	3	0	0	0	0	\N	\N	\N	Seimbang	\N	\N	2026-06-15 14:11:48.225022
17	266c53e9-355e-4176-bebd-c7c0f088e93c	\N	\N	999	1	3	3	8	1	2	0	3	0	0	0	0	\N	\N	\N	Pengendali	\N	\N	2026-06-15 14:11:48.225022
18	a0355bd2-dd2f-4e2e-b188-8e24fc0247fc	\N	\N	999	4	2	2	2	2	7	5	1	0	0	0	0	\N	\N	\N	Pendukung	\N	\N	2026-06-15 14:11:48.225022
19	9657db6a-b9fc-4ab5-99ba-b1dce9318094	\N	\N	999	9	8	0	6	6	8	4	6	0	0	0	0	\N	\N	\N	Pelaksana Teliti	\N	\N	2026-06-15 14:11:48.225022
20	82d8f94b-dedb-4e9d-8d60-420d022ad08e	\N	\N	999	0	1	1	10	9	6	2	4	0	0	0	0	\N	\N	\N	Strategis	\N	\N	2026-06-15 14:11:48.225022
21	2d1666f6-f176-47d6-91b0-3d1af8045d49	\N	\N	999	8	7	8	6	9	10	0	3	0	0	0	0	\N	\N	\N	Pelaksana Teliti	\N	\N	2026-06-15 14:11:48.225022
22	d608456c-2cf9-4b7d-af93-7fec87443402	\N	\N	999	1	4	1	2	10	7	2	6	0	0	0	0	\N	\N	\N	Pelaksana Teliti	\N	\N	2026-06-15 14:11:48.225022
23	15419209-5200-46da-b3f9-c8a63d1d57d2	\N	\N	999	0	3	4	6	0	3	6	3	0	0	0	0	\N	\N	\N	Konsultan Empatik	\N	\N	2026-06-15 14:11:48.225022
24	0532d0ed-4f72-45ea-a2a9-4c3a818ec580	\N	\N	999	4	8	10	6	8	0	1	6	0	0	0	0	\N	\N	\N	Pemimpin Dinamis	\N	\N	2026-06-15 14:11:48.225022
25	eef746bc-85f4-47dd-93c6-9cedb993e8ef	\N	\N	999	4	0	4	7	2	7	8	9	0	0	0	0	\N	\N	\N	Pemimpin Dinamis	\N	\N	2026-06-15 14:11:48.225022
26	21e9cce0-931e-4a32-b8a6-a38e52ecfd40	\N	\N	999	2	8	3	0	10	3	8	1	0	0	0	0	\N	\N	\N	Pengendali	\N	\N	2026-06-15 14:11:48.225022
27	5a32cb0e-557a-46c7-9b68-9864b80d0976	\N	\N	999	6	4	3	7	5	6	7	9	0	0	0	0	\N	\N	\N	Konsultan Empatik	\N	\N	2026-06-15 14:11:48.225022
28	1fa0df89-40ec-4307-9fdd-346b68185bf2	\N	\N	999	0	1	4	9	8	8	0	4	0	0	0	0	\N	\N	\N	Analis	\N	\N	2026-06-15 14:11:48.225022
29	c8065771-c617-4db7-87ba-8a948282e8f6	\N	\N	999	0	1	10	7	5	0	4	6	0	0	0	0	\N	\N	\N	Pelaksana Teliti	\N	\N	2026-06-15 14:11:48.225022
30	c3c2f6d7-0d35-4d04-922d-0146a7270185	\N	\N	999	8	3	4	10	8	0	6	4	0	0	0	0	\N	\N	\N	Strategis	\N	\N	2026-06-15 14:11:48.225022
31	83ee8be1-1151-4ff3-951c-b722dbf4d232	\N	\N	999	9	10	0	7	0	7	10	8	0	0	0	0	\N	\N	\N	Strategis	\N	\N	2026-06-15 14:11:48.225022
32	a3223597-2552-4dd8-8931-41775fd19d10	\N	\N	999	9	8	4	2	0	4	1	9	0	0	0	0	\N	\N	\N	Influencer	\N	\N	2026-06-15 14:11:48.225022
33	6e98e408-5a17-41ae-ad00-037080b85e0d	\N	\N	999	8	7	3	3	2	3	10	1	0	0	0	0	\N	\N	\N	Konsultan Empatik	\N	\N	2026-06-15 14:11:48.225022
34	efcc2939-2506-44c2-9bd4-6e19395b5451	\N	\N	999	3	0	9	0	7	1	3	2	0	0	0	0	\N	\N	\N	Pelaksana Teliti	\N	\N	2026-06-15 14:11:48.225022
35	0ca8b3ea-875d-421c-b230-10857175c683	\N	\N	999	4	7	9	9	7	0	8	9	0	0	0	0	\N	\N	\N	Pendukung	\N	\N	2026-06-15 14:11:48.225022
36	9ad7e7fb-8086-4fb3-bef4-62a3a181187d	\N	\N	999	8	3	4	3	3	1	2	1	0	0	0	0	\N	\N	\N	Strategis	\N	\N	2026-06-15 14:11:48.225022
37	c5a84425-3349-4ad8-9240-e1b68d62d6ef	\N	\N	999	9	6	3	9	7	6	9	8	0	0	0	0	\N	\N	\N	Pengendali	\N	\N	2026-06-15 14:11:48.225022
38	e7a9d7b1-835e-4edd-ac5d-2ba67d5bad47	\N	\N	999	4	8	0	10	2	4	4	10	0	0	0	0	\N	\N	\N	Konsultan Empatik	\N	\N	2026-06-15 14:11:48.225022
39	e1721a26-bee5-48f4-84ad-452212c07821	\N	\N	999	10	2	5	8	1	2	8	5	0	0	0	0	\N	\N	\N	Konsultan Empatik	\N	\N	2026-06-15 14:11:48.225022
40	16c5ab27-122e-4684-bab9-bfad23cbae2d	\N	\N	999	2	9	3	7	7	1	2	3	0	0	0	0	\N	\N	\N	Konsultan Empatik	\N	\N	2026-06-15 14:11:48.225022
41	250b647f-4439-4350-b1c2-52c65cc97a10	\N	\N	999	7	4	4	3	2	3	7	1	0	0	0	0	\N	\N	\N	Analis	\N	\N	2026-06-15 14:11:48.225022
42	d082f677-513d-4b8f-9cef-c73b784503b6	\N	\N	999	10	0	1	5	8	9	3	7	0	0	0	0	\N	\N	\N	Pemimpin Dinamis	\N	\N	2026-06-15 14:11:48.225022
43	cf9649b8-de12-454a-a441-6950a18718b9	\N	\N	999	1	8	2	3	1	8	2	1	0	0	0	0	\N	\N	\N	Pelaksana Teliti	\N	\N	2026-06-15 14:11:48.225022
44	bf1c1871-e40f-4ec7-8fc5-90b215a913fd	\N	\N	999	5	6	4	7	9	8	0	10	0	0	0	0	\N	\N	\N	Seimbang	\N	\N	2026-06-15 14:11:48.225022
45	7a1b13e6-55be-48e1-81d1-251ce6e50878	\N	\N	999	3	6	2	1	5	6	0	9	0	0	0	0	\N	\N	\N	Pelaksana Teliti	\N	\N	2026-06-15 14:11:48.225022
46	baa619f4-f59f-492e-bf41-67073f934db4	\N	\N	999	7	1	0	10	3	7	7	1	0	0	0	0	\N	\N	\N	Pendukung	\N	\N	2026-06-15 14:11:48.225022
47	b3e99c8c-5f9d-46ac-88de-e305679eb454	\N	\N	999	5	9	3	4	7	8	7	3	0	0	0	0	\N	\N	\N	Pendukung	\N	\N	2026-06-15 14:11:48.225022
48	edf1feed-3035-4133-ac3b-6c46e0ad3ef8	\N	\N	999	0	1	2	1	5	9	6	4	0	0	0	0	\N	\N	\N	Pemimpin Dinamis	\N	\N	2026-06-15 14:11:48.225022
49	893c6a6a-37c1-4e20-a1cc-f6f7878a5883	\N	\N	999	1	5	1	1	10	10	8	3	0	0	0	0	\N	\N	\N	Pemimpin Dinamis	\N	\N	2026-06-15 14:11:48.225022
50	4358ed04-3f46-45dc-804d-9cb71671cba8	\N	\N	999	1	3	3	4	4	5	0	10	0	0	0	0	\N	\N	\N	Seimbang	\N	\N	2026-06-15 14:11:48.225022
51	3efb78be-bc11-400c-968b-49a1bef666d6	\N	\N	999	5	9	2	10	9	4	2	5	0	0	0	0	\N	\N	\N	Pelaksana Teliti	\N	\N	2026-06-15 14:11:48.225022
52	02b4ff08-2975-44ec-931a-7ac911e503b5	\N	\N	999	5	4	3	4	0	3	3	4	0	0	0	0	\N	\N	\N	Analis	\N	\N	2026-06-15 14:11:48.225022
53	9977dfc6-4374-4406-9059-a4a50b9a1373	\N	\N	999	8	0	8	1	1	7	10	1	0	0	0	0	\N	\N	\N	Pemimpin Dinamis	\N	\N	2026-06-15 14:11:48.225022
54	e2f4031c-750d-4283-8740-75d0c7d9b5fe	\N	\N	999	3	6	6	3	3	4	3	4	0	0	0	0	\N	\N	\N	Konsultan Empatik	\N	\N	2026-06-15 14:11:48.225022
55	ef6dc49d-8639-4636-b4cc-2e3fa40d9a94	\N	\N	999	2	5	0	6	1	7	6	3	0	0	0	0	\N	\N	\N	Influencer	\N	\N	2026-06-15 14:11:48.225022
56	5516a843-6fdf-4a4d-9264-88d932b7197a	\N	\N	999	2	6	9	6	10	5	9	2	0	0	0	0	\N	\N	\N	Influencer	\N	\N	2026-06-15 14:11:48.225022
57	55492aef-4a9e-4cbf-8a66-940afc571470	\N	\N	999	2	2	4	4	3	7	7	9	0	0	0	0	\N	\N	\N	Pendukung	\N	\N	2026-06-15 14:11:48.225022
58	9b2e0574-8b56-4126-9576-e50eeb80d2f7	\N	\N	999	10	5	2	1	3	10	2	7	0	0	0	0	\N	\N	\N	Analis	\N	\N	2026-06-15 14:11:48.225022
59	ecd99560-cb6f-4359-af98-4b0d65690cda	\N	\N	999	6	4	6	0	6	2	10	3	0	0	0	0	\N	\N	\N	Analis	\N	\N	2026-06-15 14:11:48.225022
60	8c9fd6a7-b10e-4ced-b73d-7e1ca604e8ca	\N	\N	999	7	6	8	4	6	6	1	0	0	0	0	0	\N	\N	\N	Konsultan Empatik	\N	\N	2026-06-15 14:11:48.225022
61	7130a9fd-8021-402a-a29f-0e820a9805d0	\N	\N	999	9	3	1	0	9	2	1	0	0	0	0	0	\N	\N	\N	Pengendali	\N	\N	2026-06-15 14:11:48.225022
62	3dd7f158-22c1-4969-94e5-3685d27635f8	\N	\N	999	5	7	3	4	10	6	7	6	0	0	0	0	\N	\N	\N	Pendukung	\N	\N	2026-06-15 14:11:48.225022
63	00a1036d-78e4-4a5d-9274-f64b86710af4	\N	\N	999	1	0	2	7	0	1	7	1	0	0	0	0	\N	\N	\N	Strategis	\N	\N	2026-06-15 14:11:48.225022
64	8c53f9b7-bca2-495e-b7a1-1e72f3ae1d66	\N	\N	999	3	9	5	3	4	10	2	8	0	0	0	0	\N	\N	\N	Konsultan Empatik	\N	\N	2026-06-15 14:11:48.225022
65	cecc9511-5026-4181-b1bd-b5fc24db8166	\N	\N	999	6	10	3	4	7	0	6	1	0	0	0	0	\N	\N	\N	Strategis	\N	\N	2026-06-15 14:11:48.225022
66	b210a83a-93df-4e56-994c-e9c507868513	\N	\N	999	5	3	10	0	9	7	9	8	0	0	0	0	\N	\N	\N	Pemimpin Dinamis	\N	\N	2026-06-15 14:11:48.225022
67	3772b413-138d-405f-bfdd-61477808fc92	\N	\N	999	1	6	1	6	10	0	1	5	0	0	0	0	\N	\N	\N	Strategis	\N	\N	2026-06-15 14:11:48.225022
68	eacc4913-7529-40d2-ba62-446d8c45bd9b	\N	\N	999	10	0	2	8	7	10	4	9	0	0	0	0	\N	\N	\N	Pengendali	\N	\N	2026-06-15 14:11:48.225022
69	daab5116-420e-46e1-9e00-bfdcba51edd7	\N	\N	999	9	5	9	1	1	3	7	0	0	0	0	0	\N	\N	\N	Influencer	\N	\N	2026-06-15 14:11:48.225022
70	42dab708-e9d7-4cc4-a9ab-99448dcec05e	\N	\N	999	4	5	0	6	2	3	0	6	0	0	0	0	\N	\N	\N	Strategis	\N	\N	2026-06-15 14:11:48.225022
71	3128126c-b3f9-4c19-a435-9cbb527b790f	\N	\N	999	0	0	5	9	5	3	0	0	0	0	0	0	\N	\N	\N	Influencer	\N	\N	2026-06-15 14:11:48.225022
72	94dc98e0-d52c-47a0-9cf7-7d1d29f50eae	\N	\N	999	9	8	1	1	0	4	8	7	0	0	0	0	\N	\N	\N	Influencer	\N	\N	2026-06-15 14:11:48.225022
73	a8cd6eb8-a42c-4fa6-a6c4-61c668e62783	\N	\N	999	1	0	1	0	9	4	1	1	0	0	0	0	\N	\N	\N	Pendukung	\N	\N	2026-06-15 14:11:48.225022
74	6b13554f-3f28-4133-8afe-9bd13881e537	\N	\N	999	8	0	2	4	1	2	1	7	0	0	0	0	\N	\N	\N	Pelaksana Teliti	\N	\N	2026-06-15 14:11:48.225022
75	777088a3-62f1-4fd5-9217-3f32ce9df6d5	\N	\N	999	6	1	8	8	5	3	8	1	0	0	0	0	\N	\N	\N	Influencer	\N	\N	2026-06-15 14:11:48.225022
76	5dd63582-e883-4d1f-a1cf-50b620b064ab	\N	\N	999	4	3	3	0	5	3	6	2	0	0	0	0	\N	\N	\N	Strategis	\N	\N	2026-06-15 14:11:48.225022
77	a072eb9a-9e4a-465f-aba5-f4f76b5d048e	\N	\N	999	2	2	7	7	7	9	5	1	0	0	0	0	\N	\N	\N	Seimbang	\N	\N	2026-06-15 14:11:48.225022
78	19547fce-f299-4d3e-9e7e-6f42941fcae5	\N	\N	999	7	1	4	3	8	10	8	6	0	0	0	0	\N	\N	\N	Strategis	\N	\N	2026-06-15 14:11:48.225022
79	3e4dc158-b6b8-4568-b00d-ebf3f05e5628	\N	\N	999	2	2	9	7	1	7	10	4	0	0	0	0	\N	\N	\N	Analis	\N	\N	2026-06-15 14:11:48.225022
80	be826c3a-3e6c-40fb-a45c-4438e13955b6	\N	\N	999	1	3	8	6	3	10	1	2	0	0	0	0	\N	\N	\N	Influencer	\N	\N	2026-06-15 14:11:48.225022
81	22c1d10b-7f72-4e29-9fab-501730285e9e	\N	\N	999	4	3	1	8	4	1	2	6	0	0	0	0	\N	\N	\N	Strategis	\N	\N	2026-06-15 14:11:48.225022
82	b7e9e71d-78c9-4ee5-8a48-4758ad727519	\N	\N	999	1	8	2	4	2	3	9	0	0	0	0	0	\N	\N	\N	Analis	\N	\N	2026-06-15 14:11:48.225022
83	29f5cfd4-3500-4041-9ddf-4093e31b9631	\N	\N	999	5	8	2	9	7	1	9	4	0	0	0	0	\N	\N	\N	Strategis	\N	\N	2026-06-15 14:11:48.225022
84	ebdb9225-b8ec-42aa-b832-bb8ca1d97d47	\N	\N	999	5	1	7	5	5	0	2	9	0	0	0	0	\N	\N	\N	Seimbang	\N	\N	2026-06-15 14:11:48.225022
85	f063965e-80d2-4aea-889f-3f033cdda727	\N	\N	999	3	3	4	4	5	5	4	10	0	0	0	0	\N	\N	\N	Konsultan Empatik	\N	\N	2026-06-15 14:11:48.225022
86	18f6f0e3-b262-4721-a232-0134fa8a9f98	\N	\N	999	2	8	9	5	2	6	10	0	0	0	0	0	\N	\N	\N	Pelaksana Teliti	\N	\N	2026-06-15 14:11:48.225022
87	053b5809-ea38-4b14-9604-e3d5da6b1275	\N	\N	999	8	10	3	1	7	1	3	4	0	0	0	0	\N	\N	\N	Analis	\N	\N	2026-06-15 14:11:48.225022
88	3a686abb-e5a8-43c9-8441-a33d8ff8441e	\N	\N	999	1	1	5	0	8	10	10	6	0	0	0	0	\N	\N	\N	Pelaksana Teliti	\N	\N	2026-06-15 14:11:48.225022
89	4db68934-6182-45d0-b02e-6981bab3b2df	\N	\N	999	4	6	5	3	2	9	0	8	0	0	0	0	\N	\N	\N	Seimbang	\N	\N	2026-06-15 14:11:48.225022
90	4be374fe-b85f-4cfc-8a68-47c37488bcee	\N	\N	999	7	10	8	10	0	8	10	5	0	0	0	0	\N	\N	\N	Seimbang	\N	\N	2026-06-15 14:11:48.225022
91	f6f5609b-876b-4818-a86e-1fb5cb4da5b0	\N	\N	999	7	10	3	10	3	8	7	8	0	0	0	0	\N	\N	\N	Analis	\N	\N	2026-06-15 14:11:48.225022
92	0261a557-ad1d-4251-8de5-25dcb08f5b1d	\N	\N	999	0	3	0	4	7	6	6	2	0	0	0	0	\N	\N	\N	Pelaksana Teliti	\N	\N	2026-06-15 14:11:48.225022
93	b9c6b67e-40b7-4141-96c4-4b4fbe774248	\N	\N	999	0	7	0	4	9	0	2	6	0	0	0	0	\N	\N	\N	Influencer	\N	\N	2026-06-15 14:11:48.225022
94	5aa6f2b9-8377-4b81-b08c-18e00ba94d4d	\N	\N	999	5	4	7	8	8	5	4	1	0	0	0	0	\N	\N	\N	Konsultan Empatik	\N	\N	2026-06-15 14:11:48.225022
95	d83f973c-bb87-461d-a593-bb25f37d75af	\N	\N	999	0	4	0	9	2	8	9	8	0	0	0	0	\N	\N	\N	Pendukung	\N	\N	2026-06-15 14:11:48.225022
96	d8747d4a-517a-41af-b213-1b9151670cff	\N	\N	999	4	1	7	5	10	2	6	8	0	0	0	0	\N	\N	\N	Seimbang	\N	\N	2026-06-15 14:11:48.225022
97	47437537-c0a6-47c7-85b0-014c3ef9d12e	\N	\N	999	0	0	9	1	0	2	7	0	0	0	0	0	\N	\N	\N	Strategis	\N	\N	2026-06-15 14:11:48.225022
98	7f50cd56-4c37-4d16-84a5-792d845d850c	\N	\N	999	5	8	4	6	8	4	6	0	0	0	0	0	\N	\N	\N	Strategis	\N	\N	2026-06-15 14:11:48.225022
99	ff1ecf9d-14ee-4bf2-8f7e-812cee075d43	\N	\N	999	10	3	7	1	3	8	2	8	0	0	0	0	\N	\N	\N	Analis	\N	\N	2026-06-15 14:11:48.225022
100	5b0903ae-1b3f-4f4f-86bc-c25cbae5d3da	\N	\N	999	4	8	0	2	5	10	8	3	0	0	0	0	\N	\N	\N	Pendukung	\N	\N	2026-06-15 14:11:48.225022
101	bd7953c5-edff-4661-89bb-58b0c746109e	\N	\N	999	8	7	10	3	0	1	1	0	0	0	0	0	\N	\N	\N	Analis	\N	\N	2026-06-15 14:11:48.225022
102	d8870e3a-2487-47fb-a744-2617f4f48016	\N	\N	999	8	1	1	9	4	3	4	2	0	0	0	0	\N	\N	\N	Analis	\N	\N	2026-06-15 14:11:48.225022
103	51f6c406-63f1-4d67-9231-d413ee3b7850	\N	\N	999	5	7	4	2	10	7	5	3	0	0	0	0	\N	\N	\N	Strategis	\N	\N	2026-06-15 14:11:48.225022
104	71137d1d-f54b-4da3-a744-ad37a5cefb35	\N	\N	999	6	10	5	5	10	3	3	6	0	0	0	0	\N	\N	\N	Pengendali	\N	\N	2026-06-15 14:11:48.225022
105	b48324bf-3b8f-45d5-bb00-d53cdacae86e	\N	\N	999	10	4	3	0	6	6	0	8	0	0	0	0	\N	\N	\N	Pelaksana Teliti	\N	\N	2026-06-15 14:11:48.225022
106	bcbbae99-2847-4fa0-8e59-324f1044eb61	\N	\N	999	0	7	1	10	9	6	10	0	0	0	0	0	\N	\N	\N	Pengendali	\N	\N	2026-06-15 14:11:48.225022
107	d7dbe66b-d1dc-46e2-98ed-b5a34fa12d64	\N	\N	999	2	7	9	4	2	3	5	9	0	0	0	0	\N	\N	\N	Pengendali	\N	\N	2026-06-15 14:11:48.225022
108	a32f588f-cb2b-43f5-9d59-8e95c1ea45a8	\N	\N	999	6	10	10	0	8	2	1	1	0	0	0	0	\N	\N	\N	Pemimpin Dinamis	\N	\N	2026-06-15 14:11:48.225022
109	f91ac970-7e66-4360-b5d4-925cda81f2ba	\N	\N	999	8	10	0	10	1	6	2	6	0	0	0	0	\N	\N	\N	Pengendali	\N	\N	2026-06-15 14:11:48.225022
110	bda5f54a-8294-40ca-b5f2-3670f5a9eb18	\N	\N	999	8	4	7	5	8	10	10	7	0	0	0	0	\N	\N	\N	Influencer	\N	\N	2026-06-15 14:11:48.225022
111	110a7494-a769-4528-b123-660f821c6a9d	\N	\N	999	4	2	9	1	10	6	2	6	0	0	0	0	\N	\N	\N	Influencer	\N	\N	2026-06-15 14:11:48.225022
\.


--
-- Data for Name: disc_scoring_dif; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.disc_scoring_dif (id, d_score, i_score, s_score, c_score, key) FROM stdin;
1	1	0	0	0	D
2	0	1	0	0	I
3	0	0	1	0	S
4	0	0	0	1	C
5	1	1	0	0	DI
6	1	0	1	0	DS
7	1	0	0	1	DC
8	0	1	1	0	IS
9	0	1	0	1	IC
10	0	0	1	1	SC
11	1	1	1	0	DIS
12	1	1	0	1	DIC
13	1	0	1	1	DSC
14	0	1	1	1	ISC
15	1	1	1	1	X
16	0	0	0	0	X
\.


--
-- Data for Name: disc_scoring_least; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.disc_scoring_least (id, d_score, i_score, s_score, c_score, key) FROM stdin;
1	1	0	0	0	D
2	0	1	0	0	I
3	0	0	1	0	S
4	0	0	0	1	C
5	1	1	0	0	DI
6	1	0	1	0	DS
7	1	0	0	1	DC
8	0	1	1	0	IS
9	0	1	0	1	IC
10	0	0	1	1	SC
11	1	1	1	0	DIS
12	1	1	0	1	DIC
13	1	0	1	1	DSC
14	0	1	1	1	ISC
15	1	1	1	1	X
16	0	0	0	0	X
\.


--
-- Data for Name: disc_scoring_most; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.disc_scoring_most (id, d_score, i_score, s_score, c_score, key) FROM stdin;
1	1	0	0	0	D
2	0	1	0	0	I
3	0	0	1	0	S
4	0	0	0	1	C
5	1	1	0	0	DI
6	1	0	1	0	DS
7	1	0	0	1	DC
8	0	1	1	0	IS
9	0	1	0	1	IC
10	0	0	1	1	SC
11	1	1	1	0	DIS
12	1	1	0	1	DIC
13	1	0	1	1	DSC
14	0	1	1	1	ISC
15	1	1	1	1	X
16	0	0	0	0	X
\.


--
-- Data for Name: fee_config; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fee_config (id, category_id, student_fee, afiliator_share_pct, gurubk_share_pct, platform_share_pct, updated_at) FROM stdin;
1	\N	150000.00	20.00	10.00	70.00	2026-06-14 16:19:20.631978
\.


--
-- Data for Name: fee_shares; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fee_shares (id, student_id, category_id, afiliator_id, gurubk_id, total_fee, afiliator_share, gurubk_share, platform_share, created_at) FROM stdin;
1	6a2e78f6572208361f6edc48	1	\N	\N	150000.00	30000.00	15000.00	105000.00	2026-06-14 16:48:39.769709
\.


--
-- Data for Name: flyway_schema_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.flyway_schema_history (installed_rank, version, description, type, script, checksum, installed_by, installed_on, execution_time, success) FROM stdin;
1	1	core	SQL	V1__core.sql	693987810	eko	2026-06-14 16:19:20.353893	35	t
2	2	disc	SQL	V2__disc.sql	1475372757	eko	2026-06-14 16:19:20.412859	33	t
3	3	holland	SQL	V3__holland.sql	1523148676	eko	2026-06-14 16:19:20.45984	20	t
4	4	papi	SQL	V4__papi.sql	1035800859	eko	2026-06-14 16:19:20.489979	18	t
5	5	cfit	SQL	V5__cfit.sql	1808428212	eko	2026-06-14 16:19:20.516319	16	t
6	6	ist	SQL	V6__ist.sql	-1724875316	eko	2026-06-14 16:19:20.541392	35	t
7	7	fees logs	SQL	V7__fees_logs.sql	1440546488	eko	2026-06-14 16:19:20.585382	18	t
8	8	seed sample data	SQL	V8__seed_sample_data.sql	-1060579498	eko	2026-06-14 16:19:20.612998	27	t
9	9	seed evaluasi 2026	SQL	V9__seed_evaluasi_2026.sql	1665406185	eko	2026-06-15 14:11:48.306557	10	t
\.


--
-- Data for Name: holland_descriptions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.holland_descriptions (id, riasec_type, name, description, careers) FROM stdin;
1	R	Realistic (Realistis)	Menyukai pekerjaan dengan tangan, alat, mesin, atau di luar ruangan. Praktis dan fisik.	Teknisi, Mekanik, Insinyur, Pertanian, Konstruksi
2	I	Investigative (Investigatif)	Analitis, intelektual, suka memecahkan masalah ilmiah. Berorientasi riset.	Ilmuwan, Peneliti, Programmer, Dokter, Analis Data
3	A	Artistic (Artistik)	Kreatif, imajinatif, ekspresif. Menyukai seni, musik, sastra, dan desain.	Desainer, Seniman, Penulis, Musisi, Aktor
4	S	Social (Sosial)	Peduli pada orang lain, suka membantu dan mengajar. Berorientasi layanan.	Guru, Konselor, Pekerja Sosial, Perawat, HRD
5	E	Enterprising (Kewirausahaan)	Suka memimpin, memengaruhi, dan berwirausaha. Kompetitif dan ambisius.	Manajer, Pengusaha, Politisi, Sales, Marketing
6	C	Conventional (Konvensional)	Terorganisir, detail, mengikuti prosedur. Suka data dan administrasi.	Akuntan, Administrasi, Analis Keuangan, Arsiparis
\.


--
-- Data for Name: holland_questions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.holland_questions (id, group_code, item_no, riasec_type, statement, is_active) FROM stdin;
1	R1	1	R	Saya senang bekerja dengan peralatan tangan atau mesin	t
2	R1	2	R	Saya menikmati pekerjaan fisik di luar ruangan	t
3	R1	3	R	Saya tertarik pada perbaikan kendaraan atau elektronik	t
4	R1	4	R	Saya suka membangun atau merakit sesuatu	t
5	R1	5	R	Saya nyaman bekerja dengan hewan atau tanaman	t
6	R1	6	R	Saya lebih suka bertindak daripada merencanakan	t
7	R1	7	R	Saya menikmati kegiatan bertahan hidup di alam	t
8	R1	8	R	Saya suka bekerja dengan bahan-bahan fisik seperti kayu atau logam	t
9	R1	9	R	Saya tertarik pada pekerjaan konstruksi atau pertanian	t
10	R1	10	R	Saya senang memperbaiki barang-barang yang rusak	t
11	R1	11	R	Saya lebih suka pekerjaan nyata daripada pekerjaan abstrak	t
12	I1	1	I	Saya senang membaca jurnal ilmiah atau artikel riset	t
13	I1	2	I	Saya menikmati memecahkan masalah matematika yang sulit	t
14	I1	3	I	Saya tertarik pada percobaan dan eksperimen	t
15	I1	4	I	Saya suka menganalisis data untuk menemukan pola	t
16	I1	5	I	Saya tertarik pada cara kerja teknologi terbaru	t
17	I1	6	I	Saya senang belajar tentang fenomena alam	t
18	I1	7	I	Saya menikmati debat ilmiah atau diskusi logis	t
19	I1	8	I	Saya tertarik pada penelitian medis atau biologi	t
20	I1	9	I	Saya suka mencari solusi kreatif untuk masalah teknis	t
21	I1	10	I	Saya senang bekerja dengan komputer dan pemrograman	t
22	I1	11	I	Saya tertarik pada astronomi atau fisika	t
23	A1	1	A	Saya suka menggambar atau melukis	t
24	A1	2	A	Saya menikmati bermain musik	t
25	A1	3	A	Saya tertarik pada dunia seni dan pertunjukan	t
26	A1	4	A	Saya suka menulis cerita atau puisi	t
27	A1	5	A	Saya menikmati desain grafis atau fotografi	t
28	A1	6	A	Saya senang bereksplorasi dengan ide-ide kreatif	t
29	A1	7	A	Saya tertarik pada dunia mode atau desain interior	t
30	A1	8	A	Saya suka akting atau tampil di panggung	t
31	A1	9	A	Saya menikmati menonton film seni atau teater	t
32	A1	10	A	Saya tertarik pada kerajinan tangan atau seni rupa	t
33	A1	11	A	Saya lebih suka ekspresi bebas daripada aturan ketat	t
34	S1	1	S	Saya menikmati membantu teman yang kesulitan	t
35	S1	2	S	Saya tertarik pada pekerjaan sosial atau sukarela	t
36	S1	3	S	Saya senang mengajar atau melatih orang lain	t
37	S1	4	S	Saya peduli pada kesejahteraan masyarakat	t
38	S1	5	S	Saya menikmati konseling atau mendengarkan curahan hati	t
39	S1	6	S	Saya tertarik pada pekerjaan kemanusiaan	t
40	S1	7	S	Saya senang bekerja dalam tim yang kolaboratif	t
41	S1	8	S	Saya tertarik pada pendidikan anak atau remaja	t
42	S1	9	S	Saya suka menciptakan lingkungan yang nyaman bagi orang lain	t
43	S1	10	S	Saya menikmati kegiatan komunitas dan sosial	t
44	S1	11	S	Saya tertarik pada perawatan kesehatan atau terapi	t
45	E1	1	E	Saya suka memimpin sebuah proyek atau tim	t
46	E1	2	E	Saya menikmati persuasi dan negosiasi	t
47	E1	3	E	Saya tertarik pada dunia bisnis dan kewirausahaan	t
48	E1	4	E	Saya senang mengambil risiko yang terukur	t
49	E1	5	E	Saya menikmati kompetisi dan pencapaian target	t
50	E1	6	E	Saya tertarik pada strategi pemasaran	t
51	E1	7	E	Saya suka membuat keputusan besar	t
52	E1	8	E	Saya tertarik pada karier di manajemen atau kepemimpinan	t
53	E1	9	E	Saya senang berbicara di depan publik	t
54	E1	10	E	Saya menikmati memotivasi dan menginspirasi orang lain	t
55	E1	11	E	Saya tertarik pada investasi atau keuangan bisnis	t
56	C1	1	C	Saya suka bekerja dengan angka dan data	t
57	C1	2	C	Saya menikmati pengarsipan dan pengorganisasian berkas	t
58	C1	3	C	Saya tertarik pada akuntansi atau keuangan	t
59	C1	4	C	Saya senang mengikuti prosedur dengan ketat	t
60	C1	5	C	Saya menikmati pekerjaan yang membutuhkan ketelitian tinggi	t
61	C1	6	C	Saya tertarik pada administrasi atau manajemen kantor	t
62	C1	7	C	Saya suka membuat laporan dan dokumentasi	t
63	C1	8	C	Saya menikmati bekerja dengan spreadsheet atau database	t
64	C1	9	C	Saya tertarik pada pekerjaan analisis atau audit	t
65	C1	10	C	Saya senang mengikuti jadwal dan rencana	t
66	C1	11	C	Saya lebih suka pekerjaan terstruktur daripada fleksibel	t
\.


--
-- Data for Name: holland_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.holland_results (id, auth_user_id, student_name, school_name, assignment_id, r_score, i_score, a_score, s_score, e_score, c_score, type1, type2, type3, holland_code, type1_name, type1_desc, answers, completed_at) FROM stdin;
1	6a2e78f6572208361f6edc48	Al-Kahf Muhammad Zanjabiil	SMP Muhammadiyah Yogyakarta 2	1	44	44	32	44	44	44	C	E	I	CEI	Conventional (Konvensional)	Terorganisir, detail, mengikuti prosedur. Suka data dan administrasi.	[{"score": 1, "questionId": 23}, {"score": 2, "questionId": 24}, {"score": 2, "questionId": 25}, {"score": 2, "questionId": 26}, {"score": 2, "questionId": 27}, {"score": 3, "questionId": 28}, {"score": 4, "questionId": 29}, {"score": 4, "questionId": 30}, {"score": 4, "questionId": 31}, {"score": 4, "questionId": 32}, {"score": 4, "questionId": 33}, {"score": 4, "questionId": 56}, {"score": 4, "questionId": 57}, {"score": 4, "questionId": 58}, {"score": 4, "questionId": 59}, {"score": 4, "questionId": 60}, {"score": 4, "questionId": 61}, {"score": 4, "questionId": 62}, {"score": 4, "questionId": 63}, {"score": 4, "questionId": 64}, {"score": 4, "questionId": 65}, {"score": 4, "questionId": 66}, {"score": 4, "questionId": 45}, {"score": 4, "questionId": 46}, {"score": 4, "questionId": 47}, {"score": 4, "questionId": 48}, {"score": 4, "questionId": 49}, {"score": 4, "questionId": 50}, {"score": 4, "questionId": 51}, {"score": 4, "questionId": 52}, {"score": 4, "questionId": 53}, {"score": 4, "questionId": 54}, {"score": 4, "questionId": 55}, {"score": 4, "questionId": 12}, {"score": 4, "questionId": 13}, {"score": 4, "questionId": 14}, {"score": 4, "questionId": 15}, {"score": 4, "questionId": 16}, {"score": 4, "questionId": 17}, {"score": 4, "questionId": 18}, {"score": 4, "questionId": 19}, {"score": 4, "questionId": 20}, {"score": 4, "questionId": 21}, {"score": 4, "questionId": 22}, {"score": 4, "questionId": 1}, {"score": 4, "questionId": 2}, {"score": 4, "questionId": 3}, {"score": 4, "questionId": 4}, {"score": 4, "questionId": 5}, {"score": 4, "questionId": 6}, {"score": 4, "questionId": 7}, {"score": 4, "questionId": 8}, {"score": 4, "questionId": 9}, {"score": 4, "questionId": 10}, {"score": 4, "questionId": 11}, {"score": 4, "questionId": 34}, {"score": 4, "questionId": 35}, {"score": 4, "questionId": 36}, {"score": 4, "questionId": 37}, {"score": 4, "questionId": 38}, {"score": 4, "questionId": 39}, {"score": 4, "questionId": 40}, {"score": 4, "questionId": 41}, {"score": 4, "questionId": 42}, {"score": 4, "questionId": 43}, {"score": 4, "questionId": 44}]	2026-06-14 17:18:22.210699
12	cc2f0f8a-59a3-4a5e-9bfe-1c670c519393	\N	\N	999	31	48	20	27	28	22	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
13	1654ba45-7070-4d1b-a8d2-f09e3f64c11e	\N	\N	999	23	27	15	36	21	27	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
14	4c9ca049-08a2-4b28-a5d8-c8b69ec084bf	\N	\N	999	34	35	22	22	45	15	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
15	1e6a9e81-1ac2-46b5-a700-4c76ed08536d	\N	\N	999	41	47	12	16	27	36	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
16	4ca82485-a400-43b5-bbdb-0292a8b19538	\N	\N	999	26	11	50	31	48	50	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
17	266c53e9-355e-4176-bebd-c7c0f088e93c	\N	\N	999	17	43	50	44	10	21	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
18	a0355bd2-dd2f-4e2e-b188-8e24fc0247fc	\N	\N	999	41	22	15	46	23	33	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
19	9657db6a-b9fc-4ab5-99ba-b1dce9318094	\N	\N	999	41	13	26	39	11	46	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
20	82d8f94b-dedb-4e9d-8d60-420d022ad08e	\N	\N	999	10	32	19	35	12	19	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
21	2d1666f6-f176-47d6-91b0-3d1af8045d49	\N	\N	999	20	26	48	13	21	45	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
22	d608456c-2cf9-4b7d-af93-7fec87443402	\N	\N	999	50	43	38	25	19	14	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
23	15419209-5200-46da-b3f9-c8a63d1d57d2	\N	\N	999	23	42	41	20	36	25	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
24	0532d0ed-4f72-45ea-a2a9-4c3a818ec580	\N	\N	999	12	44	29	16	19	28	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
25	eef746bc-85f4-47dd-93c6-9cedb993e8ef	\N	\N	999	47	25	28	50	19	11	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
26	21e9cce0-931e-4a32-b8a6-a38e52ecfd40	\N	\N	999	19	36	11	50	40	20	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
27	5a32cb0e-557a-46c7-9b68-9864b80d0976	\N	\N	999	26	47	29	39	12	20	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
28	1fa0df89-40ec-4307-9fdd-346b68185bf2	\N	\N	999	24	34	34	41	41	27	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
29	c8065771-c617-4db7-87ba-8a948282e8f6	\N	\N	999	22	29	30	18	18	42	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
30	c3c2f6d7-0d35-4d04-922d-0146a7270185	\N	\N	999	42	10	49	16	18	49	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
31	83ee8be1-1151-4ff3-951c-b722dbf4d232	\N	\N	999	46	39	10	24	20	14	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
32	a3223597-2552-4dd8-8931-41775fd19d10	\N	\N	999	35	42	44	42	27	48	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
33	6e98e408-5a17-41ae-ad00-037080b85e0d	\N	\N	999	14	20	15	34	28	49	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
34	efcc2939-2506-44c2-9bd4-6e19395b5451	\N	\N	999	13	42	45	37	26	13	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
35	0ca8b3ea-875d-421c-b230-10857175c683	\N	\N	999	26	44	18	42	16	38	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
36	9ad7e7fb-8086-4fb3-bef4-62a3a181187d	\N	\N	999	21	32	29	46	40	12	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
37	c5a84425-3349-4ad8-9240-e1b68d62d6ef	\N	\N	999	13	35	49	13	39	22	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
38	e7a9d7b1-835e-4edd-ac5d-2ba67d5bad47	\N	\N	999	15	29	22	20	39	34	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
39	e1721a26-bee5-48f4-84ad-452212c07821	\N	\N	999	37	24	26	15	44	16	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
40	16c5ab27-122e-4684-bab9-bfad23cbae2d	\N	\N	999	31	17	29	45	47	32	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
41	250b647f-4439-4350-b1c2-52c65cc97a10	\N	\N	999	18	37	19	48	50	22	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
42	d082f677-513d-4b8f-9cef-c73b784503b6	\N	\N	999	36	41	16	32	12	44	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
43	cf9649b8-de12-454a-a441-6950a18718b9	\N	\N	999	10	42	37	45	20	39	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
44	bf1c1871-e40f-4ec7-8fc5-90b215a913fd	\N	\N	999	18	11	29	50	24	22	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
45	7a1b13e6-55be-48e1-81d1-251ce6e50878	\N	\N	999	11	12	17	10	43	32	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
46	baa619f4-f59f-492e-bf41-67073f934db4	\N	\N	999	32	38	18	10	11	17	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
47	b3e99c8c-5f9d-46ac-88de-e305679eb454	\N	\N	999	31	29	50	45	25	47	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
48	edf1feed-3035-4133-ac3b-6c46e0ad3ef8	\N	\N	999	44	17	43	20	36	24	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
49	893c6a6a-37c1-4e20-a1cc-f6f7878a5883	\N	\N	999	19	13	49	27	48	46	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
50	4358ed04-3f46-45dc-804d-9cb71671cba8	\N	\N	999	41	34	25	16	22	16	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
51	3efb78be-bc11-400c-968b-49a1bef666d6	\N	\N	999	15	49	26	33	30	25	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
52	02b4ff08-2975-44ec-931a-7ac911e503b5	\N	\N	999	28	39	18	50	45	19	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
53	9977dfc6-4374-4406-9059-a4a50b9a1373	\N	\N	999	19	41	32	18	16	43	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
54	e2f4031c-750d-4283-8740-75d0c7d9b5fe	\N	\N	999	30	14	15	47	44	46	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
55	ef6dc49d-8639-4636-b4cc-2e3fa40d9a94	\N	\N	999	35	29	31	22	24	35	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
56	5516a843-6fdf-4a4d-9264-88d932b7197a	\N	\N	999	48	40	16	35	24	25	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
57	55492aef-4a9e-4cbf-8a66-940afc571470	\N	\N	999	26	31	30	34	36	33	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
58	9b2e0574-8b56-4126-9576-e50eeb80d2f7	\N	\N	999	47	15	25	34	43	33	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
59	ecd99560-cb6f-4359-af98-4b0d65690cda	\N	\N	999	10	13	23	12	23	48	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
60	8c9fd6a7-b10e-4ced-b73d-7e1ca604e8ca	\N	\N	999	22	11	18	20	43	21	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
61	7130a9fd-8021-402a-a29f-0e820a9805d0	\N	\N	999	16	45	28	13	46	19	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
62	3dd7f158-22c1-4969-94e5-3685d27635f8	\N	\N	999	23	37	45	25	38	23	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
63	00a1036d-78e4-4a5d-9274-f64b86710af4	\N	\N	999	20	42	11	16	12	39	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
64	8c53f9b7-bca2-495e-b7a1-1e72f3ae1d66	\N	\N	999	18	16	46	20	37	40	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
65	cecc9511-5026-4181-b1bd-b5fc24db8166	\N	\N	999	20	18	31	21	17	17	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
66	b210a83a-93df-4e56-994c-e9c507868513	\N	\N	999	34	45	15	45	22	50	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
67	3772b413-138d-405f-bfdd-61477808fc92	\N	\N	999	36	25	28	16	45	47	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
68	eacc4913-7529-40d2-ba62-446d8c45bd9b	\N	\N	999	19	17	26	42	44	43	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
69	daab5116-420e-46e1-9e00-bfdcba51edd7	\N	\N	999	15	48	38	34	49	21	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
70	42dab708-e9d7-4cc4-a9ab-99448dcec05e	\N	\N	999	10	19	34	45	35	24	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
71	3128126c-b3f9-4c19-a435-9cbb527b790f	\N	\N	999	41	17	37	12	17	20	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
72	94dc98e0-d52c-47a0-9cf7-7d1d29f50eae	\N	\N	999	15	40	19	33	17	11	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
73	a8cd6eb8-a42c-4fa6-a6c4-61c668e62783	\N	\N	999	25	15	48	18	23	32	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
74	6b13554f-3f28-4133-8afe-9bd13881e537	\N	\N	999	39	34	10	11	48	26	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
75	777088a3-62f1-4fd5-9217-3f32ce9df6d5	\N	\N	999	33	16	12	28	12	21	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
76	5dd63582-e883-4d1f-a1cf-50b620b064ab	\N	\N	999	46	33	31	19	32	33	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
77	a072eb9a-9e4a-465f-aba5-f4f76b5d048e	\N	\N	999	27	33	43	15	50	27	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
78	19547fce-f299-4d3e-9e7e-6f42941fcae5	\N	\N	999	41	13	43	45	35	13	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
79	3e4dc158-b6b8-4568-b00d-ebf3f05e5628	\N	\N	999	18	49	37	44	33	21	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
80	be826c3a-3e6c-40fb-a45c-4438e13955b6	\N	\N	999	14	47	37	35	25	23	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
81	22c1d10b-7f72-4e29-9fab-501730285e9e	\N	\N	999	22	16	26	22	25	28	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
82	b7e9e71d-78c9-4ee5-8a48-4758ad727519	\N	\N	999	31	21	23	26	24	41	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
83	29f5cfd4-3500-4041-9ddf-4093e31b9631	\N	\N	999	22	20	13	23	22	17	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
84	ebdb9225-b8ec-42aa-b832-bb8ca1d97d47	\N	\N	999	29	12	48	31	48	31	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
85	f063965e-80d2-4aea-889f-3f033cdda727	\N	\N	999	43	35	31	49	42	30	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
86	18f6f0e3-b262-4721-a232-0134fa8a9f98	\N	\N	999	23	32	40	39	12	23	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
87	053b5809-ea38-4b14-9604-e3d5da6b1275	\N	\N	999	50	11	12	37	45	46	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
88	3a686abb-e5a8-43c9-8441-a33d8ff8441e	\N	\N	999	49	28	16	46	46	17	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
89	4db68934-6182-45d0-b02e-6981bab3b2df	\N	\N	999	43	45	22	25	22	33	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
90	4be374fe-b85f-4cfc-8a68-47c37488bcee	\N	\N	999	14	40	17	20	34	17	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
91	f6f5609b-876b-4818-a86e-1fb5cb4da5b0	\N	\N	999	37	28	18	27	47	43	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
92	0261a557-ad1d-4251-8de5-25dcb08f5b1d	\N	\N	999	40	25	10	10	27	40	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
93	b9c6b67e-40b7-4141-96c4-4b4fbe774248	\N	\N	999	10	50	39	18	38	20	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
94	5aa6f2b9-8377-4b81-b08c-18e00ba94d4d	\N	\N	999	36	14	14	42	24	41	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
95	d83f973c-bb87-461d-a593-bb25f37d75af	\N	\N	999	45	37	41	50	14	13	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
96	d8747d4a-517a-41af-b213-1b9151670cff	\N	\N	999	47	14	20	26	34	21	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
97	47437537-c0a6-47c7-85b0-014c3ef9d12e	\N	\N	999	44	45	18	47	24	19	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
98	7f50cd56-4c37-4d16-84a5-792d845d850c	\N	\N	999	50	23	44	14	23	17	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
99	ff1ecf9d-14ee-4bf2-8f7e-812cee075d43	\N	\N	999	33	21	21	17	32	25	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
100	5b0903ae-1b3f-4f4f-86bc-c25cbae5d3da	\N	\N	999	48	29	12	17	35	10	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
101	bd7953c5-edff-4661-89bb-58b0c746109e	\N	\N	999	43	37	40	21	29	43	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
102	d8870e3a-2487-47fb-a744-2617f4f48016	\N	\N	999	19	32	17	20	11	42	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
103	51f6c406-63f1-4d67-9231-d413ee3b7850	\N	\N	999	43	50	45	10	44	29	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
104	71137d1d-f54b-4da3-a744-ad37a5cefb35	\N	\N	999	48	23	35	45	47	23	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
105	b48324bf-3b8f-45d5-bb00-d53cdacae86e	\N	\N	999	40	44	46	25	22	32	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
106	bcbbae99-2847-4fa0-8e59-324f1044eb61	\N	\N	999	29	39	27	35	38	47	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
107	d7dbe66b-d1dc-46e2-98ed-b5a34fa12d64	\N	\N	999	26	26	35	28	21	21	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
108	a32f588f-cb2b-43f5-9d59-8e95c1ea45a8	\N	\N	999	47	31	21	36	50	14	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
109	f91ac970-7e66-4360-b5d4-925cda81f2ba	\N	\N	999	22	43	15	26	49	31	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
110	bda5f54a-8294-40ca-b5f2-3670f5a9eb18	\N	\N	999	31	50	39	16	37	40	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
111	110a7494-a769-4528-b123-660f821c6a9d	\N	\N	999	21	44	27	17	25	14	\N	\N	\N	\N	\N	\N	\N	2026-06-15 14:11:48.225022
\.


--
-- Data for Name: ist_iq_bands; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ist_iq_bands (id, wert_min, wert_max, iq_min, iq_max, category) FROM stdin;
1	100	999	130	145	Sangat Tinggi
2	80	99	115	129	Di Atas Rata-rata
3	55	79	90	114	Rata-rata
4	35	54	70	89	Di Bawah Rata-rata
5	0	34	50	69	Rendah
\.


--
-- Data for Name: ist_me_pairs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ist_me_pairs (id, item_no, word1, word2, options, correct_answer) FROM stdin;
1	1	Meja	Kursi	{"A": "Kursi", "B": "Lemari", "C": "Sofa", "D": "Kasur"}	Kursi
2	2	Buku	Pensil	{"A": "Penghapus", "B": "Pensil", "C": "Pulpen", "D": "Kertas"}	Pensil
3	3	Langit	Biru	{"A": "Putih", "B": "Abu-abu", "C": "Biru", "D": "Hitam"}	Biru
4	4	Ayam	Telur	{"A": "Daging", "B": "Susu", "C": "Telur", "D": "Anak ayam"}	Telur
\.


--
-- Data for Name: ist_norma; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ist_norma (id, subtest_code, raw_score, wert) FROM stdin;
1	SE	0	1
2	SE	1	2
3	SE	2	3
4	SE	3	4
5	SE	4	5
6	SE	5	6
7	SE	6	7
8	SE	7	8
9	SE	8	9
10	SE	9	10
11	SE	10	11
12	SE	11	12
13	SE	12	13
14	SE	13	14
15	SE	14	15
16	WA	0	1
17	WA	1	2
18	WA	2	3
19	WA	3	4
20	WA	4	5
21	WA	5	6
22	WA	6	7
23	WA	7	8
24	WA	8	9
25	WA	9	10
26	AN	0	1
27	AN	1	2
28	AN	2	3
29	AN	3	4
30	AN	4	5
31	AN	5	6
32	AN	6	7
33	AN	7	8
34	AN	8	9
35	AN	9	10
36	GE	0	1
37	GE	1	2
38	GE	2	3
39	GE	3	4
40	GE	4	5
41	GE	5	6
42	GE	6	7
43	GE	7	8
44	GE	8	9
45	GE	9	10
46	RA	0	1
47	RA	1	2
48	RA	2	3
49	RA	3	4
50	RA	4	5
51	RA	5	6
52	RA	6	7
53	RA	7	8
54	RA	8	9
55	RA	9	10
56	ZR	0	1
57	ZR	1	2
58	ZR	2	3
59	ZR	3	4
60	ZR	4	5
61	ZR	5	6
62	ZR	6	7
63	ZR	7	8
64	ZR	8	9
65	ZR	9	10
66	FA	0	1
67	FA	1	2
68	FA	2	3
69	FA	3	4
70	FA	4	5
71	FA	5	6
72	FA	6	7
73	FA	7	8
74	FA	8	9
75	FA	9	10
76	WU	0	1
77	WU	1	2
78	WU	2	3
79	WU	3	4
80	WU	4	5
81	WU	5	6
82	WU	6	7
83	WU	7	8
84	WU	8	9
85	WU	9	10
86	ME	0	1
87	ME	1	2
88	ME	2	3
89	ME	3	4
90	ME	4	5
91	ME	5	6
92	ME	6	7
93	ME	7	8
94	ME	8	9
95	ME	9	10
\.


--
-- Data for Name: ist_questions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ist_questions (id, subtest_code, item_no, question_text, image_url, options, correct_answer, time_limit_sec, is_active) FROM stdin;
1	SE	1	Pohon memiliki ___ seperti manusia memiliki tulang.	\N	\N	batang	\N	t
2	SE	2	Buku adalah untuk membaca seperti pensil adalah untuk ___.	\N	\N	menulis	\N	t
3	SE	3	Air mengalir ke bawah karena ___.	\N	\N	gravitasi	\N	t
4	SE	4	Matahari terbit di ___ dan terbenam di ___.	\N	\N	timur	\N	t
5	SE	5	Manusia bernapas menggunakan ___.	\N	\N	paru-paru	\N	t
6	WA	1	Dokter : Rumah Sakit = Guru : ?	\N	\N	Sekolah	\N	t
7	WA	2	Pensil : Menulis = Pisau : ?	\N	\N	Memotong	\N	t
8	WA	3	Panas : Api = Dingin : ?	\N	\N	Es	\N	t
9	AN	1	Kuda : Berkuda = Sepeda : ?	\N	\N	Bersepeda	\N	t
10	AN	2	Buku : Perpustakaan = Lukisan : ?	\N	\N	Museum	\N	t
11	GE	1	Anjing, Kucing, Kelinci — apa persamaannya?	\N	\N	hewan peliharaan	\N	t
12	GE	2	Merah, Biru, Hijau — apa persamaannya?	\N	\N	warna	\N	t
13	RA	1	25 + 37 = ?	\N	\N	62	\N	t
14	RA	2	144 ÷ 12 = ?	\N	\N	12	\N	t
15	RA	3	15 × 8 = ?	\N	\N	120	\N	t
16	FA	1	Mana gambar yang tidak sesuai dengan pola lainnya? (A-D)	\N	\N	D	\N	t
\.


--
-- Data for Name: ist_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ist_results (id, auth_user_id, student_name, school_name, assignment_id, subtest_scores, total_wert, iq_score, iq_category, answers, completed_at) FROM stdin;
1	6a2e78f6572208361f6edc48	Al-Kahf Muhammad Zanjabiil	SMP Muhammadiyah Yogyakarta 2	1	{"AN": {"raw": 0, "wert": 1}, "FA": {"raw": 0, "wert": 1}, "GE": {"raw": 1, "wert": 2}, "RA": {"raw": 0, "wert": 1}, "SE": {"raw": 0, "wert": 1}, "WA": {"raw": 0, "wert": 1}, "WU": {"raw": 1, "wert": 2}, "ZR": {"raw": 0, "wert": 1}}	10	50	Rendah	[{"items": [{"answer": "gigi", "itemNo": 1}, {"answer": "apaa", "itemNo": 2}, {"answer": "duh", "itemNo": 3}, {"answer": "ini", "itemNo": 4}, {"answer": "apa", "itemNo": 5}], "subtestCode": "SE"}, {"items": [{"answer": "apa", "itemNo": 1}, {"answer": "ini", "itemNo": 2}, {"answer": "itu", "itemNo": 3}], "subtestCode": "WA"}, {"items": [{"answer": "yes", "itemNo": 1}, {"answer": "okay", "itemNo": 2}], "subtestCode": "AN"}, {"items": [{"answer": "hewan", "itemNo": 1}, {"answer": "warna", "itemNo": 2}], "subtestCode": "GE"}, {"items": [{"answer": "88", "itemNo": 1}, {"answer": "98", "itemNo": 2}, {"answer": "98", "itemNo": 3}], "subtestCode": "RA"}, {"items": [{"answer": "w2", "itemNo": 1}, {"answer": "22", "itemNo": 2}, {"answer": "4", "itemNo": 3}, {"answer": "33", "itemNo": 4}], "subtestCode": "ZR"}, {"items": [{"answer": "C", "itemNo": 1}], "subtestCode": "FA"}, {"items": [{"answer": "SALAH", "itemNo": 1}, {"answer": "BENAR", "itemNo": 2}, {"answer": "SALAH", "itemNo": 3}, {"answer": "BENAR", "itemNo": 4}], "subtestCode": "WU"}]	2026-06-14 17:20:56.236423
2	cc2f0f8a-59a3-4a5e-9bfe-1c670c519393	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	135	\N	\N	2026-06-15 14:11:48.225022
3	1654ba45-7070-4d1b-a8d2-f09e3f64c11e	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	137	\N	\N	2026-06-15 14:11:48.225022
4	4c9ca049-08a2-4b28-a5d8-c8b69ec084bf	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	140	\N	\N	2026-06-15 14:11:48.225022
5	1e6a9e81-1ac2-46b5-a700-4c76ed08536d	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	100	\N	\N	2026-06-15 14:11:48.225022
6	4ca82485-a400-43b5-bbdb-0292a8b19538	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	95	\N	\N	2026-06-15 14:11:48.225022
7	266c53e9-355e-4176-bebd-c7c0f088e93c	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	83	\N	\N	2026-06-15 14:11:48.225022
8	a0355bd2-dd2f-4e2e-b188-8e24fc0247fc	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	114	\N	\N	2026-06-15 14:11:48.225022
9	9657db6a-b9fc-4ab5-99ba-b1dce9318094	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	82	\N	\N	2026-06-15 14:11:48.225022
10	82d8f94b-dedb-4e9d-8d60-420d022ad08e	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	94	\N	\N	2026-06-15 14:11:48.225022
11	2d1666f6-f176-47d6-91b0-3d1af8045d49	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	117	\N	\N	2026-06-15 14:11:48.225022
12	d608456c-2cf9-4b7d-af93-7fec87443402	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	117	\N	\N	2026-06-15 14:11:48.225022
13	15419209-5200-46da-b3f9-c8a63d1d57d2	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	83	\N	\N	2026-06-15 14:11:48.225022
14	0532d0ed-4f72-45ea-a2a9-4c3a818ec580	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	127	\N	\N	2026-06-15 14:11:48.225022
15	eef746bc-85f4-47dd-93c6-9cedb993e8ef	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	120	\N	\N	2026-06-15 14:11:48.225022
16	21e9cce0-931e-4a32-b8a6-a38e52ecfd40	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	85	\N	\N	2026-06-15 14:11:48.225022
17	5a32cb0e-557a-46c7-9b68-9864b80d0976	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	112	\N	\N	2026-06-15 14:11:48.225022
18	1fa0df89-40ec-4307-9fdd-346b68185bf2	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	106	\N	\N	2026-06-15 14:11:48.225022
19	c8065771-c617-4db7-87ba-8a948282e8f6	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	110	\N	\N	2026-06-15 14:11:48.225022
20	c3c2f6d7-0d35-4d04-922d-0146a7270185	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	101	\N	\N	2026-06-15 14:11:48.225022
21	83ee8be1-1151-4ff3-951c-b722dbf4d232	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	121	\N	\N	2026-06-15 14:11:48.225022
22	a3223597-2552-4dd8-8931-41775fd19d10	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	137	\N	\N	2026-06-15 14:11:48.225022
23	6e98e408-5a17-41ae-ad00-037080b85e0d	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	105	\N	\N	2026-06-15 14:11:48.225022
24	efcc2939-2506-44c2-9bd4-6e19395b5451	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	95	\N	\N	2026-06-15 14:11:48.225022
25	0ca8b3ea-875d-421c-b230-10857175c683	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	103	\N	\N	2026-06-15 14:11:48.225022
26	9ad7e7fb-8086-4fb3-bef4-62a3a181187d	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	84	\N	\N	2026-06-15 14:11:48.225022
27	c5a84425-3349-4ad8-9240-e1b68d62d6ef	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	97	\N	\N	2026-06-15 14:11:48.225022
28	e7a9d7b1-835e-4edd-ac5d-2ba67d5bad47	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	87	\N	\N	2026-06-15 14:11:48.225022
29	e1721a26-bee5-48f4-84ad-452212c07821	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	133	\N	\N	2026-06-15 14:11:48.225022
30	16c5ab27-122e-4684-bab9-bfad23cbae2d	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	110	\N	\N	2026-06-15 14:11:48.225022
31	250b647f-4439-4350-b1c2-52c65cc97a10	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	139	\N	\N	2026-06-15 14:11:48.225022
32	d082f677-513d-4b8f-9cef-c73b784503b6	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	87	\N	\N	2026-06-15 14:11:48.225022
33	cf9649b8-de12-454a-a441-6950a18718b9	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	107	\N	\N	2026-06-15 14:11:48.225022
34	bf1c1871-e40f-4ec7-8fc5-90b215a913fd	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	121	\N	\N	2026-06-15 14:11:48.225022
35	7a1b13e6-55be-48e1-81d1-251ce6e50878	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	138	\N	\N	2026-06-15 14:11:48.225022
36	baa619f4-f59f-492e-bf41-67073f934db4	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	140	\N	\N	2026-06-15 14:11:48.225022
37	b3e99c8c-5f9d-46ac-88de-e305679eb454	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	91	\N	\N	2026-06-15 14:11:48.225022
38	edf1feed-3035-4133-ac3b-6c46e0ad3ef8	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	116	\N	\N	2026-06-15 14:11:48.225022
39	893c6a6a-37c1-4e20-a1cc-f6f7878a5883	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	122	\N	\N	2026-06-15 14:11:48.225022
40	4358ed04-3f46-45dc-804d-9cb71671cba8	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	97	\N	\N	2026-06-15 14:11:48.225022
41	3efb78be-bc11-400c-968b-49a1bef666d6	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	113	\N	\N	2026-06-15 14:11:48.225022
42	02b4ff08-2975-44ec-931a-7ac911e503b5	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	81	\N	\N	2026-06-15 14:11:48.225022
43	9977dfc6-4374-4406-9059-a4a50b9a1373	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	95	\N	\N	2026-06-15 14:11:48.225022
44	e2f4031c-750d-4283-8740-75d0c7d9b5fe	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	112	\N	\N	2026-06-15 14:11:48.225022
45	ef6dc49d-8639-4636-b4cc-2e3fa40d9a94	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	121	\N	\N	2026-06-15 14:11:48.225022
46	5516a843-6fdf-4a4d-9264-88d932b7197a	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	105	\N	\N	2026-06-15 14:11:48.225022
47	55492aef-4a9e-4cbf-8a66-940afc571470	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	82	\N	\N	2026-06-15 14:11:48.225022
48	9b2e0574-8b56-4126-9576-e50eeb80d2f7	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	140	\N	\N	2026-06-15 14:11:48.225022
49	ecd99560-cb6f-4359-af98-4b0d65690cda	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	84	\N	\N	2026-06-15 14:11:48.225022
50	8c9fd6a7-b10e-4ced-b73d-7e1ca604e8ca	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	110	\N	\N	2026-06-15 14:11:48.225022
51	7130a9fd-8021-402a-a29f-0e820a9805d0	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	103	\N	\N	2026-06-15 14:11:48.225022
52	3dd7f158-22c1-4969-94e5-3685d27635f8	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	111	\N	\N	2026-06-15 14:11:48.225022
53	00a1036d-78e4-4a5d-9274-f64b86710af4	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	106	\N	\N	2026-06-15 14:11:48.225022
54	8c53f9b7-bca2-495e-b7a1-1e72f3ae1d66	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	123	\N	\N	2026-06-15 14:11:48.225022
55	cecc9511-5026-4181-b1bd-b5fc24db8166	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	105	\N	\N	2026-06-15 14:11:48.225022
56	b210a83a-93df-4e56-994c-e9c507868513	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	130	\N	\N	2026-06-15 14:11:48.225022
57	3772b413-138d-405f-bfdd-61477808fc92	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	109	\N	\N	2026-06-15 14:11:48.225022
58	eacc4913-7529-40d2-ba62-446d8c45bd9b	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	105	\N	\N	2026-06-15 14:11:48.225022
59	daab5116-420e-46e1-9e00-bfdcba51edd7	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	95	\N	\N	2026-06-15 14:11:48.225022
60	42dab708-e9d7-4cc4-a9ab-99448dcec05e	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	95	\N	\N	2026-06-15 14:11:48.225022
61	3128126c-b3f9-4c19-a435-9cbb527b790f	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	120	\N	\N	2026-06-15 14:11:48.225022
62	94dc98e0-d52c-47a0-9cf7-7d1d29f50eae	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	119	\N	\N	2026-06-15 14:11:48.225022
63	a8cd6eb8-a42c-4fa6-a6c4-61c668e62783	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	112	\N	\N	2026-06-15 14:11:48.225022
64	6b13554f-3f28-4133-8afe-9bd13881e537	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	105	\N	\N	2026-06-15 14:11:48.225022
65	777088a3-62f1-4fd5-9217-3f32ce9df6d5	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	84	\N	\N	2026-06-15 14:11:48.225022
66	5dd63582-e883-4d1f-a1cf-50b620b064ab	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	130	\N	\N	2026-06-15 14:11:48.225022
67	a072eb9a-9e4a-465f-aba5-f4f76b5d048e	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	88	\N	\N	2026-06-15 14:11:48.225022
68	19547fce-f299-4d3e-9e7e-6f42941fcae5	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	119	\N	\N	2026-06-15 14:11:48.225022
69	3e4dc158-b6b8-4568-b00d-ebf3f05e5628	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	112	\N	\N	2026-06-15 14:11:48.225022
70	be826c3a-3e6c-40fb-a45c-4438e13955b6	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	119	\N	\N	2026-06-15 14:11:48.225022
71	22c1d10b-7f72-4e29-9fab-501730285e9e	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	119	\N	\N	2026-06-15 14:11:48.225022
72	b7e9e71d-78c9-4ee5-8a48-4758ad727519	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	134	\N	\N	2026-06-15 14:11:48.225022
73	29f5cfd4-3500-4041-9ddf-4093e31b9631	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	123	\N	\N	2026-06-15 14:11:48.225022
74	ebdb9225-b8ec-42aa-b832-bb8ca1d97d47	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	125	\N	\N	2026-06-15 14:11:48.225022
75	f063965e-80d2-4aea-889f-3f033cdda727	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	88	\N	\N	2026-06-15 14:11:48.225022
76	18f6f0e3-b262-4721-a232-0134fa8a9f98	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	110	\N	\N	2026-06-15 14:11:48.225022
77	053b5809-ea38-4b14-9604-e3d5da6b1275	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	108	\N	\N	2026-06-15 14:11:48.225022
78	3a686abb-e5a8-43c9-8441-a33d8ff8441e	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	87	\N	\N	2026-06-15 14:11:48.225022
79	4db68934-6182-45d0-b02e-6981bab3b2df	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	111	\N	\N	2026-06-15 14:11:48.225022
80	4be374fe-b85f-4cfc-8a68-47c37488bcee	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	125	\N	\N	2026-06-15 14:11:48.225022
81	f6f5609b-876b-4818-a86e-1fb5cb4da5b0	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	132	\N	\N	2026-06-15 14:11:48.225022
82	0261a557-ad1d-4251-8de5-25dcb08f5b1d	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	102	\N	\N	2026-06-15 14:11:48.225022
83	b9c6b67e-40b7-4141-96c4-4b4fbe774248	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	91	\N	\N	2026-06-15 14:11:48.225022
84	5aa6f2b9-8377-4b81-b08c-18e00ba94d4d	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	96	\N	\N	2026-06-15 14:11:48.225022
85	d83f973c-bb87-461d-a593-bb25f37d75af	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	140	\N	\N	2026-06-15 14:11:48.225022
86	d8747d4a-517a-41af-b213-1b9151670cff	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	85	\N	\N	2026-06-15 14:11:48.225022
87	47437537-c0a6-47c7-85b0-014c3ef9d12e	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	80	\N	\N	2026-06-15 14:11:48.225022
88	7f50cd56-4c37-4d16-84a5-792d845d850c	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	115	\N	\N	2026-06-15 14:11:48.225022
89	ff1ecf9d-14ee-4bf2-8f7e-812cee075d43	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	135	\N	\N	2026-06-15 14:11:48.225022
90	5b0903ae-1b3f-4f4f-86bc-c25cbae5d3da	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	118	\N	\N	2026-06-15 14:11:48.225022
91	bd7953c5-edff-4661-89bb-58b0c746109e	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	105	\N	\N	2026-06-15 14:11:48.225022
92	d8870e3a-2487-47fb-a744-2617f4f48016	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	120	\N	\N	2026-06-15 14:11:48.225022
93	51f6c406-63f1-4d67-9231-d413ee3b7850	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	129	\N	\N	2026-06-15 14:11:48.225022
94	71137d1d-f54b-4da3-a744-ad37a5cefb35	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	113	\N	\N	2026-06-15 14:11:48.225022
95	b48324bf-3b8f-45d5-bb00-d53cdacae86e	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	100	\N	\N	2026-06-15 14:11:48.225022
96	bcbbae99-2847-4fa0-8e59-324f1044eb61	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	94	\N	\N	2026-06-15 14:11:48.225022
97	d7dbe66b-d1dc-46e2-98ed-b5a34fa12d64	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	82	\N	\N	2026-06-15 14:11:48.225022
98	a32f588f-cb2b-43f5-9d59-8e95c1ea45a8	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	89	\N	\N	2026-06-15 14:11:48.225022
99	f91ac970-7e66-4360-b5d4-925cda81f2ba	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	123	\N	\N	2026-06-15 14:11:48.225022
100	bda5f54a-8294-40ca-b5f2-3670f5a9eb18	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	101	\N	\N	2026-06-15 14:11:48.225022
101	110a7494-a769-4528-b123-660f821c6a9d	\N	\N	999	{"AN": {"raw": 10, "wert": 10}, "FA": {"raw": 10, "wert": 10}, "GE": {"raw": 10, "wert": 10}, "ME": {"raw": 10, "wert": 10}, "RA": {"raw": 10, "wert": 10}, "SE": {"raw": 10, "wert": 10}, "WA": {"raw": 10, "wert": 10}, "WU": {"raw": 10, "wert": 10}, "ZR": {"raw": 10, "wert": 10}}	90	105	\N	\N	2026-06-15 14:11:48.225022
\.


--
-- Data for Name: ist_wu_questions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ist_wu_questions (id, item_no, statement, correct_answer) FROM stdin;
1	1	Semua mamalia adalah hewan berdarah panas	BENAR
2	2	Jakarta adalah ibu kota Jawa Barat	SALAH
3	3	Air mendidih pada suhu 100 derajat Celsius pada tekanan standar	BENAR
4	4	Bumi mengelilingi Matahari dalam waktu 365 hari	BENAR
\.


--
-- Data for Name: ist_zr_questions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ist_zr_questions (id, item_no, sequence_text, correct_answer) FROM stdin;
1	1	2, 4, 6, 8, ?	10
2	2	3, 6, 12, 24, ?	48
3	3	100, 90, 80, 70, ?	60
4	4	1, 1, 2, 3, 5, 8, ?	13
\.


--
-- Data for Name: papi_descriptions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.papi_descriptions (id, trait_code, trait_name, description, high_desc, low_desc) FROM stdin;
1	N	Kebutuhan atas Aturan	Kepatuhan terhadap aturan dan prosedur	Sangat patuh pada aturan	Cenderung fleksibel terhadap aturan
2	G	Peran Pemimpin yang Aktif	Inisiatif memimpin secara aktif	Pemimpin yang tegas dan direktif	Lebih suka mengikuti daripada memimpin
3	A	Kebutuhan Persetujuan	Butuh penerimaan dari orang lain	Sangat butuh pujian dan persetujuan	Tidak terlalu mempedulikan pendapat orang
4	L	Kepemimpinan	Kemampuan memimpin	Pemimpin alami yang dihormati	Lebih nyaman sebagai anggota tim
5	P	Kecepatan Kerja	Tempo pengerjaan tugas	Bekerja dengan tempo cepat dan energik	Bekerja dengan tenang dan hati-hati
6	I	Kerapian & Ketelitian	Detail dan presisi dalam bekerja	Sangat rapi dan teliti	Lebih fokus pada gambaran besar
7	T	Orientasi Tugas	Dedikasi terhadap penyelesaian tugas	Sangat berorientasi pada hasil tugas	Lebih memprioritaskan orang daripada tugas
8	V	Ketangguhan Mental	Ketabahan menghadapi tekanan	Sangat tangguh menghadapi kritik	Lebih sensitif terhadap tekanan
9	X	Kebutuhan Bervariasi	Preferensi terhadap keberagaman	Menikmati variasi dan perubahan	Lebih suka rutinitas yang konsisten
10	S	Empati Sosial	Kepekaan terhadap perasaan orang lain	Sangat peka terhadap perasaan orang lain	Cenderung objektif dan kurang sensitif
11	B	Keterampilan Sosial	Kemampuan bersosialisasi	Sangat mudah bergaul dan terbuka	Lebih nyaman sendiri atau dalam kelompok kecil
12	O	Peran Pengasuhan	Keinginan membimbing dan memelihara	Sangat nurturing dan supportif	Lebih fokus pada diri sendiri
13	R	Pemikiran Teoritis	Kemampuan berpikir abstrak	Sangat analitis dan teoritis	Lebih praktis dan konkret
14	D	Kebutuhan Otonomi	Preferensi untuk bekerja mandiri	Sangat menyukai kebebasan dan independensi	Lebih suka arahan dan struktur jelas
15	C	Kepercayaan Diri	Keyakinan pada kemampuan diri	Sangat percaya diri dan asertif	Lebih hati-hati dan ragu-ragu
16	E	Kontrol Emosi	Kemampuan mengelola emosi	Sangat tenang dan stabil secara emosional	Lebih ekspresif dan reaktif
17	K	Kerja Keras	Dedikasi dan ketekunan	Sangat rajin dan pantang menyerah	Lebih santai dan tidak terlalu ambisius
18	F	Fleksibilitas	Kemampuan menyesuaikan diri	Sangat adaptif terhadap perubahan	Lebih terstruktur dan kurang fleksibel
19	W	Orientasi Penghargaan	Motivasi oleh pengakuan	Sangat termotivasi oleh penghargaan eksternal	Lebih termotivasi oleh kepuasan internal
20	Z	Ketegasan	Ketegasan dalam mengambil sikap	Sangat tegas dan langsung	Lebih diplomatis dan tidak langsung
\.


--
-- Data for Name: papi_questions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.papi_questions (id, pair_no, item_letter, trait_code, statement, is_active) FROM stdin;
1	1	A	N	Saya selalu mengikuti peraturan yang ada	t
2	1	B	D	Saya lebih suka bekerja dengan cara saya sendiri	t
3	2	A	G	Saya sering mengambil inisiatif memimpin kelompok	t
4	2	B	O	Saya lebih suka mendukung dan membimbing orang lain	t
5	3	A	A	Saya butuh pujian agar bisa bekerja dengan baik	t
6	3	B	C	Saya yakin dengan kemampuan saya tanpa perlu dipuji	t
7	4	A	L	Saya merasa nyaman ketika harus memimpin orang lain	t
8	4	B	S	Saya lebih suka memastikan semua orang merasa nyaman	t
9	5	A	P	Saya mengerjakan banyak hal dengan cepat	t
10	5	B	I	Saya mengerjakan setiap hal dengan sangat teliti	t
11	6	A	T	Saya fokus menyelesaikan tugas sebelum beristirahat	t
12	6	B	B	Saya senang mengobrol dengan rekan kerja saat bekerja	t
13	7	A	V	Saya tidak mudah terpuruk oleh kritik	t
14	7	B	E	Saya bisa mengendalikan emosi dalam situasi sulit	t
15	8	A	X	Saya senang mencoba cara-cara baru dalam bekerja	t
16	8	B	F	Saya dengan mudah menyesuaikan diri dengan perubahan	t
17	9	A	S	Saya peka terhadap perasaan orang-orang di sekitar saya	t
18	9	B	R	Saya lebih suka berpikir secara analitis dan teoritis	t
19	10	A	B	Saya mudah berteman dengan orang baru	t
20	10	B	W	Saya butuh pengakuan atas kerja keras saya	t
21	11	A	N	Saya percaya prosedur ada untuk diikuti	t
22	11	B	X	Saya suka variasi dalam pekerjaan	t
23	12	A	G	Saya sering jadi orang yang mengambil kendali	t
24	12	B	K	Saya siap bekerja lebih keras dari orang lain	t
25	13	A	T	Hasil pekerjaan adalah prioritas utama saya	t
26	13	B	O	Memastikan tim saya bahagia adalah prioritas saya	t
27	14	A	P	Saya suka bekerja dalam tempo yang cepat	t
28	14	B	E	Saya jarang membiarkan emosi mempengaruhi keputusan	t
29	15	A	L	Saya senang diberi tanggung jawab besar	t
30	15	B	D	Saya lebih produktif tanpa pengawasan	t
31	16	A	I	Saya memeriksa ulang pekerjaan saya berkali-kali	t
32	16	B	C	Saya percaya bahwa ragu-ragu itu merugikan	t
33	17	A	V	Saya tetap fokus meskipun banyak hambatan	t
34	17	B	A	Saya butuh dukungan emosional dari rekan kerja	t
35	18	A	R	Saya senang mendiskusikan teori dan konsep abstrak	t
36	18	B	S	Saya lebih tertarik pada perasaan dan hubungan	t
37	19	A	F	Saya bisa mengubah rencana kapan saja jika perlu	t
38	19	B	N	Saya lebih suka mengikuti jadwal yang sudah ada	t
39	20	A	W	Saya sangat menghargai penghargaan dari atasan	t
40	20	B	K	Saya tidak berhenti bekerja sampai selesai	t
\.


--
-- Data for Name: papi_results; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.papi_results (id, auth_user_id, student_name, school_name, assignment_id, trait_scores, answers, completed_at) FROM stdin;
1	6a2e78f6572208361f6edc48	Al-Kahf Muhammad Zanjabiil	SMP Muhammadiyah Yogyakarta 2	1	{"A": 1, "B": 1, "C": 2, "E": 2, "K": 2, "L": 1, "N": 3, "O": 2, "P": 1, "R": 1, "S": 2, "W": 1, "X": 1}	[{"pairNo": 1, "chosenLetter": "A"}, {"pairNo": 2, "chosenLetter": "B"}, {"pairNo": 3, "chosenLetter": "B"}, {"pairNo": 4, "chosenLetter": "B"}, {"pairNo": 5, "chosenLetter": "A"}, {"pairNo": 6, "chosenLetter": "B"}, {"pairNo": 7, "chosenLetter": "B"}, {"pairNo": 8, "chosenLetter": "A"}, {"pairNo": 9, "chosenLetter": "B"}, {"pairNo": 10, "chosenLetter": "B"}, {"pairNo": 11, "chosenLetter": "A"}, {"pairNo": 12, "chosenLetter": "B"}, {"pairNo": 13, "chosenLetter": "B"}, {"pairNo": 14, "chosenLetter": "B"}, {"pairNo": 15, "chosenLetter": "A"}, {"pairNo": 16, "chosenLetter": "B"}, {"pairNo": 17, "chosenLetter": "B"}, {"pairNo": 18, "chosenLetter": "B"}, {"pairNo": 19, "chosenLetter": "B"}, {"pairNo": 20, "chosenLetter": "B"}]	2026-06-14 17:18:58.815215
2	cc2f0f8a-59a3-4a5e-9bfe-1c670c519393	\N	\N	999	{"A": 4, "B": 0, "C": 6, "D": 7, "E": 3, "F": 5, "G": 1, "I": 3, "K": 8, "L": 4, "N": 6, "O": 8, "P": 9, "R": 1, "S": 4, "T": 1, "V": 6, "W": 5, "X": 0, "Z": 0}	\N	2026-06-15 14:11:48.225022
3	1654ba45-7070-4d1b-a8d2-f09e3f64c11e	\N	\N	999	{"A": 9, "B": 6, "C": 7, "D": 9, "E": 4, "F": 7, "G": 8, "I": 3, "K": 3, "L": 9, "N": 3, "O": 5, "P": 3, "R": 4, "S": 7, "T": 4, "V": 3, "W": 8, "X": 0, "Z": 6}	\N	2026-06-15 14:11:48.225022
4	4c9ca049-08a2-4b28-a5d8-c8b69ec084bf	\N	\N	999	{"A": 9, "B": 7, "C": 1, "D": 3, "E": 7, "F": 3, "G": 5, "I": 3, "K": 4, "L": 2, "N": 8, "O": 3, "P": 3, "R": 7, "S": 7, "T": 2, "V": 1, "W": 6, "X": 1, "Z": 4}	\N	2026-06-15 14:11:48.225022
5	1e6a9e81-1ac2-46b5-a700-4c76ed08536d	\N	\N	999	{"A": 5, "B": 8, "C": 4, "D": 1, "E": 6, "F": 9, "G": 3, "I": 8, "K": 5, "L": 5, "N": 7, "O": 1, "P": 4, "R": 0, "S": 4, "T": 0, "V": 1, "W": 4, "X": 7, "Z": 4}	\N	2026-06-15 14:11:48.225022
6	4ca82485-a400-43b5-bbdb-0292a8b19538	\N	\N	999	{"A": 2, "B": 2, "C": 9, "D": 3, "E": 9, "F": 5, "G": 8, "I": 6, "K": 5, "L": 5, "N": 7, "O": 9, "P": 6, "R": 4, "S": 8, "T": 7, "V": 8, "W": 5, "X": 4, "Z": 6}	\N	2026-06-15 14:11:48.225022
7	266c53e9-355e-4176-bebd-c7c0f088e93c	\N	\N	999	{"A": 3, "B": 8, "C": 3, "D": 6, "E": 2, "F": 1, "G": 1, "I": 7, "K": 0, "L": 4, "N": 3, "O": 4, "P": 5, "R": 2, "S": 2, "T": 0, "V": 1, "W": 3, "X": 1, "Z": 8}	\N	2026-06-15 14:11:48.225022
8	a0355bd2-dd2f-4e2e-b188-8e24fc0247fc	\N	\N	999	{"A": 3, "B": 5, "C": 1, "D": 5, "E": 3, "F": 5, "G": 5, "I": 4, "K": 2, "L": 5, "N": 0, "O": 7, "P": 4, "R": 6, "S": 3, "T": 4, "V": 7, "W": 6, "X": 8, "Z": 1}	\N	2026-06-15 14:11:48.225022
9	9657db6a-b9fc-4ab5-99ba-b1dce9318094	\N	\N	999	{"A": 1, "B": 1, "C": 8, "D": 1, "E": 6, "F": 4, "G": 9, "I": 7, "K": 7, "L": 6, "N": 9, "O": 5, "P": 7, "R": 4, "S": 1, "T": 3, "V": 4, "W": 6, "X": 8, "Z": 4}	\N	2026-06-15 14:11:48.225022
10	82d8f94b-dedb-4e9d-8d60-420d022ad08e	\N	\N	999	{"A": 0, "B": 5, "C": 9, "D": 1, "E": 7, "F": 7, "G": 1, "I": 2, "K": 0, "L": 2, "N": 0, "O": 2, "P": 2, "R": 3, "S": 0, "T": 4, "V": 4, "W": 6, "X": 3, "Z": 9}	\N	2026-06-15 14:11:48.225022
11	2d1666f6-f176-47d6-91b0-3d1af8045d49	\N	\N	999	{"A": 5, "B": 4, "C": 9, "D": 2, "E": 8, "F": 6, "G": 6, "I": 3, "K": 7, "L": 4, "N": 6, "O": 1, "P": 2, "R": 3, "S": 2, "T": 5, "V": 2, "W": 8, "X": 7, "Z": 4}	\N	2026-06-15 14:11:48.225022
12	d608456c-2cf9-4b7d-af93-7fec87443402	\N	\N	999	{"A": 6, "B": 0, "C": 5, "D": 1, "E": 3, "F": 4, "G": 8, "I": 3, "K": 5, "L": 6, "N": 0, "O": 4, "P": 9, "R": 1, "S": 2, "T": 3, "V": 9, "W": 4, "X": 2, "Z": 9}	\N	2026-06-15 14:11:48.225022
13	15419209-5200-46da-b3f9-c8a63d1d57d2	\N	\N	999	{"A": 0, "B": 6, "C": 6, "D": 4, "E": 9, "F": 8, "G": 3, "I": 8, "K": 2, "L": 5, "N": 9, "O": 7, "P": 1, "R": 9, "S": 9, "T": 9, "V": 1, "W": 9, "X": 9, "Z": 8}	\N	2026-06-15 14:11:48.225022
14	0532d0ed-4f72-45ea-a2a9-4c3a818ec580	\N	\N	999	{"A": 0, "B": 8, "C": 3, "D": 5, "E": 4, "F": 5, "G": 7, "I": 9, "K": 1, "L": 1, "N": 1, "O": 9, "P": 7, "R": 3, "S": 5, "T": 5, "V": 6, "W": 7, "X": 7, "Z": 5}	\N	2026-06-15 14:11:48.225022
15	eef746bc-85f4-47dd-93c6-9cedb993e8ef	\N	\N	999	{"A": 4, "B": 2, "C": 5, "D": 5, "E": 1, "F": 1, "G": 2, "I": 6, "K": 5, "L": 6, "N": 2, "O": 9, "P": 9, "R": 4, "S": 3, "T": 2, "V": 4, "W": 8, "X": 7, "Z": 5}	\N	2026-06-15 14:11:48.225022
16	21e9cce0-931e-4a32-b8a6-a38e52ecfd40	\N	\N	999	{"A": 8, "B": 4, "C": 6, "D": 3, "E": 9, "F": 9, "G": 4, "I": 5, "K": 5, "L": 3, "N": 4, "O": 8, "P": 2, "R": 2, "S": 1, "T": 0, "V": 9, "W": 4, "X": 2, "Z": 4}	\N	2026-06-15 14:11:48.225022
17	5a32cb0e-557a-46c7-9b68-9864b80d0976	\N	\N	999	{"A": 3, "B": 5, "C": 0, "D": 5, "E": 1, "F": 4, "G": 2, "I": 5, "K": 9, "L": 3, "N": 8, "O": 0, "P": 8, "R": 2, "S": 7, "T": 5, "V": 3, "W": 2, "X": 3, "Z": 1}	\N	2026-06-15 14:11:48.225022
18	1fa0df89-40ec-4307-9fdd-346b68185bf2	\N	\N	999	{"A": 2, "B": 1, "C": 7, "D": 1, "E": 8, "F": 7, "G": 7, "I": 6, "K": 1, "L": 6, "N": 5, "O": 6, "P": 3, "R": 2, "S": 9, "T": 2, "V": 3, "W": 5, "X": 5, "Z": 1}	\N	2026-06-15 14:11:48.225022
19	c8065771-c617-4db7-87ba-8a948282e8f6	\N	\N	999	{"A": 4, "B": 1, "C": 4, "D": 7, "E": 9, "F": 2, "G": 0, "I": 3, "K": 3, "L": 0, "N": 3, "O": 9, "P": 7, "R": 8, "S": 4, "T": 3, "V": 2, "W": 6, "X": 6, "Z": 1}	\N	2026-06-15 14:11:48.225022
20	c3c2f6d7-0d35-4d04-922d-0146a7270185	\N	\N	999	{"A": 9, "B": 1, "C": 8, "D": 8, "E": 5, "F": 8, "G": 2, "I": 7, "K": 2, "L": 4, "N": 2, "O": 0, "P": 2, "R": 5, "S": 4, "T": 7, "V": 5, "W": 2, "X": 1, "Z": 2}	\N	2026-06-15 14:11:48.225022
21	83ee8be1-1151-4ff3-951c-b722dbf4d232	\N	\N	999	{"A": 1, "B": 9, "C": 4, "D": 4, "E": 6, "F": 7, "G": 2, "I": 7, "K": 6, "L": 8, "N": 1, "O": 1, "P": 9, "R": 4, "S": 9, "T": 4, "V": 1, "W": 0, "X": 0, "Z": 5}	\N	2026-06-15 14:11:48.225022
22	a3223597-2552-4dd8-8931-41775fd19d10	\N	\N	999	{"A": 2, "B": 9, "C": 5, "D": 1, "E": 2, "F": 4, "G": 4, "I": 3, "K": 2, "L": 3, "N": 4, "O": 5, "P": 9, "R": 4, "S": 5, "T": 8, "V": 3, "W": 6, "X": 6, "Z": 3}	\N	2026-06-15 14:11:48.225022
23	6e98e408-5a17-41ae-ad00-037080b85e0d	\N	\N	999	{"A": 2, "B": 3, "C": 3, "D": 2, "E": 1, "F": 1, "G": 9, "I": 8, "K": 2, "L": 1, "N": 0, "O": 7, "P": 0, "R": 0, "S": 1, "T": 4, "V": 3, "W": 2, "X": 3, "Z": 6}	\N	2026-06-15 14:11:48.225022
24	efcc2939-2506-44c2-9bd4-6e19395b5451	\N	\N	999	{"A": 5, "B": 0, "C": 7, "D": 7, "E": 3, "F": 6, "G": 4, "I": 4, "K": 6, "L": 9, "N": 1, "O": 3, "P": 2, "R": 2, "S": 4, "T": 1, "V": 4, "W": 1, "X": 7, "Z": 5}	\N	2026-06-15 14:11:48.225022
25	0ca8b3ea-875d-421c-b230-10857175c683	\N	\N	999	{"A": 8, "B": 1, "C": 0, "D": 2, "E": 4, "F": 1, "G": 9, "I": 1, "K": 4, "L": 8, "N": 7, "O": 2, "P": 9, "R": 1, "S": 0, "T": 1, "V": 1, "W": 6, "X": 4, "Z": 5}	\N	2026-06-15 14:11:48.225022
26	9ad7e7fb-8086-4fb3-bef4-62a3a181187d	\N	\N	999	{"A": 5, "B": 5, "C": 0, "D": 4, "E": 1, "F": 9, "G": 9, "I": 2, "K": 7, "L": 7, "N": 4, "O": 6, "P": 5, "R": 2, "S": 5, "T": 8, "V": 8, "W": 4, "X": 2, "Z": 5}	\N	2026-06-15 14:11:48.225022
27	c5a84425-3349-4ad8-9240-e1b68d62d6ef	\N	\N	999	{"A": 8, "B": 1, "C": 2, "D": 2, "E": 7, "F": 1, "G": 6, "I": 7, "K": 6, "L": 8, "N": 7, "O": 4, "P": 8, "R": 7, "S": 4, "T": 9, "V": 2, "W": 2, "X": 6, "Z": 5}	\N	2026-06-15 14:11:48.225022
28	e7a9d7b1-835e-4edd-ac5d-2ba67d5bad47	\N	\N	999	{"A": 8, "B": 3, "C": 4, "D": 6, "E": 5, "F": 4, "G": 5, "I": 8, "K": 1, "L": 1, "N": 2, "O": 0, "P": 6, "R": 8, "S": 2, "T": 4, "V": 0, "W": 4, "X": 9, "Z": 7}	\N	2026-06-15 14:11:48.225022
29	e1721a26-bee5-48f4-84ad-452212c07821	\N	\N	999	{"A": 2, "B": 0, "C": 2, "D": 1, "E": 0, "F": 3, "G": 4, "I": 8, "K": 6, "L": 0, "N": 2, "O": 3, "P": 6, "R": 9, "S": 2, "T": 1, "V": 4, "W": 3, "X": 4, "Z": 7}	\N	2026-06-15 14:11:48.225022
30	16c5ab27-122e-4684-bab9-bfad23cbae2d	\N	\N	999	{"A": 0, "B": 6, "C": 5, "D": 9, "E": 7, "F": 2, "G": 2, "I": 1, "K": 5, "L": 8, "N": 8, "O": 6, "P": 2, "R": 3, "S": 7, "T": 9, "V": 2, "W": 7, "X": 2, "Z": 1}	\N	2026-06-15 14:11:48.225022
31	250b647f-4439-4350-b1c2-52c65cc97a10	\N	\N	999	{"A": 3, "B": 1, "C": 0, "D": 5, "E": 5, "F": 1, "G": 8, "I": 4, "K": 9, "L": 1, "N": 4, "O": 0, "P": 9, "R": 9, "S": 2, "T": 3, "V": 2, "W": 8, "X": 8, "Z": 6}	\N	2026-06-15 14:11:48.225022
32	d082f677-513d-4b8f-9cef-c73b784503b6	\N	\N	999	{"A": 0, "B": 0, "C": 4, "D": 5, "E": 6, "F": 5, "G": 2, "I": 8, "K": 0, "L": 7, "N": 3, "O": 9, "P": 4, "R": 9, "S": 6, "T": 7, "V": 4, "W": 3, "X": 6, "Z": 7}	\N	2026-06-15 14:11:48.225022
33	cf9649b8-de12-454a-a441-6950a18718b9	\N	\N	999	{"A": 8, "B": 7, "C": 3, "D": 2, "E": 2, "F": 7, "G": 2, "I": 6, "K": 8, "L": 1, "N": 1, "O": 0, "P": 1, "R": 9, "S": 2, "T": 6, "V": 3, "W": 5, "X": 8, "Z": 3}	\N	2026-06-15 14:11:48.225022
34	bf1c1871-e40f-4ec7-8fc5-90b215a913fd	\N	\N	999	{"A": 9, "B": 0, "C": 7, "D": 5, "E": 9, "F": 5, "G": 4, "I": 5, "K": 5, "L": 8, "N": 4, "O": 9, "P": 6, "R": 5, "S": 9, "T": 5, "V": 6, "W": 8, "X": 6, "Z": 0}	\N	2026-06-15 14:11:48.225022
35	7a1b13e6-55be-48e1-81d1-251ce6e50878	\N	\N	999	{"A": 8, "B": 4, "C": 1, "D": 1, "E": 0, "F": 1, "G": 3, "I": 5, "K": 2, "L": 6, "N": 4, "O": 6, "P": 2, "R": 3, "S": 9, "T": 7, "V": 2, "W": 9, "X": 4, "Z": 0}	\N	2026-06-15 14:11:48.225022
36	baa619f4-f59f-492e-bf41-67073f934db4	\N	\N	999	{"A": 6, "B": 6, "C": 2, "D": 7, "E": 8, "F": 5, "G": 6, "I": 4, "K": 9, "L": 5, "N": 9, "O": 5, "P": 7, "R": 2, "S": 5, "T": 0, "V": 1, "W": 6, "X": 1, "Z": 0}	\N	2026-06-15 14:11:48.225022
37	b3e99c8c-5f9d-46ac-88de-e305679eb454	\N	\N	999	{"A": 3, "B": 7, "C": 9, "D": 4, "E": 8, "F": 7, "G": 2, "I": 8, "K": 3, "L": 7, "N": 6, "O": 1, "P": 8, "R": 6, "S": 2, "T": 2, "V": 4, "W": 1, "X": 5, "Z": 5}	\N	2026-06-15 14:11:48.225022
38	edf1feed-3035-4133-ac3b-6c46e0ad3ef8	\N	\N	999	{"A": 3, "B": 6, "C": 7, "D": 6, "E": 3, "F": 8, "G": 2, "I": 9, "K": 0, "L": 0, "N": 9, "O": 4, "P": 2, "R": 4, "S": 3, "T": 3, "V": 0, "W": 6, "X": 2, "Z": 1}	\N	2026-06-15 14:11:48.225022
39	893c6a6a-37c1-4e20-a1cc-f6f7878a5883	\N	\N	999	{"A": 4, "B": 5, "C": 1, "D": 8, "E": 5, "F": 2, "G": 1, "I": 2, "K": 4, "L": 9, "N": 2, "O": 2, "P": 3, "R": 8, "S": 0, "T": 0, "V": 0, "W": 7, "X": 2, "Z": 9}	\N	2026-06-15 14:11:48.225022
40	4358ed04-3f46-45dc-804d-9cb71671cba8	\N	\N	999	{"A": 1, "B": 8, "C": 6, "D": 4, "E": 4, "F": 4, "G": 3, "I": 3, "K": 8, "L": 1, "N": 8, "O": 3, "P": 2, "R": 0, "S": 7, "T": 5, "V": 3, "W": 3, "X": 9, "Z": 1}	\N	2026-06-15 14:11:48.225022
41	3efb78be-bc11-400c-968b-49a1bef666d6	\N	\N	999	{"A": 6, "B": 6, "C": 7, "D": 7, "E": 6, "F": 6, "G": 8, "I": 5, "K": 0, "L": 3, "N": 5, "O": 7, "P": 1, "R": 0, "S": 6, "T": 0, "V": 1, "W": 8, "X": 2, "Z": 7}	\N	2026-06-15 14:11:48.225022
42	02b4ff08-2975-44ec-931a-7ac911e503b5	\N	\N	999	{"A": 3, "B": 4, "C": 7, "D": 5, "E": 5, "F": 9, "G": 3, "I": 4, "K": 9, "L": 0, "N": 5, "O": 9, "P": 5, "R": 0, "S": 5, "T": 8, "V": 9, "W": 8, "X": 0, "Z": 3}	\N	2026-06-15 14:11:48.225022
43	9977dfc6-4374-4406-9059-a4a50b9a1373	\N	\N	999	{"A": 7, "B": 5, "C": 6, "D": 9, "E": 5, "F": 6, "G": 1, "I": 4, "K": 3, "L": 9, "N": 2, "O": 9, "P": 9, "R": 9, "S": 8, "T": 6, "V": 5, "W": 4, "X": 1, "Z": 9}	\N	2026-06-15 14:11:48.225022
44	e2f4031c-750d-4283-8740-75d0c7d9b5fe	\N	\N	999	{"A": 6, "B": 8, "C": 5, "D": 1, "E": 0, "F": 8, "G": 9, "I": 6, "K": 6, "L": 0, "N": 1, "O": 1, "P": 9, "R": 1, "S": 1, "T": 6, "V": 2, "W": 2, "X": 6, "Z": 3}	\N	2026-06-15 14:11:48.225022
45	ef6dc49d-8639-4636-b4cc-2e3fa40d9a94	\N	\N	999	{"A": 3, "B": 8, "C": 9, "D": 2, "E": 0, "F": 3, "G": 6, "I": 6, "K": 2, "L": 2, "N": 4, "O": 5, "P": 0, "R": 7, "S": 5, "T": 3, "V": 6, "W": 2, "X": 3, "Z": 1}	\N	2026-06-15 14:11:48.225022
46	5516a843-6fdf-4a4d-9264-88d932b7197a	\N	\N	999	{"A": 9, "B": 9, "C": 7, "D": 3, "E": 1, "F": 6, "G": 0, "I": 5, "K": 1, "L": 9, "N": 2, "O": 8, "P": 2, "R": 3, "S": 0, "T": 3, "V": 6, "W": 9, "X": 4, "Z": 8}	\N	2026-06-15 14:11:48.225022
47	55492aef-4a9e-4cbf-8a66-940afc571470	\N	\N	999	{"A": 2, "B": 1, "C": 1, "D": 4, "E": 0, "F": 0, "G": 5, "I": 1, "K": 0, "L": 8, "N": 8, "O": 8, "P": 8, "R": 8, "S": 7, "T": 9, "V": 4, "W": 2, "X": 1, "Z": 8}	\N	2026-06-15 14:11:48.225022
48	9b2e0574-8b56-4126-9576-e50eeb80d2f7	\N	\N	999	{"A": 7, "B": 4, "C": 2, "D": 6, "E": 9, "F": 0, "G": 1, "I": 1, "K": 2, "L": 6, "N": 4, "O": 0, "P": 6, "R": 2, "S": 8, "T": 4, "V": 7, "W": 1, "X": 5, "Z": 0}	\N	2026-06-15 14:11:48.225022
49	ecd99560-cb6f-4359-af98-4b0d65690cda	\N	\N	999	{"A": 0, "B": 8, "C": 4, "D": 3, "E": 9, "F": 1, "G": 3, "I": 5, "K": 3, "L": 5, "N": 4, "O": 3, "P": 0, "R": 3, "S": 5, "T": 4, "V": 7, "W": 9, "X": 9, "Z": 1}	\N	2026-06-15 14:11:48.225022
50	8c9fd6a7-b10e-4ced-b73d-7e1ca604e8ca	\N	\N	999	{"A": 3, "B": 4, "C": 6, "D": 1, "E": 1, "F": 7, "G": 4, "I": 7, "K": 9, "L": 9, "N": 4, "O": 9, "P": 1, "R": 3, "S": 3, "T": 2, "V": 2, "W": 0, "X": 4, "Z": 9}	\N	2026-06-15 14:11:48.225022
51	7130a9fd-8021-402a-a29f-0e820a9805d0	\N	\N	999	{"A": 7, "B": 5, "C": 7, "D": 3, "E": 3, "F": 2, "G": 1, "I": 4, "K": 2, "L": 6, "N": 2, "O": 0, "P": 7, "R": 2, "S": 1, "T": 0, "V": 2, "W": 2, "X": 0, "Z": 2}	\N	2026-06-15 14:11:48.225022
52	3dd7f158-22c1-4969-94e5-3685d27635f8	\N	\N	999	{"A": 9, "B": 8, "C": 0, "D": 5, "E": 4, "F": 1, "G": 0, "I": 7, "K": 4, "L": 0, "N": 9, "O": 0, "P": 0, "R": 9, "S": 3, "T": 3, "V": 0, "W": 4, "X": 6, "Z": 2}	\N	2026-06-15 14:11:48.225022
53	00a1036d-78e4-4a5d-9274-f64b86710af4	\N	\N	999	{"A": 3, "B": 1, "C": 3, "D": 8, "E": 8, "F": 3, "G": 1, "I": 0, "K": 8, "L": 5, "N": 6, "O": 5, "P": 4, "R": 1, "S": 2, "T": 4, "V": 5, "W": 5, "X": 9, "Z": 5}	\N	2026-06-15 14:11:48.225022
54	8c53f9b7-bca2-495e-b7a1-1e72f3ae1d66	\N	\N	999	{"A": 6, "B": 4, "C": 5, "D": 2, "E": 8, "F": 0, "G": 0, "I": 0, "K": 5, "L": 6, "N": 1, "O": 0, "P": 5, "R": 9, "S": 8, "T": 2, "V": 8, "W": 2, "X": 2, "Z": 2}	\N	2026-06-15 14:11:48.225022
55	cecc9511-5026-4181-b1bd-b5fc24db8166	\N	\N	999	{"A": 1, "B": 8, "C": 2, "D": 9, "E": 3, "F": 2, "G": 3, "I": 7, "K": 1, "L": 1, "N": 9, "O": 3, "P": 5, "R": 8, "S": 9, "T": 8, "V": 7, "W": 9, "X": 5, "Z": 4}	\N	2026-06-15 14:11:48.225022
56	b210a83a-93df-4e56-994c-e9c507868513	\N	\N	999	{"A": 5, "B": 6, "C": 7, "D": 6, "E": 5, "F": 4, "G": 5, "I": 1, "K": 6, "L": 3, "N": 7, "O": 7, "P": 3, "R": 9, "S": 6, "T": 9, "V": 3, "W": 4, "X": 0, "Z": 1}	\N	2026-06-15 14:11:48.225022
57	3772b413-138d-405f-bfdd-61477808fc92	\N	\N	999	{"A": 0, "B": 2, "C": 4, "D": 1, "E": 0, "F": 3, "G": 0, "I": 6, "K": 2, "L": 2, "N": 7, "O": 2, "P": 3, "R": 5, "S": 8, "T": 7, "V": 3, "W": 9, "X": 2, "Z": 5}	\N	2026-06-15 14:11:48.225022
58	eacc4913-7529-40d2-ba62-446d8c45bd9b	\N	\N	999	{"A": 2, "B": 2, "C": 3, "D": 0, "E": 8, "F": 3, "G": 2, "I": 2, "K": 3, "L": 1, "N": 6, "O": 5, "P": 1, "R": 9, "S": 6, "T": 7, "V": 7, "W": 0, "X": 2, "Z": 7}	\N	2026-06-15 14:11:48.225022
59	daab5116-420e-46e1-9e00-bfdcba51edd7	\N	\N	999	{"A": 0, "B": 5, "C": 5, "D": 0, "E": 7, "F": 4, "G": 0, "I": 5, "K": 0, "L": 7, "N": 7, "O": 9, "P": 6, "R": 8, "S": 3, "T": 4, "V": 1, "W": 2, "X": 0, "Z": 6}	\N	2026-06-15 14:11:48.225022
60	42dab708-e9d7-4cc4-a9ab-99448dcec05e	\N	\N	999	{"A": 7, "B": 7, "C": 6, "D": 6, "E": 0, "F": 5, "G": 4, "I": 6, "K": 9, "L": 3, "N": 2, "O": 0, "P": 5, "R": 2, "S": 1, "T": 8, "V": 3, "W": 3, "X": 9, "Z": 1}	\N	2026-06-15 14:11:48.225022
61	3128126c-b3f9-4c19-a435-9cbb527b790f	\N	\N	999	{"A": 5, "B": 3, "C": 2, "D": 6, "E": 5, "F": 5, "G": 5, "I": 4, "K": 3, "L": 0, "N": 7, "O": 2, "P": 9, "R": 0, "S": 5, "T": 4, "V": 2, "W": 1, "X": 2, "Z": 6}	\N	2026-06-15 14:11:48.225022
62	94dc98e0-d52c-47a0-9cf7-7d1d29f50eae	\N	\N	999	{"A": 1, "B": 0, "C": 9, "D": 5, "E": 9, "F": 8, "G": 0, "I": 9, "K": 5, "L": 6, "N": 5, "O": 8, "P": 1, "R": 2, "S": 0, "T": 4, "V": 1, "W": 8, "X": 3, "Z": 5}	\N	2026-06-15 14:11:48.225022
63	a8cd6eb8-a42c-4fa6-a6c4-61c668e62783	\N	\N	999	{"A": 2, "B": 7, "C": 3, "D": 7, "E": 4, "F": 8, "G": 8, "I": 6, "K": 9, "L": 0, "N": 9, "O": 0, "P": 2, "R": 1, "S": 6, "T": 2, "V": 3, "W": 9, "X": 3, "Z": 6}	\N	2026-06-15 14:11:48.225022
64	6b13554f-3f28-4133-8afe-9bd13881e537	\N	\N	999	{"A": 0, "B": 2, "C": 6, "D": 2, "E": 5, "F": 4, "G": 3, "I": 2, "K": 3, "L": 7, "N": 4, "O": 0, "P": 3, "R": 8, "S": 0, "T": 5, "V": 9, "W": 2, "X": 0, "Z": 3}	\N	2026-06-15 14:11:48.225022
65	777088a3-62f1-4fd5-9217-3f32ce9df6d5	\N	\N	999	{"A": 5, "B": 0, "C": 0, "D": 9, "E": 7, "F": 2, "G": 8, "I": 9, "K": 2, "L": 6, "N": 9, "O": 7, "P": 8, "R": 9, "S": 1, "T": 2, "V": 4, "W": 5, "X": 2, "Z": 6}	\N	2026-06-15 14:11:48.225022
66	5dd63582-e883-4d1f-a1cf-50b620b064ab	\N	\N	999	{"A": 9, "B": 9, "C": 1, "D": 5, "E": 2, "F": 0, "G": 8, "I": 8, "K": 5, "L": 2, "N": 4, "O": 2, "P": 3, "R": 5, "S": 8, "T": 3, "V": 9, "W": 2, "X": 1, "Z": 3}	\N	2026-06-15 14:11:48.225022
67	a072eb9a-9e4a-465f-aba5-f4f76b5d048e	\N	\N	999	{"A": 1, "B": 3, "C": 6, "D": 8, "E": 4, "F": 9, "G": 3, "I": 4, "K": 4, "L": 8, "N": 1, "O": 8, "P": 1, "R": 9, "S": 6, "T": 6, "V": 5, "W": 9, "X": 3, "Z": 8}	\N	2026-06-15 14:11:48.225022
68	19547fce-f299-4d3e-9e7e-6f42941fcae5	\N	\N	999	{"A": 1, "B": 8, "C": 1, "D": 6, "E": 3, "F": 9, "G": 4, "I": 0, "K": 1, "L": 1, "N": 1, "O": 6, "P": 8, "R": 5, "S": 8, "T": 3, "V": 1, "W": 5, "X": 7, "Z": 4}	\N	2026-06-15 14:11:48.225022
69	3e4dc158-b6b8-4568-b00d-ebf3f05e5628	\N	\N	999	{"A": 7, "B": 2, "C": 3, "D": 3, "E": 6, "F": 3, "G": 3, "I": 3, "K": 7, "L": 5, "N": 1, "O": 8, "P": 5, "R": 2, "S": 4, "T": 8, "V": 4, "W": 6, "X": 7, "Z": 7}	\N	2026-06-15 14:11:48.225022
70	be826c3a-3e6c-40fb-a45c-4438e13955b6	\N	\N	999	{"A": 8, "B": 4, "C": 3, "D": 0, "E": 2, "F": 9, "G": 9, "I": 6, "K": 7, "L": 6, "N": 0, "O": 6, "P": 7, "R": 9, "S": 6, "T": 4, "V": 0, "W": 3, "X": 9, "Z": 9}	\N	2026-06-15 14:11:48.225022
71	22c1d10b-7f72-4e29-9fab-501730285e9e	\N	\N	999	{"A": 4, "B": 6, "C": 9, "D": 9, "E": 9, "F": 0, "G": 8, "I": 7, "K": 8, "L": 7, "N": 3, "O": 0, "P": 3, "R": 1, "S": 6, "T": 5, "V": 6, "W": 6, "X": 6, "Z": 3}	\N	2026-06-15 14:11:48.225022
72	b7e9e71d-78c9-4ee5-8a48-4758ad727519	\N	\N	999	{"A": 3, "B": 3, "C": 1, "D": 5, "E": 1, "F": 8, "G": 4, "I": 6, "K": 7, "L": 1, "N": 7, "O": 5, "P": 0, "R": 1, "S": 3, "T": 7, "V": 4, "W": 2, "X": 4, "Z": 5}	\N	2026-06-15 14:11:48.225022
73	29f5cfd4-3500-4041-9ddf-4093e31b9631	\N	\N	999	{"A": 1, "B": 6, "C": 2, "D": 1, "E": 2, "F": 8, "G": 0, "I": 5, "K": 0, "L": 1, "N": 0, "O": 3, "P": 2, "R": 7, "S": 1, "T": 3, "V": 8, "W": 9, "X": 0, "Z": 7}	\N	2026-06-15 14:11:48.225022
74	ebdb9225-b8ec-42aa-b832-bb8ca1d97d47	\N	\N	999	{"A": 7, "B": 8, "C": 1, "D": 0, "E": 8, "F": 3, "G": 8, "I": 4, "K": 8, "L": 2, "N": 6, "O": 5, "P": 0, "R": 2, "S": 4, "T": 7, "V": 5, "W": 5, "X": 9, "Z": 6}	\N	2026-06-15 14:11:48.225022
75	f063965e-80d2-4aea-889f-3f033cdda727	\N	\N	999	{"A": 7, "B": 3, "C": 9, "D": 7, "E": 9, "F": 1, "G": 4, "I": 0, "K": 6, "L": 2, "N": 8, "O": 6, "P": 5, "R": 5, "S": 7, "T": 7, "V": 4, "W": 6, "X": 3, "Z": 4}	\N	2026-06-15 14:11:48.225022
76	18f6f0e3-b262-4721-a232-0134fa8a9f98	\N	\N	999	{"A": 4, "B": 6, "C": 9, "D": 5, "E": 0, "F": 8, "G": 5, "I": 6, "K": 8, "L": 3, "N": 1, "O": 8, "P": 3, "R": 0, "S": 6, "T": 8, "V": 0, "W": 8, "X": 1, "Z": 8}	\N	2026-06-15 14:11:48.225022
77	053b5809-ea38-4b14-9604-e3d5da6b1275	\N	\N	999	{"A": 7, "B": 0, "C": 8, "D": 9, "E": 0, "F": 5, "G": 8, "I": 6, "K": 7, "L": 8, "N": 3, "O": 1, "P": 1, "R": 4, "S": 4, "T": 2, "V": 1, "W": 3, "X": 5, "Z": 0}	\N	2026-06-15 14:11:48.225022
78	3a686abb-e5a8-43c9-8441-a33d8ff8441e	\N	\N	999	{"A": 5, "B": 2, "C": 0, "D": 7, "E": 3, "F": 0, "G": 1, "I": 6, "K": 3, "L": 9, "N": 4, "O": 9, "P": 5, "R": 2, "S": 7, "T": 8, "V": 9, "W": 9, "X": 1, "Z": 7}	\N	2026-06-15 14:11:48.225022
79	4db68934-6182-45d0-b02e-6981bab3b2df	\N	\N	999	{"A": 9, "B": 8, "C": 8, "D": 5, "E": 6, "F": 5, "G": 0, "I": 4, "K": 9, "L": 5, "N": 3, "O": 3, "P": 0, "R": 3, "S": 4, "T": 9, "V": 4, "W": 0, "X": 7, "Z": 2}	\N	2026-06-15 14:11:48.225022
80	4be374fe-b85f-4cfc-8a68-47c37488bcee	\N	\N	999	{"A": 6, "B": 4, "C": 7, "D": 6, "E": 1, "F": 4, "G": 8, "I": 5, "K": 1, "L": 0, "N": 8, "O": 3, "P": 4, "R": 1, "S": 6, "T": 3, "V": 7, "W": 2, "X": 7, "Z": 7}	\N	2026-06-15 14:11:48.225022
81	f6f5609b-876b-4818-a86e-1fb5cb4da5b0	\N	\N	999	{"A": 2, "B": 4, "C": 7, "D": 2, "E": 6, "F": 8, "G": 3, "I": 7, "K": 3, "L": 2, "N": 2, "O": 9, "P": 9, "R": 4, "S": 7, "T": 3, "V": 0, "W": 2, "X": 6, "Z": 5}	\N	2026-06-15 14:11:48.225022
82	0261a557-ad1d-4251-8de5-25dcb08f5b1d	\N	\N	999	{"A": 0, "B": 1, "C": 4, "D": 2, "E": 6, "F": 5, "G": 2, "I": 7, "K": 4, "L": 5, "N": 8, "O": 2, "P": 8, "R": 4, "S": 1, "T": 5, "V": 0, "W": 3, "X": 5, "Z": 6}	\N	2026-06-15 14:11:48.225022
83	b9c6b67e-40b7-4141-96c4-4b4fbe774248	\N	\N	999	{"A": 5, "B": 3, "C": 2, "D": 2, "E": 1, "F": 6, "G": 6, "I": 3, "K": 8, "L": 4, "N": 0, "O": 5, "P": 7, "R": 3, "S": 6, "T": 9, "V": 6, "W": 1, "X": 3, "Z": 7}	\N	2026-06-15 14:11:48.225022
84	5aa6f2b9-8377-4b81-b08c-18e00ba94d4d	\N	\N	999	{"A": 2, "B": 6, "C": 4, "D": 7, "E": 5, "F": 1, "G": 9, "I": 8, "K": 0, "L": 0, "N": 2, "O": 5, "P": 7, "R": 7, "S": 1, "T": 4, "V": 1, "W": 7, "X": 4, "Z": 1}	\N	2026-06-15 14:11:48.225022
85	d83f973c-bb87-461d-a593-bb25f37d75af	\N	\N	999	{"A": 1, "B": 5, "C": 6, "D": 9, "E": 5, "F": 7, "G": 9, "I": 0, "K": 8, "L": 6, "N": 3, "O": 0, "P": 3, "R": 9, "S": 5, "T": 5, "V": 0, "W": 3, "X": 8, "Z": 6}	\N	2026-06-15 14:11:48.225022
86	d8747d4a-517a-41af-b213-1b9151670cff	\N	\N	999	{"A": 9, "B": 0, "C": 3, "D": 8, "E": 1, "F": 4, "G": 7, "I": 3, "K": 1, "L": 4, "N": 9, "O": 0, "P": 4, "R": 5, "S": 9, "T": 7, "V": 3, "W": 3, "X": 5, "Z": 9}	\N	2026-06-15 14:11:48.225022
87	47437537-c0a6-47c7-85b0-014c3ef9d12e	\N	\N	999	{"A": 2, "B": 0, "C": 7, "D": 1, "E": 9, "F": 9, "G": 1, "I": 6, "K": 0, "L": 9, "N": 9, "O": 2, "P": 6, "R": 8, "S": 9, "T": 7, "V": 6, "W": 6, "X": 5, "Z": 5}	\N	2026-06-15 14:11:48.225022
88	7f50cd56-4c37-4d16-84a5-792d845d850c	\N	\N	999	{"A": 5, "B": 5, "C": 3, "D": 4, "E": 2, "F": 2, "G": 6, "I": 3, "K": 0, "L": 7, "N": 5, "O": 6, "P": 9, "R": 9, "S": 0, "T": 1, "V": 7, "W": 4, "X": 4, "Z": 6}	\N	2026-06-15 14:11:48.225022
89	ff1ecf9d-14ee-4bf2-8f7e-812cee075d43	\N	\N	999	{"A": 1, "B": 6, "C": 4, "D": 5, "E": 3, "F": 9, "G": 3, "I": 5, "K": 5, "L": 7, "N": 4, "O": 2, "P": 5, "R": 8, "S": 9, "T": 5, "V": 9, "W": 6, "X": 8, "Z": 2}	\N	2026-06-15 14:11:48.225022
90	5b0903ae-1b3f-4f4f-86bc-c25cbae5d3da	\N	\N	999	{"A": 2, "B": 8, "C": 0, "D": 2, "E": 7, "F": 0, "G": 2, "I": 2, "K": 3, "L": 0, "N": 1, "O": 1, "P": 7, "R": 7, "S": 8, "T": 1, "V": 1, "W": 2, "X": 1, "Z": 4}	\N	2026-06-15 14:11:48.225022
91	bd7953c5-edff-4661-89bb-58b0c746109e	\N	\N	999	{"A": 6, "B": 6, "C": 9, "D": 1, "E": 7, "F": 4, "G": 6, "I": 5, "K": 1, "L": 6, "N": 6, "O": 2, "P": 8, "R": 6, "S": 0, "T": 1, "V": 6, "W": 0, "X": 6, "Z": 7}	\N	2026-06-15 14:11:48.225022
92	d8870e3a-2487-47fb-a744-2617f4f48016	\N	\N	999	{"A": 5, "B": 0, "C": 3, "D": 3, "E": 3, "F": 7, "G": 1, "I": 6, "K": 5, "L": 7, "N": 8, "O": 8, "P": 0, "R": 8, "S": 4, "T": 4, "V": 5, "W": 2, "X": 8, "Z": 0}	\N	2026-06-15 14:11:48.225022
93	51f6c406-63f1-4d67-9231-d413ee3b7850	\N	\N	999	{"A": 8, "B": 0, "C": 5, "D": 5, "E": 1, "F": 4, "G": 0, "I": 9, "K": 7, "L": 0, "N": 8, "O": 8, "P": 3, "R": 7, "S": 5, "T": 8, "V": 6, "W": 3, "X": 2, "Z": 5}	\N	2026-06-15 14:11:48.225022
94	71137d1d-f54b-4da3-a744-ad37a5cefb35	\N	\N	999	{"A": 8, "B": 4, "C": 3, "D": 2, "E": 8, "F": 7, "G": 5, "I": 7, "K": 3, "L": 4, "N": 1, "O": 3, "P": 7, "R": 2, "S": 5, "T": 5, "V": 2, "W": 0, "X": 7, "Z": 3}	\N	2026-06-15 14:11:48.225022
95	b48324bf-3b8f-45d5-bb00-d53cdacae86e	\N	\N	999	{"A": 7, "B": 8, "C": 8, "D": 5, "E": 1, "F": 6, "G": 0, "I": 8, "K": 0, "L": 5, "N": 5, "O": 4, "P": 8, "R": 0, "S": 0, "T": 9, "V": 4, "W": 9, "X": 5, "Z": 8}	\N	2026-06-15 14:11:48.225022
96	bcbbae99-2847-4fa0-8e59-324f1044eb61	\N	\N	999	{"A": 4, "B": 0, "C": 3, "D": 4, "E": 4, "F": 6, "G": 6, "I": 0, "K": 6, "L": 7, "N": 5, "O": 4, "P": 5, "R": 7, "S": 2, "T": 4, "V": 4, "W": 9, "X": 4, "Z": 0}	\N	2026-06-15 14:11:48.225022
97	d7dbe66b-d1dc-46e2-98ed-b5a34fa12d64	\N	\N	999	{"A": 0, "B": 9, "C": 2, "D": 7, "E": 6, "F": 3, "G": 6, "I": 3, "K": 7, "L": 7, "N": 4, "O": 6, "P": 2, "R": 1, "S": 5, "T": 0, "V": 9, "W": 2, "X": 1, "Z": 7}	\N	2026-06-15 14:11:48.225022
98	a32f588f-cb2b-43f5-9d59-8e95c1ea45a8	\N	\N	999	{"A": 3, "B": 9, "C": 8, "D": 0, "E": 2, "F": 7, "G": 3, "I": 7, "K": 9, "L": 5, "N": 8, "O": 1, "P": 2, "R": 7, "S": 4, "T": 9, "V": 4, "W": 2, "X": 8, "Z": 7}	\N	2026-06-15 14:11:48.225022
99	f91ac970-7e66-4360-b5d4-925cda81f2ba	\N	\N	999	{"A": 9, "B": 7, "C": 8, "D": 1, "E": 2, "F": 7, "G": 5, "I": 1, "K": 7, "L": 6, "N": 6, "O": 8, "P": 4, "R": 7, "S": 8, "T": 0, "V": 0, "W": 8, "X": 5, "Z": 8}	\N	2026-06-15 14:11:48.225022
100	bda5f54a-8294-40ca-b5f2-3670f5a9eb18	\N	\N	999	{"A": 3, "B": 9, "C": 4, "D": 9, "E": 1, "F": 3, "G": 5, "I": 5, "K": 6, "L": 6, "N": 8, "O": 2, "P": 5, "R": 1, "S": 9, "T": 1, "V": 0, "W": 6, "X": 3, "Z": 4}	\N	2026-06-15 14:11:48.225022
101	110a7494-a769-4528-b123-660f821c6a9d	\N	\N	999	{"A": 5, "B": 2, "C": 3, "D": 8, "E": 7, "F": 3, "G": 3, "I": 3, "K": 5, "L": 9, "N": 7, "O": 3, "P": 8, "R": 9, "S": 9, "T": 6, "V": 5, "W": 4, "X": 6, "Z": 9}	\N	2026-06-15 14:11:48.225022
\.


--
-- Data for Name: schools; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.schools (id, name, address, city, province, phone, email, created_at, updated_at) FROM stdin;
1	SMP Muhammadiyah Yogyakarta 2	Jl. Kapas	\N	\N	\N	\N	2026-06-14 16:48:22.555863	2026-06-14 17:14:44.854161
999	SMP Muhammadiyah Yogyakarta 2	Yogyakarta	\N	\N	\N	\N	2026-06-15 14:11:48.225022	2026-06-15 14:11:48.225022
\.


--
-- Data for Name: test_assignments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.test_assignments (id, category_id, school_id, student_id, assigned_by, window_start, window_end, is_active, created_at) FROM stdin;
1	1	1	\N	6a2963d2b574ee35716be111	2026-06-14 00:00:00	2026-06-15 23:59:59	t	2026-06-14 17:16:02.061508
999	1	999	\N	474fa60f-cac7-4e68-bd73-29445b913130	\N	\N	t	2026-06-15 14:11:48.225022
2	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 13:01:37.884309
3	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 13:10:12.297796
4	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 13:17:19.860718
5	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 13:32:37.483779
6	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 13:47:41.107367
7	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 13:50:36.256078
8	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 13:51:26.085366
9	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 13:55:01.522601
10	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 13:57:03.461249
11	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 14:23:23.811749
12	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 14:24:26.184588
13	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 15:42:23.814975
14	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 15:46:02.412488
15	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 15:46:53.821765
16	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 15:50:45.411803
17	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 15:52:42.399296
18	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 15:53:08.993249
19	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 15:53:57.515416
20	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 15:54:30.235913
21	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 15:56:02.785412
22	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 16:06:06.137059
23	1	1	\N	6a2963d2b574ee35716be111	\N	\N	t	2026-06-19 16:34:39.853138
\.


--
-- Data for Name: test_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.test_categories (id, name, slug, description, tests, price, is_active, created_at) FROM stdin;
1	Paket Lengkap	paket-lengkap	DISC + Holland + PAPI + CFIT + IST	{disc,holland,papi,cfit,ist}	350000.00	t	2026-06-14 16:19:20.631978
2	Paket Kepribadian	paket-kepribadian	DISC + Holland + PAPI	{disc,holland,papi}	150000.00	t	2026-06-14 16:19:20.631978
3	Paket IQ	paket-iq	CFIT + IST	{cfit,ist}	200000.00	t	2026-06-14 16:19:20.631978
4	DISC Saja	disc-only	Tes DISC	{disc}	75000.00	t	2026-06-14 16:19:20.631978
5	IST Saja	ist-only	Tes IQ IST	{ist}	125000.00	t	2026-06-14 16:19:20.631978
\.


--
-- Name: activity_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.activity_logs_id_seq', 16, true);


--
-- Name: cfit_descriptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cfit_descriptions_id_seq', 5, true);


--
-- Name: cfit_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cfit_questions_id_seq', 9, true);


--
-- Name: cfit_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cfit_results_id_seq', 101, true);


--
-- Name: disc_personality_profiles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.disc_personality_profiles_id_seq', 9, true);


--
-- Name: disc_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.disc_questions_id_seq', 32, true);


--
-- Name: disc_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.disc_results_id_seq', 111, true);


--
-- Name: disc_scoring_dif_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.disc_scoring_dif_id_seq', 16, true);


--
-- Name: disc_scoring_least_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.disc_scoring_least_id_seq', 16, true);


--
-- Name: disc_scoring_most_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.disc_scoring_most_id_seq', 16, true);


--
-- Name: fee_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.fee_config_id_seq', 1, true);


--
-- Name: fee_shares_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.fee_shares_id_seq', 1, true);


--
-- Name: holland_descriptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.holland_descriptions_id_seq', 6, true);


--
-- Name: holland_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.holland_questions_id_seq', 66, true);


--
-- Name: holland_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.holland_results_id_seq', 111, true);


--
-- Name: ist_iq_bands_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ist_iq_bands_id_seq', 5, true);


--
-- Name: ist_me_pairs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ist_me_pairs_id_seq', 4, true);


--
-- Name: ist_norma_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ist_norma_id_seq', 95, true);


--
-- Name: ist_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ist_questions_id_seq', 16, true);


--
-- Name: ist_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ist_results_id_seq', 101, true);


--
-- Name: ist_wu_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ist_wu_questions_id_seq', 4, true);


--
-- Name: ist_zr_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ist_zr_questions_id_seq', 4, true);


--
-- Name: papi_descriptions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.papi_descriptions_id_seq', 20, true);


--
-- Name: papi_questions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.papi_questions_id_seq', 40, true);


--
-- Name: papi_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.papi_results_id_seq', 101, true);


--
-- Name: schools_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.schools_id_seq', 1, true);


--
-- Name: test_assignments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.test_assignments_id_seq', 23, true);


--
-- Name: test_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.test_categories_id_seq', 5, true);


--
-- Name: activity_logs activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.activity_logs
    ADD CONSTRAINT activity_logs_pkey PRIMARY KEY (id);


--
-- Name: assessment_users assessment_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_users
    ADD CONSTRAINT assessment_users_pkey PRIMARY KEY (auth_user_id);


--
-- Name: cfit_descriptions cfit_descriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfit_descriptions
    ADD CONSTRAINT cfit_descriptions_pkey PRIMARY KEY (id);


--
-- Name: cfit_questions cfit_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfit_questions
    ADD CONSTRAINT cfit_questions_pkey PRIMARY KEY (id);


--
-- Name: cfit_questions cfit_questions_subtest_no_item_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfit_questions
    ADD CONSTRAINT cfit_questions_subtest_no_item_no_key UNIQUE (subtest_no, item_no);


--
-- Name: cfit_results cfit_results_auth_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfit_results
    ADD CONSTRAINT cfit_results_auth_user_id_key UNIQUE (auth_user_id);


--
-- Name: cfit_results cfit_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfit_results
    ADD CONSTRAINT cfit_results_pkey PRIMARY KEY (id);


--
-- Name: disc_personality_profiles disc_personality_profiles_most_key_least_key_dif_key_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_personality_profiles
    ADD CONSTRAINT disc_personality_profiles_most_key_least_key_dif_key_key UNIQUE (most_key, least_key, dif_key);


--
-- Name: disc_personality_profiles disc_personality_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_personality_profiles
    ADD CONSTRAINT disc_personality_profiles_pkey PRIMARY KEY (id);


--
-- Name: disc_questions disc_questions_block_no_item_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_questions
    ADD CONSTRAINT disc_questions_block_no_item_no_key UNIQUE (block_no, item_no);


--
-- Name: disc_questions disc_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_questions
    ADD CONSTRAINT disc_questions_pkey PRIMARY KEY (id);


--
-- Name: disc_results disc_results_auth_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_results
    ADD CONSTRAINT disc_results_auth_user_id_key UNIQUE (auth_user_id);


--
-- Name: disc_results disc_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_results
    ADD CONSTRAINT disc_results_pkey PRIMARY KEY (id);


--
-- Name: disc_scoring_dif disc_scoring_dif_d_score_i_score_s_score_c_score_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_scoring_dif
    ADD CONSTRAINT disc_scoring_dif_d_score_i_score_s_score_c_score_key UNIQUE (d_score, i_score, s_score, c_score);


--
-- Name: disc_scoring_dif disc_scoring_dif_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_scoring_dif
    ADD CONSTRAINT disc_scoring_dif_pkey PRIMARY KEY (id);


--
-- Name: disc_scoring_least disc_scoring_least_d_score_i_score_s_score_c_score_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_scoring_least
    ADD CONSTRAINT disc_scoring_least_d_score_i_score_s_score_c_score_key UNIQUE (d_score, i_score, s_score, c_score);


--
-- Name: disc_scoring_least disc_scoring_least_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_scoring_least
    ADD CONSTRAINT disc_scoring_least_pkey PRIMARY KEY (id);


--
-- Name: disc_scoring_most disc_scoring_most_d_score_i_score_s_score_c_score_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_scoring_most
    ADD CONSTRAINT disc_scoring_most_d_score_i_score_s_score_c_score_key UNIQUE (d_score, i_score, s_score, c_score);


--
-- Name: disc_scoring_most disc_scoring_most_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_scoring_most
    ADD CONSTRAINT disc_scoring_most_pkey PRIMARY KEY (id);


--
-- Name: fee_config fee_config_category_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_config
    ADD CONSTRAINT fee_config_category_id_key UNIQUE (category_id);


--
-- Name: fee_config fee_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_config
    ADD CONSTRAINT fee_config_pkey PRIMARY KEY (id);


--
-- Name: fee_shares fee_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_shares
    ADD CONSTRAINT fee_shares_pkey PRIMARY KEY (id);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: holland_descriptions holland_descriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.holland_descriptions
    ADD CONSTRAINT holland_descriptions_pkey PRIMARY KEY (id);


--
-- Name: holland_descriptions holland_descriptions_riasec_type_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.holland_descriptions
    ADD CONSTRAINT holland_descriptions_riasec_type_key UNIQUE (riasec_type);


--
-- Name: holland_questions holland_questions_group_code_item_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.holland_questions
    ADD CONSTRAINT holland_questions_group_code_item_no_key UNIQUE (group_code, item_no);


--
-- Name: holland_questions holland_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.holland_questions
    ADD CONSTRAINT holland_questions_pkey PRIMARY KEY (id);


--
-- Name: holland_results holland_results_auth_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.holland_results
    ADD CONSTRAINT holland_results_auth_user_id_key UNIQUE (auth_user_id);


--
-- Name: holland_results holland_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.holland_results
    ADD CONSTRAINT holland_results_pkey PRIMARY KEY (id);


--
-- Name: ist_iq_bands ist_iq_bands_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_iq_bands
    ADD CONSTRAINT ist_iq_bands_pkey PRIMARY KEY (id);


--
-- Name: ist_iq_bands ist_iq_bands_wert_min_wert_max_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_iq_bands
    ADD CONSTRAINT ist_iq_bands_wert_min_wert_max_key UNIQUE (wert_min, wert_max);


--
-- Name: ist_me_pairs ist_me_pairs_item_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_me_pairs
    ADD CONSTRAINT ist_me_pairs_item_no_key UNIQUE (item_no);


--
-- Name: ist_me_pairs ist_me_pairs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_me_pairs
    ADD CONSTRAINT ist_me_pairs_pkey PRIMARY KEY (id);


--
-- Name: ist_norma ist_norma_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_norma
    ADD CONSTRAINT ist_norma_pkey PRIMARY KEY (id);


--
-- Name: ist_norma ist_norma_subtest_code_raw_score_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_norma
    ADD CONSTRAINT ist_norma_subtest_code_raw_score_key UNIQUE (subtest_code, raw_score);


--
-- Name: ist_questions ist_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_questions
    ADD CONSTRAINT ist_questions_pkey PRIMARY KEY (id);


--
-- Name: ist_questions ist_questions_subtest_code_item_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_questions
    ADD CONSTRAINT ist_questions_subtest_code_item_no_key UNIQUE (subtest_code, item_no);


--
-- Name: ist_results ist_results_auth_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_results
    ADD CONSTRAINT ist_results_auth_user_id_key UNIQUE (auth_user_id);


--
-- Name: ist_results ist_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_results
    ADD CONSTRAINT ist_results_pkey PRIMARY KEY (id);


--
-- Name: ist_wu_questions ist_wu_questions_item_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_wu_questions
    ADD CONSTRAINT ist_wu_questions_item_no_key UNIQUE (item_no);


--
-- Name: ist_wu_questions ist_wu_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_wu_questions
    ADD CONSTRAINT ist_wu_questions_pkey PRIMARY KEY (id);


--
-- Name: ist_zr_questions ist_zr_questions_item_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_zr_questions
    ADD CONSTRAINT ist_zr_questions_item_no_key UNIQUE (item_no);


--
-- Name: ist_zr_questions ist_zr_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_zr_questions
    ADD CONSTRAINT ist_zr_questions_pkey PRIMARY KEY (id);


--
-- Name: papi_descriptions papi_descriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papi_descriptions
    ADD CONSTRAINT papi_descriptions_pkey PRIMARY KEY (id);


--
-- Name: papi_descriptions papi_descriptions_trait_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papi_descriptions
    ADD CONSTRAINT papi_descriptions_trait_code_key UNIQUE (trait_code);


--
-- Name: papi_questions papi_questions_pair_no_item_letter_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papi_questions
    ADD CONSTRAINT papi_questions_pair_no_item_letter_key UNIQUE (pair_no, item_letter);


--
-- Name: papi_questions papi_questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papi_questions
    ADD CONSTRAINT papi_questions_pkey PRIMARY KEY (id);


--
-- Name: papi_results papi_results_auth_user_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papi_results
    ADD CONSTRAINT papi_results_auth_user_id_key UNIQUE (auth_user_id);


--
-- Name: papi_results papi_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papi_results
    ADD CONSTRAINT papi_results_pkey PRIMARY KEY (id);


--
-- Name: schools schools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schools
    ADD CONSTRAINT schools_pkey PRIMARY KEY (id);


--
-- Name: test_assignments test_assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_assignments
    ADD CONSTRAINT test_assignments_pkey PRIMARY KEY (id);


--
-- Name: test_categories test_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_categories
    ADD CONSTRAINT test_categories_pkey PRIMARY KEY (id);


--
-- Name: test_categories test_categories_slug_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_categories
    ADD CONSTRAINT test_categories_slug_key UNIQUE (slug);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX flyway_schema_history_s_idx ON public.flyway_schema_history USING btree (success);


--
-- Name: idx_activity_test; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activity_test ON public.activity_logs USING btree (test_type);


--
-- Name: idx_activity_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_activity_user ON public.activity_logs USING btree (auth_user_id);


--
-- Name: idx_assessment_users_afil; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assessment_users_afil ON public.assessment_users USING btree (afiliator_id);


--
-- Name: idx_assessment_users_role; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assessment_users_role ON public.assessment_users USING btree (role);


--
-- Name: idx_assessment_users_school; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assessment_users_school ON public.assessment_users USING btree (school_id);


--
-- Name: idx_assignments_category; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assignments_category ON public.test_assignments USING btree (category_id);


--
-- Name: idx_assignments_school; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assignments_school ON public.test_assignments USING btree (school_id);


--
-- Name: idx_assignments_student; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_assignments_student ON public.test_assignments USING btree (student_id);


--
-- Name: idx_cfit_q_subtest; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cfit_q_subtest ON public.cfit_questions USING btree (subtest_no);


--
-- Name: idx_disc_q_block; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_disc_q_block ON public.disc_questions USING btree (block_no);


--
-- Name: idx_disc_results_user; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_disc_results_user ON public.disc_results USING btree (auth_user_id);


--
-- Name: idx_fee_shares_afiliator; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fee_shares_afiliator ON public.fee_shares USING btree (afiliator_id);


--
-- Name: idx_fee_shares_student; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_fee_shares_student ON public.fee_shares USING btree (student_id);


--
-- Name: idx_holland_q_group; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_holland_q_group ON public.holland_questions USING btree (group_code);


--
-- Name: idx_ist_q_subtest; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ist_q_subtest ON public.ist_questions USING btree (subtest_code);


--
-- Name: idx_papi_q_pair; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_papi_q_pair ON public.papi_questions USING btree (pair_no);


--
-- Name: idx_papi_q_trait; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_papi_q_trait ON public.papi_questions USING btree (trait_code);


--
-- Name: assessment_users assessment_users_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.assessment_users
    ADD CONSTRAINT assessment_users_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE SET NULL;


--
-- Name: cfit_results cfit_results_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfit_results
    ADD CONSTRAINT cfit_results_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.test_assignments(id);


--
-- Name: cfit_results cfit_results_auth_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cfit_results
    ADD CONSTRAINT cfit_results_auth_user_id_fkey FOREIGN KEY (auth_user_id) REFERENCES public.assessment_users(auth_user_id);


--
-- Name: disc_results disc_results_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_results
    ADD CONSTRAINT disc_results_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.test_assignments(id);


--
-- Name: disc_results disc_results_auth_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.disc_results
    ADD CONSTRAINT disc_results_auth_user_id_fkey FOREIGN KEY (auth_user_id) REFERENCES public.assessment_users(auth_user_id);


--
-- Name: fee_config fee_config_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_config
    ADD CONSTRAINT fee_config_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.test_categories(id);


--
-- Name: fee_shares fee_shares_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_shares
    ADD CONSTRAINT fee_shares_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.test_categories(id);


--
-- Name: fee_shares fee_shares_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.fee_shares
    ADD CONSTRAINT fee_shares_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.assessment_users(auth_user_id);


--
-- Name: holland_results holland_results_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.holland_results
    ADD CONSTRAINT holland_results_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.test_assignments(id);


--
-- Name: holland_results holland_results_auth_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.holland_results
    ADD CONSTRAINT holland_results_auth_user_id_fkey FOREIGN KEY (auth_user_id) REFERENCES public.assessment_users(auth_user_id);


--
-- Name: ist_results ist_results_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_results
    ADD CONSTRAINT ist_results_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.test_assignments(id);


--
-- Name: ist_results ist_results_auth_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ist_results
    ADD CONSTRAINT ist_results_auth_user_id_fkey FOREIGN KEY (auth_user_id) REFERENCES public.assessment_users(auth_user_id);


--
-- Name: papi_results papi_results_assignment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papi_results
    ADD CONSTRAINT papi_results_assignment_id_fkey FOREIGN KEY (assignment_id) REFERENCES public.test_assignments(id);


--
-- Name: papi_results papi_results_auth_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.papi_results
    ADD CONSTRAINT papi_results_auth_user_id_fkey FOREIGN KEY (auth_user_id) REFERENCES public.assessment_users(auth_user_id);


--
-- Name: test_assignments test_assignments_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_assignments
    ADD CONSTRAINT test_assignments_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.test_categories(id);


--
-- Name: test_assignments test_assignments_school_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_assignments
    ADD CONSTRAINT test_assignments_school_id_fkey FOREIGN KEY (school_id) REFERENCES public.schools(id) ON DELETE CASCADE;


--
-- Name: test_assignments test_assignments_student_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_assignments
    ADD CONSTRAINT test_assignments_student_id_fkey FOREIGN KEY (student_id) REFERENCES public.assessment_users(auth_user_id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 7s3ZyMH7JlDMk7dHwlMreXhUn11XqnhE0hfHVoc5xUewNQLmuhKxZZRrXtiWvpP

