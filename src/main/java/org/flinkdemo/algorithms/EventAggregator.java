package org.flinkdemo.algorithms;

import static org.flinkdemo.outbound.PostgresUtil.eventAggregatorSink;

import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.common.functions.ReduceFunction;
import org.apache.flink.connector.kafka.source.KafkaSource;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.windowing.assigners.TumblingProcessingTimeWindows;
import org.apache.flink.streaming.api.windowing.time.Time;
import org.flinkdemo.model.AmplitudeEvent;
import org.flinkdemo.model.EventCount;

public class EventAggregator {

    public static void performEventAggregation(
        StreamExecutionEnvironment env, KafkaSource<AmplitudeEvent> kafkaSource, String postgresIp
    ) throws Exception {

        var sourceStream = env.fromSource(
                kafkaSource,
                WatermarkStrategy.noWatermarks(),
                "Kafka Source"
        );

        var aggregatedStream = sourceStream
                .map(event -> new EventCount(event.getEventType(), 1L))
                .keyBy(EventCount::getEventType)
                .window(TumblingProcessingTimeWindows.of(Time.seconds(10)))
                .reduce(eventCountReduceFunction());

        var jdbcSink = eventAggregatorSink(postgresIp);

        aggregatedStream.addSink(jdbcSink);

        env.execute("MyFlinkJob -> Event Aggregation");
    }

    private static ReduceFunction<EventCount> eventCountReduceFunction() {
        return (t1, t2) -> {
            t1.setCount(t1.getCount() + t2.getCount());
            return t1;
        };
    }
}
