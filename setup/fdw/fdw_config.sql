-- Enable the foreign data wrapper extension
CREATE EXTENSION IF NOT EXISTS postgres_fdw;

-- Drop existing foreign servers if they exist and create new ones
DROP SERVER IF EXISTS postgresql_b1 CASCADE;
CREATE SERVER postgresql_b1 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'postgresql-b1', dbname 'books_db', port '5432');

DROP SERVER IF EXISTS postgresql_b2 CASCADE;
CREATE SERVER postgresql_b2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'postgresql-b2', dbname 'books_db', port '5432');

-- Create user mappings for each shard
CREATE USER MAPPING IF NOT EXISTS FOR user SERVER postgresql_b1 OPTIONS (user 'user', password 'password');
CREATE USER MAPPING IF NOT EXISTS FOR user SERVER postgresql_b2 OPTIONS (user 'user', password 'password');

-- Create a table on the main node
CREATE TABLE IF NOT EXISTS books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    published_date DATE,
    product_type INT NOT NULL
);

-- Create foreign tables for shard1 and shard2
CREATE FOREIGN TABLE books_b1 (
    id SERIAL,
    title VARCHAR(255),
    author VARCHAR(255),
    published_date DATE,
    product_type INT NOT NULL
)
SERVER postgresql_b1
OPTIONS (schema_name 'public', table_name 'books');

CREATE FOREIGN TABLE books_b2 (
    id SERIAL,
    title VARCHAR(255),
    author VARCHAR(255),
    published_date DATE,
    product_type INT NOT NULL
)
SERVER postgresql_b2
OPTIONS (schema_name 'public', table_name 'books');

-- Create a view to combine all shards and the main table
DROP VIEW IF EXISTS books_view;

CREATE VIEW books_view AS
    SELECT * FROM books
		UNION ALL
	SELECT * FROM books_b1
		UNION ALL
	SELECT * FROM books_b2;

-- Setup Rules
-- Drop existing rules if they exist

DROP RULE IF EXISTS books_insert ON books_view;
DROP RULE IF EXISTS books_insert_to_main ON books_view;
DROP RULE IF EXISTS books_insert_to_b1 ON books_view;
DROP RULE IF EXISTS books_insert_to_b2 ON books_view;

-- Create new rules for handling inserts across shards
CREATE RULE books_insert AS ON INSERT TO books_view DO INSTEAD NOTHING;

-- Route product_type = 1 to books table (main node)
CREATE RULE books_insert_to_main AS ON INSERT TO books_view
WHERE (product_type = 1)
DO INSTEAD INSERT INTO books (id, title, author, published_date, product_type)
VALUES (DEFAULT, NEW.title, NEW.author, NEW.published_date, NEW.product_type);

-- Route product_type = 2 to books_b1 table (shard1)
CREATE RULE books_insert_to_b1 AS ON INSERT TO books_view
WHERE (product_type = 2)
DO INSTEAD INSERT INTO books_b1 (id, title, author, published_date, product_type)
VALUES (DEFAULT, NEW.title, NEW.author, NEW.published_date, NEW.product_type);

-- Route product_type = 3 to books_b2 table (shard2)
CREATE RULE books_insert_to_b2 AS ON INSERT TO books_view
WHERE (product_type = 3)
DO INSTEAD INSERT INTO books_b2 (id, title, author, published_date, product_type)
VALUES (DEFAULT, NEW.title, NEW.author, NEW.published_date, NEW.product_type);