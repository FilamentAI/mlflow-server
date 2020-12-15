# Filament MLFlow configuration

This repository contains a `Dockerfile` and basic `docker-compose.yml` for running an MLFlow server that is backed by MySQL and Minio storage.

We also provide a basic Caddy HTTP/HTTPS proxy server configuration


# Configuration

The Filament MLFlow configuration requires the following services:

 * MySQL 5.X RDBMS server
 * S3 compatible storage server (AWS S3/GCP Storage/Minio)

Note that other SQL and storage flavours are available - see [mlflow documentation](https://mlflow.org/docs/latest/tracking.html) for more details.


The following environment variables are required:

| Variable Name| Description| Default Value|
| -------------|------------|---------------|
| MYSQL_HOST| hostname of MySQL server| `mysql` as per docker-compose example config|
| MYSQL_PORT| TCP port that MySQL is running on| `3306`| 
| MYSQL_USER| Username to authenticate against MYSQL | `root`|
| MYSQL_PASSWORD| Password to authneticate against MySQL | empty |
| MYSQL_DATABASE| Name of mysql DB to connect to | `mlflow`|
| MLFLOW_S3_ENDPOINT_URL| S3 endpoint to use| `http://minio:9000`|
| AWS_ACCESS_KEY_ID | Access key for auth against S3 server | empty|
| AWS_SECRET_ACCESS_KEY| Access password for auth against S3 server |empty|
| S3_BUCKET_NAME | Name of S3 bucket to store data in| `mlflow`|

**Note: MLFlow requires the bucket to be created - it does not create the S3 bucket if it does not already exist**

# Usage

The server image exposes an unencrypted HTTP service on port 5000 by default.

MLFlow does not provide a built in authentication mechanism - they recommend running the service behind an nginx proxy with basic auth enabled.

MLFlow will automatically try to run applicable database migrations on boot.


# End User Example

Below is a code snippet for how a user might access the system in the wild. 

**Note: the user requires access to both the HTTP service and the S3 service**

```python

import os
os.environ['MLFLOW_TRACKING_URI'] = "http://localhost:5000"
os.environ['MLFLOW_S3_ENDPOINT_URL'] = "http://localhost:9000"
os.environ['AWS_ACCESS_KEY_ID'] = "minioadmin"
os.environ['AWS_SECRET_ACCESS_KEY'] = "minioadmin"

import mlflow

mlflow.set_experiment("Riotous")
with mlflow.start_run(run_name="test-experiment"):
    mlflow.log_param("boop",1)
    mlflow.log_artifact("/home/james/BluejeansHelper.log")
```


# Credentials

Default credentials in production docker-compose setup are:

- Username: filament
- Password: hunting-FAIR-LIFT-thick
