FROM wumvi/php
MAINTAINER Vitaliy Kozlenko <vk@wumvi.com>

ADD lib-utils  /
ADD cmd/start.sh /start.sh

ENV PG_VERSION 10

RUN DEBIAN_FRONTEND=noninteractive && \
	apt-get -qq update && \
	apt-get --no-install-recommends -qq -y install sudo wget apt-transport-https lsb-release ca-certificates gnupg && \
	echo "deb http://repo.postgrespro.ru/pgpro-$PG_VERSION/debian $(lsb_release -cs) main" > /etc/apt/sources.list.d/postgrespro.list && \
	wget --quiet -O - http://repo.postgrespro.ru/pgpro-$PG_VERSION/keys/GPG-KEY-POSTGRESPRO | sudo apt-key add -  && \
	apt-get update && \
	apt-get install --no-install-recommends -qq -y postgrespro-std-$PG_VERSION postgrespro-std-$PG_VERSION-contrib && \
    mv /var/lib/pgpro/std-$PG_VERSION/data/ /data/ && \
    chmod 0700 /data/ && \
    chown postgres:postgres /data/* && \
    sed -i "s/^PGDATA=.*/PGDATA=\/data\//" /etc/init.d/postgrespro-std-10 && \
    sed -i "s/^#listen_addresses = .*/listen_addresses = '*'/" /data/postgresql.conf && \
    echo "host    all    all    0.0.0.0/0    md5" >> /data/pg_hba.conf && \
    chmod a+x /start.sh && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    echo 'end'

EXPOSE 5432

CMD ["/start.sh"]