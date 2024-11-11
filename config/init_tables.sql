DROP TABLE IF EXISTS books;

CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    published_date DATE,
    product_type INT NOT NULL
);

CREATE INDEX idx_books_title ON books (title);
CREATE INDEX idx_books_author ON books (author);
CREATE INDEX idx_books_published_date ON books (published_date);
CREATE INDEX idx_books_product_type ON books (product_type);