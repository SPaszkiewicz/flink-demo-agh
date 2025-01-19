package org.flinkdemo.metrics;

import org.apache.flink.api.common.functions.RichMapFunction;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.metrics.Counter;
import org.flinkdemo.model.AmplitudeEvent;
import org.flinkdemo.outbound.KafkaUtil;

import java.util.Random;

public class MetricsEmitter extends RichMapFunction<AmplitudeEvent, AmplitudeEvent> {

    private transient Counter counter;
    private final String kafkaIp;
    private final String metricsTopic;
    private KafkaUtil kafkaConn;
    private long startTime;

    public MetricsEmitter(
            String kafkaIp,
            String metricsTopic
    ){
        this.kafkaIp = kafkaIp;
        this.metricsTopic = metricsTopic;
    }

    @Override
    public void open(
            Configuration parameters
    ) throws java.lang.Exception {
        Random ran = new Random();
        int index = ran.nextInt(8000) + 1000;


        this.kafkaConn = new KafkaUtil(kafkaIp, metricsTopic + '-' + index);
        this.startTime = System.currentTimeMillis();
        super.open(parameters);
        this.counter = getRuntimeContext()
                .getMetricGroup()
                .counter("EventProcessed");
    }

    @Override
    public AmplitudeEvent map(
            AmplitudeEvent value
    ) {
        this.counter.inc();
        if (this.counter.getCount() % 10000 == 0) {
            kafkaConn.sendMessage(System.currentTimeMillis() - this.startTime + "," + this.counter.getCount());
        }

        return value;
    }
}
