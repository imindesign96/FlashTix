package com.flashtix.api.auth;

import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/users")
class CurrentUserController {

    private final AuthService service;

    CurrentUserController(AuthService service) {
        this.service = service;
    }

    @GetMapping("/me")
    UserResponse me(JwtAuthenticationToken authentication) {
        return service.currentUser(UUID.fromString(authentication.getName()));
    }
}
