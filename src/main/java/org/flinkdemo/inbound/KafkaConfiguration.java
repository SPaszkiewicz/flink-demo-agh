package org.flinkdemo.inbound;

import org.apache.flink.connector.kafka.source.KafkaSource;
import org.apache.flink.connector.kafka.source.enumerator.initializer.OffsetsInitializer;
import org.flinkdemo.model.AmplitudeEvent;
import org.flinkdemo.utils.AmplitudeEventDeserializationSchema;

import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.util.Random;

public class KafkaConfiguration {

    private static final String KAFKA_TOPIC_NAME = "flink-demo-topic";
    public static KafkaSource<AmplitudeEvent> buildKafkaSource(String kafkaIp) {

        byte[] array = new byte[7]; // length is bounded by 7
        new Random().nextBytes(array);
        String generatedString = new String(array, StandardCharsets.UTF_8);

        String kafkaBootstrap = kafkaIp + ":9092";
        return KafkaSource.<AmplitudeEvent>builder()
                .setBootstrapServers(kafkaBootstrap)
                .setTopics(KAFKA_TOPIC_NAME)
                .setGroupId("my-flink-job-group-" + generatedString)
                .setValueOnlyDeserializer(new AmplitudeEventDeserializationSchema())
                .setStartingOffsets(OffsetsInitializer.earliest())
                .build();
    }
}
