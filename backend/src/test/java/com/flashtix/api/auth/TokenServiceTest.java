package com.flashtix.api.auth;

import org.junit.jupiter.api.Test;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotEquals;

class TokenServiceTest {

    @Test
    void accessToken_containsUserClaimsAndConfiguredExpiration() {
        var now = Instant.parse("2026-09-01T01:00:00Z");
        var clock = Clock.fixed(now, ZoneOffset.UTC);
        var properties = new AuthProperties(
                "flashtix-test",
                "0123456789abcdef0123456789abcdef",
                Duration.ofMinutes(15),
                Duration.ofDays(30)
        );
        var configuration = new SecurityConfiguration();
        var secretKey = configuration.jwtSecretKey(properties);
        var encoder = configuration.jwtEncoder(secretKey);
        var decoder = configuration.jwtDecoder(secretKey, properties);
        var service = new TokenService(encoder, properties, clock);
        var user = new UserEntity(
                UUID.randomUUID(),
                "alex@example.com",
                "{bcrypt}password-hash",
                "Alex",
                now
        );

        var accessToken = service.createAccessToken(user);
        var jwt = decoder.decode(accessToken.value());

        assertEquals(user.getId().toString(), jwt.getSubject());
        assertEquals("alex@example.com", jwt.getClaimAsString("email"));
        assertEquals("Alex", jwt.getClaimAsString("name"));
        assertEquals(now.plus(Duration.ofMinutes(15)), accessToken.expiresAt());
    }

    @Test
    void refreshTokens_areRandomAndHashable() {
        var properties = new AuthProperties(
                "flashtix-test",
                "0123456789abcdef0123456789abcdef",
                Duration.ofMinutes(15),
                Duration.ofDays(30)
        );
        var configuration = new SecurityConfiguration();
        var secretKey = configuration.jwtSecretKey(properties);
        var service = new TokenService(
                configuration.jwtEncoder(secretKey),
                properties,
                Clock.systemUTC()
        );

        var first = service.createRefreshToken();
        var second = service.createRefreshToken();

        assertNotEquals(first, second);
        assertEquals(64, service.hashRefreshToken(first).length());
    }
}
