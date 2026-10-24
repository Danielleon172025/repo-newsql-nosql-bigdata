# Manejo de bases de datos NewSQL y NoSQL en entornos Big Data

Informe de práctica — Especialización en Analítica de Datos, Universidad de Cundinamarca (semanas 10, 11 y 12).
Autor: Daniel Felipe León Higuera.

Ejercicios resueltos sobre un mismo conjunto de datos abiertos (Familias en Acción, Puerto Boyacá, 5.543 registros)
en **CockroachDB** (NewSQL, con Visual Studio Code y la extensión PostgreSQL como cliente SQL) y **MongoDB** (NoSQL, con Compass y mongosh).

## Requisitos
- Docker con los contenedores `cockroachdb-standalone` (CockroachDB v23.2, puerto 26257) y `mi-mongodb` (MongoDB 8, puerto 27017).
- Python 3 (solo biblioteca estándar) y Git Bash o equivalente.
- Visual Studio Code con la extensión PostgreSQL y MongoDB Compass.

## Reproducción
```bash
python scripts/python/01_recoleccion_limpieza.py   # perfila y limpia; genera CSV y SQL de carga
bash scripts/newsql/ejecutar_newsql.sh             # esquema, carga, consultas y transacciones -> evidencias/newsql_*.txt
bash scripts/nosql/ejecutar_nosql.sh               # importación, CRUD, agregaciones e índices -> evidencias/nosql_*.txt
```
Las credenciales de MongoDB no se guardan en el repositorio: los scripts las toman de las variables de entorno del contenedor.

## Contenido
| Carpeta | Descripción |
|---|---|
| `data/raw` | Datos originales (CSV de datos.gov.co y JSON del SAB de IDIGER) |
| `data/clean` | CSV limpio generado por el script de Python |
| `scripts/python` | Recolección y limpieza |
| `scripts/newsql` | Esquema, carga, consultas, transacciones y verificación SQL |
| `scripts/nosql` | Importación, CRUD, agregaciones e índices (mongosh) |
| `evidencias` | Salidas de cada script y capturas (`img/`) |
| `docs` | Informe en PDF |

## Fuentes de datos
- Familias focalizadas, Familias en Acción etapa IV, Puerto Boyacá — datos.gov.co.
- SAB – Sistema de Alerta de Bogotá (Lluvia Minutal) — IDIGER, Datos Abiertos Bogotá.
