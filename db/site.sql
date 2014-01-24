--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.3
-- Dumped by pg_dump version 9.1.3
-- Started on 2013-07-03 15:47:23

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_with_oids = false;

--
-- TOC entry 162 (class 1259 OID 21498)
-- Dependencies: 6
-- Name: authproviders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE authproviders (
    provider_id integer NOT NULL,
    provider_name character varying(80) NOT NULL
);


--
-- TOC entry 163 (class 1259 OID 21501)
-- Dependencies: 6 162
-- Name: authproviders_provider_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authproviders_provider_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3053 (class 0 OID 0)
-- Dependencies: 163
-- Name: authproviders_provider_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authproviders_provider_id_seq OWNED BY authproviders.provider_id;


--
-- TOC entry 3054 (class 0 OID 0)
-- Dependencies: 163
-- Name: authproviders_provider_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('authproviders_provider_id_seq', 3, true);


--
-- TOC entry 168 (class 1259 OID 21520)
-- Dependencies: 2884 6
-- Name: characters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE characters (
    character_id integer NOT NULL,
    character_name text NOT NULL,
    is_numeric boolean DEFAULT false NOT NULL,
    character_type_id integer
);


--
-- TOC entry 169 (class 1259 OID 21527)
-- Dependencies: 6 168
-- Name: characters_character_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE characters_character_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3055 (class 0 OID 0)
-- Dependencies: 169
-- Name: characters_character_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE characters_character_id_seq OWNED BY characters.character_id;


--
-- TOC entry 3056 (class 0 OID 0)
-- Dependencies: 169
-- Name: characters_character_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('characters_character_id_seq', 1, true);


--
-- TOC entry 170 (class 1259 OID 21529)
-- Dependencies: 6
-- Name: charactertypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE charactertypes (
    character_type_id integer NOT NULL,
    character_type text NOT NULL
);


--
-- TOC entry 171 (class 1259 OID 21535)
-- Dependencies: 6 170
-- Name: charactertypes_character_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE charactertypes_character_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3057 (class 0 OID 0)
-- Dependencies: 171
-- Name: charactertypes_character_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE charactertypes_character_type_id_seq OWNED BY charactertypes.character_type_id;


--
-- TOC entry 3058 (class 0 OID 0)
-- Dependencies: 171
-- Name: charactertypes_character_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('charactertypes_character_type_id_seq', 1, true);


--
-- TOC entry 209 (class 1259 OID 27491)
-- Dependencies: 2914 6
-- Name: contactform; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE contactform (
    contact_id integer NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text NOT NULL,
    issue_type text NOT NULL,
    information text NOT NULL,
    date_added timestamp without time zone DEFAULT now() NOT NULL,
    device text
);


--
-- TOC entry 208 (class 1259 OID 27489)
-- Dependencies: 6 209
-- Name: contactform_contact_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE contactform_contact_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3059 (class 0 OID 0)
-- Dependencies: 208
-- Name: contactform_contact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE contactform_contact_id_seq OWNED BY contactform.contact_id;


--
-- TOC entry 3060 (class 0 OID 0)
-- Dependencies: 208
-- Name: contactform_contact_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('contactform_contact_id_seq', 1, true);


--
-- TOC entry 172 (class 1259 OID 21537)
-- Dependencies: 6
-- Name: genders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE genders (
    gender_id integer NOT NULL,
    gender_name character varying(20) NOT NULL
);


--
-- TOC entry 173 (class 1259 OID 21540)
-- Dependencies: 172 6
-- Name: gender_gender_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE gender_gender_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3061 (class 0 OID 0)
-- Dependencies: 173
-- Name: gender_gender_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE gender_gender_id_seq OWNED BY genders.gender_id;


--
-- TOC entry 3062 (class 0 OID 0)
-- Dependencies: 173
-- Name: gender_gender_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('gender_gender_id_seq', 1, true);


--
-- TOC entry 180 (class 1259 OID 21569)
-- Dependencies: 6
-- Name: hosts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE hosts (
    host_id integer NOT NULL,
    common_name text NOT NULL,
    scientific_name character varying(150)
);


--
-- TOC entry 181 (class 1259 OID 21575)
-- Dependencies: 180 6
-- Name: host_host_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE host_host_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3063 (class 0 OID 0)
-- Dependencies: 181
-- Name: host_host_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE host_host_id_seq OWNED BY hosts.host_id;


--
-- TOC entry 3064 (class 0 OID 0)
-- Dependencies: 181
-- Name: host_host_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('host_host_id_seq', 1, true);


--
-- TOC entry 176 (class 1259 OID 21553)
-- Dependencies: 6
-- Name: hostimages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE hostimages (
    image_id integer NOT NULL,
    host_id integer NOT NULL,
    image_type_id integer NOT NULL,
    filename text NOT NULL,
    photographer text,
    copyright text
);


--
-- TOC entry 177 (class 1259 OID 21559)
-- Dependencies: 6 176
-- Name: hostimages_image_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE hostimages_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3065 (class 0 OID 0)
-- Dependencies: 177
-- Name: hostimages_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE hostimages_image_id_seq OWNED BY hostimages.image_id;


--
-- TOC entry 3066 (class 0 OID 0)
-- Dependencies: 177
-- Name: hostimages_image_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('hostimages_image_id_seq', 1, true);


--
-- TOC entry 178 (class 1259 OID 21561)
-- Dependencies: 6
-- Name: hostimagetypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE hostimagetypes (
    image_type_id integer NOT NULL,
    image_type_name text NOT NULL
);


--
-- TOC entry 179 (class 1259 OID 21567)
-- Dependencies: 178 6
-- Name: hostimagetypes_image_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE hostimagetypes_image_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3067 (class 0 OID 0)
-- Dependencies: 179
-- Name: hostimagetypes_image_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE hostimagetypes_image_type_id_seq OWNED BY hostimagetypes.image_type_id;


--
-- TOC entry 3068 (class 0 OID 0)
-- Dependencies: 179
-- Name: hostimagetypes_image_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('hostimagetypes_image_type_id_seq', 1, true);


