## Terraform configs
This directory contains terraform to set up EMR cluster.

## Running terraform locally
At beginning, you need to install terraform and AWS Cli
Next write credentials to AWS with access-token, secret-token and session-token.
To prepare configs first initialize terraform. You need to execute command below inside terraform directory.
```shell
terraform init
```
Next to apply changes using command below:
```shell
terraform apply
```

To destroy infrastructure use:
```shell
terraform destroy
```

## Calling kafka-controller

Request flow: <br>
<strong>1. POST /controller/api/v1/loader/config</strong> <br>
#### Request body:

```json
{
  "bootstrapServer": "string",
  "inputTopic": "string",
  "s3BucketName": "string",
  "fileName": "string",
  "s3Region": "string",
  "serializer": "string",
  "rateLimit": "integer" // time between records flush in ms
}
```
<strong>Each attribute in a request body is optional. If an attribute is not provider, default one is used</strong>

#### Default config:

```json
{
  "bootstrapServer": "localhost:9092",
  "inputTopic": "input",
  "s3BucketName": "stream-graph",
  "fileName": "datasets/dataset-0",
  "s3Region": "us-east-1",
  "serializer": "string",
  "rateLimit": 5
}
```

<strong> 2.  POST /controller/api/v1/loader/start</strong> <br>
Endpoint used to run the loader with previously given config or a default one. 
Should send a 200 and run the loader. If this endpoint is called and
currently the loader is working, it will send a 409 and do nothing.


<strong>3. POST /controller/api/v1/loader/stop <br> </strong>
This endpoint allows the currently working loader to stop. If there is no loader running - it will send 409.