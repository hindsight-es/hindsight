-- Core sequence for transaction ordering
CREATE SEQUENCE IF NOT EXISTS transaction_seq;

-- Transactions table stores all transaction numbers
CREATE TABLE IF NOT EXISTS event_transactions (
    transaction_no BIGINT PRIMARY KEY DEFAULT nextval('transaction_seq')
);

-- Stream heads table tracks latest position of each stream
CREATE TABLE IF NOT EXISTS stream_heads (
    stream_id UUID PRIMARY KEY,
    latest_transaction_no BIGINT NOT NULL,
    latest_seq_no INT NOT NULL,
    last_event_id UUID NOT NULL,
    stream_version BIGINT NOT NULL DEFAULT 0, -- Local stream version (1, 2, 3, ...)
    CONSTRAINT stream_heads_latest_transaction_no 
        FOREIGN KEY (latest_transaction_no) 
        REFERENCES event_transactions (transaction_no) 
        DEFERRABLE INITIALLY DEFERRED
);

-- Events table stores all events across all streams
CREATE TABLE IF NOT EXISTS events (
    transaction_no BIGINT NOT NULL,
    seq_no INT NOT NULL,
    event_id UUID NOT NULL PRIMARY KEY,
    stream_id UUID NOT NULL,
    correlation_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    event_name TEXT NOT NULL,
    event_version INT NOT NULL,
    payload JSONB NOT NULL,
    stream_version BIGINT NOT NULL, -- Local stream version for this event
    CONSTRAINT events_transaction_no 
        FOREIGN KEY (transaction_no) 
        REFERENCES event_transactions (transaction_no) 
        DEFERRABLE INITIALLY DEFERRED
);


-- Index for efficient stream-based queries (global ordering)
CREATE INDEX IF NOT EXISTS idx_stream_events 
    ON events (stream_id, transaction_no, seq_no);

-- Index for efficient stream version queries (local ordering)
CREATE INDEX IF NOT EXISTS idx_stream_version_events 
    ON events (stream_id, stream_version);

-- Index for correlation-based queries
CREATE INDEX IF NOT EXISTS idx_correlation 
    ON events (correlation_id) 
    WHERE correlation_id IS NOT NULL;

-- Index for event type queries
CREATE INDEX IF NOT EXISTS idx_event_type 
    ON events (event_name, event_version);

-- CRITICAL: Composite index for efficient transaction-based range queries
-- This index is essential for dispatcher performance when fetching events
CREATE INDEX IF NOT EXISTS idx_events_transaction_order 
    ON events (transaction_no, seq_no);

-- Index for filtered transaction queries with event names
-- Supports queries like WHERE (transaction_no, seq_no) > (?, ?) AND event_name = ANY(?)
CREATE INDEX IF NOT EXISTS idx_events_transaction_event_name 
    ON events (transaction_no, seq_no, event_name);


-- MVCC-based safe transaction number using proper PostgreSQL snapshot functions
-- Returns the highest transaction number that is guaranteed to be visible
-- to all concurrent readers based on current MVCC snapshot
CREATE OR REPLACE FUNCTION get_safe_transaction_number_mvcc()
RETURNS bigint AS $$
DECLARE
  snapshot_xmin bigint;
  max_tx_no bigint;
BEGIN
    -- Get the oldest transaction that might still be running using modern function
    SELECT pg_snapshot_xmin(pg_current_snapshot()) INTO snapshot_xmin;
    
    -- Get the maximum transaction number we've allocated
    SELECT MAX(transaction_no) INTO max_tx_no FROM event_transactions;
    
    -- Return the safe upper bound: transactions with IDs >= snapshot_xmin might not be visible
    -- So we return the minimum of (snapshot_xmin - 1) and max_tx_no
    RETURN LEAST(COALESCE(snapshot_xmin - 1, max_tx_no), COALESCE(max_tx_no, 0));
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION notify_transaction() 
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
   PERFORM pg_notify(
       'event_store_transaction',
       json_build_object('transactionNo', NEW.transaction_no)::text
   );
   RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER transaction_notify
    AFTER INSERT ON event_transactions
    FOR EACH ROW
    EXECUTE PROCEDURE notify_transaction();

-- Unified projections metadata table (supports both sync and async projections)
CREATE TABLE IF NOT EXISTS projections (
    id TEXT PRIMARY KEY,
    head_position JSONB,                   -- Cursor storage for all projections
    last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_active BOOLEAN NOT NULL DEFAULT true,
    error_message TEXT,
    error_timestamp TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_projections_active 
    ON projections (is_active) 
    WHERE is_active = true;

-- Notification trigger for async projections
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