--
-- TOC entry 182 (class 1259 OID 21577)
-- Dependencies: 2892 2893 6
-- Name: observationimages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE observationimages (
    image_id integer NOT NULL,
    observation_id integer,
    image_type_id integer NOT NULL,
    filename text NOT NULL,
    photographer text,
    character_type_id integer,
    gender_id integer,
    description_id integer,
    image_comments text,
    copyright text,
    date_added timestamp without time zone DEFAULT now() NOT NULL,
    date_modified timestamp without time zone DEFAULT now()
);


--
-- TOC entry 183 (class 1259 OID 21583)
-- Dependencies: 6 182
-- Name: images_image_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE images_image_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3069 (class 0 OID 0)
-- Dependencies: 183
-- Name: images_image_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE images_image_id_seq OWNED BY observationimages.image_id;


--
-- TOC entry 3070 (class 0 OID 0)
-- Dependencies: 183
-- Name: images_image_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('images_image_id_seq', 1, true);


--
-- TOC entry 184 (class 1259 OID 21585)
-- Dependencies: 6
-- Name: observationimagetypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE observationimagetypes (
    image_type_id integer NOT NULL,
    image_type_name text NOT NULL
);


--
-- TOC entry 185 (class 1259 OID 21591)
-- Dependencies: 184 6
-- Name: imagetypes_image_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE imagetypes_image_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3071 (class 0 OID 0)
-- Dependencies: 185
-- Name: imagetypes_image_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE imagetypes_image_type_id_seq OWNED BY observationimagetypes.image_type_id;


--
-- TOC entry 3072 (class 0 OID 0)
-- Dependencies: 185
-- Name: imagetypes_image_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('imagetypes_image_type_id_seq', 1, true);


--
-- TOC entry 186 (class 1259 OID 21593)
-- Dependencies: 6
-- Name: observationimagedescriptiontypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE observationimagedescriptiontypes (
    description_id integer NOT NULL,
    description_name text NOT NULL
);


--
-- TOC entry 187 (class 1259 OID 21599)
-- Dependencies: 6 186
-- Name: observationimagedescriptiontype_description_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE observationimagedescriptiontype_description_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3073 (class 0 OID 0)
-- Dependencies: 187
-- Name: observationimagedescriptiontype_description_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE observationimagedescriptiontype_description_id_seq OWNED BY observationimagedescriptiontypes.description_id;


--
-- TOC entry 3074 (class 0 OID 0)
-- Dependencies: 187
-- Name: observationimagedescriptiontype_description_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('observationimagedescriptiontype_description_id_seq', 1, true);


--
-- TOC entry 188 (class 1259 OID 21601)
-- Dependencies: 6
-- Name: observationimages_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE observationimages_states (
    image_id integer NOT NULL,
    state_id integer NOT NULL
);


--
-- TOC entry 189 (class 1259 OID 21604)
-- Dependencies: 6
-- Name: observationnotes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE observationnotes (
    note_id integer NOT NULL,
    observation_id integer NOT NULL,
    notes text NOT NULL
);


--
-- TOC entry 190 (class 1259 OID 21610)
-- Dependencies: 189 6
-- Name: observationotes_note_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE observationotes_note_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3075 (class 0 OID 0)
-- Dependencies: 190
-- Name: observationotes_note_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE observationotes_note_id_seq OWNED BY observationnotes.note_id;


--
-- TOC entry 3076 (class 0 OID 0)
-- Dependencies: 190
-- Name: observationotes_note_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('observationotes_note_id_seq', 1, true);


--
-- TOC entry 216 (class 1259 OID 100118)
-- Dependencies: 6
-- Name: observationreviews; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE observationreviews (
    review_id integer NOT NULL,
    observation_id integer NOT NULL,
    comments text,
    user_changed integer NOT NULL
);


--
-- TOC entry 215 (class 1259 OID 100116)
-- Dependencies: 6 216
-- Name: observationreviews_review_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE observationreviews_review_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3077 (class 0 OID 0)
-- Dependencies: 215
-- Name: observationreviews_review_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE observationreviews_review_id_seq OWNED BY observationreviews.review_id;


--
-- TOC entry 3078 (class 0 OID 0)
-- Dependencies: 215
-- Name: observationreviews_review_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('observationreviews_review_id_seq', 1, true);


--
-- TOC entry 191 (class 1259 OID 21612)
-- Dependencies: 2898 2899 2900 2901 2902 2903 6 1332
-- Name: observations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE observations (
    observation_id integer NOT NULL,
    organism_id integer,
    datum text,
    observation_type_id integer,
    latitude double precision,
    longitude double precision,
    geom geometry,
    user_organism_id integer,
    date_observed date,
    source character varying(120),
    location_detail text,
    date_added timestamp without time zone DEFAULT now() NOT NULL,
    date_modified timestamp without time zone DEFAULT now(),
    number_seen integer DEFAULT 1 NOT NULL,
    status_id integer NOT NULL,
    CONSTRAINT enforce_dims_geom CHECK ((st_ndims(geom) = 2)),
    CONSTRAINT enforce_geotype_geom CHECK (((geometrytype(geom) = 'POINT'::text) OR (geom IS NULL))),
    CONSTRAINT enforce_srid_geom CHECK ((st_srid(geom) = 32661))
);


--
-- TOC entry 192 (class 1259 OID 21622)
-- Dependencies: 6 191
-- Name: observations_observation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE observations_observation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3079 (class 0 OID 0)
-- Dependencies: 192
-- Name: observations_observation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE observations_observation_id_seq OWNED BY observations.observation_id;


--
-- TOC entry 3080 (class 0 OID 0)
-- Dependencies: 192
-- Name: observations_observation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('observations_observation_id_seq', 1, true);


--
-- TOC entry 214 (class 1259 OID 100087)
-- Dependencies: 6
-- Name: observationstatus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE observationstatus (
    status_id integer NOT NULL,
    status_name text
);


--
-- TOC entry 213 (class 1259 OID 100085)
-- Dependencies: 6 214
-- Name: observationstatus_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE observationstatus_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3081 (class 0 OID 0)
-- Dependencies: 213
-- Name: observationstatus_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE observationstatus_status_id_seq OWNED BY observationstatus.status_id;


