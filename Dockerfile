FROM ubuntu:22.04
#FROM python:3.11.5-alpine

ARG DEBIAN_FRONTEND=noninteractive 
#  set programm
RUN apt-get update \
&& apt install -y nginx && apt update \
&& apt install -y postgresql \
&& apt-get install -y netcat \
&& apt install -y systemd

# && rm /etc/nginx/nginx.conf
#COPY ./postgresql.conf /etc/postgresql/15/main/  
#COPY ./mysite.conf /etc/nginx/sites-available/ 
COPY ./project.conf /etc/nginx/sites-available/

#RUN ln -s /etc/nginx/sites-available/mysite.conf /etc/nginx/sites-enabled/
RUN ln -s /etc/nginx/sites-available/project.conf /etc/nginx/sites-enabled/

# set python
RUN set -xe \
&& apt-get install -y python3.11 \
&& apt-get update -y \
&& apt-get install -y python3-pip \
&& pip3 install --upgrade pip

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1 
ENV PYTHONUNBUFFERED 1
ENV POSTGRES_DB=django_db 
ENV POSTGRES_USER=django_user
ENV POSTGRES_PASSWORD="1234"
ENV DEBUG=1
ENV SECRET_KEY="django-insecure-(*_%txlyuu*g(leo@@jf5%wi3j73v6i#0fn$^#9@nbfndyg@74"
ENV DJANGO_ALLOWED_HOSTS="example.com localhost 127.0.0.1 [::1]"
ENV DJANGO_SUPERUSER_USERNAME=admin
ENV DJANGO_SUPERUSER_PASSWORD=admin
ENV DJANGO_SUPERUSER_EMAIL=admin@example.com
ENV POSTGRES_ENGINE=django.db.backends.postgresql
ENV POSTGRES_HOST=localhost
ENV POSTGRES_PORT=5432
ENV DATABASE=postgres


# создание каталога для приложения
ENV APP_HOME=/usr/src/app
RUN mkdir -p $APP_HOME/static && mkdir -p $APP_HOME/media
WORKDIR $APP_HOME
VOLUME $APP_HOME

# копирование проекта Django
COPY . .

# install dependencies
RUN pip3 install -r requirements.txt


#gunicorn
COPY ./gunicorn.socket /etc/systemd/system/
COPY ./gunicorn.service /etc/systemd/system/

# создаем отдельного пользователя и изменение прав
#RUN groupadd -r django_app && useradd -r -g django_app dj_app && chown -R dj_app:dj_app $APP_HOME

# изменение рабочего пользователя
#USER app

# setting rights
RUN chmod 774 /usr/src/app/entrypoint.sh && chmod 774 /etc/systemd/system/gunicorn.service 

#EXPOSE 8000

# run entrypoint.sh
ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
#CMD ["/bin/sh","-c","python manage.py runserver 0.0.0.0:8000"]
