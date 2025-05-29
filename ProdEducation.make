# include .env


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


.PHONY: pg_dump_schema_all_institutions_jobs
pg_dump_schema_all_institutions_jobs:
	@rm -rf ./dump/prod_education/schema
	@PGPASSWORD=$(PO_SUPABASE_PASSWORD) pg_dump -h $(PO_SUPABASE_HOST) -U $(PO_SUPABASE_USER) -p $(PO_SUPABASE_PORT) -d $(PO_SUPABASE_DBNAME) \
		--schema-only \
		--no-acl \
		-j 3 \
		-F d \
		--no-owner \
		--schema prod_education \
		-f ./dump/prod_education/schema

.PHONY: pg_dump_data_all_institutions_jobs
pg_dump_data_all_institutions_jobs:
	@rm -rf ./dump/prod_education/data
	@PGPASSWORD=$(PO_SUPABASE_PASSWORD) pg_dump -h $(PO_SUPABASE_HOST) -U $(PO_SUPABASE_USER) -p $(PO_SUPABASE_PORT) -d $(PO_SUPABASE_DBNAME) \
		--data-only \
		--no-acl \
		-j 3 \
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
	PGPASSWORD=$(RDS_PASSWORD) psql -h $(RDS_HOST) -p $(RDS_PORT) -U $(RDS_USER) -d $(RDS_DATABASE) \
		-f ./dump/prod_education/institutions_table.sql

		
.PHONY: dump_prod_education_all
dump_prod_education_all:
	make -f ProdEducation.make pg_dump_schema_all_institutions_jobs
	make -f ProdEducation.make pg_dump_data_all_institutions_jobs


.PHONY: restore_prod_education_all
restore_prod_education_all:
	make -f ProdEducation.make pg_restore_schema_all_institutions_jobs
	make -f ProdEducation.make pg_restore_data_all_institutions_jobs
	make -f ProdEducation.make pg_restore_transfer_institutions_data


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
