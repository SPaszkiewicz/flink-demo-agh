#!/bin/bash
echo -e '---- Args ---- \n'
for i; do
   echo $i
done

echo -e '---- Install extras ---- \n'
sudo amazon-linux-extras install epel -y
sudo amazon-linux-extras install collectd -y

echo -e '---- Installing CloudWatch Agent ---- \n'
sudo rpm -Uvh --force https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm

echo -e '---- Installing BCC ---- \n'
sudo yum install python -y
sudo yum install bcc -y
sudo yum install kernel-devel-$(uname -r) -y
sudo yum update -y
export PATH=$PATH:/usr/share/bcc/tools/

cat > cloudwatch-config.json << EOL
{
    "agent": {
        "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log",
        "debug": false,
        "region": "us-east-1",
        "run_as_user": "cwagent"
    },
    "metrics": {
        "namespace": "FlinkSystem",
        "metrics_collected": {
            "statsd": {
                "service_address": ":8125",
                "metrics_collection_interval": 10,
                "metrics_aggregation_interval": 50
            }
        },
        "aggregation_dimensions": [["InstanceId"],[]]
    }
}
EOL

echo -e '---- List ---- \n'
sudo ls

echo -e '---- Check content ---- \n'
sudo cat cloudwatch-config.json

echo -e '---- Starting CloudWatch Agent ---- \n'
sudo amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:cloudwatch-config.json -s

echo -e '---- Status of CloudWatch Agent ---- \n'
sudo amazon-cloudwatch-agent-ctl -a status