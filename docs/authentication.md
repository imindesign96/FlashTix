# Authentication contract

## Scope

The first authentication iteration supports email registration, login, refresh-token rotation, logout, and a protected current-user endpoint.

Access tokens are short-lived JWTs. Refresh tokens are opaque random values: the client keeps the raw value in the Keychain while the API stores only a SHA-256 hash. Refreshing revokes the presented session and creates a replacement in the same database transaction.

## Endpoints

### Register

```http
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "alex@example.com",
  "password": "correct-horse-battery-staple",
  "displayName": "Alex"
}
```

Returns `201 Created` with an authenticated session.

### Login

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "alex@example.com",
  "password": "correct-horse-battery-staple"
}
```

Returns `200 OK`. Unknown emails and incorrect passwords share the same `invalid_credentials` response.

### Refresh

```http
POST /api/v1/auth/refresh
Content-Type: application/json

{
  "refreshToken": "opaque-token"
}
```

Returns `200 OK` with a new access token and a rotated refresh token. An expired, revoked, or unknown token returns `401 Unauthorized` with `invalid_refresh_token`.

### Logout

```http
POST /api/v1/auth/logout
Content-Type: application/json

{
  "refreshToken": "opaque-token"
}
```

Returns `204 No Content`. Repeating logout is safe.

### Current user

```http
GET /api/v1/users/me
Authorization: Bearer <access-token>
```

Returns `200 OK` with the authenticated user.

## Session response

```json
{
  "user": {
    "id": "9d95cd0e-9d64-49d7-a3ea-63e164608d3e",
    "email": "alex@example.com",
    "displayName": "Alex"
  },
  "tokens": {
    "accessToken": "eyJ...",
    "refreshToken": "opaque-token",
    "accessTokenExpiresAt": "2026-09-01T01:15:00Z"
  }
}
```

## Error response

```json
{
  "code": "invalid_credentials",
  "message": "Email or password is incorrect.",
  "timestamp": "2026-09-01T01:00:00Z",
  "fieldErrors": {}
}
```

Stable error codes are part of the mobile contract. Human-readable messages may change and must not drive client behavior.

## Security and concurrency rules

- Emails are trimmed and normalized to lowercase before lookup.
- Passwords are encoded through Spring Security's delegating password encoder; plaintext passwords are never persisted or logged.
- JWT signing material comes from configuration and must be replaced outside local development.
- Refresh-token rotation is protected by a database row lock, so one stored session cannot be rotated successfully twice.
- The iOS client retries a request after `401` at most once.
- Concurrent iOS requests share one in-flight refresh operation.

## Non-goals

- Social login, email verification, password reset, MFA, device management, and administrator roles.
- Distributed token revocation or Redis-backed sessions.
- Browser cookies and CSRF-based browser authentication.
