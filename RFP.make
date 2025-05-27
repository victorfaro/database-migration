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


.PHONY: pg_dump_schema_public_rfp_jobs
pg_dump_schema_public_rfp_jobs:
	@rm -rf ./dump/purchase_orders/schema
	@PGPASSWORD=$(PO_SUPABASE_PASSWORD) PGOPTIONS='--statement-timeout=0' pg_dump -h $(PO_SUPABASE_HOST) -U $(PO_SUPABASE_USER) -p $(PO_SUPABASE_PORT) -d $(PO_SUPABASE_DBNAME) \
		--schema-only \
		--no-acl \
		-j 3 \
		-F d \
		--no-owner \
		--schema public \
		--table procurements_manual \
		--table procurements_ed \
		-f ./dump/rfps/public/schema


.PHONY: pg_dump_data_public_rfp_jobs
pg_dump_data_public_rfp_jobs:
	@rm -rf ./dump/purchase_orders/data
	@PGPASSWORD=$(PO_SUPABASE_PASSWORD) PGOPTIONS='--statement-timeout=0' pg_dump -h $(PO_SUPABASE_HOST) -U $(PO_SUPABASE_USER) -p $(PO_SUPABASE_PORT) -d $(PO_SUPABASE_DBNAME) \
		--data-only \
		--no-acl \
		-j 3 \
		-F d \
		--no-owner \
		--schema public \
		--table procurements_manual \
		--table procurements_ed \
		-f ./dump/rfps/public/data


.PHONY: dump_rfp_public_all
dump_rfp_public_all:
	@echo "Started at time: $$(date)"
	make -f RFP.make pg_dump_schema_public_rfp_jobs
	make -f RFP.make pg_dump_data_public_rfp_jobs
	@echo "Finished at time: $$(date)"