--
-- TOC entry 3082 (class 0 OID 0)
-- Dependencies: 213
-- Name: observationstatus_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('observationstatus_status_id_seq', 3, true);


--
-- TOC entry 193 (class 1259 OID 21629)
-- Dependencies: 6
-- Name: observationtypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE observationtypes (
    observation_type_id integer NOT NULL,
    observation_name text NOT NULL
);


--
-- TOC entry 194 (class 1259 OID 21635)
-- Dependencies: 193 6
-- Name: observationtypes_observation_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE observationtypes_observation_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3083 (class 0 OID 0)
-- Dependencies: 194
-- Name: observationtypes_observation_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE observationtypes_observation_type_id_seq OWNED BY observationtypes.observation_type_id;


--
-- TOC entry 3084 (class 0 OID 0)
-- Dependencies: 194
-- Name: observationtypes_observation_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('observationtypes_observation_type_id_seq', 2, true);


--
-- TOC entry 164 (class 1259 OID 21503)
-- Dependencies: 6
-- Name: organisms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE organisms (
    organism_id integer NOT NULL,
    scientific_name text NOT NULL,
    common_name text,
    family_name text,
    description text
);


--
-- TOC entry 210 (class 1259 OID 27611)
-- Dependencies: 6
-- Name: organisms_defaultimages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE organisms_defaultimages (
    organism_id integer NOT NULL,
    character_type_id integer NOT NULL,
    image_id integer NOT NULL
);


--
-- TOC entry 166 (class 1259 OID 21511)
-- Dependencies: 6
-- Name: organisms_hosts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE organisms_hosts (
    organism_id integer NOT NULL,
    host_id integer NOT NULL
);


--
-- TOC entry 165 (class 1259 OID 21509)
-- Dependencies: 6 164
-- Name: organisms_organism_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE organisms_organism_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3085 (class 0 OID 0)
-- Dependencies: 165
-- Name: organisms_organism_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE organisms_organism_id_seq OWNED BY organisms.organism_id;


--
-- TOC entry 3086 (class 0 OID 0)
-- Dependencies: 165
-- Name: organisms_organism_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('organisms_organism_id_seq', 1, true);


--
-- TOC entry 167 (class 1259 OID 21514)
-- Dependencies: 6
-- Name: organisms_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE organisms_states (
    organism_id integer NOT NULL,
    state_id integer NOT NULL,
    low_value numeric,
    high_value numeric
);


--
-- TOC entry 195 (class 1259 OID 21637)
-- Dependencies: 2905 6
-- Name: picup; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE picup (
    observation_id integer NOT NULL,
    passkey character varying(30) NOT NULL,
    ip_address inet NOT NULL,
    date_added timestamp without time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 196 (class 1259 OID 21644)
-- Dependencies: 6
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE roles (
    role_id integer NOT NULL,
    role character varying(40) NOT NULL
);


--
-- TOC entry 197 (class 1259 OID 21647)
-- Dependencies: 6 196
-- Name: roles_role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3087 (class 0 OID 0)
-- Dependencies: 197
-- Name: roles_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_role_id_seq OWNED BY roles.role_id;


--
-- TOC entry 3088 (class 0 OID 0)
-- Dependencies: 197
-- Name: roles_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('roles_role_id_seq', 3, true);


--
-- TOC entry 211 (class 1259 OID 27681)
-- Dependencies: 6
-- Name: sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sessions (
    id character(72) NOT NULL,
    session_data text,
    expires integer
);


--
-- TOC entry 199 (class 1259 OID 21655)
-- Dependencies: 6
-- Name: states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE states (
    state_id integer NOT NULL,
    state_name text NOT NULL,
    character_id integer NOT NULL
);


--
-- TOC entry 200 (class 1259 OID 21661)
-- Dependencies: 6 199
-- Name: states_state_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE states_state_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3089 (class 0 OID 0)
-- Dependencies: 200
-- Name: states_state_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE states_state_id_seq OWNED BY states.state_id;


--
-- TOC entry 3090 (class 0 OID 0)
-- Dependencies: 200
-- Name: states_state_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('states_state_id_seq', 1, true);


--
-- TOC entry 201 (class 1259 OID 21663)
-- Dependencies: 6
-- Name: status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE status (
    status_id integer NOT NULL,
    status_name text NOT NULL
);


--
-- TOC entry 202 (class 1259 OID 21669)
-- Dependencies: 6 201
-- Name: status_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE status_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3091 (class 0 OID 0)
-- Dependencies: 202
-- Name: status_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE status_status_id_seq OWNED BY status.status_id;


--
-- TOC entry 3092 (class 0 OID 0)
-- Dependencies: 202
-- Name: status_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('status_status_id_seq', 3, true);


--
-- TOC entry 203 (class 1259 OID 21671)
-- Dependencies: 2909 2910 6
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    user_id integer NOT NULL,
    email character varying(120),
    first_name character varying(60),
    last_name character varying(80),
    status_id integer NOT NULL,
    date_added timestamp without time zone DEFAULT now() NOT NULL,
    date_modified timestamp without time zone DEFAULT now() NOT NULL,
    username character varying(50) NOT NULL,
    authid character varying(200) NOT NULL,
    password character varying(200),
    provider_id integer NOT NULL,
    forgot_password text
);


--
-- TOC entry 204 (class 1259 OID 21684)
-- Dependencies: 6
-- Name: users_organisms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users_organisms (
    user_id integer NOT NULL,
    organism_id integer NOT NULL,
    user_organism_id integer NOT NULL
);


--
-- TOC entry 205 (class 1259 OID 21687)
-- Dependencies: 6 204
-- Name: users_organisms_user_organism_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_organisms_user_organism_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3093 (class 0 OID 0)
-- Dependencies: 205
-- Name: users_organisms_user_organism_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_organisms_user_organism_id_seq OWNED BY users_organisms.user_organism_id;


--
-- TOC entry 3094 (class 0 OID 0)
-- Dependencies: 205
-- Name: users_organisms_user_organism_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('users_organisms_user_organism_id_seq', 1, true);


