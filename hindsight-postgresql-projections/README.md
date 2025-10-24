# hindsight-postgresql-projections

Backend-agnostic PostgreSQL projections for building read models.

## Overview

`hindsight-postgresql-projections` provides a projection system for transforming event streams into read models (database views). The key insight: **projections always use PostgreSQL for execution and state management, but can subscribe to events from any backend** (Memory, Filesystem, or PostgreSQL).

## License

BSD-3-Clause. See [LICENSE](../LICENSE) for details.
