--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: mock_custom_cell; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mock_custom_cell (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    custom_column_id uuid,
    job_id uuid,
    prev_job_id uuid,
    institution_id text,
    content jsonb,
    institution_name text,
    prev_content jsonb,
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.mock_custom_cell OWNER TO postgres;

--
-- Name: mock_custom_columns; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mock_custom_columns (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    workspace_id uuid,
    column_type public."Custom Column Types",
    data_source public."Data Source",
    rerun_frequency public."Rerun Frequency",
    description text,
    keyword_config jsonb,
    output_format public."Output Format",
    updated_at timestamp without time zone,
    column_name text,
    keywords jsonb,
    start_date date,
    end_date date
);


ALTER TABLE public.mock_custom_columns OWNER TO postgres;

--
-- Name: mock_job; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mock_job (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp without time zone,
    response_payload json,
    custom_cell_id uuid
);


ALTER TABLE public.mock_job OWNER TO postgres;

--
-- Name: mock_workbook_institution; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mock_workbook_institution (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    workspace_id uuid,
    institution_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE public.mock_workbook_institution OWNER TO postgres;

--
-- Name: mock_enrichment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mock_enrichment (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_email text NOT NULL,
    type public."Enrichment Type" NOT NULL,
    status public."Enrichment Status",
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now(),
    request_text text,
    result text,
    institution_id text NOT NULL,
    workspace_id uuid NOT NULL
);


ALTER TABLE public.mock_enrichment OWNER TO postgres;

--
-- Name: mock_user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mock_user (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    auth0_id text NOT NULL,
    email text,
    first_name text,
    last_name text,
    created_at timestamp with time zone,
    domain text
);


ALTER TABLE public.mock_user OWNER TO postgres;

--
-- Name: mock_workspaces; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mock_workspaces (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp without time zone NOT NULL,
    is_starred boolean DEFAULT false,
    updated_at timestamp without time zone,
    name text,
    user_id text,
    payload jsonb NOT NULL,
    ui_metadata jsonb
);


ALTER TABLE public.mock_workspaces OWNER TO postgres;

--
-- Name: mock_custom_cell mock_custom_cell_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mock_custom_cell
    ADD CONSTRAINT mock_custom_cell_pkey PRIMARY KEY (id);


--
-- Name: mock_custom_columns mock_custom_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mock_custom_columns
    ADD CONSTRAINT mock_custom_columns_pkey PRIMARY KEY (id);


--
-- Name: mock_enrichment mock_enrichment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mock_enrichment
    ADD CONSTRAINT mock_enrichment_pkey PRIMARY KEY (id);


--
-- Name: mock_job mock_job_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mock_job
    ADD CONSTRAINT mock_job_pkey PRIMARY KEY (id);


--
-- Name: mock_user mock_user_auth0_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mock_user
    ADD CONSTRAINT mock_user_auth0_id_key UNIQUE (auth0_id);


--
-- Name: mock_user mock_user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mock_user
    ADD CONSTRAINT mock_user_pkey PRIMARY KEY (id);


--
-- Name: mock_workbook_institution mock_workbook_institution_pkey1; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mock_workbook_institution
    ADD CONSTRAINT mock_workbook_institution_pkey1 PRIMARY KEY (id);


--
-- Name: mock_workbook_institution mock_workbook_institution_workspace_id_institution_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mock_workbook_institution
    ADD CONSTRAINT mock_workbook_institution_workspace_id_institution_id_key UNIQUE (workspace_id, institution_id);


--
-- Name: mock_workspaces mock_workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mock_workspaces
    ADD CONSTRAINT mock_workspaces_pkey PRIMARY KEY (id);


--
-- Name: idx_custom_columns_workspace; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_custom_columns_workspace ON public.mock_custom_columns USING btree (workspace_id, column_type);


--
-- Name: idx_mock_workspaces_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mock_workspaces_user_id ON public.mock_workspaces USING btree (user_id);


--
-- Name: mock_custom_cell mock_custom_cell_custom_column_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mock_custom_cell
    ADD CONSTRAINT mock_custom_cell_custom_column_id_fkey FOREIGN KEY (custom_column_id) REFERENCES public.mock_custom_columns(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mock_custom_columns mock_custom_columns_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mock_custom_columns
    ADD CONSTRAINT mock_custom_columns_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.mock_workspaces(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mock_enrichment mock_enrichment_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mock_enrichment
    ADD CONSTRAINT mock_enrichment_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.mock_workspaces(id);


--
-- Name: mock_job mock_job_custom_cell_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mock_job
    ADD CONSTRAINT mock_job_custom_cell_id_fkey FOREIGN KEY (custom_cell_id) REFERENCES public.mock_custom_cell(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mock_workbook_institution mock_workbook_institution_workspace_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mock_workbook_institution
    ADD CONSTRAINT mock_workbook_institution_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES public.mock_workspaces(id) ON DELETE CASCADE;


--
-- Name: mock_workspaces mock_workspaces_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mock_workspaces
    ADD CONSTRAINT mock_workspaces_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.mock_user(auth0_id);


--
-- Name: mock_user Enable insert for authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable insert for authenticated users" ON public.mock_user FOR INSERT WITH CHECK (true);


--
-- Name: mock_user Enable read access for all users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for all users" ON public.mock_user FOR SELECT USING (true);


--
-- Name: mock_user Enable update for authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable update for authenticated users" ON public.mock_user FOR UPDATE USING (true);


--
-- Name: mock_custom_cell; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.mock_custom_cell ENABLE ROW LEVEL SECURITY;

--
-- Name: mock_custom_columns; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.mock_custom_columns ENABLE ROW LEVEL SECURITY;

--
-- Name: mock_enrichment; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.mock_enrichment ENABLE ROW LEVEL SECURITY;

--
-- Name: mock_job; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.mock_job ENABLE ROW LEVEL SECURITY;

--
-- Name: mock_user; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.mock_user ENABLE ROW LEVEL SECURITY;

--
-- Name: mock_workbook_institution; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.mock_workbook_institution ENABLE ROW LEVEL SECURITY;

--
-- Name: mock_workspaces; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.mock_workspaces ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

