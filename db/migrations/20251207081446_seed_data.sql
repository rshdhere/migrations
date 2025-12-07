-- migrate:up

WITH inserted_users AS (
    INSERT INTO users (email, full_name, password_hash) VALUES 
    ('john@example.com', 'Jhon Doe', 'hash1')
    ('jane@example.com', 'Jane Smith', 'hash2')
    ('bob@example.com', 'Bob Martin', 'hash3')
    ('alice@example.com', 'Alice Brown', 'hash4')

    RETURNING id, email
),

inserted_profiles AS (
    INSERT INTO user_profiles (user_id, avatar_url, bio, phone)
    SELECT
        id,
        'https://example.com/avatar' || row_number() OVER() || '.jpg',
        CASE
            WHEN email LIKE 'jhon%' THEN 'Project manager with 5 years of experience'
            WHEN email LIKE 'jane%' THEN 'Senior Rust Developer'
            WHEN email LIKE 'bob%' THEN 'UI/UX Designer'
        END,
        '+123456789' || row_number() OVER()
    FROM inserted_users
),

inserted_projects AS (
    INSERT INTO projects (name, description, status, owner_id)
    SELECT 
        unnest(ARRAY[
            'Website Redesign',
            'Mobile App Development',
            'Database Migration'
        ]),
        unnest(ARRAY[
            'Complete overhaul of company website',
            'New mobile app for customers',
            'Migrate legacy database to new system'
        ]),
        unnest(ARRAY[
            'active'::project_status,
            'active'::project_status,
            'active'::project_status
        ]),
        (SELECT id FROM inserted_users WHERE email = 'john@example.com')
    RETURNING id, name
)



-- migrate:down

