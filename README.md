# Database-Sharding

docker-compose --profile sharding_fdw up -d

docker-compose --profile without_sharding up -d

## Native partitioning

These results were obtained using EXPLAIN ANALYZE.

- Analyze a single insert query to see how long it takes to insert one row.

```bash
EXPLAIN ANALYZE
INSERT INTO books (title, author, published_date, product_type)
VALUES ('Sample Book', 'Sample Author', '2024-01-01', 1);
```

![without_sharding_insert-1](./images/without_sharding_insert-1.png)

- Filter by product_type: This query evaluates the speed of filtering by the product_type column.

```bash
EXPLAIN ANALYZE
SELECT * FROM books
WHERE product_type = 1;
```

![without_sharding_select-product](./images/without_sharding_select-product.png)

- Filter by author: This query assesses the performance of selecting rows by a specific author.

```bash
EXPLAIN ANALYZE
SELECT * FROM books
WHERE author = 'Test Author 50000';
```

![without_sharding_select-author](./images/without_sharding_select-author.png)

- ORDER BY with LIMIT: This query retrieves the last 1000 rows to test how quickly the system performs sorting and
  limits the results.

```bash
EXPLAIN ANALYZE
SELECT * FROM books
ORDER BY id DESC
LIMIT 1000;
```

![without_sharding_select-limit](./images/without_sharding_select-limit.png)

## Native Sharding (FDW extension)

These results were obtained using EXPLAIN ANALYZE.

1. Query Execution Times:

- For product_type = 1 (main table books), the execution time is significantly lower.
- For product_type = 2 and product_type = 3 (sharded tables books_b1 and books_b2), the execution times are considerably
  higher.
- The execution time for inserts varies significantly depending on the product_type. Inserts into the main table (books)
  take longer compared to the sharded tables.
- The reasons for the performance difference include the cost of updating indexes for the main table and the network
  overhead associated with inserts into the sharded tables.

2. Reasons for Performance Differences:

- The main table (books) uses local sequential scanning, which ensures faster access to the data.
- Sharded tables (books_b1 and books_b2) use Foreign Scan through the Foreign Data Wrapper (FDW), which incurs
  additional network overhead to connect to remote servers, resulting in increased execution time.

### Select:

```bash
EXPLAIN ANALYZE SELECT * FROM books_view WHERE product_type = 1;
```

![fdw-select-1](./images/fdw-select-1.png)

```bash
EXPLAIN ANALYZE SELECT * FROM books_view WHERE product_type = 2;
```

![fdw-select-2](./images/fdw-select-2.png)

```bash
EXPLAIN ANALYZE SELECT * FROM books_view WHERE product_type = 3;
```

![fdw-select-3](./images/fdw-select-3.png)

### Insert:

```bash
EXPLAIN ANALYZE INSERT INTO books_view (title, author, published_date, product_type) VALUES ('Book Title', 'Author', '2024-01-01', 1);
```

![fdw-insert-1](./images/fdw-insert-1.png)

```bash
EXPLAIN ANALYZE INSERT INTO books_view (title, author, published_date, product_type) VALUES ('Book Title', 'Author', '2024-01-01', 2);
```

![fdw-insert-2](./images/fdw-insert-2.png)

```bash
EXPLAIN ANALYZE INSERT INTO books_view (title, author, published_date, product_type) VALUES ('Book Title', 'Author', '2024-01-01', 3);
```

![fdw-insert-3](./images/fdw-insert-3.png)

## Pl/Proxy sharding
