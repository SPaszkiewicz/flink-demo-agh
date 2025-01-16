package org.flinkdemo.algorithms;

import static org.flinkdemo.outbound.PostgresUtil.eventAggregatorSink;

import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.common.functions.ReduceFunction;
import org.apache.flink.api.common.functions.RichMapFunction;
import org.apache.flink.configuration.Configuration;
import org.apache.flink.connector.kafka.source.KafkaSource;
import org.apache.flink.metrics.Counter;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.windowing.assigners.TumblingProcessingTimeWindows;
import org.apache.flink.streaming.api.windowing.time.Time;
import org.flinkdemo.model.AmplitudeEvent;
import org.flinkdemo.model.EventCount;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
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
                .map(new MetricEnrichedMapper())
                .keyBy(EventCount::getEventType)
                .window(TumblingProcessingTimeWindows.of(Time.seconds(10)))
                .reduce(eventCountReduceFunction());

        var jdbcSink = eventAggregatorSink(postgresIp);

        aggregatedStream.addSink(jdbcSink);

        System.out.println("Execute Job");
        env.execute("MyFlinkJob -> Event Aggregation");
    }

    private static ReduceFunction<EventCount> eventCountReduceFunction() {
        return (t1, t2) -> {
            t1.setCount(t1.getCount() + t2.getCount());
            return t1;
        };
    }

    public static class MetricEnrichedMapper extends RichMapFunction<AmplitudeEvent, EventCount> {

        private transient Counter eventCounter;
        private transient ScheduledExecutorService scheduler;

        @Override
        public void open(Configuration parameters) {
            this.eventCounter = getRuntimeContext()
                    .getMetricGroup()
                    .counter("incoming_events_total");

            this.scheduler = Executors.newSingleThreadScheduledExecutor();
            this.scheduler.scheduleAtFixedRate(() -> {
                System.out.println("Counter value: " + eventCounter.getCount());
            }, 0, 10, TimeUnit.SECONDS);
        }

        @Override
        public EventCount map(AmplitudeEvent event) {
            this.eventCounter.inc();
            return new EventCount(event.getEventType(), 1L);
        }

        @Override
        public void close() {
            if (scheduler != null && !scheduler.isShutdown()) {
                scheduler.shutdown();
            }
        }
    }
}
