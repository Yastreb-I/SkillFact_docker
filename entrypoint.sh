#!/bin/bash
service postgresql start && sleep 2 \
&& su - postgres -c "psql -c 'CREATE DATABASE ${POSTGRES_DB};'" \
&& su - postgres -c "psql -c 'CREATE USER ${POSTGRES_USER} WITH PASSWORD '\''${POSTGRES_PASSWORD}'\'';'" \
&& su - postgres -c "psql -c 'ALTER DATABASE ${POSTGRES_DB} OWNER TO ${POSTGRES_USER};'" \
&& sleep 1

if [ "$DATABASE" = "postgres" ]
then
    echo "Waiting for postgres..."

    while ! nc -z $POSTGRES_HOST $POSTGRES_PORT; do
      sleep 0.1
    done

    echo "PostgreSQL started"
fi
systemctl start gunicorn.socket
systemctl enable --now gunicorn.socket
#service gunicorn.socket start && sleep 4
#chkconfig gunicorn.socket on

service nginx start
python3 manage.py flush --no-input
python3 manage.py migrate

if [ "$DJANGO_SUPERUSER_USERNAME" ]
then
    python3 manage.py createsuperuser \
        --noinput \
        --username $DJANGO_SUPERUSER_USERNAME \
        --email $DJANGO_SUPERUSER_EMAIL
fi

python3 manage.py collectstatic --no-input --clear
gunicorn project.wsgi:application --bind 0.0.0.0:8000

exec "$@"
