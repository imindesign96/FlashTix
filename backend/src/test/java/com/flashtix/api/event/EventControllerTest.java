package com.flashtix.api.event;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.test.context.bean.override.mockito.MockitoBean;
import org.springframework.test.web.servlet.MockMvc;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(EventController.class)
class EventControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockitoBean
    private EventQueryService service;

    @Test
    void list_returnsUpcomingEvents() throws Exception {
        var event = new EventResponse(
                UUID.fromString("7dc8b778-c268-49f0-9514-1af81f6f2244"),
                "Coldplay",
                "Music of the Spheres World Tour",
                "National Stadium, Hanoi",
                Instant.parse("2026-10-20T12:00:00Z"),
                null,
                1_200_000,
                "VND"
        );
        when(service.findUpcomingEvents()).thenReturn(List.of(event));

        mockMvc.perform(get("/api/v1/events"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].title").value("Coldplay"))
                .andExpect(jsonPath("$[0].minimumPrice").value(1_200_000));
    }
}
