package com.flashtix.api.auth;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.Clock;
import java.util.LinkedHashMap;

@RestControllerAdvice
class AuthExceptionHandler {

    private final Clock clock;

    AuthExceptionHandler(Clock clock) {
        this.clock = clock;
    }

    @ExceptionHandler(AuthExceptions.EmailAlreadyUsed.class)
    ResponseEntity<ApiErrorResponse> emailAlreadyUsed() {
        return error(
                HttpStatus.CONFLICT,
                "email_already_used",
                "An account already exists for this email."
        );
    }

    @ExceptionHandler(AuthExceptions.InvalidCredentials.class)
    ResponseEntity<ApiErrorResponse> invalidCredentials() {
        return error(
                HttpStatus.UNAUTHORIZED,
                "invalid_credentials",
                "Email or password is incorrect."
        );
    }

    @ExceptionHandler(AuthExceptions.InvalidRefreshToken.class)
    ResponseEntity<ApiErrorResponse> invalidRefreshToken() {
        return error(
                HttpStatus.UNAUTHORIZED,
                "invalid_refresh_token",
                "The refresh token is invalid or expired."
        );
    }

    @ExceptionHandler(AuthExceptions.UserNotFound.class)
    ResponseEntity<ApiErrorResponse> userNotFound() {
        return error(HttpStatus.UNAUTHORIZED, "invalid_session", "The authenticated user no longer exists.");
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<ApiErrorResponse> validationFailed(MethodArgumentNotValidException exception) {
        var fieldErrors = new LinkedHashMap<String, String>();
        exception.getBindingResult().getFieldErrors().forEach(error ->
                fieldErrors.putIfAbsent(error.getField(), error.getDefaultMessage())
        );
        var response = new ApiErrorResponse(
                "validation_failed",
                "One or more fields are invalid.",
                clock.instant(),
                fieldErrors
        );
        return ResponseEntity.badRequest().body(response);
    }

    private ResponseEntity<ApiErrorResponse> error(HttpStatus status, String code, String message) {
        return ResponseEntity.status(status).body(ApiErrorResponse.of(code, message, clock.instant()));
    }
}
