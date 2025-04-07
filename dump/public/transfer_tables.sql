CREATE TABLE app.cells (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	custom_column_id uuid NULL,
	job_id uuid NULL,
	prev_job_id uuid NULL,
	institution_id text NULL,
	"content" jsonb NULL,
	institution_name text NULL,
	prev_content jsonb NULL,
	updated_at timestamptz DEFAULT now() NULL
);

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
	updated_at timestamp NULL,
	column_name text NULL,
	keywords jsonb NULL,
	start_date date NULL,
	end_date date NULL
);

CREATE TABLE app.enrichments (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	user_email text NOT NULL,
	"type" app."Enrichment Type" NOT NULL,
	status app."Enrichment Status" NULL,
	created_at timestamp DEFAULT now() NOT NULL,
	updated_at timestamp DEFAULT now() NULL,
	request_text text NULL,
	"result" text NULL,
	institution_id text NOT NULL,
	workspace_id uuid NOT NULL
);


-- former job table. must be renamed to "tasks"
CREATE TABLE app.job (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	completed_at timestamp NULL,
	response_payload json NULL,
	custom_cell_id uuid NULL
);

CREATE TABLE app.user (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	auth0_id text NOT NULL,
	email text NULL,
	first_name text NULL,
	last_name text NULL,
	created_at timestamptz NULL,
	"domain" text NULL
);


CREATE TABLE app.workspace_institution (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	workspace_id uuid NULL,
	institution_id text NOT NULL,
	created_at timestamptz DEFAULT now() NULL
);


CREATE TABLE app.workspace (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	created_at timestamp NOT NULL,
	is_starred bool DEFAULT false NULL,
	updated_at timestamp NULL,
	"name" text NULL,
	user_id text NULL,
	payload jsonb NOT NULL,
	ui_metadata jsonb NULL
);


CREATE TABLE app.notes (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	"content" jsonb NULL,
	institution_id text NOT NULL,
	custom_column_id uuid NOT NULL,
	updated_at timestamptz DEFAULT now() NULL
);


CREATE TABLE app.starred_insights (
	created_at timestamptz DEFAULT now() NOT NULL,
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	institution_id text NOT NULL,
	"content" jsonb NULL,
	workspace_id uuid NULL,
	"type" text NULL,
	column_id uuid NULL,
	cell_id uuid NULL,
);

