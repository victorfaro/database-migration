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

-- Data Transfer Script: public.mock_workspaces to app.workspaces
-- This script transforms and loads data from the old table structure to the new one

TRUNCATE TABLE app.workspaces;
-- Insert data from public.mock_workspaces to app.workspaces
-- Only insert rows where user_id is not null (required in target schema)
INSERT INTO app.workspaces (
    id,
    created_at,
    is_starred,
    modified_at,      -- Maps from updated_at
    "name",
    user_id,
    payload,
    ui_metadata,
    is_deleted,       -- New field with default false
    deleted_at        -- New field defaulting to now() when needed
)
SELECT 
    id,
    created_at,
    is_starred,
    updated_at AS modified_at,
    "name",
    user_id,
    payload,
    ui_metadata,
    false,           -- Set is_deleted to false for all migrated records
    NULL             -- Set deleted_at to NULL for non-deleted records
FROM 
    public.mock_workspaces
WHERE 
    user_id IS NOT NULL;  -- Filter out rows with NULL user_id as it's required in target

-- Log the number of rows transferred
DO $$
DECLARE
    row_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM app.workspaces;
    RAISE NOTICE 'Transferred % rows from public.mock_workspaces to app.workspaces', row_count;
END $$;

-- Data Transfer Script: public.mock_user to app.user
-- This script transforms and loads data from the old table structure to the new one

TRUNCATE TABLE app.user;
-- Insert data from public.mock_user to app.user
INSERT INTO app.user (
    id,
    auth0_id,
    email,
    first_name,
    last_name,
    created_at,
    "domain"
)
SELECT 
    id,
    auth0_id,
    email,
    first_name,
    last_name,
    created_at,
    "domain"
FROM 
    public.mock_user;

-- Log the number of rows transferred
DO $$
DECLARE
    row_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM app.user;
    RAISE NOTICE 'Transferred % rows from public.mock_user to app.user', row_count;
END $$;

-- Data Transfer Script: public.starred_insights to app.starred_insights
-- This script transforms and loads data from the old table structure to the new one

TRUNCATE TABLE app.starred_insights;
-- Insert data from public.starred_insights to app.starred_insights
INSERT INTO app.starred_insights (
    created_at,
    id,
    institution_id,    -- NOT NULL in source, nullable in target
    "content",
    workspace_id,
    "type",
    column_id,
    cell_id
)
SELECT 
    created_at,
    id,
    institution_id,
    "content",
    workspace_id,
    "type",
    column_id,
    cell_id
FROM 
    public.starred_insights;

-- Log the number of rows transferred
DO $$
DECLARE
    row_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM app.starred_insights;
    RAISE NOTICE 'Transferred % rows from public.starred_insights to app.starred_insights', row_count;
END $$;

-- Data Transfer Script: public.notes to app.notes
-- This script transforms and loads data from the old table structure to the new one

TRUNCATE TABLE app.notes;
-- Insert data from public.notes to app.notes
INSERT INTO app.notes (
    id,
    created_at,
    "content",
    institution_id,
    custom_column_id,
    modified_at        -- Maps from updated_at
)
SELECT 
    id,
    created_at,
    "content",
    institution_id,
    custom_column_id,
    updated_at AS modified_at
FROM 
    public.notes;

-- Log the number of rows transferred
DO $$
DECLARE
    row_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM app.notes;
    RAISE NOTICE 'Transferred % rows from public.notes to app.notes', row_count;
END $$;

-- Data Transfer Script: public.tags to app.tags
-- This script transforms and loads data from the old table structure to the new one

TRUNCATE TABLE app.tags;
-- Insert data from public.tags to app.tags
INSERT INTO app.tags (
    id,
    created_at,
    hexcode,          -- New field, will be NULL
    label,            -- New field, will be NULL
    user_id,          -- New field, required in target
    institution_id,
    custom_column_id, -- NOT NULL in source, nullable in target
    "content"
)
SELECT 
    id,
    created_at,
    NULL AS hexcode,
    NULL AS label,
    'system' AS user_id,  -- Set a default value for required field
    institution_id,
    custom_column_id,
    "content"
FROM 
    public.tags;

-- Log the number of rows transferred
DO $$
DECLARE
    row_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO row_count FROM app.tags;
    RAISE NOTICE 'Transferred % rows from public.tags to app.tags', row_count;
END $$;
