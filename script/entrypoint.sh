#!/usr/bin/env bash

TRY_LOOP="20"

## Set defaults

: "${POSTGRES_HOST:='postgres'}"
: "${POSTGRES_PORT:='5432'}"
: "${POSTGRES_USER:='airflow'}"
: "${POSTGRES_PASSWORD:='airflow'}"
: "${POSTGRES_DB:='airflow'}"
: "${USER_NAME:='airflow'}"
: "${USER_EMAIL:='airflow@email.com'}"
: "${USER_PASS:='password'}"

: "${AIRFLOW__CORE__EXECUTOR:='LocalExecutor'}"
: "${AIRFLOW__CORE__LOAD_EXAMPLES:=True}}"
: "${AIRFLOW__CORE__FERNET_KEY:=${FERNET_KEY:=$(python -c 'from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)')}}"

## Export variables

export \
  AIRFLOW__CELERY__BROKER_URL \
  AIRFLOW__CELERY__RESULT_BACKEND \
  AIRFLOW__CORE__EXECUTOR \
  AIRFLOW__CORE__FERNET_KEY \
  AIRFLOW__CORE__LOAD_EXAMPLES \
  AIRFLOW__CORE__SQL_ALCHEMY_CONN 

## Install additional packages

if [ -e "/requirements.txt" ]; then
    $(which pip) install --user -r /requirements.txt
fi

## Function for checking services

wait_for_port() {
  local name="$1" host="$2" port="$3"
  local j=0
  while ! nc -z "$host" "$port" >/dev/null 2>&1 < /dev/null; do
    j=$((j+1))
    if [ $j -ge $TRY_LOOP ]; then
      echo >&2 "$(date) - $host:$port still not reachable, giving up"
      exit 1
    fi
    echo "$(date) - waiting for $name... $j/$TRY_LOOP"
    sleep 5
  done
}

## Check for Postgres db

if [[ "$AIRFLOW__CORE__EXECUTOR" != "SequentialExecutor" &&  -z "$AIRFLOW__CORE__SQL_ALCHEMY_CONN" ]]; then 
  AIRFLOW__CORE__SQL_ALCHEMY_CONN="postgresql+psycopg2://$POSTGRES_USER:$POSTGRES_PASSWORD@$POSTGRES_HOST:$POSTGRES_PORT/$POSTGRES_DB"
  wait_for_port "Postgres" "$POSTGRES_HOST" "$POSTGRES_PORT"
fi

## Run commands

case "$1" in
  first_run)
  airflow initdb
  sleep 10
  python /airflow_user_setup.py "$USER_NAME"  "$USER_EMAIL" "$USER_PASS"
  sleep 10
  exec airflow webserver
  ;;
  webserver|worker|scheduler|flower|version)
    # To give the webserver time to run initdb.
    sleep 10
    exec airflow "$@"
    ;;
  *)
    # The command is something like bash, not an airflow subcommand. Just run it in the right environment.
    exec "$@"
    ;;
esac
