#!/bin/bash

# Activating job control
set -m

MYSQL_OPT="--wsrep-new-cluster"

# Save on local config file
# HOSTIP=$(dig $HOSTNAME A +short)

# while [ -z "$HOSTIP" ]
# do
#     sleep 1
#     HOSTIP=$(dig $HOSTNAME A +short)
# done

# sed -i "s/^wsrep_cluster_address=.*/wsrep_cluster_address=gcomm:\/\/$GCOMM/g" /etc/mysql/conf.d/galera.cnf
# sed -i "s/^wsrep_node_address=.*/wsrep_node_address=$HOSTIP:4567/g" /etc/mysql/conf.d/galera.cnf
# cat /etc/mysql/conf.d/galera.cnf

echo "Installing base db"
sudo -u mysql mysql_install_db

echo "Starting mysqld"
sudo -u mysql mysqld $MYSQL_OPT &
pid="$!"
mysql="mysql -u root"

for i in {30..0}
do
    if echo "SELECT 1" | ${mysql[@]} &> /dev/null
    then
        break;
    fi
    echo "MySQL init process in progress..."
    sleep 1
done

if [ "$i" = 0 ]
then
    echo >&2 "MySQL init process failed."
    exit 1
fi

for f in /docker-entrypoint-initdb.d/*; do
    case "$f" in
        *.sh)
            echo "$0: running $f"
            . "$f"
            ;;
        *.sql)
            echo "$0: running $f"
            sudo -u mysql /usr/bin/mysql -u root < "$f"
            echo
            ;;
        *.sql.gz)
            echo "$0: running $f"
            gunzip -c "$f" | "${mysql[@]}"
            echo
            ;;
        *)
            echo "$0: ignoring $f"
            ;;
    esac
    echo
done

date
while [ 1 ]
do
    sleep 300
    date
    echo "running 1-action.sql"
    echo "source 1-action.sql;" | mysql -u root test
done
