# FlashTix

FlashTix is a full-stack event booking project built to practice production-grade iOS and backend engineering: concurrency, offline-friendly networking, modular architecture, booking consistency, observability, load testing, and system design.

## Repository layout

```text
FlashTix/
├── ios/        # Native iOS app (SwiftUI + UIKit interop)
├── backend/    # Spring Boot API
├── docs/       # Architecture notes and ADRs
└── compose.yaml
```

## Product scope

The first vertical slice is deliberately small: browse events from the backend and render them in the iOS home feed. Booking, ticket holds, authentication, realtime inventory, and payments will be added incrementally so each architectural decision is driven by a real problem.

## Local development

### Backend prerequisites

- Java 21
- Gradle 8.10+
- PostgreSQL 16 (or Docker)

### iOS prerequisites

- Xcode 16+
- XcodeGen
- iOS 17+

Generate the Xcode project:

```bash
cd ios
xcodegen generate
open FlashTix.xcodeproj
```

Run the backend:

```bash
cd backend
gradle bootRun
```

The API defaults to `http://localhost:8080`.

## Engineering roadmap

1. Foundation + event feed vertical slice
2. Authentication + token refresh coordination
3. Cursor pagination + caching + offline read model
4. Ticket hold with idempotency and database locking
5. Realtime inventory over WebSocket
6. Async booking events and notifications
7. Load testing, metrics, tracing, and scaling
