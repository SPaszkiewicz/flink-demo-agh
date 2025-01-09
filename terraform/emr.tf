resource "aws_emr_cluster" "cluster" {
  name          = "flink-demo"
  release_label = "emr-6.14.0"
  applications  = ["Flink"]

  termination_protection            = false
  keep_job_flow_alive_when_no_steps = true
  service_role = local.emr_core_arn

  depends_on = [
    aws_s3_bucket.s3_bucket,
    aws_s3_object.upload_emr_instances_config,
    aws_s3_object.upload_sidecar_service,
    aws_s3_object.upload_sidecar_config
  ]

  ec2_attributes {
    subnet_id                         = aws_subnet.private_subnets[0].id
    emr_managed_master_security_group = aws_security_group.allow_access_emr.id
    emr_managed_slave_security_group  = aws_security_group.allow_access_emr.id
    instance_profile                  = local.emr_ec2_arn
  }

  master_instance_fleet {
    instance_type_configs {
      instance_type = var.EC2_MASTER_TYPE
    }
    target_on_demand_capacity = 1
    launch_specifications {
      spot_specification {
        allocation_strategy      = "capacity-optimized"
        block_duration_minutes   = 0
        timeout_action           = "SWITCH_TO_ON_DEMAND"
        timeout_duration_minutes = 15
      }
    }
  }

  core_instance_fleet {
    name                      = "core fleet"
    target_on_demand_capacity = 1

    instance_type_configs {
      bid_price_as_percentage_of_on_demand_price = 100
      ebs_config {
        size                 = 15
        type                 = "gp2"
        volumes_per_instance = 1
      }
      instance_type     = var.EC2_SLAVE_TYPE
      weighted_capacity = var.NUM_OF_INSTANCES
    }

    launch_specifications {
      spot_specification {
        allocation_strategy      = "capacity-optimized"
        block_duration_minutes   = 0
        timeout_action           = "SWITCH_TO_ON_DEMAND"
        timeout_duration_minutes = 15
      }
    }
  }
  ebs_root_volume_size = 15

  log_uri = "s3://${var.BUCKET_NAME}/log"

  tags = {
    role = "Emr service"
    env  = "Emr env"
  }

  configurations_json = <<EOF
  [
  {
    "Classification": "hadoop-env",
    "Configurations": [
      {
        "Classification": "export",
        "Properties": {
          "JAVA_HOME": "/usr/lib/jvm/java-11-amazon-corretto.x86_64"
        }
      }
    ],
    "Properties": {}
  },
  {
    "Classification": "flink-conf",
    "Properties": {
      "containerized.master.env.JAVA_HOME": "/usr/lib/jvm/java-11-amazon-corretto.x86_64",
      "containerized.taskmanager.env.JAVA_HOME": "/usr/lib/jvm/java-11-amazon-corretto.x86_64",
      "env.java.home": "/usr/lib/jvm/java-11-amazon-corretto.x86_64",
      "jobmanager.heap.size": "1024m",
      "jobmanager.web.address": "0.0.0.0",
      "metrics.reporter.stsd.class": "org.apache.flink.metrics.statsd.StatsDReporter",
      "metrics.reporter.stsd.factory.class": "org.apache.flink.metrics.statsd.StatsDReporterFactory",
      "metrics.reporter.stsd.host": "localhost",
      "metrics.reporter.stsd.port": "8125",
      "metrics.reporters": "stsd",
      "metrics.scope.jm": "jobmanager",
      "metrics.scope.jm.job": "jobmanager.<job_id>",
      "metrics.scope.operator": "taskmanager.<tm_id>.<job_name>.<operator_name>.<subtask_index>",
      "metrics.scope.task": "taskmanager.<tm_id>.<job_name>.<task_name>.<subtask_index>",
      "metrics.scope.tm": "taskmanager.<tm_id>",
      "metrics.scope.tm.job": "taskmanager.<tm_id>.<job_id>",
      "rest.address": "0.0.0.0",
      "taskmanager.memory.process.size": "1728m"
    }
  }
]
EOF

  bootstrap_action {
    name = "bootstrap-ec2-configuration"
    path = "s3://${aws_s3_object.upload_emr_instances_config.bucket}/scripts/setup-emr-instances.sh"
    args = [aws_instance.kafka_instance.private_ip, aws_s3_object.upload_emr_instances_config.bucket]
  }

  step {
    action_on_failure = "CONTINUE"
    name              = "add-libraries"
    hadoop_jar_step {
      jar   = "command-runner.jar"
      args  = ["sudo" ,"wget", "https://repo1.maven.org/maven2/org/apache/flink/flink-metrics-statsd/1.17.1/flink-metrics-statsd-1.17.1.jar" ,"-P", "/usr/lib/flink/lib/"]
    }
  }

  step {
    action_on_failure = "TERMINATE_CLUSTER"
    name              = "create-algorithms-directory"
    hadoop_jar_step {
      jar   = "command-runner.jar"
      args  = ["sudo", "mkdir", "/usr/lib/flink/algorithms"]
    }
  }

  step {
    action_on_failure = "TERMINATE_CLUSTER"
    name              = "copy-job-jar"
    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = [
        "bash",
        "-c",
        "sudo aws s3 cp s3://${var.BUCKET_NAME}/jar-files/flink-demo-job-1.0.0.jar /usr/lib/flink/algorithms/"
      ]
    }
  }

  step {
    action_on_failure = "TERMINATE_CLUSTER"
    name              = "run-flink-demo-job"
    hadoop_jar_step {
      jar  = "command-runner.jar"
      args = [
        "sudo",
        "flink",
        "run",
        "-m", "yarn-cluster",
        "/usr/lib/flink/algorithms/flink-demo-job-1.0.0.jar",
        "${aws_instance.kafka_instance.private_ip}",
        "${aws_instance.postgres_instance.private_ip}"
      ]
    }
  }
}
