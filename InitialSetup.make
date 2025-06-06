# include .env

export RDS_ADMIN_PASSWORD
export RDS_ADMIN_USER
export RDS_ADMIN_HOST
export RDS_ADMIN_PORT
export RDS_ADMIN_DATABASE

.PHONY: create-databases
create-databases:
	@PGPASSWORD=$(RDS_ADMIN_PASSWORD) psql -h $(RDS_ADMIN_HOST) -U $(RDS_ADMIN_USER) -p $(RDS_ADMIN_PORT) -d $(RDS_ADMIN_DATABASE) \
		-f backup-data-final/database.sql

.PHONY: create-schema
create-schema:
	@PGPASSWORD=$(RDS_ADMIN_PASSWORD) psql -h $(RDS_ADMIN_HOST) -U $(RDS_ADMIN_USER) -p $(RDS_ADMIN_PORT) -d $(RDS_ADMIN_DATABASE) \
		-f backup-data-final/schemas.sql

.PHONY: create-roles
create-roles:
	@PGPASSWORD=$(RDS_ADMIN_PASSWORD) psql -h $(RDS_ADMIN_HOST) -U $(RDS_ADMIN_USER) -p $(RDS_ADMIN_PORT) -d $(RDS_ADMIN_DATABASE) \
		-f backup-data-final/roles.sql

.PHONY: initialize
initialize:
	make -f InitialSetup.make create-databases
	make -f InitialSetup.make create-roles
	make -f InitialSetup.make create-schema
