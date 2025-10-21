-- Projection state tracking table
--
-- This table tracks the state of async projections, storing cursor positions
-- and metadata. It is used by the backend-agnostic projection system to:
-- - Resume projections after restarts
-- - Track projection progress
-- - Enable LISTEN/NOTIFY for efficient waiting

CREATE TABLE IF NOT EXISTS projections (
    id TEXT PRIMARY KEY,
    head_position JSONB,                   -- Cursor storage (backend-agnostic JSON)
    last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_active BOOLEAN NOT NULL DEFAULT true,
    error_message TEXT,
    error_timestamp TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_projections_active
    ON projections (is_active)
    WHERE is_active = true;

-- Notification trigger for async projections
--
-- When a projection updates its cursor, this trigger sends a NOTIFY on a channel
-- named after the projection ID. This enables waitForEvent to efficiently wait
-- for projection progress using PostgreSQL's LISTEN/NOTIFY mechanism.

CREATE OR REPLACE FUNCTION notify_projection_update()
RETURNS trigger AS $$
BEGIN
    PERFORM pg_notify(
        NEW.id,  -- notification channel name is the projection id
        json_build_object(
            'head_position', NEW.head_position,
            'last_updated', NEW.last_updated
        )::text  -- convert to string for notification payload
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER projection_update_notify
    AFTER INSERT OR UPDATE ON projections
    FOR EACH ROW
    EXECUTE FUNCTION notify_projection_update();
