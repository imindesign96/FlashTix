# Engineering Roadmap

## Iteration 1 — Vertical slice

- [x] iOS app shell and event feed
- [x] Spring Boot event catalog endpoint
- [x] PostgreSQL schema and seed data
- [x] Local Docker environment
- [x] Basic CI

## Iteration 2 — Authentication

- [x] Sign up / sign in
- [x] Short-lived JWT access tokens and rotating refresh sessions
- [x] Keychain storage
- [x] Single-flight refresh using an actor
- [x] Request retry policy with cancellation awareness
- [x] Authentication integration and concurrency tests

## Iteration 3 — Feed at scale

- Cursor pagination
- Search and category filters
- Memory + disk image cache
- Local persistence and offline feed
- Backend query indexes and pagination benchmarks

## Iteration 4 — Ticket hold

- Inventory model
- 5-minute reservation expiry
- Idempotency keys
- Optimistic/pessimistic locking experiments
- Concurrent booking tests
- Redis only if the measured design needs it

## Iteration 5 — Realtime and async processing

- WebSocket inventory updates
- AsyncStream on iOS
- Booking events
- Queue-based notification worker
- Retry and dead-letter handling

## Iteration 6 — Production engineering

- Metrics and structured logging
- Distributed request IDs and tracing
- k6 load tests
- RDS/S3/CloudFront/ECS deployment
- Performance profiling with Instruments
- Failure-mode and capacity documentation
