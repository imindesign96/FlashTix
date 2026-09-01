package com.flashtix.api.auth;

final class AuthExceptions {
    private AuthExceptions() {
    }

    static final class EmailAlreadyUsed extends RuntimeException {
    }

    static final class InvalidCredentials extends RuntimeException {
    }

    static final class InvalidRefreshToken extends RuntimeException {
    }

    static final class UserNotFound extends RuntimeException {
    }
}
