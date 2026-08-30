package com.flashtix.api.event;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "events")
class EventEntity {

    @Id
    private UUID id;

    @Column(nullable = false, length = 160)
    private String title;

    @Column(nullable = false, length = 240)
    private String subtitle;

    @Column(nullable = false, length = 200)
    private String venue;

    @Column(name = "starts_at", nullable = false)
    private Instant startsAt;

    @Column(name = "image_url")
    private String imageUrl;

    @Column(name = "minimum_price", nullable = false)
    private long minimumPrice;

    @Column(nullable = false, length = 3)
    private String currency;

    protected EventEntity() {
    }

    UUID getId() {
        return id;
    }

    String getTitle() {
        return title;
    }

    String getSubtitle() {
        return subtitle;
    }

    String getVenue() {
        return venue;
    }

    Instant getStartsAt() {
        return startsAt;
    }

    String getImageUrl() {
        return imageUrl;
    }

    long getMinimumPrice() {
        return minimumPrice;
    }

    String getCurrency() {
        return currency;
    }
}
