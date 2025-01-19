package org.flinkdemo.outbound;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;

public class KafkaUtil {
    private final String topic;
    private final KafkaProducer producer;

    public KafkaUtil(
            String kafkaIp,
            String topic
    ) {
        this.topic = topic;
        Properties config = new Properties();
        config.setProperty(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, kafkaIp + ":9092");
        config.setProperty(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        config.setProperty(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        this.producer = new KafkaProducer<>(config);
    }

    public void sendMessage(String message) {
        ProducerRecord<String, String> record = new ProducerRecord<>(this.topic, message);
        this.producer.send(record);
        this.producer.flush();
    }
}
