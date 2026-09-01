package com.flashtix.api.auth;

import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Locale;
import java.util.UUID;

@Service
class AuthService {

    private final UserRepository userRepository;
    private final RefreshSessionRepository refreshSessionRepository;
    private final PasswordEncoder passwordEncoder;
    private final TokenService tokenService;

    AuthService(
            UserRepository userRepository,
            RefreshSessionRepository refreshSessionRepository,
            PasswordEncoder passwordEncoder,
            TokenService tokenService
    ) {
        this.userRepository = userRepository;
        this.refreshSessionRepository = refreshSessionRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenService = tokenService;
    }

    @Transactional
    AuthResponse register(RegisterRequest request) {
        var email = normalizeEmail(request.email());
        if (userRepository.existsByEmail(email)) {
            throw new AuthExceptions.EmailAlreadyUsed();
        }

        var user = new UserEntity(
                UUID.randomUUID(),
                email,
                passwordEncoder.encode(request.password()),
                request.displayName().trim(),
                tokenService.now()
        );

        try {
            userRepository.saveAndFlush(user);
        } catch (DataIntegrityViolationException error) {
            throw new AuthExceptions.EmailAlreadyUsed();
        }

        return issueSession(user);
    }

    @Transactional
    AuthResponse login(LoginRequest request) {
        var user = userRepository.findByEmail(normalizeEmail(request.email()))
                .orElseThrow(AuthExceptions.InvalidCredentials::new);

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new AuthExceptions.InvalidCredentials();
        }

        return issueSession(user);
    }

    @Transactional
    AuthResponse refresh(RefreshRequest request) {
        var tokenHash = tokenService.hashRefreshToken(request.refreshToken());
        var session = refreshSessionRepository.findByTokenHashForUpdate(tokenHash)
                .orElseThrow(AuthExceptions.InvalidRefreshToken::new);
        var now = tokenService.now();

        if (!session.isActiveAt(now)) {
            throw new AuthExceptions.InvalidRefreshToken();
        }

        session.revokeAt(now);
        return issueSession(session.getUser());
    }

    @Transactional
    void logout(LogoutRequest request) {
        var tokenHash = tokenService.hashRefreshToken(request.refreshToken());
        refreshSessionRepository.findByTokenHashForUpdate(tokenHash)
                .ifPresent(session -> session.revokeAt(tokenService.now()));
    }

    @Transactional(readOnly = true)
    UserResponse currentUser(UUID userId) {
        return userRepository.findById(userId)
                .map(UserResponse::from)
                .orElseThrow(AuthExceptions.UserNotFound::new);
    }

    private AuthResponse issueSession(UserEntity user) {
        var accessToken = tokenService.createAccessToken(user);
        var refreshToken = tokenService.createRefreshToken();
        var now = tokenService.now();
        var refreshSession = new RefreshSessionEntity(
                UUID.randomUUID(),
                user,
                tokenService.hashRefreshToken(refreshToken),
                tokenService.refreshTokenExpiresAt(),
                now
        );
        refreshSessionRepository.save(refreshSession);

        return new AuthResponse(
                UserResponse.from(user),
                new AuthTokensResponse(accessToken.value(), refreshToken, accessToken.expiresAt())
        );
    }

    private String normalizeEmail(String email) {
        return email.trim().toLowerCase(Locale.ROOT);
    }
}
