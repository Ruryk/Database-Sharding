DO $$
DECLARE
    i INT := 1;
BEGIN
    WHILE i <= 1000000 LOOP
        INSERT INTO books_view (title, author, published_date, product_type)
        VALUES ('Book Title ' || i, 'Author ' || i, '2024-01-01', (i % 3) + 1);
        i := i + 1;
    END LOOP;
END $$;
