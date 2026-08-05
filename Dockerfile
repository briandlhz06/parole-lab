FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    iproute2 \
    mariadb-server \
    nginx \
    openssh-server \
    procps \
    python3 \
    python3-pip \
    python3-venv \
    redis-server \
    sudo \
    ufw \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/run/sshd /run/mysqld /var/www/html /etc/ssh/sshd_config.d \
    /etc/mysql/mariadb.conf.d /etc/redis /opt/parole-lab/out \
    && chown mysql:mysql /run/mysqld \
    && ssh-keygen -A

RUN printf 'PermitRootLogin yes\nPasswordAuthentication yes\n' \
      > /etc/ssh/sshd_config.d/99-parole-lab.conf \
    && printf '[mysqld]\nbind-address = 0.0.0.0\nskip-networking=0\n' \
      > /etc/mysql/mariadb.conf.d/60-parole-lab.cnf \
    && printf 'bind 0.0.0.0\nprotected-mode no\nport 6379\ndaemonize yes\nlogfile /var/log/redis/redis-server.log\ndir /var/lib/redis\n' \
      > /etc/redis/redis.conf \
    && printf 'SECRET=lab-only\nDB_PASSWORD=no-usar-en-prod\n' > /var/www/html/.env \
    && chmod 644 /var/www/html/.env \
    && printf '<html><body>parole-lab</body></html>\n' > /var/www/html/index.html \
    && echo 'root:labroot' | chpasswd

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /opt/parole-lab
EXPOSE 22 3306 6379 80

ENTRYPOINT ["/entrypoint.sh"]
