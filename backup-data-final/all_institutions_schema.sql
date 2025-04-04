--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1 (Ubuntu 15.1-1.pgdg20.04+1)
-- Dumped by pg_dump version 17.4 (Ubuntu 17.4-1.pgdg24.04+2)

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

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: get_enrollment_percentiles(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_enrollment_percentiles() RETURNS TABLE(q25 numeric, q50 numeric, q75 numeric)
    LANGUAGE sql
    SET search_path TO 'public', 'public'
    AS $$SELECT 
        percentile_cont(0.25) WITHIN GROUP (ORDER BY enrollment_total_students) as q25,
        percentile_cont(0.50) WITHIN GROUP (ORDER BY enrollment_total_students) as q50,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY enrollment_total_students) as q75
    FROM public.all_education;$$;


ALTER FUNCTION public.get_enrollment_percentiles() OWNER TO postgres;

--
-- Name: get_population_percentiles(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_population_percentiles(source_table_filter text) RETURNS TABLE(q25 numeric, q50 numeric, q75 numeric)
    LANGUAGE sql
    SET search_path TO 'public', 'public'
    AS $$
    SELECT 
        percentile_cont(0.25) WITHIN GROUP (ORDER BY population) as q25,
        percentile_cont(0.50) WITHIN GROUP (ORDER BY population) as q50,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY population) as q75
    FROM public.all_institutions
    WHERE source_table = source_table_filter;
$$;


