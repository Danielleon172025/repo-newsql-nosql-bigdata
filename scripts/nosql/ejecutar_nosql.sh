#!/usr/bin/env bash
# Importa los datos y ejecuta los scripts mongosh dentro del contenedor mi-mongodb.
set -e
export MSYS_NO_PATHCONV=1
cd "$(dirname "$0")"
C=mi-mongodb
bash 01_importar.sh > ../../evidencias/nosql_01_importar.txt 2>&1
for f in 02_crud_consultas 03_agregaciones 04_indices_rendimiento; do
  docker cp "$f.js" $C:/tmp/$f.js
  docker exec $C sh -c "mongosh -u \"\$MONGO_INITDB_ROOT_USERNAME\" -p \"\$MONGO_INITDB_ROOT_PASSWORD\" --authenticationDatabase admin --quiet --file /tmp/$f.js" > "../../evidencias/nosql_$f.txt" 2>&1 || true
  echo "ejecutado $f"
done
