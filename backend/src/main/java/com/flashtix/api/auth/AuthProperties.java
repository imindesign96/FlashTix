package com.flashtix.api.auth;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.time.Duration;

@ConfigurationProperties("flashtix.auth")
record AuthProperties(
        String issuer,
        String signingSecret,
        Duration accessTokenTtl,
        Duration refreshTokenTtl
) {
}
