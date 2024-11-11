-- Add workers to the coordinator
SELECT * from master_add_node('citus-worker1', 5432);
SELECT * from master_add_node('citus-worker2', 5432);

-- Create a Sharded Table
DROP TABLE IF EXISTS books;
CREATE TABLE books (
    id SERIAL,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    published_date DATE,
    product_type INT NOT NULL,
    PRIMARY KEY (id, product_type)
);

-- This command will distribute the books table among the workers by the product_type field.
-- This means that records with the same product_type value will be stored on the same worker,
-- which ensures efficient use of worker for data distribution.
SELECT create_distributed_table('books', 'product_type');

-- Monitoring of Nodes
SELECT * FROM master_get_active_worker_nodes();

-- Create Indexes (Optional)
CREATE INDEX idx_books_product_type ON books (product_type);
CREATE INDEX idx_books_author ON books (author);

