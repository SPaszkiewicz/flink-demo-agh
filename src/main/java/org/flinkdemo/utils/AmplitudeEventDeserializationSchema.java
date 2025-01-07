package org.flinkdemo.utils;

import org.flinkdemo.model.AmplitudeEvent;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.flink.api.common.serialization.DeserializationSchema;
import org.apache.flink.api.common.typeinfo.TypeInformation;
import java.io.IOException;
import java.nio.charset.StandardCharsets;

public class AmplitudeEventDeserializationSchema implements DeserializationSchema<AmplitudeEvent> {

    private final ObjectMapper mapper = new ObjectMapper();

    @Override
    public AmplitudeEvent deserialize(byte[] message) throws IOException {
        String raw = new String(message, StandardCharsets.UTF_8);
        return mapper.readValue(raw, AmplitudeEvent.class);
    }

    @Override
    public boolean isEndOfStream(AmplitudeEvent nextElement) {
        return false;
    }

    @Override
    public TypeInformation<AmplitudeEvent> getProducedType() {
        return TypeInformation.of(AmplitudeEvent.class);
    }
}
