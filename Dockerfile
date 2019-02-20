FROM puckel/docker-airflow:1.10.2

MAINTAINER reach4avik@yahoo.com

ENTRYPOINT []

ARG AIRFLOW_HOME=/usr/local/airflow

COPY script/entrypoint.sh /entrypoint.sh

USER airflow
WORKDIR ${AIRFLOW_HOME}
EXPOSE 8080 5555 8793

ENTRYPOINT ["/entrypoint.sh"]

CMD ["webserver"] 
