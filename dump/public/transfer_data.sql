-- Data Transfer Script: public.mock_custom_cell to app.cells
-- This script transforms and loads data from the old table structure to the new one

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
