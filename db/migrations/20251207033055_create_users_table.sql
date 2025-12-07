-- migrate:up

-- create custom enum types
CREATE TYPE project_status AS ENUM ('active', 'completed', 'archived')
CREATE TYPE task_status AS ENUM ('pending', 'in_progress', 'completed', 'cancelled')
CREATE TYPE member_role AS ENUM ('owner', 'admin', 'member')

-- create user table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
)


-- migrate:down

