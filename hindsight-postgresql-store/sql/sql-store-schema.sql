-- Transactions table stores transaction IDs using PostgreSQL's native xid8
-- xid8 is a 64-bit transaction ID that never wraps and integrates with MVCC
CREATE TABLE IF NOT EXISTS event_transactions (
    transaction_xid8 xid8 PRIMARY KEY DEFAULT pg_current_xact_id()
);

-- Stream heads table tracks latest position of each stream
CREATE TABLE IF NOT EXISTS stream_heads (
    stream_id UUID PRIMARY KEY,
    latest_transaction_xid8 xid8 NOT NULL,
    latest_seq_no INT NOT NULL,
    last_event_id UUID NOT NULL,
    stream_version BIGINT NOT NULL DEFAULT 0, -- Local stream version (1, 2, 3, ...)
    CONSTRAINT stream_heads_latest_transaction_xid8
        FOREIGN KEY (latest_transaction_xid8)
        REFERENCES event_transactions (transaction_xid8)
        DEFERRABLE INITIALLY DEFERRED
);

-- Events table stores all events across all streams
CREATE TABLE IF NOT EXISTS events (
    transaction_xid8 xid8 NOT NULL,
    seq_no INT NOT NULL,
    event_id UUID NOT NULL PRIMARY KEY,
    stream_id UUID NOT NULL,
    correlation_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    event_name TEXT NOT NULL,
    event_version INT NOT NULL,
    payload JSONB NOT NULL,
    stream_version BIGINT NOT NULL, -- Local stream version for this event
    CONSTRAINT events_transaction_xid8
        FOREIGN KEY (transaction_xid8)
        REFERENCES event_transactions (transaction_xid8)
        DEFERRABLE INITIALLY DEFERRED
);


-- Index for efficient stream-based queries (global ordering)
CREATE INDEX IF NOT EXISTS idx_stream_events
    ON events (stream_id, transaction_xid8, seq_no);

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
    ON events (transaction_xid8, seq_no);

-- Index for filtered transaction queries with event names
-- Supports queries like WHERE (transaction_xid8, seq_no) > (?, ?) AND event_name = ANY(?)
CREATE INDEX IF NOT EXISTS idx_events_transaction_event_name
    ON events (transaction_xid8, seq_no, event_name);


-- MVCC-based safe transaction barrier using PostgreSQL's snapshot xmin
-- Returns the xid8 barrier: only transactions < this value are guaranteed visible
-- This prevents reading uncommitted transactions and ensures consistent ordering
CREATE OR REPLACE FUNCTION get_safe_transaction_xid8()
RETURNS xid8 AS $$
BEGIN
    -- Get the oldest transaction that might still be running
    -- Transactions with xid8 >= this value may not be visible in current snapshot
    RETURN pg_snapshot_xmin(pg_current_snapshot());
END;
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION notify_transaction()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
   PERFORM pg_notify(
       'event_store_transaction',
       json_build_object('transactionXid8', NEW.transaction_xid8::text)::text
   );
   RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER transaction_notify
    AFTER INSERT ON event_transactions
    FOR EACH ROW
    EXECUTE PROCEDURE notify_transaction();

