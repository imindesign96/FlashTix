package com.flashtix.api.auth;

record AuthResponse(UserResponse user, AuthTokensResponse tokens) {
}
