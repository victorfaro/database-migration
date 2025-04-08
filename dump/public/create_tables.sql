-- Drop all tables if they exist to ensure a clean slate
DROP TABLE IF EXISTS app.cells CASCADE;
DROP TABLE IF EXISTS app.custom_columns CASCADE;
DROP TABLE IF EXISTS app.enrichments CASCADE;
DROP TABLE IF EXISTS app.tasks CASCADE;
DROP TABLE IF EXISTS app.user CASCADE;
DROP TABLE IF EXISTS app.workspace_institutions CASCADE;
DROP TABLE IF EXISTS app.workspaces CASCADE;
DROP TABLE IF EXISTS app.notes CASCADE;
DROP TABLE IF EXISTS app.starred_insights CASCADE;
DROP TABLE IF EXISTS app.tags CASCADE;

-- Create the cells table with HASH partitioning
CREATE TABLE app.cells (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	custom_column_id uuid NULL,
	task_id uuid NULL,
	prev_task_id uuid NULL,
	institution_id text NULL,
	"content" jsonb NULL,
	prev_content jsonb NULL,
	modified_at timestamptz DEFAULT now() NULL,
	CONSTRAINT cells_pkey PRIMARY KEY (id, institution_id)
) PARTITION BY HASH (institution_id);

-- Create 8 partitions for the cells table
CREATE TABLE app.cells_p0 PARTITION OF app.cells FOR VALUES WITH (MODULUS 8, REMAINDER 0);
CREATE TABLE app.cells_p1 PARTITION OF app.cells FOR VALUES WITH (MODULUS 8, REMAINDER 1);
CREATE TABLE app.cells_p2 PARTITION OF app.cells FOR VALUES WITH (MODULUS 8, REMAINDER 2);
CREATE TABLE app.cells_p3 PARTITION OF app.cells FOR VALUES WITH (MODULUS 8, REMAINDER 3);
CREATE TABLE app.cells_p4 PARTITION OF app.cells FOR VALUES WITH (MODULUS 8, REMAINDER 4);
CREATE TABLE app.cells_p5 PARTITION OF app.cells FOR VALUES WITH (MODULUS 8, REMAINDER 5);
CREATE TABLE app.cells_p6 PARTITION OF app.cells FOR VALUES WITH (MODULUS 8, REMAINDER 6);
CREATE TABLE app.cells_p7 PARTITION OF app.cells FOR VALUES WITH (MODULUS 8, REMAINDER 7);

CREATE TABLE app.custom_columns (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	workspace_id uuid NULL,
	column_type app."Custom Column Types" NULL,
	data_source app."Data Source" NULL,
	rerun_frequency app."Rerun Frequency" NULL,
	description text NULL,
	keyword_config jsonb NULL,
	output_format app."Output Format" NULL,
	modified_at timestamp NULL,
	column_name text NULL,
	keywords jsonb NULL,
	start_date date NULL,
	end_date date NULL,
	CONSTRAINT custom_columns_pkey PRIMARY KEY (id, workspace_id)
) PARTITION BY HASH (workspace_id);

-- Create 8 partitions for the custom_columns table
-- This will distribute data evenly across partitions based on a hash of the workspace_id
CREATE TABLE app.custom_columns_p0 PARTITION OF app.custom_columns FOR VALUES WITH (MODULUS 8, REMAINDER 0);
CREATE TABLE app.custom_columns_p1 PARTITION OF app.custom_columns FOR VALUES WITH (MODULUS 8, REMAINDER 1);
CREATE TABLE app.custom_columns_p2 PARTITION OF app.custom_columns FOR VALUES WITH (MODULUS 8, REMAINDER 2);
CREATE TABLE app.custom_columns_p3 PARTITION OF app.custom_columns FOR VALUES WITH (MODULUS 8, REMAINDER 3);
CREATE TABLE app.custom_columns_p4 PARTITION OF app.custom_columns FOR VALUES WITH (MODULUS 8, REMAINDER 4);
CREATE TABLE app.custom_columns_p5 PARTITION OF app.custom_columns FOR VALUES WITH (MODULUS 8, REMAINDER 5);
CREATE TABLE app.custom_columns_p6 PARTITION OF app.custom_columns FOR VALUES WITH (MODULUS 8, REMAINDER 6);
CREATE TABLE app.custom_columns_p7 PARTITION OF app.custom_columns FOR VALUES WITH (MODULUS 8, REMAINDER 7);

