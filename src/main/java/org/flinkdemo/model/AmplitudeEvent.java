package org.flinkdemo.model;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.Map;

@Data
@NoArgsConstructor
public class AmplitudeEvent {

    @JsonProperty("user_id")
    private String userId;

    @JsonProperty("event_type")
    private String eventType;

    @JsonProperty("user_properties")
    private Map<String, String> userProperties;

    private String country;
    private String ip;
    private long time;
}