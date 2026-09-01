package com.flashtix.api.auth;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Clock;
import java.time.Instant;
import java.util.UUID;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(AuthController.class)
@AutoConfigureMockMvc(addFilters = false)
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private AuthService service;

    @MockitoBean
    private Clock clock;

    @Test
    void register_returnsCreatedSession() throws Exception {
        when(service.register(any())).thenReturn(authResponse());

        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType("application/json")
                        .content("""
                                {
                                  "email": "alex@example.com",
                                  "password": "correct-horse",
                                  "displayName": "Alex"
                                }
                                """))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.user.email").value("alex@example.com"))
                .andExpect(jsonPath("$.tokens.accessToken").value("access-token"))
                .andExpect(jsonPath("$.tokens.refreshToken").value("refresh-token"));
    }

    @Test
    void register_rejectsInvalidFields() throws Exception {
        when(clock.instant()).thenReturn(Instant.parse("2026-09-01T01:00:00Z"));

        mockMvc.perform(post("/api/v1/auth/register")
                        .contentType("application/json")
                        .content("""
                                {
                                  "email": "not-an-email",
                                  "password": "short",
                                  "displayName": ""
                                }
                                """))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("validation_failed"))
                .andExpect(jsonPath("$.fieldErrors.email").exists())
                .andExpect(jsonPath("$.fieldErrors.password").exists())
                .andExpect(jsonPath("$.fieldErrors.displayName").exists());
    }

    private AuthResponse authResponse() {
        var expiresAt = Instant.parse("2026-09-01T01:15:00Z");
        return new AuthResponse(
                new UserResponse(UUID.randomUUID(), "alex@example.com", "Alex"),
                new AuthTokensResponse("access-token", "refresh-token", expiresAt)
        );
    }
}
