FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive 
#  set programm
RUN apt-get update \
&& apt install -y nginx && apt update \
&& apt install -y postgresql-14 \
&& apt install -y netcat \
&& apt install -y systemd


COPY ./project.conf /etc/nginx/conf.d/
#COPY ./pg_ident.conf /etc/postgresql/14/main/

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1 
ENV PYTHONUNBUFFERED 1

# создание каталога для приложения
ENV APP_HOME=/usr/src/app
WORKDIR $APP_HOME

RUN mkdir -v $APP_HOME/static && mkdir -v -m 777 /usr/src/app/media

COPY ./requirements.txt $APP_HOME

# set python
RUN set -xe \
&& apt install -y python3.11 \
&& apt update -y \
&& apt install -y python3-pip \
&& pip3 install --upgrade pip \
&& pip3 install -r requirements.txt

# копирование проекта Django
COPY . .

# создаем отдельного пользователя и изменение прав
#RUN groupadd -r django_app && useradd -r -g django_app dj_app \
#&& chown -R django_app:django_app $APP_HOME \
#&& chmod go-rwx $APP_HOME \
#&& chmod go+x $APP_HOME \
#&& chgrp -R django_app $APP_HOME \  
#&& chmod -R go-rwx $APP_HOME \ 
#&& chmod -R go+rwx $APP_HOME 

# изменение рабочего пользователя
#USER app

# setting rights
RUN chmod 774 /usr/src/app/entrypoint.sh \
&& rm /etc/nginx/sites-enabled/default

EXPOSE 8000:8081

VOLUME $APP_HOME /var/lib/postgresql /var/run/postgresql

# run entrypoint.sh
ENTRYPOINT ["/usr/src/app/entrypoint.sh"]
