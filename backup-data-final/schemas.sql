CREATE SCHEMA IF NOT EXISTS app AUTHORIZATION dbowner;

GRANT USAGE ON SCHEMA app TO dbwriter, dbreader;

ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO dbwriter;  
ALTER DEFAULT PRIVILEGES IN SCHEMA app GRANT SELECT ON TABLES TO dbreader;

