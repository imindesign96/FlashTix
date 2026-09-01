package com.flashtix.api.auth;

import java.util.UUID;

record UserResponse(UUID id, String email, String displayName) {
    static UserResponse from(UserEntity user) {
        return new UserResponse(user.getId(), user.getEmail(), user.getDisplayName());
    }
}
