#!/usr/bin/env bash
# Ejecuta los scripts NewSQL dentro del contenedor cockroachdb-standalone y guarda la evidencia.
# 01 recrea la base desde cero, por lo que el script completo es repetible.
# Los scripts 01-03 se ejecutan con --echo-sql (cada resultado va precedido de su sentencia).
# El 04 se ejecuta sin eco: con transacciones el motor imprime el eco de varias sentencias antes de sus resultados.
set -e
export MSYS_NO_PATHCONV=1
C=cockroachdb-standalone
cd "$(dirname "$0")"
for f in 01_esquema 02_carga_beneficiarios 03_consultas 04_transacciones_vistas; do
  docker cp "$f.sql" $C:/tmp/$f.sql
  eco="--echo-sql"; [ "$f" = "04_transacciones_vistas" ] && eco=""
  docker exec $C ./cockroach sql --insecure --format=table $eco -f /tmp/$f.sql > "../../evidencias/newsql_$f.txt" 2>&1 || true
  echo "ejecutado $f"
done
