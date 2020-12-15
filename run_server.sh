#!/bin/bash


echo "Google auth: ${GOOGLE_AUTH_STRING}"
if [[ -z "${GOOGLE_AUTH_STRING}" ]]; then
    echo "Use AWS"
    export STORAGE_URI="s3://${S3_BUCKET_NAME}"
else
    echo "Use Google"
    echo $GOOGLE_AUTH_STRING | base64 -d > service_account.json
    export GOOGLE_APPLICATION_CREDENTIALS='service_account.json'
    export STORAGE_URI="gs://${S3_BUCKET_NAME}"

fi


mlflow server \
 --backend-store-uri mysql+pymysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE} \
 --default-artifact-root $STORAGE_URI \
 --host 0.0.0.0