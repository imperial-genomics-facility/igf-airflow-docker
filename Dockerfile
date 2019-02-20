FROM puckel/docker-airflow:1.10.2

MAINTAINER reach4avik@yahoo.com

ENTRYPOINT []

ARG AIRFLOW_HOME=/usr/local/airflow

COPY script/entrypoint.sh /entrypoint.sh
COPY script/airflow_user_setup.py /airflow_user_setup.py
COPY script/requirements.txt /requirements.txt


USER airflow
WORKDIR ${AIRFLOW_HOME}

RUN chown -R airflow: ${AIRFLOW_HOME}
RUN chmod +x /entrypoint.sh
EXPOSE 8080 5555 8793

ENTRYPOINT ["/entrypoint.sh"]

CMD ["webserver"] 
