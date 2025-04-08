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
