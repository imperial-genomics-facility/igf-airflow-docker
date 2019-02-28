FROM puckel/docker-airflow:1.10.2

MAINTAINER reach4avik@yahoo.com

ENTRYPOINT []

ARG AIRFLOW_HOME=/usr/local/airflow

USER root

RUN mkdir -p /var/lib/apt/lists/partial \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
    openssl \
    libssl1.1 \
    libssh2-1 \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

COPY script/entrypoint.sh /entrypoint.sh
COPY script/airflow_user_setup.py /airflow_user_setup.py
COPY script/requirements.txt /requirements.txt


RUN chown -R airflow: ${AIRFLOW_HOME}

USER airflow
WORKDIR ${AIRFLOW_HOME}
RUN pip install --user --upgrade pip && \
    pip install --user -r /requirements.txt

EXPOSE 8080 5555 8793

ENTRYPOINT ["bash","/entrypoint.sh"]

CMD ["webserver"] 