ALTER FUNCTION public.get_population_percentiles(source_table_filter text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: all_geo_transportation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.all_geo_transportation (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    state_fips_code integer,
    county_fips_code integer,
    city_code integer,
    stcntycity_fips_code bigint,
    city_name text,
    state character varying,
    county_name text,
    population integer
);


ALTER TABLE public.all_geo_transportation OWNER TO postgres;

--
-- Name: TABLE all_geo_transportation; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.all_geo_transportation IS 'https://data.transportation.gov/Railroads/State-County-and-City-FIPS-Reference-Table/eek5-pv8d/about_data';


--
-- Name: all_counties; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.all_counties AS
 SELECT ('county_'::text || (lpad((cty.state_fips_code)::text, 2, '0'::text) || lpad((cty.county_fips_code)::text, 3, '0'::text))) AS unique_id,
    ((cty.county_fips_code)::text)::bigint AS source_id,
    max(cty.county_name) AS name,
    max((cty.state)::text) AS state,
    max(cty.county_name) AS county,
    NULL::text AS city,
    NULL::text AS street,
    max((((cty.state)::text || '-'::text) || cty.county_name)) AS state_county,
    NULL::text AS state_city,
    sum(NULLIF((cty.population)::double precision, (0)::double precision)) AS population,
    'counties'::text AS source_table
   FROM public.all_geo_transportation cty
  GROUP BY cty.state_fips_code, cty.county_fips_code;


ALTER VIEW public.all_counties OWNER TO postgres;

--
-- Name: ipeds_2022; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ipeds_2022 (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    name text,
    state text,
    county text,
    city text,
    street text,
    zip text,
    longitude double precision,
    latitude double precision,
    control smallint
);


ALTER TABLE public.ipeds_2022 OWNER TO postgres;

--
-- Name: k12_districts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.k12_districts (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    name text NOT NULL,
    state text NOT NULL,
    county text NOT NULL,
    city text NOT NULL,
    street text,
    zip bigint,
    phone text,
    number_of_schools double precision,
    enrollment_total_students double precision
);


ALTER TABLE public.k12_districts OWNER TO postgres;

--
-- Name: all_education; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.all_education AS
 SELECT ('higher_education_'::text || hem.id) AS unique_id,
    hem.id AS source_id,
    hem.name,
    hem.state,
    hem.county,
    hem.city,
    hem.street,
    ((hem.state || '-'::text) || hem.county) AS state_county,
    ((hem.state || '-'::text) || hem.city) AS state_city,
    NULL::double precision AS enrollment_total_students,
    'higher_education'::text AS source_table
   FROM public.ipeds_2022 hem
UNION ALL
 SELECT ('k12_'::text || k12.id) AS unique_id,
    k12.id AS source_id,
    k12.name,
    k12.state,
    k12.county,
    k12.city,
    k12.street,
    ((k12.state || '-'::text) || k12.county) AS state_county,
    ((k12.state || '-'::text) || k12.city) AS state_city,
    NULLIF(k12.enrollment_total_students, (0)::double precision) AS enrollment_total_students,
    'k12_districts'::text AS source_table
   FROM public.k12_districts k12;


ALTER VIEW public.all_education OWNER TO postgres;

--
-- Name: all_geo_census; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.all_geo_census (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    summary_level integer,
    state_fips_code integer,
    county_fips_code integer,
    county_subdivision_fips_code integer,
    place_fips_code integer,
    consolidated_city_fips_code integer,
    area_name text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    state character varying,
    county_name text
);


ALTER TABLE public.all_geo_census OWNER TO postgres;

--
-- Name: TABLE all_geo_census; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.all_geo_census IS 'https://www.census.gov/geographies/reference-files/2022/demo/popest/2022-fips.html';


--
-- Name: individual_units; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.individual_units (
    state_code text,
    unit_type_code text,
    county_code text,
    unit_identification_number text,
    supplement_code text,
    sub_code text,
    name_of_government text,
    census_region_code text,
    county_name text,
    fips_state text,
    fips_county text,
    population_enrollment_function_code text,
    year_of_population_enrollment text,
    school_level_code text,
    probability_of_selection text,
    worksheet_code text,
    new_individual_unit_id text NOT NULL,
    state text
);


ALTER TABLE public.individual_units OWNER TO postgres;

--
-- Name: state_agencies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.state_agencies (
    name text NOT NULL,
    url text NOT NULL,
    state text NOT NULL,
    id bigint NOT NULL
);


ALTER TABLE public.state_agencies OWNER TO postgres;

--
-- Name: states; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.states (
    name text NOT NULL,
    capital_city text NOT NULL,
    state text NOT NULL,
    url text,
    agency_list_url text,
    source_id text
);


ALTER TABLE public.states OWNER TO postgres;

--
-- Name: all_institutions; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.all_institutions AS
 SELECT ('higher_education_'::text || hem.id) AS unique_id,
    hem.id AS source_id,
    hem.name,
    hem.state,
    hem.county,
    hem.city,
    hem.street,
    ((hem.state || '-'::text) || hem.county) AS state_county,
    ((hem.state || '-'::text) || hem.city) AS state_city,
    NULL::double precision AS population,
    'higher_education'::text AS source_table,
    'Higher Education'::text AS label
   FROM public.ipeds_2022 hem
UNION ALL
 SELECT ('k12_'::text || k12.id) AS unique_id,
    k12.id AS source_id,
    k12.name,
    k12.state,
    k12.county,
    k12.city,
    k12.street,
    ((k12.state || '-'::text) || k12.county) AS state_county,
    ((k12.state || '-'::text) || k12.city) AS state_city,
    NULLIF(k12.enrollment_total_students, (0)::double precision) AS population,
    'k12_districts'::text AS source_table,
    'K12 District'::text AS label
   FROM public.k12_districts k12
UNION ALL
 SELECT ('city_'::text || cty.stcntycity_fips_code) AS unique_id,
    cty.stcntycity_fips_code AS source_id,
    cty.city_name AS name,
    cty.state,
    cty.county_name AS county,
    cty.city_name AS city,
    NULL::text AS street,
    (((cty.state)::text || '-'::text) || cty.county_name) AS state_county,
    (((cty.state)::text || '-'::text) || cty.city_name) AS state_city,
    NULLIF((cty.population)::double precision, (0)::double precision) AS population,
    'cities'::text AS source_table,
    'Municipality'::text AS label
   FROM public.all_geo_transportation cty
  WHERE (cty.stcntycity_fips_code IS NOT NULL)
UNION ALL
 SELECT ac.unique_id,
    ac.source_id,
    ac.name,
    ac.state,
    ac.county,
    ac.city,
    ac.street,
    ac.state_county,
    ac.state_city,
    ac.population,
    ac.source_table,
    'County'::text AS label
   FROM public.all_counties ac
  WHERE (ac.unique_id IS NOT NULL)
UNION ALL
 SELECT ('state_'::text || st.source_id) AS unique_id,
    (st.source_id)::bigint AS source_id,
    st.name,
    st.state,
    NULL::text AS county,
    st.capital_city AS city,
    NULL::text AS street,
    NULL::text AS state_county,
    NULL::text AS state_city,
    NULL::double precision AS population,
    'states'::text AS source_table,
    'State'::text AS label
   FROM public.states st
UNION ALL
 SELECT ('state_agency_'::text || sa.id) AS unique_id,
    sa.id AS source_id,
    sa.name,
    sa.state,
    NULL::text AS county,
    NULL::text AS city,
    NULL::text AS street,
    NULL::text AS state_county,
    NULL::text AS state_city,
    NULL::double precision AS population,
    'state_agencies'::text AS source_table,
    'State Agency'::text AS label
   FROM public.state_agencies sa
UNION ALL
 SELECT ('individual_unit_'::text || iu.new_individual_unit_id) AS unique_id,
    (iu.new_individual_unit_id)::bigint AS source_id,
    iu.name_of_government AS name,
    iu.state,
    iu.county_name AS county,
    NULL::text AS city,
    NULL::text AS street,
    ((iu.state || '-'::text) || iu.county_name) AS state_county,
    NULL::text AS state_city,
    NULL::double precision AS population,
    'individual_units'::text AS source_table,
    'Special Districts'::text AS label
   FROM public.individual_units iu
  WHERE (iu.worksheet_code = '03'::text);


ALTER VIEW public.all_institutions OWNER TO postgres;

--
-- Name: all_institutions_metadata; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.all_institutions_metadata (
    unique_id text NOT NULL,
    url text NOT NULL,
    normalized_url text,
    best_contact_url text,
    best_contact_url_score double precision,
    best_contact_url_reason text,
    best_contact_url_array text[],
    best_rfp_url text,
    best_rfp_url_score double precision,
    best_rfp_url_array text[],
    best_rfp_url_reason text
);


ALTER TABLE public.all_institutions_metadata OWNER TO postgres;

--
-- Name: edens_demo; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.edens_demo AS
 SELECT ('higher_education_'::text || hem.id) AS unique_id,
    hem.id AS source_id,
    hem.name,
    hem.state,
    hem.county,
    hem.city,
    hem.street,
    ((hem.state || '-'::text) || hem.county) AS state_county,
    ((hem.state || '-'::text) || hem.city) AS state_city,
    NULL::double precision AS population,
    'higher_education'::text AS source_table,
    'Higher Education'::text AS label
   FROM public.ipeds_2022 hem
UNION ALL
 SELECT ('k12_'::text || k12.id) AS unique_id,
    k12.id AS source_id,
    k12.name,
    k12.state,
    k12.county,
    k12.city,
    k12.street,
    ((k12.state || '-'::text) || k12.county) AS state_county,
    ((k12.state || '-'::text) || k12.city) AS state_city,
    NULLIF(k12.enrollment_total_students, (0)::double precision) AS population,
    'k12_districts'::text AS source_table,
    'K12 District'::text AS label
   FROM public.k12_districts k12
UNION ALL
 SELECT ('city_'::text || cty.stcntycity_fips_code) AS unique_id,
    cty.stcntycity_fips_code AS source_id,
    cty.city_name AS name,
    cty.state,
    cty.county_name AS county,
    cty.city_name AS city,
    NULL::text AS street,
    (((cty.state)::text || '-'::text) || cty.county_name) AS state_county,
    (((cty.state)::text || '-'::text) || cty.city_name) AS state_city,
    NULLIF((cty.population)::double precision, (0)::double precision) AS population,
    'cities'::text AS source_table,
    'Municipality'::text AS label
   FROM public.all_geo_transportation cty
  WHERE (cty.stcntycity_fips_code IS NOT NULL)
UNION ALL
 SELECT ac.unique_id,
    ac.source_id,
    ac.name,
    ac.state,
    ac.county,
    ac.city,
    ac.street,
    ac.state_county,
    ac.state_city,
    ac.population,
    ac.source_table,
    'County'::text AS label
   FROM public.all_counties ac
  WHERE (ac.unique_id IS NOT NULL)
UNION ALL
 SELECT ('state_'::text || st.source_id) AS unique_id,
    (st.source_id)::bigint AS source_id,
    st.name,
    st.state,
    NULL::text AS county,
    st.capital_city AS city,
    NULL::text AS street,
    NULL::text AS state_county,
    NULL::text AS state_city,
    NULL::double precision AS population,
    'states'::text AS source_table,
    'State'::text AS label
   FROM public.states st
UNION ALL
 SELECT ('state_agency_'::text || sa.id) AS unique_id,
    sa.id AS source_id,
    sa.name,
    sa.state,
    NULL::text AS county,
    NULL::text AS city,
    NULL::text AS street,
    NULL::text AS state_county,
    NULL::text AS state_city,
    NULL::double precision AS population,
    'state_agencies'::text AS source_table,
    'State Agency'::text AS label
   FROM public.state_agencies sa
UNION ALL
 SELECT ('individual_unit'::text || iu.new_individual_unit_id) AS unique_id,
    (iu.new_individual_unit_id)::bigint AS source_id,
    iu.name_of_government AS name,
    iu.state,
    iu.county_name AS county,
    NULL::text AS city,
    NULL::text AS street,
    ((iu.state || '-'::text) || iu.county_name) AS state_county,
    NULL::text AS state_city,
    NULL::double precision AS population,
    'individual_units'::text AS source_table,
    'Special Districts'::text AS label
   FROM public.individual_units iu
  WHERE (iu.worksheet_code = '03'::text);


ALTER VIEW public.edens_demo OWNER TO postgres;

--
-- Name: higher_education_mock; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.higher_education_mock (
    id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    name text,
    state text,
    county text,
    city text,
    street text,
    zip text,
    longitude double precision,
    latitude double precision,
    control smallint
);


ALTER TABLE public.higher_education_mock OWNER TO postgres;

--
-- Name: TABLE higher_education_mock; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.higher_education_mock IS 'This is a duplicate of ipeds_2022';


--
-- Name: higher_education_mock_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.higher_education_mock ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.higher_education_mock_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: ipeds_2022_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.ipeds_2022 ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.ipeds_2022_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: k12_districts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.k12_districts ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.k12_districts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: mock_all_institutions; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.mock_all_institutions AS
 SELECT ('higher_education_'::text || hem.id) AS unique_id,
    hem.id AS source_id,
    hem.name,
    hem.state,
    hem.county,
    hem.city,
    hem.street,
    ((hem.state || '-'::text) || hem.county) AS state_county,
    ((hem.state || '-'::text) || hem.city) AS state_city,
    NULL::double precision AS population,
    'higher_education'::text AS source_table,
    'Higher Education'::text AS label
   FROM public.ipeds_2022 hem
UNION ALL
 SELECT ('k12_'::text || k12.id) AS unique_id,
    k12.id AS source_id,
    k12.name,
    k12.state,
    k12.county,
    k12.city,
    k12.street,
    ((k12.state || '-'::text) || k12.county) AS state_county,
    ((k12.state || '-'::text) || k12.city) AS state_city,
    NULLIF(k12.enrollment_total_students, (0)::double precision) AS population,
    'k12_districts'::text AS source_table,
    'K12 District'::text AS label
   FROM public.k12_districts k12
UNION ALL
 SELECT ('city_'::text || cty.stcntycity_fips_code) AS unique_id,
    cty.stcntycity_fips_code AS source_id,
    cty.city_name AS name,
    cty.state,
    cty.county_name AS county,
    cty.city_name AS city,
    NULL::text AS street,
    (((cty.state)::text || '-'::text) || cty.county_name) AS state_county,
    (((cty.state)::text || '-'::text) || cty.city_name) AS state_city,
    NULLIF((cty.population)::double precision, (0)::double precision) AS population,
    'cities'::text AS source_table,
    'Municipality'::text AS label
   FROM public.all_geo_transportation cty
  WHERE (cty.stcntycity_fips_code IS NOT NULL)
UNION ALL
 SELECT ac.unique_id,
    ac.source_id,
    ac.name,
    ac.state,
    ac.county,
    ac.city,
    ac.street,
    ac.state_county,
    ac.state_city,
    ac.population,
    ac.source_table,
    'County'::text AS label
   FROM public.all_counties ac
  WHERE (ac.unique_id IS NOT NULL);


ALTER VIEW public.mock_all_institutions OWNER TO postgres;

--
-- Name: mock_dummy_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mock_dummy_data (
    "Region" text,
    "Country" text,
    "Item Type" text,
    "Sales Channel" text,
    "Order Priority" text,
    "Order Date" text,
    "Order ID" bigint,
    "Ship Date" text,
    "Units Sold" bigint,
    "Unit Price" double precision,
    "Unit Cost" double precision,
    "Total Revenue" double precision,
    "Total Cost" double precision,
    "Total Profit" double precision
);


ALTER TABLE public.mock_dummy_data OWNER TO postgres;

--
-- Name: state_agencies_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.state_agencies ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.state_agencies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: test_all_education_mock; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.test_all_education_mock AS
 SELECT ('higher_education_'::text || hem.id) AS unique_id,
    hem.id AS source_id,
    hem.name,
    hem.state,
    hem.county,
    hem.city,
    hem.street,
    ((hem.state || '-'::text) || hem.county) AS state_county,
    ((hem.state || '-'::text) || hem.city) AS state_city,
    NULL::double precision AS enrollment_total_students,
    'higher_education_mock'::text AS source_table
   FROM public.higher_education_mock hem
UNION ALL
 SELECT ('k12_'::text || k12.id) AS unique_id,
    k12.id AS source_id,
    k12.name,
    k12.state,
    k12.county,
    k12.city,
    k12.street,
    ((k12.state || '-'::text) || k12.county) AS state_county,
    ((k12.state || '-'::text) || k12.city) AS state_city,
    k12.enrollment_total_students,
    'k12_districts_mock'::text AS source_table
   FROM public.k12_districts k12;


ALTER VIEW public.test_all_education_mock OWNER TO postgres;

--
-- Name: all_geo_transportation all_geo_duplicate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.all_geo_transportation
    ADD CONSTRAINT all_geo_duplicate_pkey PRIMARY KEY (id);


--
-- Name: all_geo_census all_geo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.all_geo_census
    ADD CONSTRAINT all_geo_pkey PRIMARY KEY (id);


--
-- Name: all_institutions_metadata all_institutions_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.all_institutions_metadata
    ADD CONSTRAINT all_institutions_metadata_pkey PRIMARY KEY (unique_id);


--
-- Name: higher_education_mock higher_education_mock_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.higher_education_mock
    ADD CONSTRAINT higher_education_mock_pkey PRIMARY KEY (id);


--
-- Name: individual_units individual_units_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.individual_units
    ADD CONSTRAINT individual_units_pkey PRIMARY KEY (new_individual_unit_id);


--
-- Name: ipeds_2022 ipeds_2022_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ipeds_2022
    ADD CONSTRAINT ipeds_2022_pkey PRIMARY KEY (id);


--
-- Name: k12_districts k12_districts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.k12_districts
    ADD CONSTRAINT k12_districts_pkey PRIMARY KEY (id);


--
-- Name: state_agencies state_agencies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.state_agencies
    ADD CONSTRAINT state_agencies_pkey PRIMARY KEY (name, url, state, id);


--
-- Name: states states_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT states_pkey PRIMARY KEY (name, state);


--
-- Name: higher_education_mock Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON public.higher_education_mock FOR INSERT TO authenticated WITH CHECK (true);


--
-- Name: ipeds_2022 Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON public.ipeds_2022 FOR INSERT TO authenticated WITH CHECK (true);


--
-- Name: k12_districts Enable insert for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users only" ON public.k12_districts FOR INSERT TO authenticated WITH CHECK (true);


--
-- Name: higher_education_mock Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.higher_education_mock FOR SELECT USING (true);


--
-- Name: ipeds_2022 Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.ipeds_2022 FOR SELECT USING (true);


--
-- Name: k12_districts Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.k12_districts FOR SELECT USING (true);


--
-- Name: all_geo_census; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.all_geo_census ENABLE ROW LEVEL SECURITY;

--
-- Name: all_geo_transportation; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.all_geo_transportation ENABLE ROW LEVEL SECURITY;

--
-- Name: all_institutions_metadata; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.all_institutions_metadata ENABLE ROW LEVEL SECURITY;

--
-- Name: higher_education_mock; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.higher_education_mock ENABLE ROW LEVEL SECURITY;

--
-- Name: ipeds_2022; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ipeds_2022 ENABLE ROW LEVEL SECURITY;

--
-- Name: k12_districts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.k12_districts ENABLE ROW LEVEL SECURITY;

--
-- Name: mock_dummy_data; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.mock_dummy_data ENABLE ROW LEVEL SECURITY;

--
-- Name: state_agencies; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.state_agencies ENABLE ROW LEVEL SECURITY;

--
-- Name: states; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.states ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