--
-- TOC entry 206 (class 1259 OID 21689)
-- Dependencies: 6
-- Name: users_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users_roles (
    user_id integer NOT NULL,
    role_id integer NOT NULL
);


--
-- TOC entry 207 (class 1259 OID 21692)
-- Dependencies: 203 6
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3095 (class 0 OID 0)
-- Dependencies: 207
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_user_id_seq OWNED BY users.user_id;


--
-- TOC entry 3096 (class 0 OID 0)
-- Dependencies: 207
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('users_user_id_seq', 1, true);


--
-- TOC entry 2882 (class 2604 OID 21694)
-- Dependencies: 163 162
-- Name: provider_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authproviders ALTER COLUMN provider_id SET DEFAULT nextval('authproviders_provider_id_seq'::regclass);


--
-- TOC entry 2885 (class 2604 OID 21696)
-- Dependencies: 169 168
-- Name: character_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY characters ALTER COLUMN character_id SET DEFAULT nextval('characters_character_id_seq'::regclass);


--
-- TOC entry 2886 (class 2604 OID 21697)
-- Dependencies: 171 170
-- Name: character_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY charactertypes ALTER COLUMN character_type_id SET DEFAULT nextval('charactertypes_character_type_id_seq'::regclass);


--
-- TOC entry 2913 (class 2604 OID 27494)
-- Dependencies: 208 209 209
-- Name: contact_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY contactform ALTER COLUMN contact_id SET DEFAULT nextval('contactform_contact_id_seq'::regclass);


--
-- TOC entry 2887 (class 2604 OID 21698)
-- Dependencies: 173 172
-- Name: gender_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY genders ALTER COLUMN gender_id SET DEFAULT nextval('gender_gender_id_seq'::regclass);


--
-- TOC entry 2888 (class 2604 OID 21699)
-- Dependencies: 177 176
-- Name: image_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY hostimages ALTER COLUMN image_id SET DEFAULT nextval('hostimages_image_id_seq'::regclass);


--
-- TOC entry 2889 (class 2604 OID 21700)
-- Dependencies: 179 178
-- Name: image_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY hostimagetypes ALTER COLUMN image_type_id SET DEFAULT nextval('hostimagetypes_image_type_id_seq'::regclass);


--
-- TOC entry 2890 (class 2604 OID 21701)
-- Dependencies: 181 180
-- Name: host_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY hosts ALTER COLUMN host_id SET DEFAULT nextval('host_host_id_seq'::regclass);


--
-- TOC entry 2895 (class 2604 OID 21702)
-- Dependencies: 187 186
-- Name: description_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationimagedescriptiontypes ALTER COLUMN description_id SET DEFAULT nextval('observationimagedescriptiontype_description_id_seq'::regclass);


--
-- TOC entry 2891 (class 2604 OID 21703)
-- Dependencies: 183 182
-- Name: image_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationimages ALTER COLUMN image_id SET DEFAULT nextval('images_image_id_seq'::regclass);


--
-- TOC entry 2894 (class 2604 OID 21704)
-- Dependencies: 185 184
-- Name: image_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationimagetypes ALTER COLUMN image_type_id SET DEFAULT nextval('imagetypes_image_type_id_seq'::regclass);


--
-- TOC entry 2896 (class 2604 OID 21705)
-- Dependencies: 190 189
-- Name: note_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationnotes ALTER COLUMN note_id SET DEFAULT nextval('observationotes_note_id_seq'::regclass);


--
-- TOC entry 2916 (class 2604 OID 100121)
-- Dependencies: 215 216 216
-- Name: review_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationreviews ALTER COLUMN review_id SET DEFAULT nextval('observationreviews_review_id_seq'::regclass);


--
-- TOC entry 2897 (class 2604 OID 21706)
-- Dependencies: 192 191
-- Name: observation_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY observations ALTER COLUMN observation_id SET DEFAULT nextval('observations_observation_id_seq'::regclass);


--
-- TOC entry 2915 (class 2604 OID 100090)
-- Dependencies: 214 213 214
-- Name: status_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationstatus ALTER COLUMN status_id SET DEFAULT nextval('observationstatus_status_id_seq'::regclass);


--
-- TOC entry 2904 (class 2604 OID 21707)
-- Dependencies: 194 193
-- Name: observation_type_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationtypes ALTER COLUMN observation_type_id SET DEFAULT nextval('observationtypes_observation_type_id_seq'::regclass);


--
-- TOC entry 2883 (class 2604 OID 27571)
-- Dependencies: 165 164
-- Name: organism_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY organisms ALTER COLUMN organism_id SET DEFAULT nextval('organisms_organism_id_seq'::regclass);


--
-- TOC entry 2906 (class 2604 OID 21708)
-- Dependencies: 197 196
-- Name: role_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN role_id SET DEFAULT nextval('roles_role_id_seq'::regclass);


--
-- TOC entry 2907 (class 2604 OID 21709)
-- Dependencies: 200 199
-- Name: state_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY states ALTER COLUMN state_id SET DEFAULT nextval('states_state_id_seq'::regclass);


--
-- TOC entry 2908 (class 2604 OID 21710)
-- Dependencies: 202 201
-- Name: status_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY status ALTER COLUMN status_id SET DEFAULT nextval('status_status_id_seq'::regclass);


--
-- TOC entry 2911 (class 2604 OID 21711)
-- Dependencies: 207 203
-- Name: user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN user_id SET DEFAULT nextval('users_user_id_seq'::regclass);


--
-- TOC entry 2912 (class 2604 OID 21712)
-- Dependencies: 205 204
-- Name: user_organism_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_organisms ALTER COLUMN user_organism_id SET DEFAULT nextval('users_organisms_user_organism_id_seq'::regclass);


--
-- TOC entry 3022 (class 0 OID 21498)
-- Dependencies: 162
-- Data for Name: authproviders; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO authproviders (provider_id, provider_name) VALUES (2, 'Facebook');
INSERT INTO authproviders (provider_id, provider_name) VALUES (3, 'Twitter');
INSERT INTO authproviders (provider_id, provider_name) VALUES (1, 'Site');


