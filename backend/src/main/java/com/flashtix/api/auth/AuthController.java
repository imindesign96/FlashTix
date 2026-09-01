package com.flashtix.api.auth;

import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/auth")
class AuthController {

    private final AuthService service;

    AuthController(AuthService service) {
        this.service = service;
    }

    @PostMapping("/register")
    ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(service.register(request));
    }

    @PostMapping("/login")
    AuthResponse login(@Valid @RequestBody LoginRequest request) {
        return service.login(request);
    }

    @PostMapping("/refresh")
    AuthResponse refresh(@Valid @RequestBody RefreshRequest request) {
        return service.refresh(request);
    }

    @PostMapping("/logout")
    ResponseEntity<Void> logout(@Valid @RequestBody LogoutRequest request) {
        service.logout(request);
        return ResponseEntity.noContent().build();
    }
}
