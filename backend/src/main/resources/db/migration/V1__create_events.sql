CREATE TABLE events (
    id UUID PRIMARY KEY,
    title VARCHAR(160) NOT NULL,
    subtitle VARCHAR(240) NOT NULL,
    venue VARCHAR(200) NOT NULL,
    starts_at TIMESTAMPTZ NOT NULL,
    image_url TEXT,
    minimum_price BIGINT NOT NULL CHECK (minimum_price >= 0),
    currency VARCHAR(3) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_events_starts_at ON events (starts_at);
