package com.flashtix.api.auth;

import java.time.Instant;

record AuthTokensResponse(
        String accessToken,
        String refreshToken,
        Instant accessTokenExpiresAt
) {
}
