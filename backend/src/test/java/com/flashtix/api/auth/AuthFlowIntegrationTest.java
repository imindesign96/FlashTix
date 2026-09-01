package com.flashtix.api.auth;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledIfEnvironmentVariable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.servlet.MockMvc;

import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
@EnabledIfEnvironmentVariable(named = "FLASHTIX_RUN_INTEGRATION_TESTS", matches = "true")
class AuthFlowIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private RefreshSessionRepository refreshSessionRepository;

    @Autowired
    private UserRepository userRepository;

    @AfterEach
    void cleanDatabase() {
        refreshSessionRepository.deleteAll();
        userRepository.deleteAll();
    }

    @Test
    void registerAuthenticateRotateAndLogout() throws Exception {
        var email = "alex+" + UUID.randomUUID() + "@example.com";
        var registered = postJson("/api/v1/auth/register", """
                {
                  "email": "%s",
                  "password": "correct-horse-battery-staple",
                  "displayName": "Alex"
                }
                """.formatted(email), 201);
        var accessToken = registered.path("tokens").path("accessToken").asText();
        var refreshToken = registered.path("tokens").path("refreshToken").asText();

        mockMvc.perform(get("/api/v1/users/me")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value(email));

        var refreshed = postJson("/api/v1/auth/refresh", """
                {"refreshToken": "%s"}
                """.formatted(refreshToken), 200);
        var rotatedRefreshToken = refreshed.path("tokens").path("refreshToken").asText();

        mockMvc.perform(post("/api/v1/auth/refresh")
                        .contentType("application/json")
                        .content("""
                                {"refreshToken": "%s"}
                                """.formatted(refreshToken)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("invalid_refresh_token"));

        mockMvc.perform(post("/api/v1/auth/logout")
                        .contentType("application/json")
                        .content("""
                                {"refreshToken": "%s"}
                                """.formatted(rotatedRefreshToken)))
                .andExpect(status().isNoContent());

        mockMvc.perform(post("/api/v1/auth/refresh")
                        .contentType("application/json")
                        .content("""
                                {"refreshToken": "%s"}
                                """.formatted(rotatedRefreshToken)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.code").value("invalid_refresh_token"));
    }

    private JsonNode postJson(String path, String body, int expectedStatus) throws Exception {
        var response = mockMvc.perform(post(path)
                        .contentType("application/json")
                        .content(body))
                .andExpect(status().is(expectedStatus))
                .andReturn()
                .getResponse()
                .getContentAsString();
        return objectMapper.readTree(response);
    }
}
