-- migrate:up

WITH inserted_users AS (
    INSERT INTO users (email, full_name, password_hash) VALUES 
    ('john@example.com', 'Jhon Doe', 'hash1')
    ('jane@example.com', 'Jane Smith', 'hash2')
    ('bob@example.com', 'Bob Martin', 'hash3')
    ('alice@example.com', 'Alice Brown', 'hash4')

    RETURNING id, email
),


-- migrate:down

