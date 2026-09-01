CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(254) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(80) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL
);

CREATE UNIQUE INDEX uq_users_email ON users (email);

CREATE TABLE refresh_sessions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    token_hash VARCHAR(64) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL
);

CREATE UNIQUE INDEX uq_refresh_sessions_token_hash ON refresh_sessions (token_hash);
CREATE INDEX idx_refresh_sessions_user_id ON refresh_sessions (user_id);
CREATE INDEX idx_refresh_sessions_expires_at ON refresh_sessions (expires_at);
