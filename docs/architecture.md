# Architecture

## Current shape

FlashTix starts as a modular monolith. The backend exposes versioned REST endpoints and owns transactional consistency. The iOS app follows feature-oriented boundaries with lightweight MVVM and dependency injection at composition roots.

```text
┌──────────────┐      HTTPS       ┌──────────────────┐
│   iOS App    │ ───────────────▶ │ Spring Boot API  │
└──────┬───────┘                  └────────┬─────────┘
       │                                   │
       │ local cache (later)               │ JPA
       ▼                                   ▼
   local store                         PostgreSQL
```

## Principles

- Add infrastructure only when a concrete requirement needs it.
- Keep domain logic independent from transport concerns.
- Prefer explicit state machines for async UI flows.
- Treat retries as a distributed-systems concern, not only a networking convenience.
- Measure before optimizing.

## Planned evolution

Redis, queues, WebSocket, distributed tracing, and horizontal scaling are intentionally not part of the first commit. They will be introduced with a measurable reason and documented through ADRs.
