#!/usr/bin/env bash
# Lab de la trilogía: Hoztage -> Hozfix -> Parole.
# Windows: Git Bash o WSL. Requiere Docker Compose.
set -eu
cd "$(dirname "$0")"

OUT_HOST="$(pwd)/out"
OUT_CT="/opt/parole-lab/out"
STATE="/tmp/parole-baseline.json"
COMPOSE=(docker compose)

echo "==> Levantando parole-lab..."
"${COMPOSE[@]}" up -d --build

echo "==> Esperando health..."
i=0
while [ "$i" -lt 60 ]; do
  st=$("${COMPOSE[@]}" ps --format '{{.Health}}' 2>/dev/null | head -n1 || true)
  if [ "$st" = "healthy" ]; then
    break
  fi
  if "${COMPOSE[@]}" exec -T target sh -c "ss -lnt | grep -q ':3306' && ss -lnt | grep -q ':6379'" 2>/dev/null; then
    break
  fi
  i=$((i + 1))
  sleep 2
done

exec_lab() {
  "${COMPOSE[@]}" exec -T target "$@"
}

install_one() {
  local name="$1" url="$2" src_env="$3"
  local src
  src="$(printenv "$src_env" 2>/dev/null || true)"
  if [ -n "$src" ] && [ -d "$src" ]; then
    echo "    $name desde local: $src"
    cid=$("${COMPOSE[@]}" ps -q target)
    docker exec "$cid" mkdir -p "/opt/src/$name"
    docker cp "$src/." "$cid:/opt/src/$name/"
    exec_lab pip3 install --break-system-packages -e "/opt/src/$name" -q \
      || exec_lab pip3 install -e "/opt/src/$name" -q
  else
    echo "    $name desde git"
    exec_lab pip3 install --break-system-packages "$url" -q \
      || exec_lab pip3 install "$url" -q
  fi
}

echo "==> Instalando tools (Python >=3.12)..."
install_one hoztage "git+https://github.com/briandlhz06/hoztage.git" HOZTAGE_SRC
install_one hozfix "git+https://github.com/briandlhz06/hozfix.git" HOZFIX_SRC
install_one parole "git+https://github.com/briandlhz06/parole.git" PAROLE_SRC

mkdir -p "$OUT_HOST"

echo "==> Hoztage..."
exec_lab python3 -m hoztage -q \
  --md "$OUT_CT/hoztage.md" \
  --json "$OUT_CT/hoztage.json" \
  --fail-on critical || true

echo "==> Hozfix..."
exec_lab python3 -m hozfix -q \
  --from-json "$OUT_CT/hoztage.json" \
  --md "$OUT_CT/hozfix.md"

redis_bind() {
  local addr="$1"
  exec_lab sh -c "
    printf 'bind ${addr}\\nprotected-mode no\\nport 6379\\ndaemonize yes\\nlogfile /var/log/redis/redis-server.log\\ndir /var/lib/redis\\n' > /etc/redis/redis.conf
    redis-cli shutdown nosave 2>/dev/null || true
    sleep 1
    redis-server /etc/redis/redis.conf
    for _ in \$(seq 1 30); do
      if ss -lnt | grep -q ':6379'; then break; fi
      sleep 0.3
    done
  "
}

echo "==> Parole: baseline con Redis en 127.0.0.1..."
redis_bind "127.0.0.1"
exec_lab python3 -m parole init --force --state "$STATE"

echo "==> Parole: reabro Redis en 0.0.0.0 (drift)..."
redis_bind "0.0.0.0"

set +e
exec_lab python3 -m parole check \
  --state "$STATE" \
  --md "$OUT_CT/parole-drift.md" \
  --json "$OUT_CT/parole-drift.json"
rc=$?
set -e

if [ "$rc" -eq 2 ]; then
  echo "parole check: exit 2 (drift, esperado)"
elif [ "$rc" -eq 0 ]; then
  echo "AVISO: parole check salió 0; esperaba drift (exit 2)." >&2
else
  echo "AVISO: parole check exit $rc" >&2
fi

echo ""
echo "Listo. Reportes:"
echo "  $OUT_HOST/hoztage.md"
echo "  $OUT_HOST/hoztage.json"
echo "  $OUT_HOST/hozfix.md"
echo "  $OUT_HOST/parole-drift.md"
echo "  $OUT_HOST/parole-drift.json"
echo ""
echo "Host publish (lab): 13306->3306, 16379->6379, 2222->22"
echo "Bajar: docker compose down"
