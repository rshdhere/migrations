-- migrate:up

-- create custom enum types
CREATE TYPE project_status AS ENUM ('active', 'completed', 'archived')
CREATE TYPE task_status AS ENUM ('pending', 'in_progress', 'completed', 'cancelled')
CREATE TYPE member_role AS ENUM ('owner', 'admin', 'member')


-- migrate:down

