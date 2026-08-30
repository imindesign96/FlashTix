package com.flashtix.api.event;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/events")
class EventController {

    private final EventQueryService service;

    EventController(EventQueryService service) {
        this.service = service;
    }

    @GetMapping
    List<EventResponse> list() {
        return service.findUpcomingEvents();
    }
}
