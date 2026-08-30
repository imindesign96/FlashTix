package com.flashtix.api.event;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
class EventQueryService {

    private final EventRepository repository;

    EventQueryService(EventRepository repository) {
        this.repository = repository;
    }

    @Transactional(readOnly = true)
    List<EventResponse> findUpcomingEvents() {
        return repository.findAllByOrderByStartsAtAsc()
                .stream()
                .map(EventResponse::from)
                .toList();
    }
}
