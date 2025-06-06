- Foreign Key Constraints for app schema
-- This file contains all foreign key relationships between tables

-- Cells table constraints
ALTER TABLE app.cells
    ADD CONSTRAINT cells_custom_column_id_fkey 
    FOREIGN KEY (custom_column_id) 
    REFERENCES app.custom_columns(id) 
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE app.cells
    ADD CONSTRAINT cells_institution_id_fkey 
    FOREIGN KEY (institution_id) 
    REFERENCES app.institutions(unique_id) 
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Custom columns table constraints
ALTER TABLE app.custom_columns
    ADD CONSTRAINT custom_columns_workspace_id_fkey 
    FOREIGN KEY (workspace_id) 
    REFERENCES app.workspaces(id) 
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Enrichments table constraints
ALTER TABLE app.enrichments
    ADD CONSTRAINT enrichments_workspace_id_fkey 
    FOREIGN KEY (workspace_id) 
    REFERENCES app.workspaces(id) 
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE app.enrichments
    ADD CONSTRAINT enrichments_institution_id_fkey 
    FOREIGN KEY (institution_id) 
    REFERENCES app.institutions(unique_id) 
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Tasks table constraints
ALTER TABLE app.tasks
    ADD CONSTRAINT tasks_custom_cell_id_fkey 
    FOREIGN KEY (custom_cell_id) 
    REFERENCES app.cells(id) 
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Workspace institutions table constraints
ALTER TABLE app.workspace_institutions
    ADD CONSTRAINT workspace_institutions_workspace_id_fkey 
    FOREIGN KEY (workspace_id) 
    REFERENCES app.workspaces(id) 
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE app.workspace_institutions
    ADD CONSTRAINT workspace_institutions_institution_id_fkey 
    FOREIGN KEY (institution_id) 
    REFERENCES app.institutions(unique_id) 
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Notes table constraints
ALTER TABLE app.notes
    ADD CONSTRAINT notes_custom_column_id_fkey 
    FOREIGN KEY (custom_column_id) 
    REFERENCES app.custom_columns(id) 
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Starred insights table constraints
ALTER TABLE app.starred_insights
    ADD CONSTRAINT starred_insights_column_id_fkey 
    FOREIGN KEY (column_id) 
    REFERENCES app.custom_columns(id) 
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE app.starred_insights
    ADD CONSTRAINT starred_insights_cell_id_fkey 
    FOREIGN KEY (cell_id) 
    REFERENCES app.cells(id) 
    ON DELETE CASCADE ON UPDATE CASCADE;

-- Tags table constraints
ALTER TABLE app.tags
    ADD CONSTRAINT tags_custom_column_id_fkey 
    FOREIGN KEY (custom_column_id) 
    REFERENCES app.custom_columns(id) 
    ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE app.tags ENABLE ROW LEVEL SECURITY;



CREATE INDEX IF NOT EXISTS idx_purchase_orders_deduped_vendor_mod on purchase_orders using btree (
  ((deduped_vendor_id % (100)::bigint)),
  deduped_vendor_id
)
where
  (deduped_vendor_id is not null);

create index IF not exists idx_purchase_orders_entity_name on app.purchase_orders using btree (entity_name);

create index IF not exists idx_purchase_orders_total_amount on app.purchase_orders using btree (total_amount);

create index IF not exists idx_purchase_orders_po_date on app.purchase_orders using btree (po_date);

create index IF not exists idx_purchase_orders_entity_id on app.purchase_orders using btree (entity_id);

create index IF not exists idx_purchase_orders_input_file on app.purchase_orders using btree (input_file);

create index IF not exists idx_purchase_orders_supplier_name on app.purchase_orders using btree (supplier_name);

create index IF not exists idx_purchase_orders_deduped_vendor_id on app.purchase_orders using hash (deduped_vendor_id);

create index IF not exists idx_purchase_orders_item_description_trgm on app.purchase_orders using gin (item_description gin_trgm_ops);

create index IF not exists purchase_orders_supplier_name_trgm_idx on app.purchase_orders using gin (supplier_name gin_trgm_ops);
