# Hoztage - vps-lab

- Generado: `2026-08-05T14:00:00Z`
- Plataforma: `Linux-6.8.0-generic-x86_64-with-glibc2.39`
- Resumen: **2 critical**, **5 high**, **2 medium**, 8 info, 3 skip

## Resumen

| Severidad | Cantidad |
| --- | ---: |
| critical | 2 |
| high | 5 |
| medium | 2 |
| info | 8 |
| skip | 3 |

## host

### [INFO] HOZ-HOST-001 - Identidad del host

vps-lab, kernel 6.8.0-generic, up 0 days

```text
NAME="Ubuntu"
VERSION="24.04 LTS"
ID=ubuntu
VERSION_ID="24.04"
```

## net

### [INFO] HOZ-NET-100 - Puertos en escucha

6 listeners (ss)

```text
Netid State  Recv-Q Send-Q Local Address:Port  Peer Address:Port
tcp   LISTEN 0      128    0.0.0.0:22         0.0.0.0:*    users:(("sshd",pid=42,fd=3))
tcp   LISTEN 0      511    0.0.0.0:80         0.0.0.0:*    users:(("nginx",pid=50,fd=8))
tcp   LISTEN 0      80     0.0.0.0:3306       0.0.0.0:*    users:(("mysqld",pid=30,fd=21))
tcp   LISTEN 0      511    0.0.0.0:6379       0.0.0.0:*    users:(("redis-server",pid=38,fd=6))
```

### [HIGH] HOZ-NET-004 - MariaDB/MySQL expuesto públicamente

MariaDB/MySQL escucha en 0.0.0.0:3306 (mysqld).

```text
tcp   LISTEN 0      80     0.0.0.0:3306       0.0.0.0:*    users:(("mysqld",pid=30,fd=21))
```

No publiques 3306 a Internet; bind a localhost o filtrá el puerto.

### [CRITICAL] HOZ-NET-006 - Redis expuesto públicamente

Redis escucha en 0.0.0.0:6379 (redis-server).

```text
tcp   LISTEN 0      511    0.0.0.0:6379       0.0.0.0:*    users:(("redis-server",pid=38,fd=6))
```

Redis público casi siempre es urgente: bind localhost + auth o cerralo.

## ssh

### [CRITICAL] HOZ-SSH-001 - Root por SSH con password posible

PermitRootLogin yes.

```text
permitrootlogin yes
```

Poné PermitRootLogin no y entrá con un usuario con sudo.

### [HIGH] HOZ-SSH-002 - Login SSH con password

PasswordAuthentication yes.

Cuando tengas keys cargadas, deshabilitá PasswordAuthentication.

### [INFO] HOZ-SSH-005 - Puerto SSH

Port 22.

## firewall

### [HIGH] HOZ-FW-001 - UFW inactivo

UFW está instalado pero inactive.

```text
Status: inactive
```

Activá UFW o asegurate de tener iptables/nft con política clara.

### [MEDIUM] HOZ-FW-003 - fail2ban ausente

No encontré fail2ban.

Instalalo, aunque sea jail sshd.

## docker

### [SKIP] HOZ-DOCK-000 - Docker

No hay docker.

## db

### [INFO] HOZ-DB-001 - MySQL/MariaDB corriendo

Hay proceso mysqld/mariadbd.

### [HIGH] HOZ-DB-002 - MySQL bind público en config

bind-address = 0.0.0.0

```text
/etc/mysql/mariadb.conf.d/60-parole-lab.cnf
```

Poné bind-address = 127.0.0.1 si no necesita red externa.

### [INFO] HOZ-DB-004 - Redis corriendo

Hay redis-server. Si además escucha público, mirá net.

## web

### [CRITICAL] HOZ-WEB-001 - .env legible en docroot

/var/www/html/.env es legible por otros (0o644).

```text
/var/www/html/.env 0o644
```

Sacá el .env del docroot o permisos 600 y fuera de la web.
