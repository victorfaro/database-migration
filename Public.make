include .env


export PO_SUPABASE_DBNAME
export PO_SUPABASE_USER
export PO_SUPABASE_PASSWORD
export PO_SUPABASE_HOST
export PO_SUPABASE_PORT
export PO_CONN_STRING
export PO_CONN_STRING=postgresql://$(PO_SUPABASE_USER):$(PO_SUPABASE_PASSWORD)@$(PO_SUPABASE_HOST):$(PO_SUPABASE_PORT)/$(PO_SUPABASE_DBNAME)

export RDS_PASSWORD
export RDS_USER
export RDS_HOST
export RDS_PORT
export RDS_DATABASE=dev
export RDS_CONN=postgresql://$(RDS_USER):$(RDS_PASSWORD)@$(RDS_HOST):$(RDS_PORT)/$(RDS_DATABASE)


.PHONY: pg_dump_schema_public_jobs
pg_dump_schema_public_jobs:
	@rm -rf ./dump/public/schema
	@PGPASSWORD=$(PO_SUPABASE_PASSWORD) pg_dump -h $(PO_SUPABASE_HOST) -U $(PO_SUPABASE_USER) -p $(PO_SUPABASE_PORT) -d $(PO_SUPABASE_DBNAME) \
		--schema-only \
		--no-acl \
		-j 3 \
		-F d \
		--no-owner \
		--schema public \
		--table mock_workpaces \
		--table mock_workbook_institutions \
		--table mock_custom_cell \
		--table mock_custom_columns \
		--table mock_enrichement \
		--table mock_job \
		--table mock_user \
		--table notes \
		--table tags \
		-f ./dump/public/schema


.PHONY: pg_dump_data_public_jobs
pg_dump_data_public_jobs:
	@rm -rf ./dump/public/data
	@PGPASSWORD=$(PO_SUPABASE_PASSWORD) pg_dump -h $(PO_SUPABASE_HOST) -U $(PO_SUPABASE_USER) -p $(PO_SUPABASE_PORT) -d $(PO_SUPABASE_DBNAME) \
		--data-only \
		--no-acl \
		-j 3 \
		-F d \
		--no-owner \
		--schema public \
		--table mock_workpaces \
		--table mock_workbook_institutions \
		--table mock_custom_cell \
		--table mock_custom_columns \
		--table mock_enrichement \
		--table mock_job \
		--table mock_user \
		--table notes \
		--table tags \
		-f ./dump/public/data


.PHONY: pg_restore_schema_public_jobs
pg_restore_schema_public_jobs:
	PGPASSWORD=$(RDS_PASSWORD) pg_restore -h $(RDS_HOST) -p $(RDS_PORT) -U $(RDS_USER) -d $(RDS_DATABASE) \
		--disable-triggers \
		--if-exists \
		--clean \
		-j 3 \
		-F d \
		--use-set-session-authorization \
		--no-owner \
		./dump/public/schema

.PHONY: pg_restore_data_public_jobs
pg_restore_data_public_jobs:
	PGPASSWORD=$(RDS_PASSWORD) pg_restore -h $(RDS_HOST) -p $(RDS_PORT) -U $(RDS_USER) -d $(RDS_DATABASE) \
		--disable-triggers \
		-j 3 \
		-F d \
		--use-set-session-authorization \
		--no-owner \
		--data-only \
		./dump/public/data

.PHONY: pg_restore_custom_types
pg_restore_custom_types:
	PGPASSWORD=$(RDS_PASSWORD) psql -h $(RDS_HOST) -p $(RDS_PORT) -U $(RDS_USER) -d $(RDS_DATABASE) \
		-f ./dump/public/custom-types.sql

.PHONY: pg_restore_transfer_data
pg_restore_transfer_data:
	PGPASSWORD=$(RDS_PASSWORD) psql -h $(RDS_HOST) -p $(RDS_PORT) -U $(RDS_USER) -d $(RDS_DATABASE) \
		-f ./dump/public/transfer_tables.sql

		
.PHONY: dump_public_all
dump_public_all:
	make -f Public.make pg_dump_schema_public_jobs
	make -f Public.make pg_dump_data_public_jobs


.PHONY: restore_public_all
restore_public_all:
	make -f Public.make pg_restore_custom_types
	make -f Public.make pg_restore_schema_public_jobs
	make -f Public.make pg_restore_data_public_jobs
	make -f Public.make pg_restore_transfer_data


.PHONY: pg_dump_institutions_target
pg_dump_institutions_target:
	@PGPASSWORD=$(RDS_ADMIN_PASSWORD) pg_dump -h $(RDS_ADMIN_HOST) \
		-U $(RDS_ADMIN_USER) -p $(RDS_ADMIN_PORT) -d $(RDS_DATABASE) \
		--data-only \
		--no-acl \
		-j 3 \
		-F d \
		--no-owner \
		-t institutions \
		-f ./dump/sal_request/data
