package org.flinkdemo.model;

import lombok.Data;

@Data
public class EventCount {

    private String eventType;
    private long count;

    public EventCount(String eventType, long count) {
        System.out.println("Received event: " + eventType);
        this.eventType = eventType;
        this.count = count;
    }
}
