-- Create Keycloak database
CREATE DATABASE keycloakdb;

-- Grant permissions to dbadmin user
GRANT ALL PRIVILEGES ON DATABASE keycloakdb TO dbadmin;

-- Connect to keycloakdb and grant schema permissions
\c keycloakdb
GRANT ALL ON SCHEMA public TO dbadmin;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO dbadmin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO dbadmin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO dbadmin;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO dbadmin;
