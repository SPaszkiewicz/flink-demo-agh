package org.flinkdemo;

import java.util.Arrays;

import static org.flinkdemo.algorithms.FlinkJobsController.runFlinkJobs;

public class FlinkDemoApp {
    public static void main(String[] args) {
        if (args.length < 2) {
            System.err.println("Usage: MyFlinkJob <kafka-ip> <postgres-ip>");
            System.exit(1);
        }

        System.out.println("Starting Flink demo with args: " + Arrays.toString(args));
        runFlinkJobs(args[0], args[1]);
    }
}