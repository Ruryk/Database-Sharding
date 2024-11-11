DO $$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'books_db') THEN
      CREATE DATABASE books_db;
   END IF;
END $$;
