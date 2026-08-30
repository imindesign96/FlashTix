package com.flashtix.api.event;

import java.time.Instant;
import java.util.UUID;

record EventResponse(
        UUID id,
        String title,
        String subtitle,
        String venue,
        Instant startsAt,
        String imageURL,
        long minimumPrice,
        String currency
) {
    static EventResponse from(EventEntity event) {
        return new EventResponse(
                event.getId(),
                event.getTitle(),
                event.getSubtitle(),
                event.getVenue(),
                event.getStartsAt(),
                event.getImageUrl(),
                event.getMinimumPrice(),
                event.getCurrency()
        );
    }
}
