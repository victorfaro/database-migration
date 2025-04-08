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
	CONSTRAINT cells_pkey PRIMARY KEY (id),
	CONSTRAINT cells_custom_column_id_fkey FOREIGN KEY (custom_column_id) REFERENCES app.custom_columns(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT cells_institution_id_fkey FOREIGN KEY (institution_id) REFERENCES app.institutions(unique_id) ON DELETE CASCADE ON UPDATE CASCADE
) PARTITION BY RANGE (institution_id);

-- Create partitions for ranges of institution_id values
-- Each partition covers a range of 10,000 values
CREATE TABLE app.cells_range_0_10k PARTITION OF app.cells FOR VALUES FROM ('0') TO ('10000');
CREATE TABLE app.cells_range_10k_20k PARTITION OF app.cells FOR VALUES FROM ('10000') TO ('20000');
CREATE TABLE app.cells_range_20k_30k PARTITION OF app.cells FOR VALUES FROM ('20000') TO ('30000');
CREATE TABLE app.cells_range_30k_40k PARTITION OF app.cells FOR VALUES FROM ('30000') TO ('40000');
CREATE TABLE app.cells_range_40k_50k PARTITION OF app.cells FOR VALUES FROM ('40000') TO ('50000');
CREATE TABLE app.cells_range_50k_60k PARTITION OF app.cells FOR VALUES FROM ('50000') TO ('60000');
CREATE TABLE app.cells_range_60k_70k PARTITION OF app.cells FOR VALUES FROM ('60000') TO ('70000');
CREATE TABLE app.cells_range_70k_80k PARTITION OF app.cells FOR VALUES FROM ('70000') TO ('80000');
CREATE TABLE app.cells_range_80k_90k PARTITION OF app.cells FOR VALUES FROM ('80000') TO ('90000');
CREATE TABLE app.cells_range_90k_100k PARTITION OF app.cells FOR VALUES FROM ('90000') TO ('100000');
CREATE TABLE app.cells_range_100k_110k PARTITION OF app.cells FOR VALUES FROM ('100000') TO ('110000');
CREATE TABLE app.cells_range_110k_120k PARTITION OF app.cells FOR VALUES FROM ('110000') TO ('120000');
CREATE TABLE app.cells_range_120k_130k PARTITION OF app.cells FOR VALUES FROM ('120000') TO ('130000');
CREATE TABLE app.cells_range_130k_140k PARTITION OF app.cells FOR VALUES FROM ('130000') TO ('140000');
CREATE TABLE app.cells_range_140k_150k PARTITION OF app.cells FOR VALUES FROM ('140000') TO ('150000');
CREATE TABLE app.cells_range_150k_160k PARTITION OF app.cells FOR VALUES FROM ('150000') TO ('160000');
CREATE TABLE app.cells_range_160k_170k PARTITION OF app.cells FOR VALUES FROM ('160000') TO ('170000');
CREATE TABLE app.cells_range_170k_180k PARTITION OF app.cells FOR VALUES FROM ('170000') TO ('180000');
CREATE TABLE app.cells_range_180k_190k PARTITION OF app.cells FOR VALUES FROM ('180000') TO ('190000');
CREATE TABLE app.cells_range_190k_200k PARTITION OF app.cells FOR VALUES FROM ('190000') TO ('200000');
CREATE TABLE app.cells_range_200k_210k PARTITION OF app.cells FOR VALUES FROM ('200000') TO ('210000');
CREATE TABLE app.cells_range_210k_220k PARTITION OF app.cells FOR VALUES FROM ('210000') TO ('220000');
CREATE TABLE app.cells_range_220k_230k PARTITION OF app.cells FOR VALUES FROM ('220000') TO ('230000');
CREATE TABLE app.cells_range_230k_240k PARTITION OF app.cells FOR VALUES FROM ('230000') TO ('240000');
CREATE TABLE app.cells_range_240k_250k PARTITION OF app.cells FOR VALUES FROM ('240000') TO ('250000');
CREATE TABLE app.cells_range_250k_260k PARTITION OF app.cells FOR VALUES FROM ('250000') TO ('260000');
CREATE TABLE app.cells_range_260k_270k PARTITION OF app.cells FOR VALUES FROM ('260000') TO ('270000');
CREATE TABLE app.cells_range_270k_280k PARTITION OF app.cells FOR VALUES FROM ('270000') TO ('280000');
CREATE TABLE app.cells_range_280k_290k PARTITION OF app.cells FOR VALUES FROM ('280000') TO ('290000');
CREATE TABLE app.cells_range_290k_300k PARTITION OF app.cells FOR VALUES FROM ('290000') TO ('300000');
CREATE TABLE app.cells_default PARTITION OF app.cells DEFAULT;

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
	CONSTRAINT custom_columns_pkey PRIMARY KEY (id),
	CONSTRAINT custom_columns_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES app.workspace(id) ON DELETE CASCADE ON UPDATE CASCADE
) PARTITION BY HASH (id);

-- Create 8 partitions for the custom_columns table
-- This will distribute data evenly across partitions based on a hash of the id
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
	CONSTRAINT enrichments_pkey PRIMARY KEY (id),
	CONSTRAINT enrichments_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES app.workspace(id) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE app.tasks (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	completed_at timestamp NULL,
	response_payload json NULL,
	custom_cell_id uuid NOT NULL,
	CONSTRAINT tasks_pkey PRIMARY KEY (id),
	CONSTRAINT tasks_custom_cell_id_fkey FOREIGN KEY (custom_cell_id) REFERENCES app.cells(id) ON DELETE CASCADE ON UPDATE CASCADE
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


CREATE TABLE app.workspace_institutions (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	workspace_id uuid NOT NULL,
	institution_id text NOT NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	is_deleted boolean DEFAULT false NOT NULL,
	deleted_at timestamptz DEFAULT now() NULL,
	CONSTRAINT workspace_institutions_pkey PRIMARY KEY (id),
	CONSTRAINT workspace_institutions_workspace_id_institution_id_key UNIQUE (workspace_id, institution_id),
	CONSTRAINT workspace_institutions_workspace_id_fkey FOREIGN KEY (workspace_id) REFERENCES app.workspaces(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT workspace_institutions_institution_id_fkey FOREIGN KEY (institution_id) REFERENCES app.institutions(unique_id) ON DELETE CASCADE ON UPDATE CASCADE
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
) ;


CREATE TABLE app.notes (
	id uuid DEFAULT gen_random_uuid() NOT NULL,
	created_at timestamptz DEFAULT now() NOT NULL,
	"content" jsonb NULL,
	institution_id text NOT NULL,
	custom_column_id uuid NOT NULL,
	modified_at timestamptz DEFAULT now() NULL,
	CONSTRAINT notes_pkey PRIMARY KEY (id),
	CONSTRAINT notes_custom_column_id_fkey FOREIGN KEY (custom_column_id) REFERENCES app.custom_columns(id) ON DELETE CASCADE ON UPDATE CASCADE
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
	CONSTRAINT starred_insights_pkey PRIMARY KEY (id),
	CONSTRAINT starred_insights_column_id_fkey FOREIGN KEY (column_id) REFERENCES app.custom_columns(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT starred_insights_cell_id_fkey FOREIGN KEY (cell_id) REFERENCES app.cells(id) ON DELETE CASCADE ON UPDATE CASCADE
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
	CONSTRAINT tags_pkey PRIMARY KEY (id),
	CONSTRAINT tags_custom_column_id_fkey FOREIGN KEY (custom_column_id) REFERENCES app.custom_columns(id) ON DELETE CASCADE ON UPDATE CASCADE
);

