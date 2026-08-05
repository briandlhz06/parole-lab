#!/usr/bin/env bash
set -eu

mkdir -p /var/log/redis /var/lib/redis /run/mysqld /opt/parole-lab/out
chown mysql:mysql /run/mysqld /var/lib/mysql || true
chown redis:redis /var/log/redis /var/lib/redis || true

if [[ ! -d /var/lib/mysql/mysql ]]; then
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql >/tmp/mysql-init.log 2>&1 || true
fi

mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 &
for _ in $(seq 1 60); do
  if mysqladmin ping --silent 2>/dev/null; then
    break
  fi
  sleep 0.5
done

redis-server /etc/redis/redis.conf
nginx
/usr/sbin/sshd

echo "parole-lab up (mariadb/redis/nginx/sshd/ufw-inactive)" >&2
exec sleep infinity
