-- Ejercicio NewSQL 3: consultas SQL de analisis (SELECT, GROUP BY, JOIN, CTE, ventanas)
USE familias_accion_db;

-- 3.1 Conteo general y verificacion de la carga
SELECT count(*) AS total_registros FROM beneficiarios;

-- 3.2 Distribucion por estado y genero
SELECT estado, genero, count(*) AS total
FROM beneficiarios
GROUP BY estado, genero
ORDER BY estado, total DESC;

-- 3.3 Beneficiarios por tipo de poblacion (JOIN con tabla de referencia) y porcentaje
SELECT t.descripcion,
       count(*) AS total,
       round(100.0 * count(*) / sum(count(*)) OVER (), 2) AS porcentaje
FROM beneficiarios b
JOIN tipos_poblacion t ON t.codigo = b.tipo_poblacion
GROUP BY t.descripcion
ORDER BY total DESC;

-- 3.4 Bancarizacion por rango de edad (CASE + filtro HAVING)
SELECT rango_edad,
       count(*) AS total,
       count(*) FILTER (WHERE bancarizado = 'SI') AS bancarizados,
       round(100.0 * count(*) FILTER (WHERE bancarizado = 'SI') / count(*), 1) AS pct_bancarizados
FROM beneficiarios
GROUP BY rango_edad
HAVING count(*) > 100
ORDER BY rango_edad;

-- 3.5 CTE + funcion de ventana: ranking de rangos de beneficio dentro de cada tipo de poblacion
WITH conteo AS (
    SELECT tipo_poblacion, rango_beneficio_total, count(*) AS total
    FROM beneficiarios
    WHERE estado = 'ACTIVO'
    GROUP BY tipo_poblacion, rango_beneficio_total
)
SELECT tipo_poblacion, rango_beneficio_total, total,
       DENSE_RANK() OVER (PARTITION BY tipo_poblacion ORDER BY total DESC) AS posicion
FROM conteo
ORDER BY tipo_poblacion, posicion;

-- 3.6 Evolucion de inscripciones por anio (funciones de fecha)
SELECT extract(year FROM fecha_inscripcion) AS anio, count(*) AS inscritos
FROM beneficiarios
WHERE fecha_inscripcion IS NOT NULL
GROUP BY anio
ORDER BY anio;

-- 3.7 Consulta sobre la base de subredes de salud (semana 5-6): JOIN, JSONB y agregacion
SELECT s.nombre_sede, s.localidad,
       s.caracteristicas->>'camas_uci' AS camas_uci,
       count(t.tx_id) AS atenciones,
       round(avg(t.costo_estimado), 2) AS costo_promedio
FROM subred_newsql_db.sedes_prestadores s
JOIN subred_newsql_db.transacciones_atencion t ON t.sede_id = s.sede_id
GROUP BY s.nombre_sede, s.localidad, s.caracteristicas
ORDER BY atenciones DESC;
