package com.flashtix.api.auth;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.Instant;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    private static final Instant NOW = Instant.parse("2026-09-01T01:00:00Z");
    private static final Instant ACCESS_EXPIRES_AT = Instant.parse("2026-09-01T01:15:00Z");
    private static final Instant REFRESH_EXPIRES_AT = Instant.parse("2026-10-01T01:00:00Z");

    @Mock
    private UserRepository userRepository;

    @Mock
    private RefreshSessionRepository refreshSessionRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private TokenService tokenService;

    private AuthService service;

    @BeforeEach
    void setUp() {
        service = new AuthService(userRepository, refreshSessionRepository, passwordEncoder, tokenService);
    }

    @Test
    void register_normalizesEmailHashesPasswordAndIssuesSession() {
        when(userRepository.existsByEmail("alex@example.com")).thenReturn(false);
        when(passwordEncoder.encode("correct-horse")).thenReturn("{bcrypt}password-hash");
        when(tokenService.now()).thenReturn(NOW);
        stubIssuedTokens();

        var response = service.register(new RegisterRequest(
                "  Alex@Example.COM ",
                "correct-horse",
                " Alex "
        ));

        var userCaptor = ArgumentCaptor.forClass(UserEntity.class);
        verify(userRepository).saveAndFlush(userCaptor.capture());
        assertEquals("alex@example.com", userCaptor.getValue().getEmail());
        assertEquals("{bcrypt}password-hash", userCaptor.getValue().getPasswordHash());
        assertEquals("Alex", userCaptor.getValue().getDisplayName());
        assertEquals("access-token", response.tokens().accessToken());
        assertEquals("refresh-token", response.tokens().refreshToken());
        verify(refreshSessionRepository).save(any(RefreshSessionEntity.class));
    }

    @Test
    void login_rejectsUnknownEmailWithoutCheckingPassword() {
        when(userRepository.findByEmail("missing@example.com")).thenReturn(Optional.empty());

        assertThrows(
                AuthExceptions.InvalidCredentials.class,
                () -> service.login(new LoginRequest("missing@example.com", "password"))
        );

        verify(passwordEncoder, never()).matches(any(), any());
        verify(refreshSessionRepository, never()).save(any());
    }

    @Test
    void refresh_revokesPresentedSessionAndIssuesReplacement() {
        var user = user();
        var existingSession = new RefreshSessionEntity(
                java.util.UUID.randomUUID(),
                user,
                "old-hash",
                REFRESH_EXPIRES_AT,
                NOW.minusSeconds(60)
        );
        when(tokenService.hashRefreshToken("old-refresh-token")).thenReturn("old-hash");
        when(refreshSessionRepository.findByTokenHashForUpdate("old-hash"))
                .thenReturn(Optional.of(existingSession));
        when(tokenService.now()).thenReturn(NOW);
        stubIssuedTokens();

        var response = service.refresh(new RefreshRequest("old-refresh-token"));

        assertFalse(existingSession.isActiveAt(NOW));
        assertEquals("refresh-token", response.tokens().refreshToken());
        verify(refreshSessionRepository).save(any(RefreshSessionEntity.class));
    }

    private void stubIssuedTokens() {
        when(tokenService.createAccessToken(any(UserEntity.class)))
                .thenReturn(new TokenService.AccessToken("access-token", ACCESS_EXPIRES_AT));
        when(tokenService.createRefreshToken()).thenReturn("refresh-token");
        when(tokenService.hashRefreshToken("refresh-token")).thenReturn("refresh-hash");
        when(tokenService.refreshTokenExpiresAt()).thenReturn(REFRESH_EXPIRES_AT);
    }

    private UserEntity user() {
        return new UserEntity(
                java.util.UUID.randomUUID(),
                "alex@example.com",
                "{bcrypt}password-hash",
                "Alex",
                NOW.minusSeconds(60)
        );
    }
}
