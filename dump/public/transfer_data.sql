-- Data Transfer Script: public.mock_custom_cell to app.cells
-- This script transforms and loads data from the old table structure to the new one
TRUNCATE TABLE app.cells;
-- Insert data from public.mock_custom_cell to app.cells
INSERT INTO app.cells (
    id,
    created_at,
    custom_column_id,
    task_id,           -- Maps from job_id
    prev_task_id,      -- Maps from prev_job_id
    institution_id,
    content,
    prev_content,
    modified_at        -- Maps from updated_at
)
SELECT 
    id,
    created_at,
    custom_column_id,
    job_id AS task_id,
    prev_job_id AS prev_task_id,
    institution_id,
    content,
    prev_content,
    updated_at AS modified_at
FROM 
    public.mock_custom_cell;

-- Log the number of rows transferred
DO $$
DECLARE
    row_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM app.cells;
    RAISE NOTICE 'Transferred % rows from public.mock_custom_cell to app.cells', row_count;
END $$;

-- Data Transfer Script: public.mock_custom_columns to app.custom_columns
-- This script transforms and loads data from the old table structure to the new one

TRUNCATE TABLE app.custom_columns;
-- Insert data from public.mock_custom_columns to app.custom_columns
INSERT INTO app.custom_columns (
    id,
    created_at,
    workspace_id,
    column_type,
    data_source,
    rerun_frequency,
    description,
    keyword_config,
    output_format,
    modified_at,       -- Maps from updated_at
    column_name,
    keywords,
    start_date,
    end_date
)
SELECT 
    id,
    created_at,
    workspace_id,
    column_type::text::app."Custom Column Types",  -- Convert through text
    data_source::text::app."Data Source",          -- Convert through text
    rerun_frequency::text::app."Rerun Frequency",  -- Convert through text
    description,
    keyword_config,
    output_format::text::app."Output Format",      -- Convert through text
    updated_at AS modified_at,
    column_name,
    keywords,
    start_date,
    end_date
FROM 
    public.mock_custom_columns;

-- Log the number of rows transferred
DO $$
DECLARE
    row_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM app.custom_columns;
    RAISE NOTICE 'Transferred % rows from public.mock_custom_columns to app.custom_columns', row_count;
END $$;

-- Data Transfer Script: public.mock_job to app.tasks
-- This script transforms and loads data from the old table structure to the new one

TRUNCATE TABLE app.tasks;
-- Insert data from public.mock_job to app.tasks
-- Only insert rows where custom_cell_id is not null
INSERT INTO app.tasks (
    id,
    created_at,
    completed_at,
    response_payload,
    custom_cell_id
)
SELECT 
    id,
    created_at,
    completed_at,
    response_payload,
    custom_cell_id
FROM 
    public.mock_job
WHERE 
    custom_cell_id IS NOT NULL;  -- Filter out rows with NULL custom_cell_id

-- Log the number of rows transferred
DO $$
DECLARE
    row_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM app.tasks;
    RAISE NOTICE 'Transferred % rows from public.mock_job to app.tasks', row_count;
END $$;

-- Data Transfer Script: public.mock_workbook_institution to app.workspace_institutions
-- This script transforms and loads data from the old table structure to the new one

TRUNCATE TABLE app.workspace_institutions;
-- Insert data from public.mock_workbook_institution to app.workspace_institutions
-- Only insert rows where workspace_id is not null (required in target schema)
INSERT INTO app.workspace_institutions (
    id,
    workspace_id,
    institution_id,
    created_at,
    is_deleted,        -- New field with default false
    deleted_at         -- New field defaulting to now() when needed
)
SELECT 
    id,
    workspace_id,
    institution_id,
    COALESCE(created_at, now()),  -- Handle NULL created_at values
    false,                        -- Set is_deleted to false for all migrated records
    NULL                         -- Set deleted_at to NULL for non-deleted records
FROM 
    public.mock_workbook_institution
WHERE 
    workspace_id IS NOT NULL;     -- Filter out rows with NULL workspace_id as it's required in target

-- Log the number of rows transferred
DO $$
DECLARE
    row_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM app.workspace_institutions;
    RAISE NOTICE 'Transferred % rows from public.mock_workbook_institution to app.workspace_institutions', row_count;
END $$;

-- Data Transfer Script: public.mock_enrichment to app.enrichments
-- This script transforms and loads data from the old table structure to the new one

TRUNCATE TABLE app.enrichments;
-- Insert data from public.mock_enrichment to app.enrichments
INSERT INTO app.enrichments (
    id,
    user_email,
    "type",            -- Need to convert from public."Enrichment Type" to app."Enrichment Type"
    status,            -- Need to convert from public."Enrichment Status" to app."Enrichment Status"
    created_at,
    modified_at,       -- Maps from updated_at
    request_text,
    "result",
    institution_id,    -- Now nullable in target
    workspace_id       -- Now nullable in target
)
SELECT 
    id,
    user_email,
    "type"::text::app."Enrichment Type",      -- Convert through text
    status::text::app."Enrichment Status",    -- Convert through text
    created_at,
    updated_at AS modified_at,
    request_text,
    "result",
    institution_id,
    workspace_id
FROM 
    public.mock_enrichment;

-- Log the number of rows transferred
DO $$
DECLARE
    row_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM app.enrichments;
    RAISE NOTICE 'Transferred % rows from public.mock_enrichment to app.enrichments', row_count;
END $$;
