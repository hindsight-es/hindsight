#!/usr/bin/env bash
# Helper script for managing KurrentDB test database

set -euo pipefail

CMD="${1:-help}"

case "$CMD" in
  start)
    echo "Starting KurrentDB..."
    docker compose up -d
    echo "Waiting for KurrentDB to be healthy..."
    timeout 60 bash -c 'until docker compose ps kurrentdb | grep -q "healthy"; do sleep 2; done' || {
      echo "Error: KurrentDB failed to become healthy"
      docker compose logs kurrentdb
      exit 1
    }
    echo "✓ KurrentDB is ready"
    echo "Admin UI: http://localhost:2113"
    echo "gRPC endpoint: localhost:1113"
    ;;

  stop)
    echo "Stopping KurrentDB..."
    docker compose down
    ;;

  restart)
    "$0" stop
    "$0" start
    ;;

  clean)
    echo "Stopping and removing KurrentDB volumes..."
    docker compose down -v
    ;;

  logs)
    docker compose logs -f kurrentdb
    ;;

  status)
    docker compose ps
    ;;

  test)
    echo "Running tests..."
    cabal test hindsight-kurrentdb-store --test-show-details=streaming
    ;;

  help|*)
    cat <<EOF
Usage: $0 {start|stop|restart|clean|logs|status|test}

Commands:
  start    - Start KurrentDB container and wait for health check
  stop     - Stop KurrentDB container
  restart  - Restart KurrentDB container
  clean    - Stop and remove all data (fresh start)
  logs     - Follow KurrentDB logs
  status   - Show container status
  test     - Run test suite (requires KurrentDB to be running)
  help     - Show this message

Examples:
  $0 start        # Start database
  $0 test         # Run tests
  $0 clean        # Clean everything and start fresh
EOF
    ;;
esac
