package com.flashtix.api.auth;

import org.springframework.security.oauth2.jose.jws.MacAlgorithm;
import org.springframework.security.oauth2.jwt.JwtClaimsSet;
import org.springframework.security.oauth2.jwt.JwtEncoder;
import org.springframework.security.oauth2.jwt.JwtEncoderParameters;
import org.springframework.security.oauth2.jwt.JwsHeader;
import org.springframework.stereotype.Service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Clock;
import java.time.Instant;
import java.util.Base64;
import java.util.HexFormat;

@Service
class TokenService {

    private static final int REFRESH_TOKEN_BYTES = 32;

    private final JwtEncoder jwtEncoder;
    private final AuthProperties properties;
    private final Clock clock;
    private final SecureRandom secureRandom = new SecureRandom();

    TokenService(JwtEncoder jwtEncoder, AuthProperties properties, Clock clock) {
        this.jwtEncoder = jwtEncoder;
        this.properties = properties;
        this.clock = clock;
    }

    AccessToken createAccessToken(UserEntity user) {
        var issuedAt = clock.instant();
        var expiresAt = issuedAt.plus(properties.accessTokenTtl());
        var claims = JwtClaimsSet.builder()
                .issuer(properties.issuer())
                .subject(user.getId().toString())
                .issuedAt(issuedAt)
                .expiresAt(expiresAt)
                .claim("email", user.getEmail())
                .claim("name", user.getDisplayName())
                .build();
        var header = JwsHeader.with(MacAlgorithm.HS256).build();
        var token = jwtEncoder.encode(JwtEncoderParameters.from(header, claims));

        return new AccessToken(token.getTokenValue(), expiresAt);
    }

    String createRefreshToken() {
        var bytes = new byte[REFRESH_TOKEN_BYTES];
        secureRandom.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    String hashRefreshToken(String token) {
        try {
            var digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(token.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException error) {
            throw new IllegalStateException("SHA-256 is not available", error);
        }
    }

    Instant refreshTokenExpiresAt() {
        return clock.instant().plus(properties.refreshTokenTtl());
    }

    Instant now() {
        return clock.instant();
    }

    record AccessToken(String value, Instant expiresAt) {
    }
}
