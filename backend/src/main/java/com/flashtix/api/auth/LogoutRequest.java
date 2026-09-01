package com.flashtix.api.auth;

import jakarta.validation.constraints.NotBlank;

record LogoutRequest(@NotBlank String refreshToken) {
}
