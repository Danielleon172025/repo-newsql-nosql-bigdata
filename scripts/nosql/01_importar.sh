#!/usr/bin/env bash
# Importa los datos limpios a MongoDB (contenedor mi-mongodb). Las credenciales se toman de las
# variables de entorno del propio contenedor (MONGO_INITDB_ROOT_*), no se escriben en el repositorio.
set -e
export MSYS_NO_PATHCONV=1
cd "$(dirname "$0")"
C=mi-mongodb
docker cp ../../data/clean/beneficiarios_limpio.csv $C:/tmp/beneficiarios_limpio.csv
docker cp ../../data/raw/sab_tipo_sensores.json $C:/tmp/sab_tipo_sensores.json
# --ignoreBlanks omite los campos vacios (fechas sin dato) en lugar de guardar cadenas vacias
docker exec $C sh -c 'mongoimport -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin   --db familias_accion --collection beneficiarios --type csv --headerline --ignoreBlanks --drop --file /tmp/beneficiarios_limpio.csv'
# El JSON del SAB es un unico objeto {"TipoSensores":[...]}: se importa como un documento
docker exec $C sh -c 'mongoimport -u "$MONGO_INITDB_ROOT_USERNAME" -p "$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin   --db SAB --collection sensores --drop --file /tmp/sab_tipo_sensores.json'
