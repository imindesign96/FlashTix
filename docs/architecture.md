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

## Authentication

The API issues short-lived signed JWT access tokens and persists hashed opaque refresh tokens. Refreshing rotates the stored session inside a transaction protected by a row lock, allowing logout and replay rejection without adding Redis.

The iOS app stores the authenticated session in the Keychain. A `TokenManager` actor owns in-memory token state and a single in-flight refresh task. When concurrent requests receive `401`, they await that shared task and retry once with the replacement access token. A failed refresh clears the Keychain session and returns the app to the signed-out state.

```text
request A ─┐
request B ─┼──▶ TokenManager actor ───▶ one refresh request
request C ─┘               │
                           └──────────▶ rotated Keychain session
```

Password reset, MFA, social login, browser cookies, and distributed revocation remain outside this iteration.
