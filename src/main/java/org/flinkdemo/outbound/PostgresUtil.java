package org.flinkdemo.outbound;

import org.apache.flink.connector.jdbc.JdbcConnectionOptions;
import org.apache.flink.connector.jdbc.JdbcSink;
import org.apache.flink.streaming.api.functions.sink.SinkFunction;
import org.flinkdemo.model.EventCount;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.sql.Statement;

public class PostgresUtil {

    private static final String POSTGRES_USER = "postgres";
    private static final String POSTGRES_PASSWORD = "postgres";

    public static SinkFunction<EventCount> eventAggregatorSink(String postgresIp) {

        String postgresDBUrl = "jdbc:postgresql://" + postgresIp + ":5432/flinkdb";

        String upsertSQL =
                "INSERT INTO event_aggregator(event_type, event_count) " +
                "VALUES (?, ?) " +
                "ON CONFLICT (event_type) " +
                "DO UPDATE SET event_count = events.event_count + EXCLUDED.event_count";

        return JdbcSink.sink(
                upsertSQL,
                (ps, event) -> {
                    ps.setString(1, event.getEventType());
                    ps.setLong(2, event.getCount());
                },
                new JdbcConnectionOptions.JdbcConnectionOptionsBuilder()
                        .withUrl(postgresDBUrl)
                        .withDriverName("org.postgresql.Driver")
                        .withUsername(POSTGRES_USER)
                        .withPassword(POSTGRES_PASSWORD)
                        .build()
        );
    }

    public static void createTablesIfNecessary(String postgresIp) {
        var postgresDBUrl = "jdbc:postgresql://" + postgresIp + ":5432/flinkdb";

        var createTableSQL = "CREATE TABLE IF NOT EXISTS event_aggregator (" +
                             "event_type VARCHAR(64) PRIMARY KEY, " +
                             "event_count BIGINT NOT NULL DEFAULT 0)";

        try (Connection conn = DriverManager.getConnection(postgresDBUrl, POSTGRES_USER, POSTGRES_PASSWORD);
             Statement stmt = conn.createStatement()) {

            stmt.execute(createTableSQL);

        } catch (SQLException e) {
            throw new RuntimeException("Failed to create table", e);
        }
    }
}
