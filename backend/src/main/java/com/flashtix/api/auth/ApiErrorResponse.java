package com.flashtix.api.auth;

import java.time.Instant;
import java.util.Map;

record ApiErrorResponse(
        String code,
        String message,
        Instant timestamp,
        Map<String, String> fieldErrors
) {
    static ApiErrorResponse of(String code, String message, Instant timestamp) {
        return new ApiErrorResponse(code, message, timestamp, Map.of());
    }
}
