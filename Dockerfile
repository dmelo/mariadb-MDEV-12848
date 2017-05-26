FROM mariadb:10.2.6

RUN apt-get update -y
RUN apt-get install -y \
        dnsutils \
        file \
        htop \
        procps \
        psmisc \
        redis-tools \
        sudo \
        vim


USER mysql
COPY galera.cnf /etc/mysql/conf.d/galera.cnf
WORKDIR /opt

COPY start.sh ./
COPY 0-create-and-populate.sql /docker-entrypoint-initdb.d/
COPY 1-action.sql ./

EXPOSE 3306 4444 4567 4567/udp 4568

USER root

ENTRYPOINT ["./start.sh"]
