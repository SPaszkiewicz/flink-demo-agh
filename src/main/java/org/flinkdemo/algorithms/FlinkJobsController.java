package org.flinkdemo.algorithms;

import static org.flinkdemo.algorithms.EventAggregator.performEventAggregation;
import static org.flinkdemo.outbound.PostgresUtil.createTablesIfNecessary;

import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.flinkdemo.inbound.KafkaConfiguration;

public class FlinkJobsController {

    public static void runFlinkJobs(String kafkaIp, String postgresIp) {

        createTablesIfNecessary(postgresIp);

        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        var kafkaSource = KafkaConfiguration.buildKafkaSource(kafkaIp);

        try {
            performEventAggregation(env, kafkaSource, postgresIp);
        } catch (Exception e) {
            throw new RuntimeException("Failed to run event aggregation job", e);
        }
    }
}
