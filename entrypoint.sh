#!/bin/bash
POSTGRES_DB=django_db
POSTGRES_USER=django_user
POSTGRES_PASSWORD="0987poiu"
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
DATABASE=postgres


service postgresql start && sleep 2
su - postgres -c "psql -c 'CREATE DATABASE ${POSTGRES_DB};'" \
&& su - postgres -c "psql -c 'CREATE USER ${POSTGRES_USER} WITH PASSWORD '\''${POSTGRES_PASSWORD}'\'';'" \
&& su - postgres -c "psql -c 'ALTER DATABASE ${POSTGRES_DB} OWNER TO ${POSTGRES_USER};'" \
&& su - postgres -c "psql -c 'ALTER ROLE ${POSTGRES_USER} SET client_encoding TO '\''utf8'\'';'" \
&& su - postgres -c "psql -c 'ALTER ROLE ${POSTGRES_USER} SET default_transaction_isolation TO '\''read committed'\'';'" \
&& su - postgres -c "psql -c 'ALTER ROLE ${POSTGRES_USER} SET timezone TO '\''UTC'\'';'" \
&& su - postgres -c "psql -c 'GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_USER};'"


if [ "$DATABASE" = "postgres" ]
then
    echo "Waiting for postgres..."

    while ! nc -z $POSTGRES_HOST $POSTGRES_PORT; do
      sleep 0.1
    done

    echo "PostgreSQL started"
fi

service nginx start

#python3 manage.py flush --no-input
sleep 1
python3 manage.py migrate

DJANGO_SUPERUSER_USERNAME=admin python3 manage.py createsuperuser \
        --noinput \
        --username admin \
        --email admin@example.com

python3 manage.py collectstatic --no-input --clear
gunicorn project.wsgi:application --bind 0.0.0.0:8000

exec "$@"
