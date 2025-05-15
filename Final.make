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
export RDS_DATABASE
export RDS_CONN=postgresql://$(RDS_USER):$(RDS_PASSWORD)@$(RDS_HOST):$(RDS_PORT)/$(RDS_DATABASE)

# export LIQUIBASE_URL
# export LIQUIBASE_COMMAND_USERNAME
# export LIQUIBASE_COMMAND_PASSWORD


.PHONY: pg_dump_schema_jobs
pg_dump_schema_jobs:
	pg_dump -h $(RDS_HOST) -U $(RDS_USER) -p $(RDS_PORT) -d $(RDS_DATABASE) \
		--schema-only \
		-f ./backup-data-final \
		-F d \
		-j 3 \
		--no-acl \
		-t mock_workbook_institution \
		-t mock_enrichment \
		-t mock_user \
		-t mock_workspaces \
		-t mock_job \
		-t mock_custom_columns \
		-t mock_custom_cell

.PHONY: pg_dump_schema
pg_dump_schema:
	pg_dump -h $(RDS_HOST) -U $(RDS_USER) -p $(RDS_PORT) -d $(RDS_DATABASE) \
		--schema-only \
		--no-acl \
		-t mock_workbook_institution \
		-t mock_enrichment \
		-t mock_user \
		-t mock_workspaces \
		-t mock_job \
		-t mock_custom_columns \
		-t mock_custom_cell > ./backup-data-final/dump.sql

.PHONY: pg_dump_schema_all_institutions
pg_dump_schema_all_institutions:
	@PGPASSWORD=$(PO_SUPABASE_PASSWORD) pg_dump -h $(PO_SUPABASE_HOST) -U $(PO_SUPABASE_USER) -p $(PO_SUPABASE_PORT) -d $(PO_SUPABASE_DBNAME) \
		--schema-only \
		--no-acl \
		--schema prod_education > ./backup-data-final/all_institutions_schema.sql

.PHONY: pg_restore_schema_all_institutions
pg_restore_schema_all_institutions:
	#sed -i 's/prod_education/public/g' ./backup-data-final/all_institutions_schema.sql⏎

	PGPASSWORD=$(RDS_PASSWORD) psql -h $(RDS_HOST) -p $(RDS_PORT) -U $(RDS_USER) -d $(RDS_DATABASE) -f ./backup-data-final/all_institutions_schema.sql
	sed -i 's/prod_education/public/g' ./backup-data-final/all_institutions_schema.sql⏎

.PHONY: pg_dump_schema_all_institutions_jobs
pg_dump_schema_all_institutions_jobs:
	@PGPASSWORD=$(PO_SUPABASE_PASSWORD) pg_dump -h $(PO_SUPABASE_HOST) -U $(PO_SUPABASE_USER) -p $(PO_SUPABASE_PORT) -d $(PO_SUPABASE_DBNAME) \
		--schema-only \
		--no-acl \
		-j 1 \
		-F d \
		--no-owner \
		--schema prod_education \
		-f ./dump/prod_education/schema

.PHONY: pg_dump_data_all_institutions_jobs
pg_dump_data_all_institutions_jobs:
	@PGPASSWORD=$(PO_SUPABASE_PASSWORD) pg_dump -h $(PO_SUPABASE_HOST) -U $(PO_SUPABASE_USER) -p $(PO_SUPABASE_PORT) -d $(PO_SUPABASE_DBNAME) \
		--data-only \
		--no-acl \
		-j 1 \
		-F d \
		--no-owner \
		--schema prod_education \
		-f ./dump/prod_education/data

.PHONY: pg_restore_schema_all_institutions_jobs
pg_restore_schema_all_institutions_jobs:
	PGPASSWORD=$(RDS_PASSWORD) pg_restore -h $(RDS_HOST) -p $(RDS_PORT) -U $(RDS_USER) -d $(RDS_DATABASE) \
		--disable-triggers \
		--if-exists \
		--clean \
		-j 3 \
		-F d \
		--use-set-session-authorization \
		--no-owner \
		./dump/prod_education/schema

.PHONY: pg_restore_data_all_institutions_jobs
pg_restore_data_all_institutions_jobs:
	PGPASSWORD=$(RDS_PASSWORD) pg_restore -h $(RDS_HOST) -p $(RDS_PORT) -U $(RDS_USER) -d $(RDS_DATABASE) \
		--disable-triggers \
		-j 3 \
		-F d \
		--use-set-session-authorization \
		--no-owner \
		--data-only \
		./dump/prod_education/data

.PHONY: pg_restore_transfer_institutions_data
pg_restore_transfer_institutions_data:
	# PGPASSWORD=$(RDS_PASSWORD) psql -h $(RDS_HOST) -p $(RDS_PORT) -U $(RDS_USER) -d $(RDS_DATABASE) \
	# 	-f ./dump/prod_education/transformation.sql

	PGPASSWORD=$(RDS_PASSWORD) psql -h $(RDS_HOST) -p $(RDS_PORT) -U $(RDS_USER) -d $(RDS_DATABASE) \
		-f ./dump/prod_education/institutions_table.sql

.PHONY: restore_prod_education_all
restore_prod_education_all:
	make -f Makefile.Final pg_restore_schema_all_institutions_jobs
	make -f Makefile.Final pg_restore_data_all_institutions_jobs
	make -f Makefile.Final pg_restore_transfer_institutions_data
	

.PHONY: replace_schemas
replace_schemas:
	sed -i 's/public\.//g' ./backup-data-final/dump.sql
	