CREATE TABLE app.enrichments (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	user_email text NOT NULL,
	"type" app."Enrichment Type" NULL,
	status app."Enrichment Status" NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	modified_at timestamp NULL,
	request_text text NULL,
	"result" text NULL,
	institution_id text NULL,
	workspace_id uuid NULL,
	CONSTRAINT enrichments_pkey PRIMARY KEY (id)
);

CREATE TABLE app.tasks (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	completed_at timestamp NULL,
	response_payload json NULL,
	custom_cell_id uuid NOT NULL,
	CONSTRAINT tasks_pkey PRIMARY KEY (id, custom_cell_id, created_at)
) PARTITION BY HASH (custom_cell_id);

CREATE TABLE app.user (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	auth0_id text NOT NULL,
	email text NULL,
	first_name text NULL,
	last_name text NULL,
	created_at timestamptz NULL,
	"domain" text NULL
);

CREATE TABLE app.workspace_institutions (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	workspace_id uuid NOT NULL,
	institution_id text NOT NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	is_deleted boolean DEFAULT false NOT NULL,
	deleted_at timestamptz DEFAULT now() NULL,
	CONSTRAINT workspace_institutions_pkey PRIMARY KEY (id, workspace_id),
	CONSTRAINT workspace_institutions_workspace_id_institution_id_key UNIQUE (workspace_id, institution_id)
) PARTITION BY HASH (workspace_id);

-- Create 8 partitions for the workspace_institutions table
-- This will distribute data evenly across partitions based on a hash of the workspace_id
CREATE TABLE app.workspace_institutions_p0 PARTITION OF app.workspace_institutions FOR VALUES WITH (MODULUS 8, REMAINDER 0);
CREATE TABLE app.workspace_institutions_p1 PARTITION OF app.workspace_institutions FOR VALUES WITH (MODULUS 8, REMAINDER 1);
CREATE TABLE app.workspace_institutions_p2 PARTITION OF app.workspace_institutions FOR VALUES WITH (MODULUS 8, REMAINDER 2);
CREATE TABLE app.workspace_institutions_p3 PARTITION OF app.workspace_institutions FOR VALUES WITH (MODULUS 8, REMAINDER 3);
CREATE TABLE app.workspace_institutions_p4 PARTITION OF app.workspace_institutions FOR VALUES WITH (MODULUS 8, REMAINDER 4);
CREATE TABLE app.workspace_institutions_p5 PARTITION OF app.workspace_institutions FOR VALUES WITH (MODULUS 8, REMAINDER 5);
CREATE TABLE app.workspace_institutions_p6 PARTITION OF app.workspace_institutions FOR VALUES WITH (MODULUS 8, REMAINDER 6);
CREATE TABLE app.workspace_institutions_p7 PARTITION OF app.workspace_institutions FOR VALUES WITH (MODULUS 8, REMAINDER 7);

CREATE TABLE app.workspaces (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	created_at timestamp NOT NULL,
	is_starred boolean DEFAULT false NULL,
	modified_at timestamp NULL,
	"name" text NULL,
	user_id text NOT NULL,
	payload jsonb NOT NULL,
	ui_metadata jsonb NULL,
	is_deleted boolean DEFAULT false NOT NULL,
	deleted_at timestamp DEFAULT now() NULL,
	CONSTRAINT workspaces_pkey PRIMARY KEY (id)
);

CREATE TABLE app.notes (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	"content" jsonb NULL,
	institution_id text NOT NULL,
	custom_column_id uuid NOT NULL,
	modified_at timestamptz DEFAULT now() NULL,
	CONSTRAINT notes_pkey PRIMARY KEY (id)
);

CREATE TABLE app.starred_insights (
	created_at timestamptz DEFAULT now() NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	institution_id text NULL,
	"content" jsonb NULL,
	workspace_id uuid NULL,
	"type" text NULL,
	column_id uuid NULL,
	cell_id uuid NULL,
	CONSTRAINT starred_insights_pkey PRIMARY KEY (id)
);

CREATE TABLE app.tags (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	hexcode text NULL,
	label text NULL,
	user_id text NOT NULL,
	institution_id text NULL,
	custom_column_id uuid NULL,
	"content" jsonb NULL,
	CONSTRAINT tags_pkey PRIMARY KEY (id)
);

