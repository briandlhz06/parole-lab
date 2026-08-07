# Seguridad

## Este lab es inseguro a propósito

parole-lab levanta un contenedor con fallas sembradas para demostrar Hoztage, Hozfix y Parole: MariaDB y Redis abiertos, sshd con root y password, `.env` con permisos flojos, UFW inactivo, sin fail2ban. El password root es `labroot` y está en el README.

No es un descubrimiento. Es el punto.

**No lo corras en una máquina expuesta a internet.** Los puertos se publican al host (13306, 16379, 2222). Levantalo en local, mirá los reportes, bajalo.

## Reportar

Si encontrás algo que escape del contenedor al host, o una falla que no esté documentada en el README, mandá un mail a briandlhz@proton.me con "parole-lab" en el asunto.

Para las tools en sí, reportá en su repo: [hoztage](https://github.com/briandlhz06/hoztage), [hozfix](https://github.com/briandlhz06/hozfix), [parole](https://github.com/briandlhz06/parole).
