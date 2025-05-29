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
export RDS_DATABASE=prod
export RDS_CONN=postgresql://$(RDS_USER):$(RDS_PASSWORD)@$(RDS_HOST):$(RDS_PORT)/$(RDS_DATABASE)


.PHONY: pg_dump_schema_public_rfp_jobs
pg_dump_schema_public_rfp_jobs:
	@rm -rf ./dump/rfps/public/schema
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
	@rm -rf ./dump/rfps/public/data
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

.PHONY: pg_dump_schema_rfp_jobs
pg_dump_schema_rfp_jobs:
	@rm -rf ./dump/rfps/schema
	PGPASSWORD=$(PO_SUPABASE_PASSWORD) PGOPTIONS='--statement-timeout=0' pg_dump -h $(PO_SUPABASE_HOST) -U $(PO_SUPABASE_USER) -p $(PO_SUPABASE_PORT) -d $(PO_SUPABASE_DBNAME) \
		--schema-only \
		--no-acl \
		-j 3 \
		-F d \
		--no-owner \
		--schema rfps \
		--table california_news_rfp_dump \
		--table florida_news_rfp_dump \
		--table new_york_news_rfp_dump \
		-f ./dump/rfps/schema


.PHONY: pg_dump_data_rfp_jobs
pg_dump_data_rfp_jobs:
	@rm -rf ./dump/rfps/data
	@PGPASSWORD=$(PO_SUPABASE_PASSWORD) PGOPTIONS='--statement-timeout=0' pg_dump -h $(PO_SUPABASE_HOST) -U $(PO_SUPABASE_USER) -p $(PO_SUPABASE_PORT) -d $(PO_SUPABASE_DBNAME) \
		--data-only \
		--no-acl \
		-j 3 \
		-F d \
		---schema rfps \
		--table california_news_rfp_dump \
		--table florida_news_rfp_dump \
		--table new_york_news_rfp_dump \
		--no-owner \	
		-f ./dump/rfps/data


.PHONY: dump_rfp_public_all
dump_rfp_public_all:
	@echo "Started at time: $$(date)"
	make -f RFP.make pg_dump_schema_public_rfp_jobs
	make -f RFP.make pg_dump_data_public_rfp_jobs
	@echo "Finished at time: $$(date)"


.PHONY: pg_restore_schema_rfp_pre_data_jobs
pg_restore_schema_rfp_pre_data_jobs:
	PGPASSWORD=$(RDS_PASSWORD) pg_restore -h $(RDS_HOST) -p $(RDS_PORT) -U $(RDS_USER) -d $(RDS_DATABASE) \
		--section pre-data \
		--disable-triggers \
		--if-exists \
		--clean \
		-j 3 \
		-F d \
		--use-set-session-authorization \
		--no-owner \
		./dump/rfps/public/schema

.PHONY: pg_restore_data_rfp_jobs
pg_restore_data_rfp_jobs:
	PGPASSWORD=$(RDS_PASSWORD) pg_restore -h $(RDS_HOST) -p $(RDS_PORT) -U $(RDS_USER) -d $(RDS_DATABASE) \
		--disable-triggers \
		-j 3 \
		-F d \
		--use-set-session-authorization \
		--no-owner \
		--data-only \
		./dump/rfps/public/data


.PHONY: dump_rfp_all
dump_rfp_all:
	@echo "Started at time: $$(date)"
	make -f RFP.make pg_dump_schema_rfp_jobs  
	make -f RFP.make pg_dump_data_rfp_jobs 
	@echo "Finished at time: $$(date)"


.PHONY: pg_restore_rfps_schema
pg_restore_rfps_schema:
	PGPASSWORD=$(RDS_PASSWORD) psql -h $(RDS_HOST) -p $(RDS_PORT) -U $(RDS_USER) -d $(RDS_DATABASE) \
	-f ./dump/rfps/schema/ddls.sql



.PHONY: transfer-loads
transfer-loads:
	$(eval FILES = california_news_rfp_dump_rows.sql florida_news_rfp_dump_rows.sql new_york_news_rfp_dump_rows.sql)
	$(foreach file, $(FILES), scp ~/Downloads/$(file) migration-box:/home/ubuntu/workspace/dump/rfps/data/;)
