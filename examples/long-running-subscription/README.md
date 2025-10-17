# Long-Running Subscription Example

This example demonstrates a long-running event sourcing application with PostgreSQL projections, designed to test subscription stability over extended periods.

## Purpose

Tests for a historical bug where PostgreSQL LISTEN/NOTIFY subscriptions would become stale after running for several hours, causing projections to stop receiving events without the connection closing.

## Architecture

- **Servant API** (NamedRoutes-based) for inserting events and querying projection state
- **PostgreSQL event store** for event persistence
- **Async projection** that subscribes to events and maintains a counter
- **Heartbeat logger** that reports projection state every 30 seconds

## Quick Start

### Using Docker Compose

```bash
# Build and start all services (PostgreSQL + app)
docker-compose up --build

# In another terminal, test the API
curl -X POST http://localhost:8080/events \
  -H 'Content-Type: application/json' \
  -d '{"amount": 5}'

curl http://localhost:8080/projection

# Monitor logs for heartbeat messages
docker-compose logs -f app
```

### Running Locally

```bash
# Start PostgreSQL
docker-compose up postgres -d

# Build and run the application
cabal build
cabal run long-running-subscription

# Test the API
curl -X POST http://localhost:8080/events \
  -H 'Content-Type: application/json' \
  -d '{"amount": 1}'
```

## API Endpoints

- **POST /events** - Add a counter increment event
  ```json
  {"amount": 5}
  ```

- **GET /projection** - Query the current projection state
  ```json
  {
    "currentCount": 42,
    "lastUpdated": "2025-10-17T12:34:56.789Z"
  }
  ```

- **GET /health** - Health check
  ```json
  {
    "status": "ok",
    "timestamp": "2025-10-17T12:34:56.789Z"
  }
  ```

## Testing Multi-GHC Compatibility

```bash
# Test with GHC 9.10
docker build -f Dockerfile.ghc-9.10 -t hindsight-example:ghc-9.10 .

# Test with GHC 9.12
docker build -f Dockerfile.ghc-9.12 -t hindsight-example:ghc-9.12 .
```

## Monitoring Subscription Health

The application logs a heartbeat message every 30 seconds showing:
- Current projection count
- Last update timestamp
- System time

If the subscription goes stale, the "last updated" timestamp will stop advancing while events continue to be inserted.

## Long-Running Test Protocol

1. Start the application: `docker-compose up -d`
2. Generate periodic events (script or manual curls)
3. Monitor heartbeat logs: `docker-compose logs -f app`
4. Observe for several hours
5. **Expected behavior**: Heartbeat continues, projection count increases
6. **Bug manifestation**: Heartbeat continues, but projection count freezes

## Dependencies

This example references Hindsight packages from GitHub:
- `hindsight-core`
- `hindsight-postgresql-store`
- `hindsight-postgresql-projections`

See `cabal.project` for the exact GitHub source configuration.
