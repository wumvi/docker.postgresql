[![Build Status](https://travis-ci.org/wumvi/postgresql.svg?branch=master)](https://travis-ci.org/wumvi/postgresql)

##
Postgresql База данных с extension:

pg_cron https://github.com/citusdata/pg_cron

pg_stat_statements

# Сборка

```
docker build -t wumvi/db.prod:v10 -f Dockerfile .
```

## Переменные

```
DOCKER_CONTAINER_NAME=db.dev
DOCKER_DB_NAME=dbname
```

## Сменить пароль для postgres
```
docker exec -ti $DOCKER_CONTAINER_NAME sudo -u postgres psql --command "ALTER USER postgres with password 'pwd';"
```

## Создать нового пользователя

```
docker exec -ti $DOCKER_CONTAINER_NAME sudo -u postgres psql --command "CREATE USER user_name WITH PASSWORD 'pwd';"
```

## Восстанить backup
```
docker exec -ti $DOCKER_CONTAINER_NAME sudo -u postgres psql --command "DROP DATABASE $DOCKER_DB_NAME;"

docker exec -ti $DOCKER_CONTAINER_NAME sudo -u postgres psql --command "CREATE DATABASE $DOCKER_DB_NAME;"

docker exec -ti $DOCKER_CONTAINER_NAME sudo -u postgres psql $DOCKER_DB_NAME --set ON_ERROR_STOP=on -f /tmp/$DOCKER_DB_NAME.sql
```

## Сделать backup

```
docker exec -ti $DOCKER_CONTAINER_NAME sudo -u postgres pg_dump $DOCKER_DB_NAME | gzip > /tmp/$DOCKER_DB_NAME.sql.gz
```

## Unpack gz backup
```
docker exec -ti $DOCKER_CONTAINER_NAME gunzip /tmp/$DOCKER_DB_NAME.sql.gz
```

# SQL запросы для мониторинга

## Размер БД
```sql
SELECT pg_database.datname, pg_database_size(pg_database.datname) as size FROM pg_database
```
