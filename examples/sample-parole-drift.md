# Parole

Host: `vps-lab`
Baseline: 2026-08-05T14:05:00Z
Check: 2026-08-05T14:05:30Z

1 drifts.

### HOZ-DRIFT-NET-6379 - Listener público nuevo en 6379

(no estaba) -> 0.0.0.0:6379 (redis-server)
remediate: HOZ-NET-006

Hozfix: `python -m hozfix --ids HOZ-NET-006`
