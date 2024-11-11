DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'user') THEN
        CREATE ROLE "user" WITH LOGIN PASSWORD 'password';
        ALTER ROLE "user" CREATEDB;
    END IF;
END $$;