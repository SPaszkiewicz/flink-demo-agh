package org.flinkdemo;

import static org.flinkdemo.algorithms.FlinkJobsController.runFlinkJobs;

public class FlinkDemoApp {
    public static void main(String[] args) {
        if (args.length < 2) {
            System.err.println("Usage: MyFlinkJob <kafka-ip> <postgres-ip>");
            System.exit(1);
        }
        runFlinkJobs(args[0], args[1]);
    }
}