--
-- TOC entry 3026 (class 0 OID 21520)
-- Dependencies: 168
-- Data for Name: characters; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3027 (class 0 OID 21529)
-- Dependencies: 170
-- Data for Name: charactertypes; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3046 (class 0 OID 27491)
-- Dependencies: 209
-- Data for Name: contactform; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3028 (class 0 OID 21537)
-- Dependencies: 172
-- Data for Name: genders; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3029 (class 0 OID 21553)
-- Dependencies: 176
-- Data for Name: hostimages; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3030 (class 0 OID 21561)
-- Dependencies: 178
-- Data for Name: hostimagetypes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO hostimagetypes (image_type_id, image_type_name) VALUES (1, 'Field');


--
-- TOC entry 3031 (class 0 OID 21569)
-- Dependencies: 180
-- Data for Name: hosts; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3034 (class 0 OID 21593)
-- Dependencies: 186
-- Data for Name: observationimagedescriptiontypes; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3032 (class 0 OID 21577)
-- Dependencies: 182
-- Data for Name: observationimages; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3035 (class 0 OID 21601)
-- Dependencies: 188
-- Data for Name: observationimages_states; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3033 (class 0 OID 21585)
-- Dependencies: 184
-- Data for Name: observationimagetypes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO observationimagetypes (image_type_id, image_type_name) VALUES (1, 'Field');


--
-- TOC entry 3036 (class 0 OID 21604)
-- Dependencies: 189
-- Data for Name: observationnotes; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3050 (class 0 OID 100118)
-- Dependencies: 216
-- Data for Name: observationreviews; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3037 (class 0 OID 21612)
-- Dependencies: 191
-- Data for Name: observations; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3049 (class 0 OID 100087)
-- Dependencies: 214
-- Data for Name: observationstatus; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO observationstatus (status_id, status_name) VALUES (1, 'Published');
INSERT INTO observationstatus (status_id, status_name) VALUES (2, 'Unpublished');
INSERT INTO observationstatus (status_id, status_name) VALUES (3, 'Send For Review');


--
-- TOC entry 3038 (class 0 OID 21629)
-- Dependencies: 193
-- Data for Name: observationtypes; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO observationtypes (observation_type_id, observation_name) VALUES (1, 'User');
INSERT INTO observationtypes (observation_type_id, observation_name) VALUES (2, 'System');


--
-- TOC entry 3023 (class 0 OID 21503)
-- Dependencies: 164
-- Data for Name: organisms; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3047 (class 0 OID 27611)
-- Dependencies: 210
-- Data for Name: organisms_defaultimages; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3024 (class 0 OID 21511)
-- Dependencies: 166
-- Data for Name: organisms_hosts; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3025 (class 0 OID 21514)
-- Dependencies: 167
-- Data for Name: organisms_states; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3039 (class 0 OID 21637)
-- Dependencies: 195
-- Data for Name: picup; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3040 (class 0 OID 21644)
-- Dependencies: 196
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO roles (role_id, role) VALUES (1, 'User');
INSERT INTO roles (role_id, role) VALUES (2, 'Admin');
INSERT INTO roles (role_id, role) VALUES (3, 'Reviewer');


--
-- TOC entry 3048 (class 0 OID 27681)
-- Dependencies: 211
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3041 (class 0 OID 21655)
-- Dependencies: 199
-- Data for Name: states; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3042 (class 0 OID 21663)
-- Dependencies: 201
-- Data for Name: status; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO status (status_id, status_name) VALUES (1, 'Active');
INSERT INTO status (status_id, status_name) VALUES (2, 'Inactive');
INSERT INTO status (status_id, status_name) VALUES (3, 'Registered');


--
-- TOC entry 3043 (class 0 OID 21671)
-- Dependencies: 203
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3044 (class 0 OID 21684)
-- Dependencies: 204
-- Data for Name: users_organisms; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3045 (class 0 OID 21689)
-- Dependencies: 206
-- Data for Name: users_roles; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 2918 (class 2606 OID 21727)
-- Dependencies: 162 162
-- Name: pk-authprovider-provider_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authproviders
    ADD CONSTRAINT "pk-authprovider-provider_id" PRIMARY KEY (provider_id);


--
-- TOC entry 2929 (class 2606 OID 21735)
-- Dependencies: 168 168
-- Name: pk-character-character_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY characters
    ADD CONSTRAINT "pk-character-character_id" PRIMARY KEY (character_id);


--
-- TOC entry 2931 (class 2606 OID 21737)
-- Dependencies: 170 170
-- Name: pk-character_types-character_type_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY charactertypes
    ADD CONSTRAINT "pk-character_types-character_type_id" PRIMARY KEY (character_type_id);


--
-- TOC entry 2979 (class 2606 OID 27499)
-- Dependencies: 209 209
-- Name: pk-contactform-contact_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY contactform
    ADD CONSTRAINT "pk-contactform-contact_id" PRIMARY KEY (contact_id);


--
-- TOC entry 2933 (class 2606 OID 21739)
-- Dependencies: 172 172
-- Name: pk-genders-gender_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY genders
    ADD CONSTRAINT "pk-genders-gender_id" PRIMARY KEY (gender_id);


--
-- TOC entry 2940 (class 2606 OID 21741)
-- Dependencies: 180 180
-- Name: pk-host-host_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hosts
    ADD CONSTRAINT "pk-host-host_id" PRIMARY KEY (host_id);


--
-- TOC entry 2936 (class 2606 OID 44091)
-- Dependencies: 176 176
-- Name: pk-hostimages-image_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hostimages
    ADD CONSTRAINT "pk-hostimages-image_id" PRIMARY KEY (image_id);


--
-- TOC entry 2938 (class 2606 OID 21745)
-- Dependencies: 178 178
-- Name: pk-hostimagetypes-image_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hostimagetypes
    ADD CONSTRAINT "pk-hostimagetypes-image_id" PRIMARY KEY (image_type_id);


--
-- TOC entry 2945 (class 2606 OID 21747)
-- Dependencies: 184 184
-- Name: pk-image_type-image_type_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationimagetypes
    ADD CONSTRAINT "pk-image_type-image_type_id" PRIMARY KEY (image_type_id);


