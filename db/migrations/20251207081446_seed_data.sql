-- migrate:up

WITH inserted_users AS (
    INSERT INTO users (email, full_name, password_hash) VALUES 
    ('john@example.com', 'John Doe', 'hash1'),
    ('jane@example.com', 'Jane Smith', 'hash2'),
    ('bob@example.com', 'Bob Martin', 'hash3'),
    ('alice@example.com', 'Alice Brown', 'hash4')
    RETURNING id, email
),

inserted_profiles AS (
    INSERT INTO user_profiles (user_id, avatar_url, bio, phone)
    SELECT
        id,
        'https://example.com/avatar' || row_number() OVER() || '.jpg',
        CASE
            WHEN email LIKE 'john%' THEN 'Project manager with 5 years of experience'
            WHEN email LIKE 'jane%' THEN 'Senior Rust Developer'
            WHEN email LIKE 'bob%' THEN 'UI/UX Designer'
            WHEN email LIKE 'alice%' THEN 'Full-stack Developer and Tech Lead'
        END,
        '+123456789' || row_number() OVER()
    FROM inserted_users
    RETURNING user_id
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
    RETURNING id, name, owner_id
),

inserted_tasks AS (
    INSERT INTO tasks (project_id, title, description, priority, status, due_date, assigned_to)
    SELECT * FROM (
        SELECT 
            (SELECT id FROM inserted_projects WHERE name = 'Website Redesign'),
            'Design new homepage',
            'Create wireframes and mockups for new homepage design',
            3,
            'pending'::task_status,
            CURRENT_DATE + INTERVAL '30 days',
            (SELECT id FROM inserted_users WHERE email = 'bob@example.com')
        UNION ALL
        SELECT 
            (SELECT id FROM inserted_projects WHERE name = 'Website Redesign'),
            'Implement responsive layout',
            'Make website responsive across all device sizes',
            2,
            'in_progress'::task_status,
            CURRENT_DATE + INTERVAL '20 days',
            (SELECT id FROM inserted_users WHERE email = 'jane@example.com')
        UNION ALL
        SELECT 
            (SELECT id FROM inserted_projects WHERE name = 'Mobile App Development'),
            'Set up user authentication',
            'Implement secure user authentication system',
            4,
            'pending'::task_status,
            CURRENT_DATE + INTERVAL '15 days',
            (SELECT id FROM inserted_users WHERE email = 'alice@example.com')
        UNION ALL
        SELECT 
            (SELECT id FROM inserted_projects WHERE name = 'Mobile App Development'),
            'Create API endpoints',
            'Build RESTful API for mobile app backend',
            3,
            'in_progress'::task_status,
            CURRENT_DATE + INTERVAL '45 days',
            (SELECT id FROM inserted_users WHERE email = 'jane@example.com')
        UNION ALL
        SELECT 
            (SELECT id FROM inserted_projects WHERE name = 'Database Migration'),
            'Write migration scripts',
            'Write SQL scripts to migrate legacy data',
            5,
            'pending'::task_status,
            CURRENT_DATE + INTERVAL '60 days',
            (SELECT id FROM inserted_users WHERE email = 'alice@example.com')
        UNION ALL
        SELECT 
            (SELECT id FROM inserted_projects WHERE name = 'Database Migration'),
            'Test data integrity',
            'Verify all data migrated correctly without loss',
            4,
            'pending'::task_status,
            CURRENT_DATE + INTERVAL '65 days',
            (SELECT id FROM inserted_users WHERE email = 'alice@example.com')
    ) AS tasks
    RETURNING id, project_id
)

INSERT INTO project_members (project_id, user_id, role)
SELECT 
    p.id,
    u.id,
    CASE 
        WHEN u.id = p.owner_id THEN 'owner'::member_role
        WHEN u.email = 'jane@example.com' THEN 'admin'::member_role
        ELSE 'member'::member_role
    END
FROM inserted_projects p
CROSS JOIN inserted_users u
WHERE u.email IN ('john@example.com', 'jane@example.com', 'bob@example.com', 'alice@example.com');

-- migrate:down

DELETE FROM project_members;
DELETE FROM tasks;
DELETE FROM projects;
DELETE FROM user_profiles;
DELETE FROM users;
