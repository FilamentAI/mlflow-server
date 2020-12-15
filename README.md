# Filament MLFlow configuration

This repository contains a `Dockerfile` and basic docker compose file (`docker-compose-production.yml`) for running an MLFlow server that is backed by MySQL and Minio storage.

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

# Using with Google Cloud Storage

To authenticate with Google Cloud Storage instead of S3 or Minio you have to set the `GOOGLE_APPLICATION_CREDENTIALS` environment variable to point to a 
valid service account  [Credentials file](https://cloud.google.com/docs/authentication/production).

In order to avoid baking a JSON file into our docker image or setting up a volume mount just for a small json file, we provide a new environment variable `GOOGLE_AUTH_STRING` which should contain the base64 encoded value of your credentials file.

If your credentials file is called `service_account.json` then you can create a .env file in the same folder as your docker-compose.yml containing
```
GOOGLE_AUTH_STRING=`base64 -w 0 < service_account.json`
```
Docker compose will automatically try to source this file when it runs and pass the auth string through to the container.

**NB: if GOOGLE_AUTH_STRING is set to a non-empty value the container then will try to use GCS. Otherwise it will default to S3-like storage**


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
- Password: supersecretpassword

If you want to change the username and password then simply override the env vars `AUTH_USER` and `AUTH_PASSWORD` in the `.env` file.

You need to use Caddy to generate a new password hash. This can be achieved by running `docker run --rm -it caddy:2 caddy hash-password` and entering the password of your choice