--
-- TOC entry 2955 (class 2606 OID 21749)
-- Dependencies: 191 191
-- Name: pk-observation-observation_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observations
    ADD CONSTRAINT "pk-observation-observation_id" PRIMARY KEY (observation_id);


--
-- TOC entry 2957 (class 2606 OID 21751)
-- Dependencies: 193 193
-- Name: pk-observation_type-observation_type_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationtypes
    ADD CONSTRAINT "pk-observation_type-observation_type_id" PRIMARY KEY (observation_type_id);


--
-- TOC entry 2947 (class 2606 OID 21753)
-- Dependencies: 186 186
-- Name: pk-observationimagedescriptiontypes-description_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationimagedescriptiontypes
    ADD CONSTRAINT "pk-observationimagedescriptiontypes-description_id" PRIMARY KEY (description_id);


--
-- TOC entry 2943 (class 2606 OID 21755)
-- Dependencies: 182 182
-- Name: pk-observationimages-image_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationimages
    ADD CONSTRAINT "pk-observationimages-image_id" PRIMARY KEY (image_id);


--
-- TOC entry 2949 (class 2606 OID 21757)
-- Dependencies: 188 188 188
-- Name: pk-observationimages_states-image_id-state_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationimages_states
    ADD CONSTRAINT "pk-observationimages_states-image_id-state_id" PRIMARY KEY (image_id, state_id);


--
-- TOC entry 2951 (class 2606 OID 21759)
-- Dependencies: 189 189
-- Name: pk-observationnotes-note_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationnotes
    ADD CONSTRAINT "pk-observationnotes-note_id" PRIMARY KEY (note_id);


--
-- TOC entry 2987 (class 2606 OID 100126)
-- Dependencies: 216 216
-- Name: pk-observationreviews-review_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationreviews
    ADD CONSTRAINT "pk-observationreviews-review_id" PRIMARY KEY (review_id);


--
-- TOC entry 2985 (class 2606 OID 100095)
-- Dependencies: 214 214
-- Name: pk-observationstatus-status_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationstatus
    ADD CONSTRAINT "pk-observationstatus-status_id" PRIMARY KEY (status_id);


--
-- TOC entry 2920 (class 2606 OID 21729)
-- Dependencies: 164 164
-- Name: pk-organisms-organism_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organisms
    ADD CONSTRAINT "pk-organisms-organism_id" PRIMARY KEY (organism_id);


--
-- TOC entry 2981 (class 2606 OID 27619)
-- Dependencies: 210 210 210
-- Name: pk-organisms_defaultimages-organism_id-character_type_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organisms_defaultimages
    ADD CONSTRAINT "pk-organisms_defaultimages-organism_id-character_type_id" PRIMARY KEY (organism_id, character_type_id);


--
-- TOC entry 2923 (class 2606 OID 27565)
-- Dependencies: 166 166 166
-- Name: pk-organisms_hosts-organism_id-host_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organisms_hosts
    ADD CONSTRAINT "pk-organisms_hosts-organism_id-host_id" PRIMARY KEY (organism_id, host_id);


--
-- TOC entry 2927 (class 2606 OID 27590)
-- Dependencies: 167 167 167
-- Name: pk-organisms_states-organism_id-state_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organisms_states
    ADD CONSTRAINT "pk-organisms_states-organism_id-state_id" PRIMARY KEY (organism_id, state_id);


--
-- TOC entry 2959 (class 2606 OID 21761)
-- Dependencies: 195 195
-- Name: pk-picup-observation_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY picup
    ADD CONSTRAINT "pk-picup-observation_id" PRIMARY KEY (observation_id);


--
-- TOC entry 2961 (class 2606 OID 21763)
-- Dependencies: 196 196
-- Name: pk-role-role_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT "pk-role-role_id" PRIMARY KEY (role_id);


--
-- TOC entry 2983 (class 2606 OID 27688)
-- Dependencies: 211 211
-- Name: pk-sessions-id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sessions
    ADD CONSTRAINT "pk-sessions-id" PRIMARY KEY (id);


--
-- TOC entry 2963 (class 2606 OID 21765)
-- Dependencies: 199 199
-- Name: pk-states-state_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY states
    ADD CONSTRAINT "pk-states-state_id" PRIMARY KEY (state_id);


--
-- TOC entry 2965 (class 2606 OID 21767)
-- Dependencies: 201 201
-- Name: pk-status-status_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY status
    ADD CONSTRAINT "pk-status-status_id" PRIMARY KEY (status_id);


--
-- TOC entry 2977 (class 2606 OID 21769)
-- Dependencies: 206 206 206
-- Name: pk-user_roles-user_id-role_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_roles
    ADD CONSTRAINT "pk-user_roles-user_id-role_id" PRIMARY KEY (user_id, role_id);


--
-- TOC entry 2967 (class 2606 OID 21771)
-- Dependencies: 203 203
-- Name: pk-users-user_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT "pk-users-user_id" PRIMARY KEY (user_id);


--
-- TOC entry 2973 (class 2606 OID 21775)
-- Dependencies: 204 204
-- Name: pk_users_organisms-user_organism_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_organisms
    ADD CONSTRAINT "pk_users_organisms-user_organism_id" PRIMARY KEY (user_organism_id);


--
-- TOC entry 2969 (class 2606 OID 27644)
-- Dependencies: 203 203 203
-- Name: unq-users-authid-provider_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT "unq-users-authid-provider_id" UNIQUE (authid, provider_id);


--
-- TOC entry 2971 (class 2606 OID 21779)
-- Dependencies: 203 203
-- Name: unq-users-email; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT "unq-users-email" UNIQUE (email);


--
-- TOC entry 2975 (class 2606 OID 21783)
-- Dependencies: 204 204 204
-- Name: unq-users_organisms-user_id-organism_id; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_organisms
    ADD CONSTRAINT "unq-users_organisms-user_id-organism_id" UNIQUE (user_id, organism_id);


--
-- TOC entry 2921 (class 1259 OID 28049)
-- Dependencies: 166
-- Name: fki_fk-organisms_hosts-host_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_fk-organisms_hosts-host_id" ON organisms_hosts USING btree (host_id);


