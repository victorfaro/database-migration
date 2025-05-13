CREATE ROLE dbowner NOLOGIN;

CREATE ROLE dbwriter WITH PASSWORD 'nJwbirC03lxKoHX';

CREATE ROLE dbreader WITH PASSWORD 'e5XHdFT4OCMZp9E';

CREATE ROLE dbadmin WITH PASSWORD 'kUqHcCXWtDQGVfMnsvrdge';
GRANT CONNECT TO DATABASE dev, prod TO dbwriter;
GRANT CONNECT TO DATABASE dev, prod TO dbreader;
GRANT CONNECT TO DATABASE dev, prod TO dbadmin;

GRANT dbowner TO postgres;
GRANT dbowner TO dbadmin;
