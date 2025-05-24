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


.PHONY: pg_dump_schema_purchase_orders_jobs
pg_dump_schema_purchase_orders_jobs:
	@rm -rf ./dump/purchase_orders/schema
	@PGPASSWORD=$(PO_SUPABASE_PASSWORD) PGOPTIONS='--statement-timeout=0' pg_dump -h $(PO_SUPABASE_HOST) -U $(PO_SUPABASE_USER) -p $(PO_SUPABASE_PORT) -d $(PO_SUPABASE_DBNAME) \
		--schema-only \
		--no-acl \
		-j 3 \
		-F d \
		--no-owner \
		--schema public \
		--table purchase_orders_v2 \
		-f ./dump/purchase_orders/schema

.PHONY: pg_dump_data_purchase_orders_jobs
pg_dump_data_purchase_orders_jobs:
	@rm -rf ./dump/purchase_orders/data
	@PGPASSWORD=$(PO_SUPABASE_PASSWORD) PGOPTIONS='--statement-timeout=0' pg_dump -h $(PO_SUPABASE_HOST) -U $(PO_SUPABASE_USER) -p $(PO_SUPABASE_PORT) -d $(PO_SUPABASE_DBNAME) \
		--data-only \
		--no-acl \
		-j 3 \
		-F d \
		--no-owner \
		--schema public \
		--table purchase_orders_v2 \
		-f ./dump/purchase_orders/data

.PHONY: pg_restore_schema_purchase_orders_pre_data_jobs
pg_restore_schema_purchase_orders_pre_data_jobs:
	PGPASSWORD=$(RDS_PASSWORD) pg_restore -h $(RDS_HOST) -p $(RDS_PORT) -U $(RDS_USER) -d $(RDS_DATABASE) \
		--section pre-data \
		--disable-triggers \
		--if-exists \
		--clean \
		-j 3 \
		-F d \
		--use-set-session-authorization \
		--no-owner \
		./dump/purchase_orders/schema

.PHONY: pg_restore_data_purchase_orders_jobs
pg_restore_data_purchase_orders_jobs:
	PGPASSWORD=$(RDS_PASSWORD) pg_restore -h $(RDS_HOST) -p $(RDS_PORT) -U $(RDS_USER) -d $(RDS_DATABASE) \
		--disable-triggers \
		-j 3 \
		-F d \
		--use-set-session-authorization \
		--no-owner \
		--data-only \
		./dump/purchase_orders/data

.PHONY: pg_restore_transfer_data
pg_restore_transfer_data:
	PGPASSWORD=$(RDS_PASSWORD) psql -h $(RDS_HOST) -p $(RDS_PORT) -U $(RDS_USER) -d $(RDS_DATABASE) \
		-f ./dump/purchase_orders/transfer_data.sql

.PHONY: dump_purchase_orders_all
dump_purchase_orders_all:
	@echo "Started at time: $$(date)"
	make -f PurchaseOrders.make pg_dump_schema_purchase_orders_jobs
	make -f PurchaseOrders.make pg_dump_data_purchase_orders_jobs
	@echo "Finished at time: $$(date)"


.PHONY: restore_purchase_orders_all
restore_purchase_orders_all:
	@echo "Started at time: $$(date)"
	make -f Public.make pg_restore_custom_types
	make -f Public.make pg_restore_schema_public_pre_data_jobs
	make -f Public.make pg_restore_data_public_jobs
	make -f Public.make pg_restore_create_tables
	@echo "Finished at time: $$(date)"
