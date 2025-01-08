package org.flinkdemo.inbound;

import org.apache.flink.connector.kafka.source.KafkaSource;
import org.apache.flink.connector.kafka.source.enumerator.initializer.OffsetsInitializer;
import org.flinkdemo.model.AmplitudeEvent;
import org.flinkdemo.utils.AmplitudeEventDeserializationSchema;

public class KafkaConfiguration {

    private static final String KAFKA_TOPIC_NAME = "flink-demo-topic";
    public static KafkaSource<AmplitudeEvent> buildKafkaSource(String kafkaIp) {

        String kafkaBootstrap = kafkaIp + ":9092";
        return KafkaSource.<AmplitudeEvent>builder()
                .setBootstrapServers(kafkaBootstrap)
                .setTopics(KAFKA_TOPIC_NAME)
                .setGroupId("my-flink-job-group")
                .setValueOnlyDeserializer(new AmplitudeEventDeserializationSchema())
                .setStartingOffsets(OffsetsInitializer.latest())
                .build();
    }
}
