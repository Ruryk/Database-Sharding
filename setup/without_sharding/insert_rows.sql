DO $$
DECLARE
    i INTEGER;
BEGIN
    FOR i IN 1..1000000 LOOP
        INSERT INTO books (title, author, published_date, product_type)
        VALUES (
            'Book Title ' || i,
            'Author ' || i,
            '2024-01-01',
            (i % 3) + 1
        );

        IF i % 1000000 = 0 THEN
            RAISE NOTICE 'Inserted % rows...', i;
        END IF;
    END LOOP;
END $$;
