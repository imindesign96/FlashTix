package com.flashtix.api.event;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

interface EventRepository extends JpaRepository<EventEntity, UUID> {
    List<EventEntity> findAllByOrderByStartsAtAsc();
}
