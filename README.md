# parole-lab

Lab reproducible de la trilogía VPS: [Hoztage](https://github.com/briandlhz06/hoztage) (intake), [Hozfix](https://github.com/briandlhz06/hozfix) (remediación), [Parole](https://github.com/briandlhz06/parole) (drift día N). No es un scanner.

## Requisitos

- Docker Compose
- Bash (Git Bash o WSL en Windows)
- Python >=3.12 adentro del contenedor (viene en la imagen)

## Cómo correr

```bash
git clone https://github.com/briandlhz06/parole-lab.git
cd parole-lab
chmod +x demo.sh entrypoint.sh
./demo.sh
```

O a mano:

```bash
docker compose up -d --build
docker compose exec target pip3 install --break-system-packages \
  "git+https://github.com/briandlhz06/hoztage.git" \
  "git+https://github.com/briandlhz06/hozfix.git" \
  "git+https://github.com/briandlhz06/parole.git"
docker compose exec target python3 -m hoztage --md /opt/parole-lab/out/hoztage.md --json /opt/parole-lab/out/hoztage.json
docker compose exec target python3 -m hozfix --from-json /opt/parole-lab/out/hoztage.json --md /opt/parole-lab/out/hozfix.md
```

Tools locales (opcional):

```bash
export HOZTAGE_SRC=/path/a/hoztage
export HOZFIX_SRC=/path/a/hozfix
export PAROLE_SRC=/path/a/parole
./demo.sh
```

## Fallas del lab

- MariaDB en `0.0.0.0:3306` (`HOZ-NET-004`, `HOZ-DB-002`)
- Redis en `0.0.0.0:6379` sin protected-mode (`HOZ-NET-006`)
- sshd: `PermitRootLogin yes`, `PasswordAuthentication yes` (`HOZ-SSH-001`, `HOZ-SSH-002`)
- `/var/www/html/.env` 644 (`HOZ-WEB-001`)
- UFW instalado e inactive (`HOZ-FW-001`); fail2ban ausente (`HOZ-FW-003`)
- Sin Docker adentro: `HOZ-DOCK-000` skip

## Puertos en el host

Publish explícito (no son "secretos"):

| Host | Contenedor |
| --- | --- |
| 13306 | 3306 MariaDB |
| 16379 | 6379 Redis |
| 2222 | 22 SSH |

Password root del lab: `labroot` (solo el contenedor).

## Demo (salida típica)

```text
$ ./demo.sh
==> Levantando parole-lab...
==> Esperando health...
==> Instalando tools (Python >=3.12)...
    hoztage desde git
    hozfix desde git
    parole desde git
==> Hoztage...
==> Hozfix...
==> Parole: baseline con Redis en 127.0.0.1...
Baseline guardado: /tmp/parole-baseline.json
==> Parole: reabro Redis en 0.0.0.0 (drift)...
1 drifts.
md: /opt/parole-lab/out/parole-drift.md
json: /opt/parole-lab/out/parole-drift.json
parole check: exit 2 (drift, esperado)

Listo. Reportes:
  ./out/hoztage.md
  ./out/hoztage.json
  ./out/hozfix.md
  ./out/parole-drift.md
  ./out/parole-drift.json
```

Samples estáticos: [`examples/sample-hoztage.md`](examples/sample-hoztage.md), [`examples/sample-parole-drift.md`](examples/sample-parole-drift.md).

## Limitaciones

- Corré las tools **adentro** del contenedor (`compose exec`). En el host Windows no hay listeners Linux.
- sshd en Docker funciona acá via `sshd -T` (config efectiva real). No es un VPS completo.
- Sin DinD: findings Docker quedan skip. El publish al host alcanza para ver el patrón; Hoztage/Parole miran listeners con `ss`.
- `demo.sh` reapunta Redis a localhost, hace `parole init`, lo vuelve a abrir y espera exit 2.

## Links

- [Hoztage](https://github.com/briandlhz06/hoztage)
- [Hozfix](https://github.com/briandlhz06/hozfix)
- [Parole](https://github.com/briandlhz06/parole)

MIT · [Brian De La Hoz](https://briandlhz.space) · [@briandlhz06](https://github.com/briandlhz06)
