FROM python:3.6.11

RUN pip install mlflow pymysql boto3 google-cloud-storage

WORKDIR  /app

ADD run_server.sh /app/run_server.sh

ENV MYSQL_USER root
ENV MYSQL_PASSWORD ""
ENV MYSQL_HOST mysql
ENV MYSQL_PORT 3306
ENV MYSQL_DATABASE mlflow
ENV S3_BUCKET_NAME mlflow

EXPOSE 5000

CMD /app/run_server.sh