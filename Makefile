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


.PHONY: check
check:
	echo "$(PO_CONN_STRING)"


.PHONY: prep-tmp-dir
prep-tmp-dir:
	mkdir -p ./backup-data


.PHONY: backup-roles
backup-roles:
	supabase db dump --db-url $(PO_CONN_STRING) -f ./backup-data/roles.sql --role-only


.PHONY: backup-schemas
backup-schemas:
	supabase db dump --db-url $(PO_CONN_STRING) -f ./backup-data/schemas.sql


.PHONY: backup-data
backup-data:
	supabase db dump --db-url $(PO_CONN_STRING) -f ./backup-data/data.sql --use-copy --data-only


.PHONY: backup-all
backup-all: prep-tmp-dir
	echo "Started at $(shell date)"
	make backup-roles
	make backup-schemas
	make backup-data
	echo "Finished at $(shell date)"


.PHONY: run-psql-supabase
run-psql-supabase:
	docker run -it postgres:14-alpine psql -U $(PO_SUPABASE_USER) -h $(PO_SUPABASE_HOST) -d $(PO_SUPABASE_DBNAME) -p $(PO_SUPABASE_PORT)


.PHONY: run-psql-pgbounce
run-psql-pgbounce:
	docker run -it --network host --rm postgres:14-alpine psql -U $(PO_SUPABASE_USER) -h localhost -d $(PO_SUPABASE_DBNAME) -p 5432


.PHONY: connect-to-rds
connect-to-rds:
	docker run -it --network host --rm postgres:14-alpine psql -U postgres -h $(RDS_HOST) -d $(RDS_DATABASE) -p $(RDS_PORT)


.PHONY: connect-to-pgbouncer
connect-to-pgbouncer:
	docker run -it --network host --rm postgres:14-alpine psql -U $(RDS_USER) -h localhost -d rds_session -p 5432


.PHONY: connect-to-proxy-gateway
connect-to-proxy-gateway:
	docker run -it --rm postgres:14-alpine psql -U $(RDS_USER) -h proxy-gateway.bravo.nationgraph.com -d rds_session -p 1801


.PHONY: restore
restore:
	# docker run -it -e "PGPASSWORD=$(RDS_PASSWORD)" -v ./backup-data:/home --rm postgres:14-alpine pg_restore -h $(RDS_HOST) -U $(RDS_USER) -p $(RDS_PORT) -d postgres --disable-triggers /home/roles.sql
	# docker run -it -e "PGPASSWORD=$(RDS_PASSWORD)" -v ./backup-data:/home --rm postgres:14-alpine pg_restore --help
	# psql -h $(RDS_HOST) -U $(RDS_USER) -p $(RDS_PORT) -b -L restore-roles.log -f ./backup-data/roles.sql
	# psql -h $(RDS_HOST) -U $(RDS_USER) -p $(RDS_PORT) -b -L restore-roles.log -f ./backup-data/pre-schema.sql
	# psql -h $(RDS_HOST) -U $(RDS_USER) -p $(RDS_PORT) -b -L restore-schemas.log -f ./backup-data/schemas.sql
	psql -h $(RDS_HOST) -U $(RDS_USER) -p $(RDS_PORT) -b -L restore-manual-schemas.log -f ./backup-data/manual_schema_dump.sql
	# psql -h $(RDS_HOST) -U $(RDS_USER) -p $(RDS_PORT) -f ./backup-data/data.sql
	# docker run -it -v ./backup-data:/home --rm postgres:14-alpine pg_restore -h $(RDS_HOST) -U $(RDS_USER) -p $(RDS_PORT) -f /home/schemas.sql
	# docker run -it -v ./backup-data:/home --rm postgres:14-alpine psql -h $(RDS_HOST) -U $(RDS_USER)


.PHONY: jump-into-vm-box
jump-into-vm-box:
	# @ssh -i migration-database.pem ubuntu@ec2-54-163-30-37.compute-1.amazonaws.com
	ssh migration-box # This only works for me (Victor), please uncomment the above command and use it instead


.PHONY: creds-dump
creds-dump:
	echo "$(RDS_HOST):$(RDS_PORT):$(RDS_DATABASE):$(RDS_USER):$(RDS_PASSWORD)" | sed 's/k:G/k\\:G/g' > ~/.pgpass


.PHONY: pg_dump_schema
pg_dump_schema:
	pg_dump -h $(PO_SUPABASE_HOST) -U $(PO_SUPABASE_USER) -p $(PO_SUPABASE_PORT) -d $(PO_SUPABASE_DBNAME) --schema-only -f ./backup-data/manual_schema_dump.sql

.PHONY: liquibase
liquibase:
	# docker compose build --no-cache
	docker compose up --build

.PHONY: transfer-scripts
transfer-scripts:
	$(eval FILES = Makefile Final.make InitialSetup.make ProdEducation.make)
	$(foreach file, $(FILES), scp $(file) migration-box:/home/ubuntu/workspace;)

	$(eval FILES = .env)
	$(foreach file, $(FILES), scp $(file) migration-box:/home/ubuntu/workspace;)

	$(eval FILES =  ./backup-data-final/database.sql ./backup-data-final/roles.sql ./backup-data-final/schemas.sql)
	$(foreach file, $(FILES), scp $(file) migration-box:/home/ubuntu/workspace/backup-data-final;)

	$(eval FILES = install-docker.sh .env initiate-backup.sh initiate-restore.sh ./backup-data/post-processing-ddl.sql)
	$(foreach file, $(FILES), scp $(file) migration-box:/home/ubuntu/workspace;)
	
	$(eval FILES = ./backup-data/post-processing-ddl.sql ./backup-data/pre-schema.sql)
	$(foreach file, $(FILES), scp $(file) migration-box:/home/ubuntu/workspace/backup-data;)

	$(eval FILES = ./dump/prod_education/transformation.sql ./dump/prod_education/institutions_table.sql)
	$(foreach file, $(FILES), scp $(file) migration-box:/home/ubuntu/workspace/dump/prod_education;)


.PHONY: running-psl
running-psl:
	kubectl -n db-pooler run postgres --image=postgres:14-alpine --env="POSTGRES_PASSWORD=mysecretpassword" --command -- sleep infinity

.PHONY: running-ubuntu-proxy
running-ubuntu-proxy:
	kubectl -n proxy-gateway run box --image=alpine:latest --command -- sleep infinity

.PHONY: copy-passw
copy-passw:
	@cat .env | grep PASS | sed 's/=/: /g' | yq .PO_SUPABASE_PASSWORD | pbcopy
