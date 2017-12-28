[![Build Status](https://travis-ci.org/wumvi/postgresql.svg?branch=master)](https://travis-ci.org/wumvi/postgresql)

#### Описание
Postgresql База данных с включёнными extension:

[pg_cron v1.0.2](https://github.com/citusdata/pg_cron)

pg_stat_statements

#### Build
Для ручной сборки запустить:
```
docker build -t wumvi/postgresql:v10 -f Dockerfile .
```

#### Run
Запуск на prod сервере. Предворительно надо создать net и volume
```
DOCKER_NODE_TYPE=prod
```

```
docker network create db.$DOCKER_NODE_TYPE
docker volume create net.$DOCKER_NODE_TYPE 

docker run \
    --restart=always \
    --rm \
    -d \
    -v db.$DOCKER_NODE_TYPE:/data \
    -v /tmp/db/:/tmp/ \
    --name=db.$DOCKER_NODE_TYPE \
    --hostname=db.$DOCKER_NODE_TYPE.master \
    --net=net.$DOCKER_NODE_TYPE \
    wumvi/postgresql:v10
```

Запуск на dev сервере.
```
DOCKER_NODE_TYPE=dev
```

```
docker network create db.$DOCKER_NODE_TYPE
docker volume create net.$DOCKER_NODE_TYPE 

docker run \
    --restart=always \
    --rm \
    -d \
    -p 5432:5432
    -v db.$DOCKER_NODE_TYPE:/data \
    -v /tmp/db/:/tmp/ \
    --name=db.$DOCKER_NODE_TYPE \
    --hostname=db.$DOCKER_NODE_TYPE.master \
    --net=net.$DOCKER_NODE_TYPE \
    wumvi/postgresql:v10
```


#### Порты

Порт 5432 - для подключений к БД 

#### Переменные

```
DOCKER_CONTAINER_NAME=db.$DOCKER_NODE_TYPE
DOCKER_DB_NAME=dbname
```

#### Сменить пароль для postgres
Сменить пароль у postgres на pwd
```
docker exec \
    -ti \
    $DOCKER_CONTAINER_NAME \
    sudo \
    -u postgres \
    psql \
    --command "ALTER USER postgres with password 'pwd';"
```

#### Создать нового пользователя
Создать нового пользователя user_name с паролем pwd в БД

```
docker exec \
    -ti \
    $DOCKER_CONTAINER_NAME \
    sudo \
    -u postgres \
    psql \
    --command "CREATE USER user_name WITH PASSWORD 'pwd';"
```

#### Сделать backup
Сделать backup, сжать его и сохранить его папку tmp
```
docker exec \
    -ti \
    $DOCKER_CONTAINER_NAME \
    sudo \
    -u postgres \
    pg_dump \
    $DOCKER_DB_NAME | gzip > /tmp/$DOCKER_DB_NAME.sql.gz
```

## Unpack gz backup
Распаковать архив
```
docker exec \
    -ti $DOCKER_CONTAINER_NAME \
    gunzip \
    /tmp/$DOCKER_DB_NAME.sql.gz
```

#### Восстанить backup
Восстановить распакованный архив
```
docker exec \
    -ti \
    $DOCKER_CONTAINER_NAME \
    sudo \
    -u postgres \
    psql --command "DROP DATABASE $DOCKER_DB_NAME;"

docker exec \
    -ti \
    $DOCKER_CONTAINER_NAME \
    sudo \
    -u postgres \
    psql --command "CREATE DATABASE $DOCKER_DB_NAME;"

docker exec \
    -ti \
    $DOCKER_CONTAINER_NAME \
    sudo \
    -u postgres \
    psql \
    $DOCKER_DB_NAME \
    --set ON_ERROR_STOP=on \
    -f /tmp/$DOCKER_DB_NAME.sql
```

### SQL запросы для мониторинга

#### Размер БД
```sql
SELECT pg_database.datname, pg_database_size(pg_database.datname) as size FROM pg_database
```


#### Добавить задание в крон
SELECT cron.schedule('* * * * *', $$EXEC some_function()$$);

####
```sql
CREATE EXTENSION pg_stat_statements;
CREATE EXTENSION pg_cron;
```