--
-- TOC entry 2934 (class 1259 OID 44104)
-- Dependencies: 176
-- Name: idx-hostimages-host_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx-hostimages-host_id" ON hostimages USING btree (host_id);


--
-- TOC entry 2941 (class 1259 OID 44107)
-- Dependencies: 182
-- Name: idx-observationimages-observation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx-observationimages-observation_id" ON observationimages USING btree (observation_id);


--
-- TOC entry 2952 (class 1259 OID 44112)
-- Dependencies: 191
-- Name: idx-observations-organism_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx-observations-organism_id" ON observations USING btree (organism_id);


--
-- TOC entry 2953 (class 1259 OID 44114)
-- Dependencies: 191
-- Name: idx-observations-user_organism_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx-observations-user_organism_id" ON observations USING btree (user_organism_id DESC NULLS LAST);


--
-- TOC entry 2924 (class 1259 OID 44108)
-- Dependencies: 167
-- Name: idx-organisms_states-organism_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx-organisms_states-organism_id" ON organisms_states USING btree (organism_id);


--
-- TOC entry 2925 (class 1259 OID 44109)
-- Dependencies: 167
-- Name: idx-organisms_states-state_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "idx-organisms_states-state_id" ON organisms_states USING btree (state_id);


-- Function: observation_updategeomcolumn()

-- DROP FUNCTION observation_updategeomcolumn();

CREATE OR REPLACE FUNCTION observation_updategeomcolumn()
  RETURNS trigger AS
$BODY$
	DECLARE
	BEGIN
		IF tg_op = 'INSERT' THEN
		
			/*UPDATE observation SET geom = ST_SetSRID(ST_Point(new.longitude, new.latitude),4326) WHERE observation_id = new.observation_id;*/
			UPDATE observations SET geom = ST_transform(ST_PointFromText('POINT ('|| new.longitude || ' ' || new.latitude ||')', 4269), 32661) WHERE observation_id = new.observation_id;
		ELSIF tg_op = 'UPDATE' THEN
			/*UPDATE observation SET geom = ST_SetSRID(ST_Point(new.longitude, new.latitude),4326) WHERE observation_id = new.observation_id AND (old.latitude <> new.latitude OR old.longitude <> new.longitude);*/
			UPDATE observations SET geom = ST_transform(ST_PointFromText('POINT ('|| new.longitude || ' ' || new.latitude ||')', 4269), 32661) WHERE observation_id = new.observation_id AND (old.latitude <> new.latitude OR old.longitude <> new.longitude);
			RETURN NULL;
		END IF;
		RETURN NULL;
	END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
--
-- TOC entry 3020 (class 2620 OID 44131)
-- Dependencies: 191 452
-- Name: trigger_updategeomcolumn; Type: TRIGGER; Schema: public; Owner: -
--


CREATE TRIGGER trigger_updategeomcolumn AFTER INSERT OR UPDATE ON observations FOR EACH ROW EXECUTE PROCEDURE observation_updategeomcolumn();


-- Function: update_datemodified_column()

-- DROP FUNCTION update_datemodified_column();

CREATE OR REPLACE FUNCTION update_datemodified_column()
  RETURNS trigger AS
$BODY$
BEGIN
   NEW.date_modified = now(); 
   RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

--
-- TOC entry 3021 (class 2620 OID 21785)
-- Dependencies: 997 203
-- Name: update_users_datemodified; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_users_datemodified BEFORE UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE update_datemodified_column();


