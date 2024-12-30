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

echo -e '---- Fetching Sidecar ---- \n'
sudo aws s3 cp s3://$2/sidecar/config.json ./sidecar/config.json
sudo aws s3 cp s3://$2/sidecar/sidecar-service-1.0.0 ./sidecar/sidecar-service-1.0.0

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

cd sidecar
sudo chmod 744 sidecar-service-1.0.0
sudo chmod 744 config.json
sudo ./sidecar-service-1.0.0 "$1:9092" $(ec2-metadata --instance-id | cut -d' ' -f2-) "/emr/instance-controller/lib/bootstrap-actions/1/sidecar/config.json" &
cd ..