--
-- TOC entry 2992 (class 2606 OID 21811)
-- Dependencies: 2930 170 168
-- Name: fk-characters-character_type_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY characters
    ADD CONSTRAINT "fk-characters-character_type_id" FOREIGN KEY (character_type_id) REFERENCES charactertypes(character_type_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2993 (class 2606 OID 44080)
-- Dependencies: 2939 180 176
-- Name: fk-hostimages-host_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hostimages
    ADD CONSTRAINT "fk-hostimages-host_id" FOREIGN KEY (host_id) REFERENCES hosts(host_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2994 (class 2606 OID 44085)
-- Dependencies: 176 178 2937
-- Name: fk-hostimages-image_type_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY hostimages
    ADD CONSTRAINT "fk-hostimages-image_type_id" FOREIGN KEY (image_type_id) REFERENCES hostimagetypes(image_type_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3003 (class 2606 OID 100096)
-- Dependencies: 193 191 2956
-- Name: fk-observation_observation_type_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observations
    ADD CONSTRAINT "fk-observation_observation_type_id" FOREIGN KEY (observation_type_id) REFERENCES observationtypes(observation_type_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2995 (class 2606 OID 27771)
-- Dependencies: 170 2930 182
-- Name: fk-observationimages-character_type_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationimages
    ADD CONSTRAINT "fk-observationimages-character_type_id" FOREIGN KEY (character_type_id) REFERENCES charactertypes(character_type_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 2996 (class 2606 OID 27776)
-- Dependencies: 182 186 2946
-- Name: fk-observationimages-description_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationimages
    ADD CONSTRAINT "fk-observationimages-description_id" FOREIGN KEY (description_id) REFERENCES observationimagedescriptiontypes(description_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 2997 (class 2606 OID 27781)
-- Dependencies: 2932 182 172
-- Name: fk-observationimages-gender_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationimages
    ADD CONSTRAINT "fk-observationimages-gender_id" FOREIGN KEY (gender_id) REFERENCES genders(gender_id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 2998 (class 2606 OID 27786)
-- Dependencies: 2944 182 184
-- Name: fk-observationimages-image_type_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationimages
    ADD CONSTRAINT "fk-observationimages-image_type_id" FOREIGN KEY (image_type_id) REFERENCES observationimagetypes(image_type_id);


--
-- TOC entry 2999 (class 2606 OID 27791)
-- Dependencies: 191 182 2954
-- Name: fk-observationimages-observation_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationimages
    ADD CONSTRAINT "fk-observationimages-observation_id" FOREIGN KEY (observation_id) REFERENCES observations(observation_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3000 (class 2606 OID 21866)
-- Dependencies: 2942 182 188
-- Name: fk-observationimages_states-image_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationimages_states
    ADD CONSTRAINT "fk-observationimages_states-image_id" FOREIGN KEY (image_id) REFERENCES observationimages(image_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3001 (class 2606 OID 21871)
-- Dependencies: 188 199 2962
-- Name: fk-observationimages_states-state_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationimages_states
    ADD CONSTRAINT "fk-observationimages_states-state_id" FOREIGN KEY (state_id) REFERENCES states(state_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3002 (class 2606 OID 21876)
-- Dependencies: 189 191 2954
-- Name: fk-observationotes-observation_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationnotes
    ADD CONSTRAINT "fk-observationotes-observation_id" FOREIGN KEY (observation_id) REFERENCES observations(observation_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3018 (class 2606 OID 100137)
-- Dependencies: 2954 191 216
-- Name: fk-observationreviews-observation_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationreviews
    ADD CONSTRAINT "fk-observationreviews-observation_id" FOREIGN KEY (observation_id) REFERENCES observations(observation_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3019 (class 2606 OID 100142)
-- Dependencies: 2966 216 203
-- Name: fk-observationreviews-user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observationreviews
    ADD CONSTRAINT "fk-observationreviews-user_id" FOREIGN KEY (user_changed) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3004 (class 2606 OID 100101)
-- Dependencies: 191 164 2919
-- Name: fk-observations-organism_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observations
    ADD CONSTRAINT "fk-observations-organism_id" FOREIGN KEY (organism_id) REFERENCES organisms(organism_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3006 (class 2606 OID 100111)
-- Dependencies: 191 214 2984
-- Name: fk-observations-status_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observations
    ADD CONSTRAINT "fk-observations-status_id" FOREIGN KEY (status_id) REFERENCES observationstatus(status_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3005 (class 2606 OID 100106)
-- Dependencies: 191 204 2972
-- Name: fk-observations-user_organism_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY observations
    ADD CONSTRAINT "fk-observations-user_organism_id" FOREIGN KEY (user_organism_id) REFERENCES users_organisms(user_organism_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3015 (class 2606 OID 44152)
-- Dependencies: 210 170 2930
-- Name: fk-organism_defaultimages-character_type_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organisms_defaultimages
    ADD CONSTRAINT "fk-organism_defaultimages-character_type_id" FOREIGN KEY (character_type_id) REFERENCES charactertypes(character_type_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3016 (class 2606 OID 44157)
-- Dependencies: 2942 182 210
-- Name: fk-organism_defaultimages-image_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organisms_defaultimages
    ADD CONSTRAINT "fk-organism_defaultimages-image_id" FOREIGN KEY (image_id) REFERENCES observationimages(image_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3017 (class 2606 OID 44162)
-- Dependencies: 210 164 2919
-- Name: fk-organism_defaultimages-organism_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organisms_defaultimages
    ADD CONSTRAINT "fk-organism_defaultimages-organism_id" FOREIGN KEY (organism_id) REFERENCES organisms(organism_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2988 (class 2606 OID 44132)
-- Dependencies: 166 180 2939
-- Name: fk-organisms_hosts-host_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organisms_hosts
    ADD CONSTRAINT "fk-organisms_hosts-host_id" FOREIGN KEY (host_id) REFERENCES hosts(host_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2989 (class 2606 OID 44137)
-- Dependencies: 166 164 2919
-- Name: fk-organisms_hosts-organism_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organisms_hosts
    ADD CONSTRAINT "fk-organisms_hosts-organism_id" FOREIGN KEY (organism_id) REFERENCES organisms(organism_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2990 (class 2606 OID 27811)
-- Dependencies: 167 164 2919
-- Name: fk-organisms_states-organism_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organisms_states
    ADD CONSTRAINT "fk-organisms_states-organism_id" FOREIGN KEY (organism_id) REFERENCES organisms(organism_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 2991 (class 2606 OID 27816)
-- Dependencies: 167 199 2962
-- Name: fk-organisms_states-state_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY organisms_states
    ADD CONSTRAINT "fk-organisms_states-state_id" FOREIGN KEY (state_id) REFERENCES states(state_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3007 (class 2606 OID 21881)
-- Dependencies: 195 191 2954
-- Name: fk-picup-observation_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY picup
    ADD CONSTRAINT "fk-picup-observation_id" FOREIGN KEY (observation_id) REFERENCES observations(observation_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3008 (class 2606 OID 21886)
-- Dependencies: 2928 168 199
-- Name: fk-state-character_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY states
    ADD CONSTRAINT "fk-state-character_id" FOREIGN KEY (character_id) REFERENCES characters(character_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3013 (class 2606 OID 21901)
-- Dependencies: 206 2960 196
-- Name: fk-user_roles-role_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_roles
    ADD CONSTRAINT "fk-user_roles-role_id" FOREIGN KEY (role_id) REFERENCES roles(role_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3014 (class 2606 OID 21906)
-- Dependencies: 206 2966 203
-- Name: fk-user_roles-user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_roles
    ADD CONSTRAINT "fk-user_roles-user_id" FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3010 (class 2606 OID 27645)
-- Dependencies: 2917 203 162
-- Name: fk-users-provider_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT "fk-users-provider_id" FOREIGN KEY (provider_id) REFERENCES authproviders(provider_id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 3009 (class 2606 OID 27638)
-- Dependencies: 203 201 2964
-- Name: fk-users-status_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT "fk-users-status_id" FOREIGN KEY (status_id) REFERENCES status(status_id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 3011 (class 2606 OID 27796)
-- Dependencies: 2919 164 204
-- Name: fk-users_organisms-organism_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_organisms
    ADD CONSTRAINT "fk-users_organisms-organism_id" FOREIGN KEY (organism_id) REFERENCES organisms(organism_id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 3012 (class 2606 OID 27801)
-- Dependencies: 203 204 2966
-- Name: fk-users_organisms-user_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users_organisms
    ADD CONSTRAINT "fk-users_organisms-user_id" FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE CASCADE;


-- Completed on 2013-07-03 15:47:23

--
-- PostgreSQL database dump complete
--

